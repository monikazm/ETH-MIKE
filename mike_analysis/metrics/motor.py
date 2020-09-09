from dataclasses import dataclass

import pandas as pd

from mike_analysis.column_computers.derivatives import DefaultVelocityComputer
from mike_analysis.core.meta import VelCol, ForceCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar


@dataclass
class MaxVelocity(TrialMetric):
    name = 'MaxVelocity'
    required_column_computers = (DefaultVelocityComputer, )

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[VelCol].abs().max()


@dataclass
class MaxForce(TrialMetric):
    name = 'MaxForce'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[ForceCol].abs().max()
