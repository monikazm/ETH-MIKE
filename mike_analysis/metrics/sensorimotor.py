from dataclasses import dataclass
from math import sqrt

import numpy as np
import pandas as pd
import scipy.signal as sig

from mike_analysis.core.constants import PosCol, TPosCol, TimeCol, RowDict
from mike_analysis.core.metric import TrialMetric, Scalar
from mike_analysis.core.precomputer import PrecomputeDict

pos_unit = 'deg'


@dataclass
class RMSError(TrialMetric):
    name = 'RMSE'
    bigger_is_better = False
    unit = pos_unit

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowDict) -> Scalar:
        pos_delta = trial_data[TPosCol] - trial_data[PosCol]
        return sqrt((pos_delta * pos_delta).mean())


class MeanAbsPeakdiff(TrialMetric):
    name = 'MeanAbsPeakdiff'
    bigger_is_better = False
    unit = pos_unit

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowDict) -> Scalar:
        min_peak_dist = 5.3 / trial_data[TimeCol].diff().mean()
        target_peak_indices, _ = sig.find_peaks(trial_data[TPosCol], distance=min_peak_dist)
        actual_peak_indices, _ = sig.find_peaks(trial_data[PosCol], distance=min_peak_dist)

        target_peaks = trial_data[TPosCol].iloc[target_peak_indices].values
        if len(actual_peak_indices) <= 2:
            peak_diff = target_peaks - trial_data[PosCol].iloc[0]
        else:
            actual_peaks = trial_data[PosCol].iloc[actual_peak_indices].values
            if len(actual_peak_indices) >= len(target_peak_indices):
                peak_diff = target_peaks - actual_peaks[:len(target_peak_indices)]
            else:
                closest_peaks = np.argmin(np.abs(np.reshape(target_peaks, (len(target_peaks), 1)) - np.reshape(actual_peaks, (1, len(actual_peaks)))), axis=0)
                peak_diff = target_peaks[closest_peaks] - actual_peaks

        mean_abs_peakdiff = np.mean(np.abs(peak_diff))
        return mean_abs_peakdiff


class StdPeakAmplitude(TrialMetric):
    name = 'StdPeakAmplitude'
    bigger_is_better = True
    unit = pos_unit

    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowDict) -> Scalar:
        min_peak_dist = 5.3 / trial_data[TimeCol].diff().mean()
        peaks, _ = sig.find_peaks(trial_data[PosCol], distance=min_peak_dist)
        std_peak_amplitude = trial_data[PosCol].iloc[peaks].std()
        return std_peak_amplitude
