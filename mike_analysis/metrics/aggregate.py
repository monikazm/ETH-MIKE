from dataclasses import dataclass
from typing import Callable, Iterable

import numpy as np
import pandas as pd

from mike_analysis.core.metric import AggregateMetric, TrialMetric


def sort_each_column(data: pd.DataFrame):
    return pd.DataFrame(np.sort(data.values, axis=0), index=data.index, columns=data.columns)


def compute_top_n_aggregate(data: pd.DataFrame, n: int, smaller_is_better_cols: Iterable[str], aggregate_fct: Callable[[pd.DataFrame], pd.Series]):
    top_n = min(n, len(data))
    bigger_is_better_cols = data.columns.difference(smaller_is_better_cols, False)
    sorted_metrics = sort_each_column(data)
    res = pd.concat(map(aggregate_fct, [
        sorted_metrics.loc[:, bigger_is_better_cols].tail(top_n),
        sorted_metrics.loc[:, smaller_is_better_cols].head(top_n)
    ]))
    return res


@dataclass
class Mean(AggregateMetric):
    name = 'Mean'

    def bigger_is_better(self, single_metric: TrialMetric) -> bool:
        return single_metric.bigger_is_better

    def compute_aggregate_across_trials(self, all_metric_trial_values: pd.DataFrame) -> pd.Series:
        return all_metric_trial_values.mean(axis=0)


@dataclass
class MeanTop3(Mean):
    name = f'MeanTop3'
    smaller_is_better_cols: Iterable[str] = ()

    def compute_aggregate_across_trials(self, all_metric_trial_values: pd.DataFrame) -> pd.Series:
        return compute_top_n_aggregate(all_metric_trial_values, 3, self.smaller_is_better_cols, super().compute_aggregate_across_trials)


@dataclass
class StdDev(AggregateMetric):
    name = 'Std'

    def bigger_is_better(self, single_metric: TrialMetric) -> bool:
        return False

    def compute_aggregate_across_trials(self, all_metric_trial_values: pd.DataFrame) -> pd.Series:
        return all_metric_trial_values.std(axis=0)


@dataclass
class StdDevTop3(StdDev):
    name = 'StdTop3'
    smaller_is_better_cols: Iterable[str] = ()

    def compute_aggregate_across_trials(self, all_metric_trial_values: pd.DataFrame) -> pd.Series:
        return compute_top_n_aggregate(all_metric_trial_values, 3, self.smaller_is_better_cols, super().compute_aggregate_across_trials)
