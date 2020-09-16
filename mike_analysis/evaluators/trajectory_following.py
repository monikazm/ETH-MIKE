from dataclasses import dataclass

from mike_analysis.core.metric_evaluator import RowType, MetricEvaluator
from mike_analysis.metrics.motor import MAPR, VelocitySD, NIJ
from mike_analysis.metrics.positional import MinRom, Rom
from mike_analysis.metrics.sensorimotor import RMSError


# TODO (other metrics)
# mean_abs_shift, mean_abs_peakdiff, std_peak_amplitude, NIJ, R^2

@dataclass
class _TrajectoryFollowingSeriesEvaluator(MetricEvaluator):
    trial_metrics = (
        RMSError(),
        MAPR(),
        MinRom(),
        Rom(),
        NIJ(),
        VelocitySD(),
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
