from dataclasses import dataclass

import numpy as np
import pandas as pd

from mike_analysis.core.meta import ForceCol, PosCol, SPosCol, TimeCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar
from mike_analysis.core.precomputer import PrecomputeDict
from mike_analysis.precomputers.derivatives import AbsVelocity, Jerk

speed_unit = 'deg/s'


@dataclass
class MaxVelocity(TrialMetric):
    name = 'MaxVelocity'
    bigger_is_better = True
    unit = speed_unit
    requires = (AbsVelocity,)

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        return precomputed[AbsVelocity].max()


@dataclass
class MaxNormalizedVelocity(TrialMetric):
    name = 'MaxVelocityNormalized'
    bigger_is_better = True
    unit = '1/s'
    requires = (AbsVelocity,)

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        abs_vel = precomputed[AbsVelocity]
        max_abs_v = abs_vel.max()
        data_at_max_v = trial_data[abs_vel == max_abs_v].head(1)
        return max_abs_v / (data_at_max_v[PosCol] - data_at_max_v[SPosCol]).abs().iloc[0]


@dataclass
class MAPR(TrialMetric):
    name = 'MAPR'
    bigger_is_better = False
    unit = ''
    requires = (AbsVelocity,)

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        abs_vel = precomputed[AbsVelocity]
        v_thresh = 0.2 * abs_vel.mean()
        mapr = (abs_vel < v_thresh).sum() / float(len(trial_data))
        return mapr


@dataclass
class VelocitySD(TrialMetric):
    name = 'VelocitySD'
    bigger_is_better = False
    unit = speed_unit
    requires = (AbsVelocity,)

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        return precomputed[AbsVelocity].std()


@dataclass
class MaxForce(TrialMetric):
    name = 'MaxForce'
    bigger_is_better = True
    unit = 'N'

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        return trial_data[ForceCol].abs().max()


class NIJ(TrialMetric):
    name = 'NIJ'
    bigger_is_better = False
    unit = ''
    requires = (AbsVelocity, Jerk,)

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        if (precomputed[AbsVelocity] < 0.05).sum() > len(trial_data) * 0.9:
            # Non moving patient
            return np.inf

        # Normalized jerk
        # \sqrt{\frac{1}{2} \cdot \frac{MD^5}{L^2} \cdot \int_{t_{start}}^{t_{end}}{jerk^2(t) dt}}
        # Where MD = movement duration, L = movement length, jerk = third derivative of position
        # Ref: "Impact of Time on Quality of Motor Control of the Paretic Upper Limb After Stroke" (Kordelaar, Wegen, Kwakkel, 2014)

        md = trial_data[TimeCol].iloc[-1]
        md_2 = md * md
        md_5 = md_2 * md_2 * md

        l = trial_data[PosCol].diff().abs().sum()
        l_2 = l * l

        jerk = precomputed[Jerk]
        jerk_2 = jerk * jerk

        nij = np.sqrt((md_5 / (2.0 * l_2)) * np.trapz(jerk_2, trial_data[TimeCol]))
        return nij
