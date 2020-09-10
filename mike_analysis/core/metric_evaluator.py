import collections
from abc import ABCMeta
from dataclasses import dataclass
from typing import List, Dict, Union, Tuple, ClassVar, OrderedDict

import pandas as pd

from mike_analysis.core.computed_columns import ColumnComputer
from mike_analysis.core.metric import AggregateMetric, DiffMetric, SummaryMetric, TrialMetric
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

    def get_required_column_computers(self) -> OrderedDict[ColumnComputer, None]:
        column_computers = collections.OrderedDict()
        for computer in self.series_metric_computers:
            column_computers.update(computer.get_required_column_computers())
        for metric in self.trial_metrics + self.diff_metrics + self.summary_metrics + self.aggregator_metrics:
            column_computers.update((computer, None) for computer in metric.required_column_computers)
        return column_computers

    def get_result_column_names_and_types(self) -> List[Tuple[str, str]]:
        col_name_and_types = []
        for series_computer in self.series_metric_computers:
            col_name_and_types += series_computer.get_result_column_names_and_types()
        col_name_and_types += [(f'{metric.name}_{aggregate_metric.name}', aggregate_metric.d_type)
                               for metric in self.trial_metrics for aggregate_metric in self.aggregator_metrics]
        col_name_and_types += [(f'{metric.name}', metric.d_type) for metric in self.diff_metrics + self.summary_metrics]
        return [(f'{self.name_prefix}_{name}', d_type) for name, d_type in col_name_and_types]

    def get_result_column_names(self) -> List[str]:
        return next(zip(*self.get_result_column_names_and_types()))

    def compute_trial_metrics(self, all_trials: List[pd.DataFrame], db_results: List[RowType]) -> AllMetricsTrialValues:
        return [metric.compute(all_trials, db_results) for metric in self.trial_metrics]

    def compute_assessment_metrics(self, all_trials: List[pd.DataFrame], db_results: List[RowType]) -> Dict[str, Scalar]:
        result_dict = {}

        # Split trials into series (if any) and compute individual series results
        series_trials = [([], []) for _ in self.series_metric_computers]
        if series_trials:
            for raw_trial_data, db_trial_result in zip(all_trials, db_results):
                series_raw_trials, series_db_results = series_trials[self.get_series_idx(db_trial_result)]
                series_raw_trials.append(raw_trial_data)
                series_db_results.append(db_trial_result)
            for series_computer, (series_raw_trials, series_db_results) in zip(self.series_metric_computers, series_trials):
                result_dict.update(series_computer.compute_assessment_metrics(series_raw_trials, series_db_results))

        # Compute trial metrics
        data = pd.DataFrame.from_dict(dict(self.compute_trial_metrics(all_trials, db_results)))

        # Compute aggregate metrics
        for aggregator_metric in self.aggregator_metrics:
            aggregator_metric.compute_and_store_in_result_dict(result_dict, data)

        # Compute summary metric
        for metric in self.summary_metrics:
            name, value = metric.compute(all_trials, db_results)
            result_dict[name] = value

        # Compute diff metrics
        for metric in self.diff_metrics:
            name, value = metric.compute(result_dict)
            result_dict[name] = value

        # Append prefix to name
        return {f'{self.name_prefix}_{metric_name}': metric_value for metric_name, metric_value in result_dict.items()}

    def get_series_idx(self, db_trial_result: RowType) -> int:
        return -1
