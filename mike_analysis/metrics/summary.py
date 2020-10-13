from dataclasses import dataclass
from math import sqrt
from typing import List

import pandas as pd

from mike_analysis.core.constants import SPosCol, PosCol, TPosCol
from mike_analysis.core.metric import RowType, Scalar, SummaryMetric, DTypes
from mike_analysis.core.precomputer import PrecomputeDict


@dataclass
class NumTrials(SummaryMetric):
    name = 'NumTrials'
    d_type = DTypes.INT
    bigger_is_better = True
    unit = ''

    def compute_across_trials(self, all_trials: List[pd.DataFrame], all_precomputed: List[PrecomputeDict], db_trial_results: List[RowType]) -> Scalar:
        return len(all_trials)


@dataclass
class DeltaRMSE(SummaryMetric):
    name = 'RMSE'
    d_type = DTypes.DOUBLE
    bigger_is_better = False
    unit = 'deg'

    target_col: str
    actual_col: str

    def compute_across_trials(self, all_trials: List[pd.DataFrame], all_precomputed: List[PrecomputeDict], db_trial_results: List[RowType]) -> Scalar:
        squared_sum = 0.0
        for db_trial_result in db_trial_results:
            delta = db_trial_result[self.target_col] - db_trial_result[self.actual_col]
            squared_sum += delta * delta
        return sqrt(squared_sum / len(db_trial_results))


@dataclass
class NrOfTrialsWithoutReachingTarget(SummaryMetric):
    name = 'TrialsWhereTargetNotReachedPerc'
    d_type = DTypes.DOUBLE
    bigger_is_better = False
    unit = ''

    def compute_across_trials(self, all_trials: List[pd.DataFrame], all_precomputed: List[PrecomputeDict], db_trial_results: List[RowType]) -> Scalar:
        total_trial_count = len(all_trials)
        count_where_target_not_reached = 0
        for trial in all_trials:
            no_position_past_target = ((trial[SPosCol] < trial[TPosCol]) == (trial[PosCol] < trial[TPosCol])).all()
            no_position_close_to_target = ((trial[TPosCol] - trial[PosCol]).abs() > 3.0).all()
            if no_position_past_target and no_position_close_to_target:
                count_where_target_not_reached += 1
        return float(count_where_target_not_reached) / float(total_trial_count)
