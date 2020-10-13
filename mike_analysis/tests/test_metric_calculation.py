import unittest
from typing import Callable

import numpy as np
import pandas as pd

from mike_analysis.core.constants import TimeCol, PosCol, ForceCol
from mike_analysis.metrics.motor import MaxVelocity, MAPR, MaxForce, NIJ
from mike_analysis.precomputers.derivatives import AbsVelocity


class MetricTests(unittest.TestCase):
    # Motor

    def test_max_velocity(self):
        metric = MaxVelocity()
        trial_data, precomp = self.generate_trajectory(30.0, lambda t: -0.125 * np.power(t, 3) + 0.482143 * np.square(t) + 1.60714 * t - 2.2, 6.2)
        max_v = metric.compute_single_trial(trial_data, precomp, None)
        self.assertAlmostEqual(max_v, 4.0158, places=4)

    def test_max_norm_velocity(self):
        pass

    def test_mapr(self):
        metric = MAPR()
        trial_data, precomp = self.generate_trajectory(30.0, lambda t: np.concatenate((t[t <= 3.0] * 0.1, t[t > 3.0] * -5)), 6.001)
        mapr = metric.compute_single_trial(trial_data, precomp, None)
        self.assertAlmostEqual(mapr, 0.5, places=4)

    def test_max_force(self):
        metric = MaxForce()
        trial_data = pd.DataFrame({ForceCol: [-0.5, 3, 2, 5, -10, 0]})
        max_force = metric.compute_single_trial(trial_data, None, None)
        self.assertEqual(max_force, 10.0)

    def test_nij(self):
        metric = NIJ()

        md = 5.0
        l = 20.0
        trial_data, precomp = self.generate_trajectory(30.0, lambda t: np.concatenate((t[t <= 3.0] * 0.1, t[t > 3.0] * -5)), md)

        pass

    # Positional

    def test_pos_error(self):
        raise NotImplementedError()

    def test_abs_pos_error(self):
        raise NotImplementedError()

    def test_abs_pos_error_at_ss(self):
        raise NotImplementedError()

    def test_min_rom(self):
        raise NotImplementedError()

    def test_max_rom(self):
        raise NotImplementedError()

    def test_rom(self):
        raise NotImplementedError()

    # Sensorimotor

    def test_rmse(self):
        raise NotImplementedError()

    def test_mean_abs_peakdiff(self):
        raise NotImplementedError()

    def test_std_peak_amplitude(self):
        raise NotImplementedError()

    # Temporal

    def test_force_rt(self):
        raise NotImplementedError()

    def test_movement_rt(self):
        raise NotImplementedError()

    # Summary

    def test_num_trials(self):
        raise NotImplementedError()

    def test_pos_match_rmse(self):
        raise NotImplementedError()

    def test_nr_no_target_trials(self):
        raise NotImplementedError()

    @staticmethod
    def generate_trajectory(start_pos: float, v_func: Callable[[np.ndarray], np.ndarray], duration: float):
        t = np.linspace(0.0, duration, num=int(duration * 1000.0 + 1.0))
        v = v_func(t)
        p = start_pos + np.cumsum(v * 0.001)
        return pd.DataFrame({TimeCol: t, PosCol: p}), {AbsVelocity: pd.Series(np.abs(v))}


if __name__ == '__main__':
    unittest.main()
