import collections
from abc import ABCMeta
from dataclasses import dataclass
from itertools import compress
from typing import List, Dict, Union, Tuple, ClassVar, OrderedDict

import pandas as pd

from mike_analysis.core.metric import AggregateMetric, DiffMetric, SummaryMetric, TrialMetric
from mike_analysis.core.precomputer import Precomputer, PrecomputeDict
from mike_analysis.metrics.aggregate import StdDev, Mean

Scalar = Union[bool, int, float]
RowType = Dict[str, Scalar]
AllMetricsTrialValues = List[Tuple[str, List[Scalar]]]
AllAssessmentMetricsValues = List[Tuple[str, Scalar]]


@dataclass
class MetricEvaluator(metaclass=ABCMeta):
    name_prefix: str
    db_result_columns_to_select: ClassVar[Tuple[str, ...]] = None

    trial_metrics: ClassVar[Tuple[TrialMetric, ...]] = ()
    diff_metrics: ClassVar[Tuple[DiffMetric, ...]] = ()
    summary_metrics: ClassVar[Tuple[SummaryMetric, ...]] = ()
    aggregator_metrics: ClassVar[Tuple[AggregateMetric, ...]] = (Mean(), StdDev())

    series_metric_evaluators: ClassVar[Tuple['MetricEvaluator', ...]] = ()

    def get_precompute_dependencies(self) -> OrderedDict[Precomputer, None]:
        precompute_dependencies = collections.OrderedDict()

        # Include precompute requirements of sub series evaluators (if any)
        for computer in self.series_metric_evaluators:
            precompute_dependencies.update(computer.get_precompute_dependencies())

        # Include precompute requirements of metrics from this evaluator
        for metric in self.trial_metrics + self.diff_metrics + self.summary_metrics + self.aggregator_metrics:
            for dependency in metric.requires:
                dependency.add_to(precompute_dependencies)
        return precompute_dependencies

    def get_result_column_info(self) -> List[Tuple[str, str, bool, str]]:
        result_columns = []

        # Get metric metadata of sub series evaluators (if any)
        for series_computer in self.series_metric_evaluators:
            result_columns += series_computer.get_result_column_info()

        # Get metric metadata for summary metrics, aggregated trial metrics and diff metrics
        result_columns += [(f'{metric.name}', metric.d_type, metric.bigger_is_better, metric.unit)
                           for metric in self.summary_metrics]
        result_columns += [(f'{metric.name}_{aggregate.name}', aggregate.d_type, aggregate.bigger_is_better(metric), aggregate.unit(metric))
                           for metric in self.trial_metrics for aggregate in self.aggregator_metrics]
        result_columns += [(f'{metric.name}', metric.d_type, metric.bigger_is_better, metric.unit)
                           for metric in self.diff_metrics]

        # Return metadata with evaluator name prepended to metric name
        return [(f'{self.name_prefix}_{name}', d_type, big_is_better, unit) for name, d_type, big_is_better, unit in result_columns]

    def compute_assessment_metrics(self, all_trials: List[pd.DataFrame], precomputed_vals: List[PrecomputeDict], db_results: List[RowType]) -> Dict[str, Scalar]:
        result_dict = {}

        # If this metric evaluator contains sub-evaluators in series_metric_evaluators,
        # split trials into series (based on self.get_series_idx which determines the series from a db_trial_result)
        # and pass the partial trial data to the corresponding series metric evaluator to compute separate metrics for each series
        if self.series_metric_evaluators:
            trial_series_indices = [self.get_series_idx(db_trial_result) for db_trial_result in db_results]
            for current_series_idx, series_evaluator in enumerate(self.series_metric_evaluators):
                # Determine which trial indices belong to this series (series_mask == list of booleans)
                series_mask = [current_series_idx == trial_series_idx for trial_series_idx in trial_series_indices]

                # Recursively call series metric evaluator to compute series results,
                # itertools.compress function is used to only select those trials where series mask is true
                computed_metrics_for_series = series_evaluator.compute_assessment_metrics(list(compress(all_trials, series_mask)),
                                                                                          list(compress(precomputed_vals, series_mask)),
                                                                                          list(compress(db_results, series_mask)))
                result_dict.update(computed_metrics_for_series)

        # Compute trial metrics
        metric_values_for_trials = pd.DataFrame({metric.name: metric.compute_for_all_trials(all_trials, precomputed_vals, db_results)
                                                 for metric in self.trial_metrics})

        # Compute aggregate metrics
        for aggregate_metric in self.aggregator_metrics:
            aggregate_metric_value_dict = aggregate_metric.compute_for_all_metrics(metric_values_for_trials)
            result_dict.update(aggregate_metric_value_dict)

        # Compute summary metric
        for summary_metric in self.summary_metrics:
            value = summary_metric.compute_across_trials(all_trials, precomputed_vals, db_results)
            result_dict[summary_metric.name] = value

        # Compute diff metrics
        for diff_metric in self.diff_metrics:
            value = diff_metric.compute_from_results(result_dict)
            result_dict[diff_metric.name] = value

        # Append prefix to name
        return {f'{self.name_prefix}_{metric_name}': metric_value for metric_name, metric_value in result_dict.items()}

    def get_series_idx(self, db_trial_result: RowType) -> int:
        return -1
