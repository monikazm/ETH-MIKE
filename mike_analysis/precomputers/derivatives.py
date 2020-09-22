from dataclasses import dataclass

import numpy as np
import pandas as pd
from scipy.signal import filtfilt

from mike_analysis.core.meta import TimeCol, ForceCol, PosCol
from mike_analysis.core.precomputer import ColumnPrecomputer, PrecomputeDict
from mike_analysis.precomputers.base_values import MeanPeriod


@dataclass(frozen=True)
class ForceDerivativeComputer(ColumnPrecomputer):
    requires = (MeanPeriod,)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        b, a = self.get_default_filter(precomputed_values[MeanPeriod])
        df_dt = np.gradient(data[ForceCol], data[TimeCol])
        df_dt_flt = filtfilt(b, a, df_dt)
        return df_dt_flt
ForceDerivative = ForceDerivativeComputer('dFdT')


@dataclass(frozen=True)
class VelocityComputer(ColumnPrecomputer):
    requires = (MeanPeriod,)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        b, a = self.get_default_filter(precomputed_values[MeanPeriod])
        dp_dt = np.gradient(data[PosCol], data[TimeCol])
        dp_dt_flt = filtfilt(b, a, dp_dt)
        return np.abs(dp_dt_flt)
AbsVelocity = VelocityComputer('AbsVelocity')


@dataclass(frozen=True)
class JerkComputer(ColumnPrecomputer):
    requires = (MeanPeriod, AbsVelocity)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        b, a = self.get_default_filter(precomputed_values[MeanPeriod])

        # Compute acceleration
        accel = np.gradient(precomputed_values[AbsVelocity], data[TimeCol])
        accel_flt = filtfilt(b, a, accel)

        # Compute jerk
        jerk = np.gradient(accel_flt, data[TimeCol])
        jerk_flt = filtfilt(b, a, jerk)

        return jerk_flt
Jerk = JerkComputer('Jerk')
