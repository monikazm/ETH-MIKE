from abc import ABCMeta, abstractmethod
from dataclasses import dataclass
from typing import Iterable, OrderedDict, ClassVar, Dict, Tuple, Any

import numpy as np
import pandas as pd
from scipy.signal import butter


@dataclass(frozen=True)
class Precomputer(metaclass=ABCMeta):
    requires: ClassVar[Iterable['Precomputer']] = ()
    """
    List of precomputers (columns and values) which are required to evaluate this precomputer

    The system ensures that the columns/values corresponding to the precomputers in the precomputer's
    requires field are precomputed once and passed to the precomputer during evaluation as PrecomputeDict.

    Note: The developer must ensure that there are no cyclic dependencies.
    Note: ColumnPrecomputers cannot require ValuePrecomputers (as they are computed before them).
    """

    def add_to(self, precomputers: OrderedDict):
        for required_computer in self.requires:
            required_computer.add_to(precomputers)
        precomputers[self] = None

    @staticmethod
    def get_filter(fs: float, fc: float = 8.0, deg=4) -> Tuple[np.ndarray, np.ndarray]:
        b, a = butter(deg, fc, fs=fs)
        return b, a


@dataclass(frozen=True)
class ValuePrecomputer(Precomputer, metaclass=ABCMeta):
    """A Precomputer which precomputes an arbitrary value/series/dict/list for each trial."""

    @abstractmethod
    def precompute_value(self, data: pd.DataFrame, precomputed: 'PrecomputeDict') -> Any:
        """
        Precompute value for the given trial data frame (only TS = 1 rows for one trial, time starting at 0.0)

        :param data: data frame for a single trial (only TargetState = 1 rows, time starting at 0.0)
               e.g.   Force | Position | TargetPosition | ...
                    -----------------------------------------
                (0)  23.4   | 2.31     | 30.0           | ...
                (1)  33.1   |   ....   |   ....         | ...
        :param precomputed: mapping precomputer -> column/value for other values and columns which have been precomputed so far
                            (the system should guarantee that other precomputers which are mentioned in the requires field of this
                             precomputer have already been precomputed and that their values are accessible via this dictionary)
        :return: an arbitrary value which this precomputer precomputed for this trial
        """
        pass


@dataclass(frozen=True)
class ColumnPrecomputer(Precomputer, metaclass=ABCMeta):
    """
    A Precomputer which precomputes an additional column for the full raw data frame
    (all trials, same number of elements as rows in tdms data).

    Note. ColumnPrecomputers cannot require ValuePrecomputers.
    """

    col_name: str
    """Column name to use when adding the precomputed column to the data frame (must not conflict with other column names)"""

    def precompute_df_column(self, data: pd.DataFrame, precomputed_columns: 'PrecomputeDict', fs: float) -> pd.Series:
        """
        Precompute and add an additional column to the data frame 'data' (same number of rows), return the new column.

        :param data: full raw data frame (data for all trials for one assessment, no matter if target state true)
                     e.g. Time | Trial | TargetState | RomState | Pos  | StartingPos | TargetPos | Force
                          -----------------------------------------------------------------------------
                          2.123|    1  |      0      |    0     | 12.2 |  70.0      |    30.0   | 0123.2
                          ..     ....     ....           ...      ...     ...           ...        ...
        :param precomputed_columns: mapping precomputer -> column series for other columns which have been precomputed so far
                                    (the system should guarantee that other column precomputers which are mentioned in the
                                     requires field of this precomputer have already been precomputed and
                                     that their values are accessible via this dictionary)
        :param fs: estimated sampling rate of the raw data in 'data'
        :return: A pandas series corresponding to the new column
        """
        assert self not in precomputed_columns
        data[self.col_name] = self._compute_column(data, precomputed_columns, fs)
        return data[self.col_name]

    @abstractmethod
    def _compute_column(self, data: pd.DataFrame, precomputed_columns: 'PrecomputeDict', fs: float) -> np.array:
        """
        Precompute vector/array with as many elements as there are rows in the given data frame.

        :param data: full raw data frame (data for all trials for one assessment, no matter if target state true)
        :param precomputed_columns: mapping precomputer -> column series for other columns which have been precomputed so far
        :param fs: estimated sampling rate of the raw data in 'data'
        :return: numpy array of size rowcount(data)
        """
        pass


PrecomputeDict = Dict[Precomputer, Any]
"""Type representing a mapping from Precomputer object/instance to the corresponding precomputed column or value"""
