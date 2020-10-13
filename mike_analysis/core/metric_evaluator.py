import collections
from abc import ABCMeta
from dataclasses import dataclass
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

    series_metric_computers: ClassVar[Tuple['MetricEvaluator', ...]] = ()

    def get_precompute_dependencies(self) -> OrderedDict[Precomputer, None]:
        precompute_dependencies = collections.OrderedDict()
        for computer in self.series_metric_computers:
            precompute_dependencies.update(computer.get_precompute_dependencies())
        for metric in self.trial_metrics + self.diff_metrics + self.summary_metrics + self.aggregator_metrics:
            for dependency in metric.requires:
                dependency.add_to(precompute_dependencies)
        return precompute_dependencies

    def get_result_column_names_and_info(self) -> List[Tuple[str, str, bool, str]]:
        col_name_and_types = []
        col_name_and_types += [(f'{metric.name}', metric.d_type, metric.bigger_is_better, metric.unit) for metric in self.summary_metrics]
        col_name_and_types += [(f'{metric.name}_{aggregate_metric.name}', aggregate_metric.d_type, aggregate_metric.bigger_is_better(metric), aggregate_metric.unit(metric))
                               for metric in self.trial_metrics for aggregate_metric in self.aggregator_metrics]
        for series_computer in self.series_metric_computers:
            col_name_and_types += series_computer.get_result_column_names_and_info()
        col_name_and_types += [(f'{metric.name}', metric.d_type, metric.bigger_is_better, metric.unit) for metric in self.diff_metrics]
        return [(f'{self.name_prefix}_{name}', d_type, big_is_better, unit) for name, d_type, big_is_better, unit in col_name_and_types]

    def compute_assessment_metrics(self, all_trials: List[pd.DataFrame], precomputed_vals: List[PrecomputeDict], db_results: List[RowType]) -> Dict[str, Scalar]:
        result_dict = {}

        # Split trials into series (if any) and compute individual series results
        series_trials = [([], [], []) for _ in self.series_metric_computers]
        if series_trials:
            for raw_trial_data, precomputed, db_trial_result in zip(all_trials, precomputed_vals, db_results):
                series_raw_trials, series_precomputed, series_db_results = series_trials[self.get_series_idx(db_trial_result)]
                series_raw_trials.append(raw_trial_data)
                series_precomputed.append(precomputed)
                series_db_results.append(db_trial_result)
            for series_computer, (series_raw_trials, series_precomputed, series_db_results) in zip(self.series_metric_computers, series_trials):
                result_dict.update(series_computer.compute_assessment_metrics(series_raw_trials, series_precomputed, series_db_results))

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
