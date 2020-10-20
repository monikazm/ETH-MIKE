# Extract trial data from tdms
import os
import shutil
from typing import Any
from zipfile import ZipFile

import pandas as pd
from nptdms import TdmsFile
from scipy.signal import filtfilt

from mike_analysis.core.constants import tdms_cols, col_names, Modes, TrialCol, RStateCol, TimeCol, ForceCol, PosCol, SPosCol, TPosCol, \
    TSCol, colored_print, TColor
from mike_analysis.core.precomputer import Precomputer, ColumnPrecomputer
from mike_analysis.evaluators import *

EXPECTED_DATA_RATE = 1000.0


def search_and_extract_tdms_from_zips(zip_dir, session_id, rel_path, output_path) -> bool:
    if os.path.exists(zip_dir):
        os.makedirs(os.path.dirname(output_path), exist_ok=True)
        files = [os.path.join(zip_dir, file) for file in os.listdir(zip_dir) if file.startswith(f'sid_{session_id}_')]
        rel_path = rel_path.replace('\\', '/')
        for file in sorted(files, reverse=True):
            try:
                with ZipFile(file, 'r') as f:
                    if rel_path in f.namelist():
                        with f.open(rel_path) as i, open(output_path, 'wb') as o:
                            shutil.copyfileobj(i, o)
                        try:
                            with f.open(f'{rel_path}_index') as i, open(f'{output_path}_index', 'wb') as o:
                                shutil.copyfileobj(i, o)
                        except FileNotFoundError as e:
                            print(f'WARN: tdms_index file missing from archive\n{e}')
                        return True
            except Exception as e:
                print(f'Error while reading zip file {file}\n{e}')
    return False


def process_tdms(filename: str, left_hand: bool, task_type: int, trial_results_from_db: List[Dict[str, Any]]) -> Dict:
    mode = Modes(task_type)
    evaluator = metric_evaluator_for_mode[mode]
    column_precomputers, value_precomputers = required_precomputations_for_mode[mode]

    # Read and preprocess tdms file
    tdms_data = _read_tdms_file(filename)

    # Compute sampling rate
    fs = estimate_sampling_rate(tdms_data)

    # Check if data rate matches expectation
    if abs(EXPECTED_DATA_RATE - fs) > 1.0:
        with colored_print(TColor.WARNING):
            print(f'WARNING: Data rate of {filename} differs significantly from {EXPECTED_DATA_RATE} (was {fs})')

    # Preprocess data (flip sign for right hand, precompute columns, filter position, remove TS=0 rows, split by trial, ...)
    tdms_trials = preprocess_and_split_trials(tdms_data, left_hand, column_precomputers, fs)

    # Precompute ValuePrecomputers and build precompute dicts for each trial
    all_precomputed = [{} for _ in tdms_trials]
    if value_precomputers or column_precomputers:
        for trial_data_frame, precomputed_for_trial in zip(tdms_trials, all_precomputed):
            for column_precomputer in column_precomputers:
                # For column precomputers, store the pandas series with the section/rows of the
                # precomputed column corresponding to the trial in the corresponding precompute dict
                precomputed_for_trial[column_precomputer] = trial_data_frame[column_precomputer.col_name]
            for value_precomputer in value_precomputers:
                precomputed_for_trial[value_precomputer] = value_precomputer.precompute_value(trial_data_frame, precomputed_for_trial)

    # Compute metrics
    computed_metrics = evaluator.compute_assessment_metrics(tdms_trials, all_precomputed, trial_results_from_db)
    return computed_metrics


def _read_tdms_file(filename: str):
    tdms_data = TdmsFile.read(filename).groups()[0].as_dataframe()[tdms_cols]
    tdms_data = tdms_data.rename(columns={tdms_c: c for (tdms_c, c) in zip(tdms_cols, col_names)})
    return tdms_data


def estimate_sampling_rate(data: pd.DataFrame) -> float:
    fs = round(1.0 / data[TimeCol].diff().median(), 8)
    return fs


def preprocess_and_split_trials(data: pd.DataFrame, left_hand: bool, column_computers: List[ColumnPrecomputer],
                                fs: float, filter_position=True) -> List[pd.DataFrame]:
    # Drop duplicate rows to avoid nans in derivatives
    data.drop_duplicates(subset=[TimeCol], inplace=True)

    # Negate vectors if right hand (so that flexion direction is always positive)
    if not left_hand:
        data[PosCol] = -data[PosCol]
        data[SPosCol] = -data[SPosCol]
        data[TPosCol] = -data[TPosCol]
        data[ForceCol] = -data[ForceCol]

    # Filter position signal
    b, a = Precomputer.get_filter(fs, fc=20.0, deg=2)
    pos_flt = filtfilt(b, a, data[PosCol]) if filter_position else data[PosCol]
    data[PosCol] = pos_flt.clip(-90.0, 90.0) # Restrict position to [-90.0, 90.0] range
    #data[PosCol] = pos_flt

    # import matplotlib.pyplot as plt
    # plt.plot(data[TimeCol], data[PosCol], label='unfiltered')
    # plt.plot(data[TimeCol], pos_flt, label='filtered20')
    # plt.title('pos')
    # plt.legend()
    # plt.show()

    # Precompute other columns
    precomputed_columns = {}
    for cc in column_computers:
        precomputed_columns[cc] = cc.precompute_df_column(data, precomputed_columns, fs)

    # Remove rows where target state is not true or TrialNr is 0 (happens sometimes at the end)
    data = data[data[TSCol] == 1]
    data = data[data[TrialCol] != 0]

    # Get data frames for individual trials with normalized time
    trials = data[TrialCol].unique()
    rom_states = data[RStateCol].unique()

    # Split into trials and offset time so that its always starting at 0
    computed_col_names = [c.col_name for c in column_computers]
    return [_preprocess_trial_data(data, i, r, computed_col_names) for r in rom_states for i in trials]


def _preprocess_trial_data(data: pd.DataFrame, i: int, r: int, computed_col_names) -> pd.DataFrame:
    trial_data = data.loc[(data[TrialCol] == i) & (data[RStateCol] == r), [TimeCol, ForceCol, PosCol, SPosCol, TPosCol] + computed_col_names].copy()
    start_time = trial_data[TimeCol].iloc[0]
    trial_data[TimeCol] -= start_time
    return trial_data
