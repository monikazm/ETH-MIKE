import unittest
from typing import Tuple, Callable

import numpy as np
from numpy.testing import assert_almost_equal
import pandas as pd
import sympy as sym
from scipy.signal import filtfilt

#import matplotlib.pyplot as plt

from mike_analysis.core.constants import PosCol, TimeCol, ForceCol
from mike_analysis.core.file_processing import estimate_sampling_rate
from mike_analysis.core.precomputer import Precomputer
from mike_analysis.precomputers.derivatives import AbsVelocity, ForceDerivative, Jerk, Velocity

sampling_rate = 1000.0


class PrecomputationTests(unittest.TestCase):
    @staticmethod
    def _compute_nth_derivative(movement_duration, fct, n=1) -> Tuple[np.ndarray, Callable[[np.ndarray], np.ndarray], np.ndarray]:
        # Compute symbolic derivative
        x = sym.Symbol('x')
        y = fct(x)
        dy_dx = y.diff(x, n)

        # Compute exact y with ms resolution
        t_vals = np.linspace(0.0, movement_duration, num=int(movement_duration * sampling_rate + 1.0))
        dydx_fct = sym.lambdify(x, dy_dx)
        dy_dx_exact = dydx_fct(t_vals)
        y_fct = sym.lambdify(x, y)

        return t_vals, y_fct, dy_dx_exact

    def test_force_deriv(self):
        t, f, df_dt_exact = self._compute_nth_derivative(5.0, lambda t: -3.0 * (t ** 3) + 0.5 * (t ** 2) + 10 * t - 2.5)
        data = pd.DataFrame({TimeCol: t, ForceCol: f(t)})
        fs = estimate_sampling_rate(data)
        abs_dfdt = ForceDerivative._compute_column(data, {}, fs)
        abs_dfdt, df_dt_exact = abs_dfdt[100:-100], df_dt_exact[100:-100] # restrict range to ignore filtering boundary artifacts

        # Check if computed velocity roughly matches symbolic solution (will not be equal due to numerical differentiation and filtering)
        assert_almost_equal(abs_dfdt, df_dt_exact, decimal=0)
        assert_almost_equal(np.mean(abs_dfdt), np.mean(df_dt_exact), decimal=3)

    def test_velocity(self):
        t, p, v_exact = self._compute_nth_derivative(5.0, lambda t: -3.0 * (t ** 3) + 0.5 * (t ** 2) + 10 * t - 2.5)
        data = pd.DataFrame({TimeCol: t, PosCol: p(t)})
        fs = estimate_sampling_rate(data)
        v = Velocity._compute_column(data, {}, fs)
        v, v_exact = v[100:-100], v_exact[100:-100] # restrict range to ignore filtering boundary artifacts

        # Check if computed velocity roughly matches symbolic solution (will not be equal due to numerical differentiation and filtering)
        assert_almost_equal(v, v_exact, decimal=0)
        assert_almost_equal(np.mean(v), np.mean(v_exact), decimal=3)

        abs_v_exact = np.abs(v_exact)
        abs_v = AbsVelocity._compute_column(None, {Velocity: v}, fs)

        # Check if computed velocity roughly matches symbolic solution (will not be equal due to numerical differentiation and filtering)
        assert_almost_equal(abs_v, abs_v_exact, decimal=0)
        assert_almost_equal(np.mean(abs_v), np.mean(abs_v_exact), decimal=3)

    def test_jerk(self):
        b, a = Precomputer.get_filter(sampling_rate, fc=20.0, deg=2)

        t, p, jerk_exact = self._compute_nth_derivative(5.0, lambda t: 15.0 * (sym.sin(2.0*sym.pi*t/5.0) + sym.sin(2.0*sym.pi*3*t/5.0)), n=3)
        t_full = np.linspace(-5.0, 10.0, 1000*15 + 1)
        p_in = filtfilt(b, a, p(t_full))# + np.random.normal(0, 0.0001, len(t_full)))

        data = pd.DataFrame({TimeCol: t_full, PosCol: p_in})
        fs = estimate_sampling_rate(data)
        v = Velocity._compute_column(data, {}, fs)
        jerk = Jerk._compute_column(data, {Velocity: v}, fs)

        # Check if computed velocity roughly matches symbolic solution (will not be equal due to numerical differentiation and filtering)
        assert_almost_equal(jerk[5000:-5000], jerk_exact, decimal=2)
        assert_almost_equal(np.mean(jerk[5000:-5000]), np.mean(jerk_exact), decimal=6)


if __name__ == '__main__':
    unittest.main()
