from dataclasses import dataclass
from math import sqrt
from typing import List

import pandas as pd

from mike_analysis.core.metric import RowType, Scalar, SummaryMetric, DTypes


@dataclass
class DeltaRMSE(SummaryMetric):
    name = 'RMSE'
    d_type = DTypes.DOUBLE

    target_col: str
    actual_col: str

    def compute_metric_value(self, all_trials: List[pd.DataFrame], db_trial_results: List[RowType]) -> Scalar:
        squared_sum = 0.0
        for db_trial_result in db_trial_results:
            delta = db_trial_result[self.target_col] - db_trial_result[self.actual_col]
            squared_sum += delta * delta
        return sqrt(squared_sum / len(db_trial_results))
