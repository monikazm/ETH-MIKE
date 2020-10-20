from dataclasses import dataclass

import numpy as np
import pandas as pd
from scipy.signal import filtfilt

from mike_analysis.core.constants import TimeCol, ForceCol, PosCol
from mike_analysis.core.precomputer import ColumnPrecomputer, PrecomputeDict


@dataclass(frozen=True)
class ForceDerivativeComputer(ColumnPrecomputer):
    def _compute_column(self, data: pd.DataFrame, precomputed_columns: PrecomputeDict, fs: float) -> np.array:
        b, a = self.get_filter(fs)
        df_dt = np.gradient(data[ForceCol], data[TimeCol])
        df_dt_flt = filtfilt(b, a, df_dt)
        return df_dt_flt
ForceDerivative = ForceDerivativeComputer('dFdT')


@dataclass(frozen=True)
class VelocityComputer(ColumnPrecomputer):
    def _compute_column(self, data: pd.DataFrame, precomputed_columns: PrecomputeDict, fs: float) -> np.array:
        dp_dt = np.gradient(data[PosCol], data[TimeCol])

        b, a = self.get_filter(fs)
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
    requires = (Velocity,)

    def _compute_column(self, data: pd.DataFrame, precomputed_columns: PrecomputeDict, fs: float) -> np.array:
        return np.abs(precomputed_columns[Velocity])
AbsVelocity = AbsVelocityComputer('AbsVelocity')


@dataclass(frozen=True)
class JerkComputer(ColumnPrecomputer):
    requires = (Velocity,)

    def _compute_column(self, data: pd.DataFrame, precomputed_columns: PrecomputeDict, fs: float) -> np.array:
        b, a = self.get_filter(fs)

        # Compute acceleration
        accel = np.gradient(precomputed_columns[Velocity], data[TimeCol])
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
