from dataclasses import dataclass
from math import sqrt

import pandas as pd

from mike_analysis.core.meta import *
from mike_analysis.core.metric import TrialMetric, RowType, Scalar


@dataclass
class PositionError(TrialMetric):
    name = 'PositionError'
    target_col: str
    actual_col: str

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return db_trial_result[self.target_col] - db_trial_result[self.actual_col]


@dataclass
class AbsPositionError(PositionError):
    name = 'AbsPositionError'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return abs(super().compute_single_trial(trial_data, db_trial_result))


@dataclass
class RMSError(TrialMetric):
    name = 'RMSE'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        pos_delta = trial_data[TPosCol] - trial_data[PosCol]
        return sqrt((pos_delta * pos_delta).mean())


@dataclass
class MinRom(TrialMetric):
    name = 'MinROM'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[PosCol].min()


@dataclass
class MaxRom(TrialMetric):
    name = 'MaxROM'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[PosCol].max()


@dataclass
class Rom(TrialMetric):
    name = 'ROM'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return abs(trial_data[PosCol].max() - trial_data[PosCol].min())
