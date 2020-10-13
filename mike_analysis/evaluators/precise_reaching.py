from dataclasses import dataclass

from mike_analysis.core.metric_evaluator import MetricEvaluator, RowType
from mike_analysis.metrics.positional import PositionError, AbsPositionError
from mike_analysis.metrics.summary import DeltaRMSE, NumTrials

target_col = 'Target'
actual_col = 'Actual'


@dataclass
class _PreciseReachingSeriesEvaluator(MetricEvaluator):
    trial_metrics = (
        PositionError(target_col, actual_col),
        AbsPositionError(target_col, actual_col),
    )
    summary_metrics = (
        NumTrials(),
        DeltaRMSE(target_col, actual_col),
    )


@dataclass
class PreciseReachingEvaluator(MetricEvaluator):
    name_prefix: str = 'PreciseReaching'
    db_result_columns_to_select = (
        'Flexion',
        f'CASE LeftHand WHEN 1 THEN {target_col} ELSE -{target_col} END AS {target_col}',
        f'CASE LeftHand WHEN 1 THEN {actual_col} ELSE -{actual_col} END AS {actual_col}',
    )
    series_metric_evaluators = (
        _PreciseReachingSeriesEvaluator('Extension'),
        _PreciseReachingSeriesEvaluator('Flexion'),
    )

    @classmethod
    def get_series_idx(cls, db_trial_result: RowType) -> int:
        return db_trial_result['Flexion']
