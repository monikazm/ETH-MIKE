from dataclasses import dataclass

import numpy as np
import pandas as pd

from mike_analysis.column_computers.derivatives import DefaultForceDerivativeComputer, DefaultVelocityComputer
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
    required_column_computers = (DefaultVelocityComputer, )

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        abs_vel = trial_data[VelCol].abs()
        max_v_ind = abs_vel.argmax()
        abs_vel = abs_vel.iloc[:max_v_ind]

        ind_start = np.where(abs_vel >= 10.0)[0]
        diff_ind_start = np.diff(ind_start)
        if len(ind_start) == 0:
            return np.inf
        elif (diff_ind_start > 50).any():
            ind_onset = ind_start[np.where(diff_ind_start > 50)[0][-1]+1]
            return trial_data[TimeCol].iloc[ind_onset]
        else:
            return trial_data[TimeCol].iloc[ind_start[0]]
