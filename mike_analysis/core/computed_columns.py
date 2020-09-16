from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from typing import Iterable, OrderedDict, ClassVar

import numpy as np
import pandas as pd


@dataclass(frozen=True)
class ColumnComputer(metaclass=ABCMeta):
    col_name: str
    column_dependencies: ClassVar[Iterable['ColumnComputer']] = ()

    def add_computer_to(self, column_computers: OrderedDict):
        for column_dep in self.column_dependencies:
            column_dep.add_computer_to(column_computers)
        column_computers[self] = None

    def add_column_to(self, data: pd.DataFrame, data_period: float):
        data[self.col_name] = self._compute_column(data, data_period)

    @abstractmethod
    def _compute_column(self, data: pd.DataFrame, data_period: float) -> np.array:
        pass
