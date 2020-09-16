from dataclasses import dataclass

import numpy as np
import pandas as pd

from mike_analysis.core.meta import TPosCol, PosCol, VelCol, TimeCol
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
class AbsPositionErrorAtSteadyState(TrialMetric):
    name = 'AbsPositionErrorAtSS'

    @staticmethod
    def get_indices_where_abs_vel_above_threshold_after_peak_vel_reached(trial_data: pd.DataFrame):
        abs_vel = trial_data[VelCol].abs()
        max_v_ind = abs_vel.argmax()
        abs_vel = abs_vel.iloc[max_v_ind+1:]
        return np.where(abs_vel >= 10.0)[0] + max_v_ind + 1

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        ind_large_v = self.get_indices_where_abs_vel_above_threshold_after_peak_vel_reached(trial_data)

        if len(ind_large_v) == 0:
            # Non-moving patient
            return np.inf
        else:
            diff_indices_end = np.diff(ind_large_v)
            if (diff_indices_end > 600).any():
                ind_ss = ind_large_v[np.where(diff_indices_end > 600)[0][0]]
                time_ss = trial_data[TimeCol].iloc[ind_ss]
            else:
                time_ss = trial_data[TimeCol].iloc[ind_large_v[-1]]
                if time_ss > 0.9 * trial_data[TimeCol].iloc[-1]: # no steady state if not reached before 90% of available time
                    time_ss = trial_data[TimeCol].iloc[-1]
            data_at_ss = trial_data[trial_data[TimeCol] == time_ss]
            return (data_at_ss[TPosCol] - data_at_ss[PosCol]).abs().iloc[0]


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
