from dataclasses import dataclass
from typing import Iterable, ClassVar

import numpy as np
import pandas as pd
from scipy.signal import butter, filtfilt

from mike_analysis.core.meta import TimeCol, ForceCol, PosCol
from mike_analysis.core.precomputer import ColumnPrecomputer, Precomputer, PrecomputeDict
from mike_analysis.precomputers.base_values import MeanPeriod

AbsVelCol = 'Velocity'
DfDtCol = 'dFdT'
JerkCol = 'Jerk'


@dataclass(frozen=True)
class ForceDerivativeComputer(ColumnPrecomputer):
    requires = (MeanPeriod,)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        b, a = self.get_default_filter(precomputed_values[MeanPeriod])
        df_dt = np.gradient(data[ForceCol], data[TimeCol])
        return filtfilt(b, a, df_dt)
ForceDerivative = ForceDerivativeComputer(DfDtCol)


@dataclass(frozen=True)
class VelocityComputer(ColumnPrecomputer):
    requires = (MeanPeriod,)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        fc = 20.0
        [b, a] = butter(2, 2.0 * fc * precomputed_values[MeanPeriod])
        pos_flt = filtfilt(b, a, data[PosCol])
        dp_dt = np.abs(np.gradient(pos_flt, data[TimeCol]))
        return filtfilt(b, a, dp_dt)
AbsVelocity = VelocityComputer(AbsVelCol)


@dataclass(frozen=True)
class JerkComputer(ColumnPrecomputer):
    requires = (MeanPeriod, AbsVelocity)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        b, a = self.get_default_filter(precomputed_values[MeanPeriod])

        # Compute acceleration
        accel = np.gradient(data[AbsVelCol], data[TimeCol])
        accel_flt = filtfilt(b, a, accel)

        # Compute jerk
        jerk = np.gradient(accel_flt, data[TimeCol])
        jerk_flt = filtfilt(b, a, jerk)

        return jerk_flt
Jerk = JerkComputer(JerkCol)
