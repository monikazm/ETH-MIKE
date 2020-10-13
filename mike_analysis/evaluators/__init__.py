from typing import Dict, Tuple, List

from mike_analysis.core.constants import Modes as _Modes
from mike_analysis.core.metric_evaluator import MetricEvaluator as _MetricEvaluator
from mike_analysis.core.precomputer import ColumnPrecomputer as _ColumnPrecomputer, ValuePrecomputer as _ValuePrecomputer

from .fast_reaching import FastReachingEvaluator
from .force import ForceEvaluator
from .pos_match import PositionMatchingEvaluator
from .precise_reaching import PreciseReachingEvaluator
from .rom import RomEvaluator
from .trajectory_following import TrajectoryFollowingEvaluator

metric_evaluator_for_mode: Dict[_Modes, _MetricEvaluator] = {
    _Modes.RangeOfMotion: RomEvaluator(),
    _Modes.Force: ForceEvaluator(),
    _Modes.PositionMatch: PositionMatchingEvaluator(),
    _Modes.TargetFollowing: TrajectoryFollowingEvaluator(),
    _Modes.TargetReaching: FastReachingEvaluator(),
    _Modes.PreciseReaching: PreciseReachingEvaluator()
}

required_precomputations_for_mode: Dict[_Modes, Tuple[List[_ColumnPrecomputer], List[_ValuePrecomputer]]] = {
    mode: ([dep for dep in evaluator.get_precompute_dependencies() if isinstance(dep, _ColumnPrecomputer)],
           [dep for dep in evaluator.get_precompute_dependencies() if not isinstance(dep, _ColumnPrecomputer)])
    for mode, evaluator in metric_evaluator_for_mode.items()
}
