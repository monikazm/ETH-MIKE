import unittest

import pandas as pd
from numpy.testing import assert_equal, assert_almost_equal

from mike_analysis.core.file_processor import _read_tdms_file, preprocess_and_split_trials
from mike_analysis.core.meta import RomPhase
from mike_analysis.precomputers.derivatives import AbsVelocity, Velocity
from mike_analysis.tests import test_data_folder


class TdmsTests(unittest.TestCase):
    def test_tdms_read(self):
        expected = pd.read_csv(test_data_folder.joinpath('test_rom.csv')) # This csv was manually created using the Excel importer on test_rom.tdms
        tdms_data = _read_tdms_file(test_data_folder.joinpath('test_rom.tdms'))

        # Test if column names correct
        assert_equal(tdms_data.columns.values, expected.columns.values)

        # Test if data matches (The match is not perfect, possibly due to slight numerical differences in Excel/tdms reader)
        assert_almost_equal(tdms_data.values, expected.values, decimal=13)

    def test_trial_splitting(self):
        tdms_data = _read_tdms_file(test_data_folder.joinpath('test_rom.tdms'))
        tdms_trials = preprocess_and_split_trials(tdms_data, True, [Velocity, AbsVelocity], filter_position=False)
        i = 0

        for phase in RomPhase:
            for trial in (1, 2, 3):
                expected = pd.read_csv(test_data_folder.joinpath('test_rom_trials').joinpath(f'test_rom_{phase}_{trial}.csv'))

                # Check if the data matches the csv data which which was manually created with Excel
                self.assertTrue(all(col in tdms_trials[i].columns.values for col in expected.columns.values))
                assert_almost_equal(tdms_trials[i].loc[:, expected.columns].values, expected.values, decimal=11)
                i += 1


if __name__ == '__main__':
    unittest.main()
