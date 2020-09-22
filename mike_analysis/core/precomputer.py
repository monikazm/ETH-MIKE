from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from typing import Iterable, OrderedDict, ClassVar, Union, Dict, Tuple

import numpy as np
import pandas as pd
from scipy.signal import butter

PrecomputedValue = Union[float, int, bool, np.array]


@dataclass(frozen=True)
class Precomputer(metaclass=ABCMeta):
    requires: ClassVar[Iterable['Precomputer']] = ()

    def add_to(self, precomputers: OrderedDict):
        for required_computer in self.requires:
            required_computer.add_to(precomputers)
        precomputers[self] = None

    @staticmethod
    def get_default_filter(period: float) -> Tuple[np.ndarray, np.ndarray]:
        #fc = 8.0
        #b, a = butter(4, 2.0 * fc * period)
        fc = 20.0
        b, a = butter(2, 2.0 * fc * period)
        return b, a

    @abstractmethod
    def precompute_for(self, data: pd.DataFrame, precomputed_values: 'PrecomputeDict'):
        pass


@dataclass(frozen=True)
class ValuePrecomputer(Precomputer, metaclass=ABCMeta):
    def precompute_for(self, data: pd.DataFrame, precomputed_values: 'PrecomputeDict'):
        precomputed_values[self] = self._compute_value(data, precomputed_values)

    @abstractmethod
    def _compute_value(self, data: pd.DataFrame, precomputed_values: 'PrecomputeDict') -> PrecomputedValue:
        pass


@dataclass(frozen=True)
class ColumnPrecomputer(Precomputer, metaclass=ABCMeta):
    col_name: str

    def precompute_for(self, data: pd.DataFrame, precomputed_values: 'PrecomputeDict'):
        assert self not in precomputed_values
        data[self.col_name] = self._compute_column(data, precomputed_values)
        precomputed_values[self] = data[self.col_name]

    @abstractmethod
    def _compute_column(self, data: pd.DataFrame, precomputed_values: 'PrecomputeDict') -> np.array:
        pass


PrecomputeDict = Dict[Precomputer, PrecomputedValue]
