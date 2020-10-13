from typing import Dict

from mike_analysis.core.constants import Modes as _Modes
from mike_analysis.core.metric_evaluator import MetricEvaluator as _MetricEvaluator

from .rom import RomEvaluator
from .force import ForceEvaluator
from .pos_match import PositionMatchingEvaluator
from .precise_reaching import PreciseReachingEvaluator
from .fast_reaching import FastReachingEvaluator
from .trajectory_following import TrajectoryFollowingEvaluator

metric_evaluator_for_mode: Dict[_Modes, _MetricEvaluator] = {
    _Modes.RangeOfMotion: RomEvaluator(),
    _Modes.Force: ForceEvaluator(),
    _Modes.PositionMatch: PositionMatchingEvaluator(),
    _Modes.TargetFollowing: TrajectoryFollowingEvaluator(),
    _Modes.TargetReaching: FastReachingEvaluator(),
    _Modes.PreciseReaching: PreciseReachingEvaluator()
}
