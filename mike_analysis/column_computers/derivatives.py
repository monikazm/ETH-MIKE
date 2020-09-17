from dataclasses import dataclass
from typing import Iterable, ClassVar

import numpy as np
import pandas as pd
from scipy.signal import butter, filtfilt

from mike_analysis.core.meta import TimeCol, ForceCol, AbsVelCol, PosCol, DfDtCol, JerkCol
from mike_analysis.core.computed_columns import ColumnComputer


@dataclass(frozen=True)
class ForceDerivativeComputer(ColumnComputer):
    def _compute_column(self, data: pd.DataFrame, data_period: float) -> np.array:
        fc = 8.0
        [b, a] = butter(4, 2.0 * fc * data_period)
        df_dt = np.gradient(data[ForceCol], data[TimeCol])
        return filtfilt(b, a, df_dt)
DefaultForceDerivativeComputer = ForceDerivativeComputer(DfDtCol)


@dataclass(frozen=True)
class VelocityComputer(ColumnComputer):
    def _compute_column(self, data: pd.DataFrame, data_period: float) -> np.array:
        fc = 20.0
        [b, a] = butter(2, 2.0 * fc * data_period)
        pos_flt = filtfilt(b, a, data[PosCol])
        dp_dt = np.abs(np.gradient(pos_flt, data[TimeCol]))
        return filtfilt(b, a, dp_dt)
DefaultAbsVelocityComputer = VelocityComputer(AbsVelCol)


@dataclass(frozen=True)
class JerkComputer(ColumnComputer):
    column_dependencies: ClassVar[Iterable['ColumnComputer']] = (DefaultAbsVelocityComputer, )

    def _compute_column(self, data: pd.DataFrame, data_period: float) -> np.array:
        fc = 8.0
        [b, a] = butter(4, 2.0 * fc * data_period)

        # Compute acceleration
        accel = np.gradient(data[AbsVelCol], data[TimeCol])
        accel_flt = filtfilt(b, a, accel)

        # Compute jerk
        jerk = np.gradient(accel_flt, data[TimeCol])
        jerk_flt = filtfilt(b, a, jerk)

        return jerk_flt
DefaultJerkComputer = JerkComputer(JerkCol)
