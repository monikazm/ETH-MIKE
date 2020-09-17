from dataclasses import dataclass

import numpy as np
import pandas as pd
import scipy.optimize as opt

from mike_analysis.column_computers.derivatives import DefaultAbsVelocityComputer, DefaultJerkComputer
from mike_analysis.core.meta import AbsVelCol, ForceCol, PosCol, SPosCol, TimeCol, JerkCol
from mike_analysis.core.metric import TrialMetric, RowType, Scalar


@dataclass
class MaxVelocity(TrialMetric):
    name = 'MaxVelocity'
    required_column_computers = (DefaultAbsVelocityComputer,)

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[AbsVelCol].max()


@dataclass
class MaxNormalizedVelocity(TrialMetric):
    name = 'MaxVelocityNormalized'
    required_column_computers = (DefaultAbsVelocityComputer,)

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        abs_vel = trial_data.loc[:, AbsVelCol]
        max_abs_v = abs_vel.max()
        data_at_max_v = trial_data[abs_vel == max_abs_v].head(1)
        return max_abs_v / (data_at_max_v[PosCol] - data_at_max_v[SPosCol]).abs().iloc[0]


@dataclass
class MAPR(TrialMetric):
    name = 'MAPR'
    required_column_computers = (DefaultAbsVelocityComputer,)

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        v_thresh = 0.2 * trial_data[AbsVelCol].mean()
        mapr = (trial_data[AbsVelCol] < v_thresh).sum() / float(len(trial_data))
        return mapr


@dataclass
class VelocitySD(TrialMetric):
    name = 'VelocitySD'
    required_column_computers = (DefaultAbsVelocityComputer,)

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[AbsVelCol].std()


@dataclass
class MaxForce(TrialMetric):
    name = 'MaxForce'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        return trial_data[ForceCol].abs().max()


class NIJ(TrialMetric):
    name = 'NIJ'
    required_column_computers = (DefaultAbsVelocityComputer, DefaultJerkComputer, )

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        if (trial_data[AbsVelCol] < 0.05).sum() > len(trial_data) * 0.9:
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

        jerk = trial_data[JerkCol]
        jerk_2 = jerk * jerk

        nij = np.sqrt((md_5 / (2.0 * l_2)) * np.trapz(jerk_2, trial_data[TimeCol]))
        return nij


class R2(TrialMetric):
    name = 'R2'

    def compute_single_trial(self, trial_data: pd.DataFrame, db_trial_result: RowType) -> Scalar:
        pass
