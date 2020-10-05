import unittest

import pandas as pd

from mike_analysis.cfg import config as cfg
from mike_analysis.core.redcap_api import RedCap
from mike_analysis.tests import test_data_folder


class RedcapTests(unittest.TestCase):
    rc = RedCap(api_url=cfg.REDCAP_URL, token=cfg.RECAP_API_TOKEN)

    def test_datadict_export(self):
        self.rc.export_metadata()

    def test_column_extraction(self):
        data = pd.read_csv(test_data_folder.joinpath('test_datadict.csv'))
        exported_data = data[(data['field_type'] != 'file') & (data['field_type'] != 'notes') & (data['field_type'] != 'checkbox')]
        checkbox_values = data[data['field_type'] == 'checkbox']

        # All fields except notes and files were extracted
        columns = self.rc._columns_from_metadata(data, set(checkbox_values['field_name'].values))
        all_fields = [name_type[0] for form, values in columns.items() for name_type in values]
        self.assertListEqual(sorted(exported_data['field_name'].values), sorted(all_fields))

        # All values associated with correct form
        for form, values in columns.items():
            self.assertListEqual(sorted(exported_data[exported_data['form_name'] == form]['field_name'].values), sorted([n for n, _ in values]))

        # Ignored fields are not included
        columns = self.rc._columns_from_metadata(data, {'nr_right_omissions'} | set(checkbox_values['field_name'].values))
        all_fields = [name_type[0] for form, values in columns.items() for name_type in values]
        self.assertEqual(len(exported_data[exported_data['field_name'] == 'nr_right_omissions']), 1)
        self.assertListEqual(sorted(exported_data[exported_data['field_name'] != 'nr_right_omissions']['field_name'].values), sorted(all_fields))

        # Correct handling of checkbox entries
        columns = self.rc._columns_from_metadata(data, set(data[data['field_type'] != 'checkbox']['field_name'].values))
        all_fields = [name_type[0] for form, values in columns.items() for name_type in values]
        column_fields = [f"{row['field_name']}___{n}" for _, row in checkbox_values.iterrows() for n in range(1, row['select_choices_or_calculations'].count('|')+2)]
        self.assertListEqual(sorted(column_fields), sorted(all_fields))

    def test_instrument_export(self):
        self.rc.export_instruments()

    def test_event_map_export(self):
        self.rc.export_event_map()

    def test_repeating_events_export(self):
        self.rc.export_repeating_events()

    def test_record_export(self):
        self.rc.export_records([])


if __name__ == '__main__':
    unittest.main()
