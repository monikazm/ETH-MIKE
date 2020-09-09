from dataclasses import dataclass

import pandas as pd

from mike_analysis.column_computers.derivatives import DefaultForceDerivativeComputer
from mike_analysis.core.meta import DfDtCol, TimeCol, ForceCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar


@dataclass
class ForceReactionTime(TrialMetric):
    name = 'ForceRT'
    required_column_computers = (DefaultForceDerivativeComputer, )

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        first_reaction = trial_data[(trial_data[DfDtCol] > 0.5) | (trial_data[ForceCol] > 2.0)]
        return first_reaction[TimeCol].iloc[0] if len(first_reaction.index) > 0 else 0.0
