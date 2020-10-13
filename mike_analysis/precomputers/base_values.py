from dataclasses import dataclass

import pandas as pd

from mike_analysis.core.constants import TimeCol
from mike_analysis.core.precomputer import ValuePrecomputer, PrecomputedValue, PrecomputeDict


@dataclass(frozen=True)
class SamplingRateComputer(ValuePrecomputer):
    def _compute_value(self, data: pd.DataFrame, precomputed_values: PrecomputeDict) -> PrecomputedValue:
        fs = 1.0 / data[TimeCol].diff().median()
        return fs
SamplingRate = SamplingRateComputer()
