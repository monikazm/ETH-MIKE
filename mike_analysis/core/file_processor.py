# Extract trial data from tdms
from typing import List, Any

import pandas as pd
from nptdms import TdmsFile
from scipy.signal import filtfilt

from mike_analysis.core.constants import tdms_cols, col_names, Modes, TrialCol, RStateCol, TimeCol, ForceCol, PosCol, SPosCol, TPosCol, TSCol
from mike_analysis.core.precomputer import Precomputer, ColumnPrecomputer
from mike_analysis.evaluators import *
from mike_analysis.precomputers.base_values import SamplingRate


def process_tdms(filename: str, left_hand: bool, task_type: int, trial_results_from_db: List[Dict[str, Any]]) -> Dict:
    evaluator = metric_evaluator_for_mode[Modes(task_type)]
    precomputed_dependencies = evaluator.get_precompute_dependencies()
    col_deps, normal_deps = [], []
    for dep in precomputed_dependencies:
        if isinstance(dep, ColumnPrecomputer):
            col_deps.append(dep)
        else:
            normal_deps.append(dep)

    tdms_data = _read_tdms_file(filename)
    tdms_trials = preprocess_and_split_trials(tdms_data, left_hand, col_deps)
    precomputed_vals = [{} for _ in tdms_trials]
    if normal_deps or col_deps:
        for trial_data, precomputed_vals_for_trial in zip(tdms_trials, precomputed_vals):
            for dependency in col_deps:
                precomputed_vals_for_trial[dependency] = trial_data[dependency.col_name]
            for dependency in normal_deps:
                dependency.precompute_for(trial_data, precomputed_vals_for_trial)
    return evaluator.compute_assessment_metrics(tdms_trials, precomputed_vals, trial_results_from_db)


def _read_tdms_file(filename: str):
    tdms_data = TdmsFile.read(filename).groups()[0].as_dataframe()[tdms_cols]
    tdms_data = tdms_data.rename(columns={tdms_c: c for (tdms_c, c) in zip(tdms_cols, col_names)})
    return tdms_data


def preprocess_and_split_trials(data: pd.DataFrame, left_hand: bool, column_computers, filter_position=True) -> List[pd.DataFrame]:
    # Drop duplicate rows to avoid nans in derivatives
    data.drop_duplicates(subset=[TimeCol], inplace=True)

    # Compute sampling rate
    precomputed_cols = {}
    SamplingRate.precompute_for(data, precomputed_cols)

    # Negate vectors if right hand (so that flexion direction is always positive)
    if not left_hand:
        data[PosCol] = -data[PosCol]
        data[SPosCol] = -data[SPosCol]
        data[TPosCol] = -data[TPosCol]
        data[ForceCol] = -data[ForceCol]

    # Filter position signal
    b, a = Precomputer.get_filter(precomputed_cols[SamplingRate], fc=20.0, deg=2)
    pos_flt = filtfilt(b, a, data[PosCol]) if filter_position else data[PosCol]
    data[PosCol] = pos_flt.clip(-90.0, 90.0)
    #data[PosCol] = pos_flt

    # import matplotlib.pyplot as plt
    # plt.plot(data[TimeCol], data[PosCol], label='unfiltered')
    # plt.plot(data[TimeCol], pos_flt, label='filtered20')
    # plt.title('pos')
    # plt.legend()
    # plt.show()

    # Precompute other columns
    for cc in column_computers:
        cc.precompute_for(data, precomputed_cols)

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
