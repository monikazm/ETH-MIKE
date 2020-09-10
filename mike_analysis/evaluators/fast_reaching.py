from dataclasses import dataclass

from mike_analysis.core.metric_evaluator import RowType, MetricEvaluator
from mike_analysis.metrics.aggregate import MeanTop3, StdDevTop3
from mike_analysis.metrics.motor import MaxVelocity, MaxNormalizedVelocity
from mike_analysis.metrics.summary import NrOfTrialsWithoutReachingTarget
from mike_analysis.metrics.temporal import MovementReactionTime

abs_pos_error_metric = 'AbsPositionError'


@dataclass
class _FastReachingSeriesEvaluator(MetricEvaluator):
    trial_metrics = (
        MaxVelocity(),
        MaxNormalizedVelocity(),
        MovementReactionTime(),
    )

    aggregator_metrics = (
        MeanTop3([MovementReactionTime.name]),
        StdDevTop3([MovementReactionTime.name]),
    )

    summary_metrics = (
        NrOfTrialsWithoutReachingTarget(),
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
