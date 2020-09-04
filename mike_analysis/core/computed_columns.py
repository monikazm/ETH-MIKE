from abc import ABCMeta, abstractmethod
from dataclasses import dataclass

import numpy as np
import pandas as pd


@dataclass(frozen=True)
class ColumnComputer(metaclass=ABCMeta):
    col_name: str

    def add_column_to(self, data: pd.DataFrame):
        data[self.col_name] = self._compute_column(data)

    @abstractmethod
    def _compute_column(self, data: pd.DataFrame) -> np.array:
        pass
