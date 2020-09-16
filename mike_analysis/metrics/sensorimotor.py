from dataclasses import dataclass
from math import sqrt

import pandas as pd

from mike_analysis.core.meta import PosCol, TPosCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar


@dataclass
class RMSError(TrialMetric):
    name = 'RMSE'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        pos_delta = trial_data[TPosCol] - trial_data[PosCol]
        return sqrt((pos_delta * pos_delta).mean())


class MeanAbsShift(TrialMetric):
    name = 'MeanAbsShift'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        pass


class MeanAbsPeakdiff(TrialMetric):
    name = 'MeanAbsPeakdiff'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        pass


class StdPeakAmplitude(TrialMetric):
    name = 'StdPeakAmplitude'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        pass
