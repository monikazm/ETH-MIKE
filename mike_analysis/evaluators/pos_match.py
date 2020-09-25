from dataclasses import dataclass

from mike_analysis.core.metric_evaluator import MetricEvaluator
from mike_analysis.metrics.positional import PositionError, AbsPositionError
from mike_analysis.metrics.summary import DeltaRMSE, NumTrials

target_col = 'Target'
actual_col = 'Indicated'


@dataclass
class PositionMatchingEvaluator(MetricEvaluator):
    name_prefix: str = 'PositionMatching'
    db_result_columns_to_select = (f'CASE LeftHand WHEN 1 THEN {target_col} ELSE -{target_col} END AS {target_col}',
                                   f'CASE LeftHand WHEN 1 THEN {actual_col} ELSE -{actual_col} END AS {actual_col}',)
    trial_metrics = (
        PositionError(target_col, actual_col),
        AbsPositionError(target_col, actual_col),
    )

    summary_metrics = (
        NumTrials(),
        DeltaRMSE(target_col, actual_col),
    )
