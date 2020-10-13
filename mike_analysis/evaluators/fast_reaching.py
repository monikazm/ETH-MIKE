from dataclasses import dataclass

from mike_analysis.core.metric_evaluator import RowType, MetricEvaluator
from mike_analysis.metrics.aggregate import MeanTop3, StdDevTop3
from mike_analysis.metrics.motor import MaxVelocity, MaxNormalizedVelocity
from mike_analysis.metrics.positional import AbsPositionErrorAtSteadyState
from mike_analysis.metrics.summary import NrOfTrialsWithoutReachingTarget, NumTrials
from mike_analysis.metrics.temporal import MovementReactionTime


@dataclass
class _FastReachingSeriesEvaluator(MetricEvaluator):
    trial_metrics = (
        MaxVelocity(),
        MaxNormalizedVelocity(),
        MovementReactionTime(),
        AbsPositionErrorAtSteadyState(),
    )

    aggregator_metrics = (
        MeanTop3([metric.name for metric in trial_metrics if not metric.bigger_is_better]),
        StdDevTop3([metric.name for metric in trial_metrics if not metric.bigger_is_better]),
    )

    summary_metrics = (
        NumTrials(),
        NrOfTrialsWithoutReachingTarget(),
    )


@dataclass
class FastReachingEvaluator(MetricEvaluator):
    name_prefix: str = 'FastReaching'
    db_result_columns_to_select = ('Flexion', )

    series_metric_evaluators = (
        _FastReachingSeriesEvaluator('Extension'),
        _FastReachingSeriesEvaluator('Flexion'),
    )

    @classmethod
    def get_series_idx(cls, db_trial_result: RowType) -> int:
        return db_trial_result['Flexion']
