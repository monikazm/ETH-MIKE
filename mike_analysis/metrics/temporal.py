from dataclasses import dataclass

import numpy as np
import pandas as pd

from mike_analysis.column_computers.derivatives import DefaultForceDerivativeComputer, DefaultAbsVelocityComputer
from mike_analysis.core.meta import DfDtCol, TimeCol, ForceCol, VelCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar


@dataclass
class ForceReactionTime(TrialMetric):
    name = 'ForceRT'
    required_column_computers = (DefaultForceDerivativeComputer, )

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        first_reaction = trial_data[(trial_data[DfDtCol] > 0.5) | (trial_data[ForceCol] > 2.0)]
        return first_reaction[TimeCol].iloc[0] if len(first_reaction.index) > 0 else 0.0


@dataclass
class MovementReactionTime(TrialMetric):
    name = 'MovementRT'
    required_column_computers = (DefaultAbsVelocityComputer,)

    @staticmethod
    def get_indices_where_abs_vel_above_threshold_before_peak_vel_reached(trial_data: pd.DataFrame):
        abs_vel = trial_data[VelCol]
        max_v_ind = abs_vel.argmax()
        abs_vel = abs_vel.iloc[:max_v_ind+1]
        return np.where(abs_vel >= 10.0)[0]

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        ind_start = self.get_indices_where_abs_vel_above_threshold_before_peak_vel_reached(trial_data)
        if len(ind_start) == 0:
            return np.inf
        else:
            diff_ind_start = np.diff(ind_start)
            if (diff_ind_start > 50).any():
                ind_onset = ind_start[np.where(diff_ind_start > 50)[0][-1]+1]
                return trial_data[TimeCol].iloc[ind_onset]
            else:
                return trial_data[TimeCol].iloc[ind_start[0]]
