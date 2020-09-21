from dataclasses import dataclass

import pandas as pd

from mike_analysis.core.meta import TimeCol
from mike_analysis.core.precomputer import ValuePrecomputer, PrecomputedValue, PrecomputeDict


@dataclass(frozen=True)
class MeanPeriodComputer(ValuePrecomputer):
    def _compute_value(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> PrecomputedValue:
        period = data[TimeCol].diff().mean()
        return period
MeanPeriod = MeanPeriodComputer()
