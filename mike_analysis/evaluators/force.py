from dataclasses import dataclass

from mike_analysis.core.metric_evaluator import RowType, MetricEvaluator
from mike_analysis.metrics.motor import MaxForce
from mike_analysis.metrics.temporal import ForceReactionTime


@dataclass
class _ForceSeriesEvaluator(MetricEvaluator):
    trial_metrics = (
        MaxForce(),
        ForceReactionTime(),
    )


@dataclass
class ForceEvaluator(MetricEvaluator):
    name_prefix: str = 'Force'
    db_result_columns_to_select = ('Flexion', )

    series_metric_computers = (
        _ForceSeriesEvaluator('Extension'),
        _ForceSeriesEvaluator('Flexion'),
    )

    @classmethod
    def get_series_idx(cls, db_trial_result: RowType) -> int:
        return db_trial_result['Flexion']
