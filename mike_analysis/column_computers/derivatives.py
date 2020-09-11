from dataclasses import dataclass

import numpy as np
import pandas as pd
from scipy.signal import butter, filtfilt

from mike_analysis.core.meta import TimeCol, ForceCol, VelCol, PosCol, DfDtCol
from mike_analysis.core.computed_columns import ColumnComputer


@dataclass(frozen=True)
class ForceDerivativeComputer(ColumnComputer):
    def _compute_column(self, data: pd.DataFrame) -> np.array:
        fs = 1.0 / np.mean(data[TimeCol].diff())
        fc = 8.0
        [b, a] = butter(4, fc / (fs / 2.0))
        df_dt = data[ForceCol].diff() / data[TimeCol].diff()
        df_dt.iloc[0] = df_dt.iloc[1]
        return filtfilt(b, a, df_dt)


@dataclass(frozen=True)
class VelocityComputer(ColumnComputer):
    def _compute_column(self, data: pd.DataFrame) -> np.array:
        fs = 1.0 / np.mean(data[TimeCol].diff())
        fc = 20.0
        [b, a] = butter(2, fc / (fs / 2.0))
        data[VelCol] = filtfilt(b, a, data[PosCol])
        dp_dt = data[VelCol].diff() / data[TimeCol].diff()
        dp_dt.iloc[0] = dp_dt.iloc[1]
        return filtfilt(b, a, dp_dt.abs())


DefaultForceDerivativeComputer = ForceDerivativeComputer(DfDtCol)
DefaultAbsVelocityComputer = VelocityComputer(VelCol)
