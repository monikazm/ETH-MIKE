# Extract trial data from tdms
from typing import List, Any

import pandas as pd
from nptdms import TdmsFile

from mike_analysis.core.meta import tdms_cols, col_names, Modes, TrialCol, RStateCol, TimeCol, ForceCol, PosCol, SPosCol, TPosCol, TSCol
from mike_analysis.evaluators import *


def process_tdms(filename: str, left_hand: bool, task_type: int, trial_results_from_db: List[Dict[str, Any]]) -> Dict:
    tdms_data = TdmsFile.read(filename).groups()[0].as_dataframe()[tdms_cols]
    tdms_data = tdms_data.rename(columns={tdms_c: c for (tdms_c, c) in zip(tdms_cols, col_names)})
    tdms_trials = preprocess_and_split_trials(tdms_data, left_hand)
    evaluator = metric_evaluator_for_mode[Modes(task_type)]
    for computer in evaluator.get_required_column_computers():
        for trial_data in tdms_trials:
            computer.add_column_to(trial_data)
    return evaluator.compute_assessment_metrics(tdms_trials, trial_results_from_db)


def preprocess_and_split_trials(data: pd.DataFrame, left_hand: bool) -> List[pd.DataFrame]:
    # Remove rows where target state is not true or TrialNr is 0 (happens sometimes at the end)
    data = data[data[TSCol] == 1]
    data = data[data[TrialCol] != 0]

    # Negate vectors if right hand (so that flexion direction is always positive)
    if not left_hand:
        data[PosCol] = -data[PosCol]
        data[SPosCol] = -data[SPosCol]
        data[TPosCol] = -data[TPosCol]
        data[ForceCol] = -data[ForceCol]

    # Get data frames for individual trials with normalized time
    trials = data[TrialCol].unique()
    rom_states = data[RStateCol].unique()
    return [_preprocess_trial_data(data, i, r) for i in trials for r in rom_states]


def _preprocess_trial_data(data: pd.DataFrame, i: int, r: int) -> pd.DataFrame:
    trial_data = data.loc[(data[TrialCol] == i) & (data[RStateCol] == r), (TimeCol, ForceCol, PosCol, SPosCol, TPosCol)].copy()
    start_time = trial_data[TimeCol].iloc[0]
    trial_data[TimeCol] -= start_time
    trial_data = trial_data.drop_duplicates(subset=[TimeCol])
    return trial_data
