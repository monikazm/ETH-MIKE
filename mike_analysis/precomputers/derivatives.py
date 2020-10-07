from dataclasses import dataclass

import numpy as np
import pandas as pd
from scipy.signal import filtfilt

from mike_analysis.core.meta import TimeCol, ForceCol, PosCol
from mike_analysis.core.precomputer import ColumnPrecomputer, PrecomputeDict
from mike_analysis.precomputers.base_values import SamplingRate


@dataclass(frozen=True)
class ForceDerivativeComputer(ColumnPrecomputer):
    requires = (SamplingRate,)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        b, a = self.get_filter(precomputed_values[SamplingRate])
        df_dt = np.gradient(data[ForceCol], data[TimeCol])
        df_dt_flt = filtfilt(b, a, df_dt)
        return df_dt_flt
ForceDerivative = ForceDerivativeComputer('dFdT')


@dataclass(frozen=True)
class VelocityComputer(ColumnPrecomputer):
    requires = (SamplingRate,)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        dp_dt = np.gradient(data[PosCol], data[TimeCol])

        b, a = self.get_filter(precomputed_values[SamplingRate])
        dp_dt_flt = filtfilt(b, a, dp_dt)
        # import matplotlib.pyplot as plt
        # plt.plot(data[TimeCol], dp_dt, label='unfiltered')
        # plt.plot(data[TimeCol], dp_dt_flt, label='filtered')
        # plt.legend()
        # plt.title('v')
        # plt.show()
        return dp_dt_flt
Velocity = VelocityComputer('Velocity')


@dataclass(frozen=True)
class AbsVelocityComputer(ColumnPrecomputer):
    requires = (SamplingRate, Velocity,)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        return np.abs(precomputed_values[Velocity])
AbsVelocity = AbsVelocityComputer('AbsVelocity')


@dataclass(frozen=True)
class JerkComputer(ColumnPrecomputer):
    requires = (SamplingRate, Velocity,)

    def _compute_column(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> np.array:
        b, a = self.get_filter(precomputed_values[SamplingRate])

        # Compute acceleration
        accel = np.gradient(precomputed_values[Velocity], data[TimeCol])
        accel_flt = filtfilt(b, a, accel)

        # import matplotlib.pyplot as plt
        # plt.plot(data[TimeCol], accel, label='unfiltered')
        # plt.plot(data[TimeCol], accel_flt, label='filtered')
        # plt.title('accel')
        # plt.legend()

        # Compute jerk
        jerk = np.gradient(accel_flt, data[TimeCol])
        jerk_flt = filtfilt(b, a, jerk)

        # plt.plot(data[TimeCol], jerk, label='unfiltered')
        # plt.plot(data[TimeCol], jerk_flt, label='filtered')
        # plt.title('jerk')
        # plt.legend()
        #
        # plt.show()

        return jerk_flt
Jerk = JerkComputer('Jerk')
