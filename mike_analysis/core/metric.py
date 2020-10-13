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

    @abstractmethod
    def bigger_is_better(self, single_metric: 'TrialMetric') -> bool:
        pass

    def unit(self, single_metric: 'TrialMetric') -> str:
        return single_metric.unit

    def compute_for_all_metrics(self, all_metric_trial_values: pd.DataFrame) -> Dict[str, Scalar]:
        summary_values = self.compute_aggregate_across_trials(all_metric_trial_values)
        aggregated_metrics = {f'{metric_name}_{self.name}': value for metric_name, value in summary_values.items()}
        return aggregated_metrics

    @abstractmethod
    def compute_aggregate_across_trials(self, all_metric_trial_values: pd.DataFrame) -> pd.Series:
        """
        This function needs to be implemented when implementing a custom aggregate metric.

        It takes a dataframe of metric values (columns == different trial metrics, rows = individual trials)
        and returns a series with one aggregate value per metric

        :param all_metric_trial_values: data frame with all trial_metric values for all trials
        :return: series of aggregated metric values
        """
        pass


@dataclass
class TrialMetric(Metric, metaclass=ABCMeta):
    """Metric for a single trial"""
    d_type: ClassVar[str] = DTypes.DOUBLE
    bigger_is_better: ClassVar[bool]
    unit: ClassVar[str]

    def compute_for_all_trials(self, all_trials: List[pd.DataFrame], precomputed_vals: List[PrecomputeDict], db_trial_results: List[RowType]) -> List[Scalar]:
        return [self.compute_single_trial(trial_data, precomputed_data, db_trial_result)
                for trial_data, precomputed_data, db_trial_result in zip(all_trials, precomputed_vals, db_trial_results)]

    @abstractmethod
    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        """
        This function needs to be implemented when implementing a custom trial metric.

        It takes the raw data corresponding to the TargetState=True period of a single trial as input and should return the scalar metric value
        :param trial_data: dataframe with raw tdms data for a single trial (Time starts at 0.0, only rows where TargetState=1)
        :param precomputed: dictionary which allows accessing precomputed columns and values, for which the precomputer object is
                            included in the "requires" list of this metric
        :param db_trial_result: dictionary which provides access to the column values of the result table in the frontend database
                                which correspond to this trial
                                (only columns from the metric evaluators db_result_columns_to_select field are included)
        :return: metric value
        """
        pass


@dataclass
class DiffMetric(Metric):
    """Metric comparing two different aggregate values"""
    d_type: ClassVar[str] = DTypes.DOUBLE
    bigger_is_better: ClassVar[bool]
    unit: ClassVar[str]
    src_metric1: str
    src_metric2: str

    @property
    def name(self) -> str:
        return f'{self.src_metric1}_{self.src_metric2}_Diff'

    def compute_from_results(self, result_dict: Dict[str, Scalar]) -> Scalar:
        res = abs(result_dict[self.src_metric1] - result_dict[self.src_metric2])
        return res


@dataclass
class SummaryMetric(Metric, metaclass=ABCMeta):
    bigger_is_better: ClassVar[bool]
    unit: ClassVar[str]

    """Metric based on all trials (in contrast to AggregateMetric, this is not automatically applied to all TrialMetrics)"""

    @abstractmethod
    def compute_across_trials(self, all_trials: List[pd.DataFrame], all_precomputed: List[PrecomputeDict], db_trial_results: List[RowType]) -> Scalar:
        """
        This function needs to be implemented when implementing a custom SummaryMetric.
        It should compute the value of the metric based on all trials.

        :param all_trials: list with one dataframe per trial
        :param all_precomputed: list with one precomputed dict per trial
        :param db_trial_results: list with one db_trial_result per trial
        Note: see compute_single_trial documentation in TrialMetric for more information
        :return: metric value
        """
        pass
