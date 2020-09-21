from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from sqlite3 import Row as RowType
from typing import List, Union, Tuple, Dict, ClassVar

import pandas as pd

from mike_analysis.core.precomputer import ColumnPrecomputer, PrecomputeDict

Scalar = Union[bool, int, float]
MetricTrialValues = Tuple[str, List[Scalar]]


class DTypes:
    DOUBLE = 'double'
    INT = 'integer'


@dataclass
class Metric(metaclass=ABCMeta):
    """Base class for all metrics"""
    name: ClassVar[str]
    d_type: ClassVar[str]
    requires: ClassVar[Tuple[ColumnPrecomputer, ...]] = ()


@dataclass
class AggregateMetric(Metric, metaclass=ABCMeta):
    """Metric which aggregates the TrialMetrics over all trials"""
    d_type: ClassVar[str] = DTypes.DOUBLE

    def compute_and_store_in_result_dict(self, result_dict: Dict[str, Scalar], all_metric_trial_values: pd.DataFrame):
        summary_values = self.compute_metric(all_metric_trial_values)
        for metric_name, value in summary_values.items():
            result_dict[f'{metric_name}_{self.name}'] = value

    @abstractmethod
    def compute_metric(self, all_metric_trial_values: pd.DataFrame) -> pd.Series:
        pass


@dataclass
class TrialMetric(Metric, metaclass=ABCMeta):
    """Metric for a single trial"""
    d_type: ClassVar[str] = DTypes.DOUBLE

    def compute(self, all_trials: List[pd.DataFrame], precomputed_vals: List[PrecomputeDict], db_trial_results: List[RowType]) -> MetricTrialValues:
        return self.name, [self.compute_single_trial(trial_data, precomputed_data, db_trial_result)
                           for trial_data, precomputed_data, db_trial_result in zip(all_trials, precomputed_vals, db_trial_results)]

    @abstractmethod
    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        pass


@dataclass
class DiffMetric(Metric):
    """Metric comparing two different aggregate values"""
    d_type: ClassVar[str] = DTypes.DOUBLE
    src_metric1: str
    src_metric2: str

    def compute(self, result_dict: Dict[str, Scalar]) -> Tuple[str, Scalar]:
        res = abs(result_dict[self.src_metric1] - result_dict[self.src_metric2])
        return self.name, res


@dataclass
class SummaryMetric(Metric, metaclass=ABCMeta):
    """Metric based on all trials (in contrast to AggregateMetric, this is not automatically applied to all TrialMetrics)"""
    def compute(self, all_trials: List[pd.DataFrame], precomputed_vals: List[PrecomputeDict], db_trial_results: List[RowType]) -> Tuple[str, Scalar]:
        return self.name, self.compute_metric_value(all_trials, precomputed_vals, db_trial_results)

    @abstractmethod
    def compute_metric_value(self, all_trials: List[pd.DataFrame], all_precomputed: List[PrecomputeDict], db_trial_results: List[RowType]) -> Scalar:
        pass
