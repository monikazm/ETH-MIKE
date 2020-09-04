from dataclasses import dataclass

from mike_analysis.core.metric_evaluator import RowType, MetricEvaluator
from mike_analysis.metrics.positional import RMSError


# TODO (other metrics)

@dataclass
class _TrajectoryFollowingSeriesEvaluator(MetricEvaluator):
    trial_metrics = (
        RMSError(),
    )


@dataclass
class TrajectoryFollowingEvaluator(MetricEvaluator):
    name_prefix: str = 'TrajectoryFollowing'
    db_result_columns_to_select = ('Fast', )

    series_metric_computers = (
        _TrajectoryFollowingSeriesEvaluator('Slow'),
        _TrajectoryFollowingSeriesEvaluator('Fast'),
    )

    @classmethod
    def get_series_idx(cls, db_trial_result: RowType) -> int:
        return db_trial_result['Fast']
