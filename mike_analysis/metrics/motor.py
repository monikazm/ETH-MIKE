from dataclasses import dataclass

import pandas as pd

from mike_analysis.column_computers.derivatives import DefaultAbsVelocityComputer
from mike_analysis.core.meta import VelCol, ForceCol, PosCol, SPosCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar


@dataclass
class MaxVelocity(TrialMetric):
    name = 'MaxVelocity'
    required_column_computers = (DefaultAbsVelocityComputer,)

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[VelCol].max()


@dataclass
class MaxNormalizedVelocity(TrialMetric):
    name = 'MaxVelocityNormalized'
    required_column_computers = (DefaultAbsVelocityComputer,)

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        abs_vel = trial_data.loc[:, VelCol]
        max_abs_v = abs_vel.max()
        data_at_max_v = trial_data[abs_vel == max_abs_v].head(1)
        return max_abs_v / (data_at_max_v[PosCol] - data_at_max_v[SPosCol]).abs().iloc[0]


@dataclass
class MAPR(TrialMetric):
    name = 'MAPR'
    required_column_computers = (DefaultAbsVelocityComputer,)

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        v_thresh = 0.2 * trial_data[VelCol].mean()
        mapr = (trial_data[VelCol] < v_thresh).sum() / float(len(trial_data))
        return mapr


@dataclass
class VelocitySD(TrialMetric):
    name = 'VelocitySD'
    required_column_computers = (DefaultAbsVelocityComputer,)

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[VelCol].std()


@dataclass
class MaxForce(TrialMetric):
    name = 'MaxForce'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[ForceCol].abs().max()
