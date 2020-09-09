from dataclasses import dataclass

from mike_analysis.core.metric_evaluator import RowType, MetricEvaluator
from mike_analysis.metrics.aggregate import MeanTop3, StdDevTop3
from mike_analysis.metrics.motor import MaxVelocity

## TODO
max_normalized_velocity_metric = 'MaxNormalizedVelocity'
nr_no_target_trials_metric = 'NrNoTargetTrials'
rt_metric = 'ReactionTime'
abs_pos_error_metric = 'AbsPositionError'


@dataclass
class _FastReachingSeriesEvaluator(MetricEvaluator):
    trial_metrics = (
        MaxVelocity(),
    )

    aggregator_metrics = (
        MeanTop3(),
        StdDevTop3()
    )


@dataclass
class FastReachingEvaluator(MetricEvaluator):
    name_prefix: str = 'FastReaching'
    db_result_columns_to_select = ('Flexion', )

    series_metric_computers = (
        _FastReachingSeriesEvaluator('Extension'),
        _FastReachingSeriesEvaluator('Flexion'),
    )

    @classmethod
    def get_series_idx(cls, db_trial_result: RowType) -> int:
        return db_trial_result['Flexion']
