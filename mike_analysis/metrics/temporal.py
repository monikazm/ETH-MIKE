from dataclasses import dataclass

import numpy as np
import pandas as pd

from mike_analysis.core.constants import TimeCol, ForceCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar
from mike_analysis.core.precomputer import PrecomputeDict
from mike_analysis.precomputers.derivatives import ForceDerivative, AbsVelocity

time_unit = 's'


@dataclass
class ForceReactionTime(TrialMetric):
    name = 'ForceRT'
    bigger_is_better = False
    unit = time_unit
    requires = (ForceDerivative,)

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        first_reaction = trial_data[(precomputed[ForceDerivative] > 0.5) | (trial_data[ForceCol] > 2.0)]
        return first_reaction[TimeCol].iloc[0] if len(first_reaction.index) > 0 else np.inf


@dataclass
class MovementReactionTime(TrialMetric):
    name = 'MovementRT'
    bigger_is_better = False
    unit = time_unit
    requires = (AbsVelocity,)

    @staticmethod
    def get_indices_where_abs_vel_above_threshold_before_peak_vel_reached(abs_vel: pd.Series):
        max_v_ind = abs_vel.argmax()
        abs_vel = abs_vel.iloc[:max_v_ind+1]
        return np.where(abs_vel >= 10.0)[0]

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        ind_start = self.get_indices_where_abs_vel_above_threshold_before_peak_vel_reached(precomputed[AbsVelocity])
        if len(ind_start) == 0:
            return np.inf
        else:
            diff_ind_start = np.diff(ind_start)
            if (diff_ind_start > 50).any():
                ind_onset = ind_start[np.where(diff_ind_start > 50)[0][-1]+1]
                return trial_data[TimeCol].iloc[ind_onset]
            else:
                return trial_data[TimeCol].iloc[ind_start[0]]
