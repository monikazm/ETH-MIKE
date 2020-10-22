from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from typing import List, Union, Tuple, Dict, ClassVar
import pandas as pd

from mike_analysis.core.constants import RowDict
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
    """The name of this metric (factors into the name of the database column)"""

    d_type: ClassVar[str]
    """The sql datatype of this metric"""

    requires: ClassVar[Tuple[ColumnPrecomputer, ...]] = ()
    """
    List of precomputers which are required to compute this metric

    The system ensures that the columns/values corresponding to the precomputers in the metric's
    requires field are precomputed once and passed to the metric during evaluation as PrecomputeDict.
    """


@dataclass
class AggregateMetric(Metric, metaclass=ABCMeta):
    """Metric which aggregates the TrialMetrics over all trials"""
    # Default datatype = double, override if necessary
    d_type: ClassVar[str] = DTypes.DOUBLE

    @abstractmethod
    def bigger_is_better(self, single_metric: 'TrialMetric') -> bool:
        """
        Return true if bigger_is_better holds for the aggregate of single_metric.

        :param single_metric: the trial metric for which to check if bigger_is_better holds for the aggregate.
        :return: True if larger values of aggregate(single_metric) are "better".
        """
        pass

    def unit(self, single_metric: 'TrialMetric') -> str:
        """
        Return the unit of the aggregate for the given trial metric

        :param single_metric: base metric for which to return the unit of the aggregate
        :return: unit string (e.g. 'deg/s')
        """
        # Default implementation returns unit of the trial metric
        # This function needs to be overridden if the aggregation changes the unit
        return single_metric.unit

    def compute_for_all_metrics(self, all_metric_trial_values: pd.DataFrame) -> Dict[str, Scalar]:
        """
        Compute aggregate across trial dimension

        :param all_metric_trial_values: data frame (matrix) with trial metric values (one column per trial metric and one row per trial)
               e.g.   metric1 | metric2 | ...
                    -----------------------------------
                (1)  234.3    | 2.31    | ...
                (2)  2323.1   | ....

        :return: dictionary which maps trial metric name (with name of this AggreagteMetric appended) to the corresponding aggregate value
                 e.g. {
                    'metric1_{self.name}': 345.2,
                    'metric2_{self.name}': 32.1,
                    ...
                 }
                 where self.name is this AggregateMetric's name (e.g. Mean)
        """
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
               e.g.   metric1 | metric2 | ...
                    -----------------------------------
                (0)  234.3    | 2.31    | ...
                (1)  2323.1   | ....
        :return: pandas series of aggregated metric values (len == num cols/metrics of input data frame)
                 e.g.        values
                        ----------------
                        (metric1) 123.2
                        (metric2) 234.2
                           ...
                 where self.name is the name of this aggregate metric
        """
        pass


@dataclass
class TrialMetric(Metric, metaclass=ABCMeta):
    """Metric for a single trial"""
    d_type: ClassVar[str] = DTypes.DOUBLE
    bigger_is_better: ClassVar[bool]
    unit: ClassVar[str]

    def compute_for_all_trials(self, all_trials: List[pd.DataFrame], all_precomputed: List[PrecomputeDict],
                               db_trial_results: List[RowDict]) -> List[Scalar]:
        """
        Compute trial metric value for all trials.

        All three input list parameter have the same length and element order (== # of trials, each element corresponds to one trial).

        :param all_trials: List of data frames corresponding to the raw data for each trial
                           (result from file_processing.preprocess_and_split_trials)
        :param all_precomputed: List of PrecomputeDicts (maps precomputer object to corresponding precomputed column/value, for each trial)
        :param db_trial_results: List of dictionaries with selected columns from frontend db result table
        see compute_single_trial for more details about parameters

        :return: List of metric value for each trial e.g. [123.2, 2132.2, 23.4, ...]
        """
        return [self.compute_single_trial(trial_data_frame, precomputed, db_trial_result)
                for trial_data_frame, precomputed, db_trial_result in zip(all_trials, all_precomputed, db_trial_results)]

    @abstractmethod
    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowDict) -> Scalar:
        """
        This function needs to be implemented when implementing a custom trial metric.

        It takes the raw data corresponding to the TargetState=True period of a single trial as input and should return the scalar metric value
        :param trial_data: dataframe with raw tdms data for a single trial (Time starts at 0.0, only rows where TargetState=1)
               e.g.   Force | Position | TargetPosition | ...
                    -----------------------------------------
                (0)  23.4   | 2.31     | 30.0           | ...
                (1)  33.1   |   ....   |   ....         | ...
        :param precomputed: dictionary which allows accessing precomputed columns and values, for which the precomputer object is
                            included in the "requires" list of this metric
               e.g. {
                    Velocity: velocity_series,
                    Jerk: jerk_series
               }
        :param db_trial_result: dictionary which provides access to the column values of the result table in the frontend database
                                which correspond to this trial (only columns which were added to the metric evaluator's
                                db_result_columns_to_select field are included)
               e.g. {
                    'Flexion': 1,
                    'Indicated': 23.3
               }
        :return: scalar metric value
        """
        pass


@dataclass
class DiffMetric:
    """Special Metric comparing two different aggregate values"""
    # Names of the two metrics from which to take the absolute difference (names are without name prefix of the current evaluator)
    src_metric1: str
    src_metric2: str

    d_type: str = DTypes.DOUBLE
    bigger_is_better: bool = True
    unit: str = ''

    @property
    def name(self) -> str:
        return f'{self.src_metric1}_{self.src_metric2}_Diff'

    def compute_from_results(self, result_dict: Dict[str, Scalar]) -> Scalar:
        """
        Return the absolute difference between result_dict[src_metric1] and result_dict[src_metric2].

        This can be useful to create metrics which span different series (e.g. difference between active and passive ROM)
        :param result_dict: dictionary with all other metric values computed by the current evaluator and it's series evaluators
               e.g. {
                    'Flexion_MaxForce_Mean': 12.2,
                    'Flexion_MaxForce_Std': 2.2,
                    'Flexion_NumTrials': 3,
                    'Extension_MaxForce_Mean': 134.2,
                    ....
               }
        :return: absolute difference between metrics (scalar)
        """
        res = abs(result_dict[self.src_metric1] - result_dict[self.src_metric2])
        return res


@dataclass
class SummaryMetric(Metric, metaclass=ABCMeta):
    bigger_is_better: ClassVar[bool]
    unit: ClassVar[str]

    """Metric based on all trials (in contrast to AggregateMetric, this is not automatically applied to all TrialMetrics)"""

    @abstractmethod
    def compute_across_trials(self, all_trials: List[pd.DataFrame], all_precomputed: List[PrecomputeDict], db_trial_results: List[RowDict]) -> Scalar:
        """
        This function needs to be implemented when implementing a custom SummaryMetric.
        It should compute the value of the metric based on all trials.

        :param all_trials: List of data frames corresponding to the raw data for each trial (result from file_processing.preprocess_and_split_trials)
        :param all_precomputed: List of PrecomputeDicts (maps precomputer object to corresponding precomputed column/value, for each trial)
        :param db_trial_results: List of dictionaries with selected columns from frontend db result table
        see TrialMetric.compute_single_trial for more details about these parameters

        Note: see compute_single_trial documentation in TrialMetric for more information
        :return: metric value
        """
        pass
