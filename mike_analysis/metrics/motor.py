from dataclasses import dataclass

import pandas as pd

from mike_analysis.column_computers.derivatives import DefaultVelocityComputer
from mike_analysis.core.meta import VelCol, ForceCol, PosCol, SPosCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar


@dataclass
class MaxVelocity(TrialMetric):
    name = 'MaxVelocity'
    required_column_computers = (DefaultVelocityComputer, )

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[VelCol].abs().max()


@dataclass
class MaxNormalizedVelocity(TrialMetric):
    name = 'MaxVelocityNormalized'
    required_column_computers = (DefaultVelocityComputer, )

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        abs_vel = trial_data.loc[:, VelCol].abs()
        max_abs_v = abs_vel.max()
        data_at_max_v = trial_data[abs_vel == max_abs_v].head(1)
        return max_abs_v / (data_at_max_v[PosCol] - data_at_max_v[SPosCol]).abs().iloc[0]


@dataclass
class MaxForce(TrialMetric):
    name = 'MaxForce'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[ForceCol].abs().max()
