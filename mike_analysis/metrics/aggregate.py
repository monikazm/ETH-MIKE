from dataclasses import dataclass

import pandas as pd

from mike_analysis.core.metric import AggregateMetric


@dataclass
class Mean(AggregateMetric):
    name = 'Mean'

    def compute_metric(self, all_metric_trial_values: pd.DataFrame) -> pd.Series:
        return all_metric_trial_values.mean(axis=0)


@dataclass
class StdDev(AggregateMetric):
    name = 'Std'

    def compute_metric(self, all_metric_trial_values: pd.DataFrame) -> pd.Series:
        return all_metric_trial_values.std(axis=0)
