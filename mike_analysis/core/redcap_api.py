import io
from typing import Dict, Tuple, List, Set, Optional

import pandas as pd
import requests

from mike_analysis.core.constants import SqlTypes

FAKE_DATA = False


class RedCap:
    def __init__(self, api_url: str, token: str):
        self.api_url = api_url
        self.token = token

    def export_metadata(self, **kwargs) -> pd.DataFrame:
        data = {
            'content': 'metadata',
            **kwargs
        }
        return self._post_request(data)

    def export_event_map(self, **kwargs) -> pd.DataFrame:
        data = {
            'content': 'formEventMapping',
            **kwargs
        }
        return self._post_request(data)

    def export_repeating_events(self, **kwargs) -> pd.DataFrame:
        data = {
            'content': 'repeatingFormsEvents',
            **kwargs
        }
        return self._post_request(data)

    def export_columns(self, redcap_excluded_fields: Set[str]) -> Dict[str, List[Tuple[str, str]]]:
        return self._columns_from_metadata(self.export_metadata(), redcap_excluded_fields)

    @staticmethod
    def _columns_from_metadata(data: pd.DataFrame, redcap_excluded_fields: Set[str]) -> Dict[str, List[Tuple[str, str]]]:
        redcap_columns = {}

        data = data.to_dict(orient='list')
        for field_type, form_name, field_name, select_choices, validation_type in zip(data['field_type'],
                                                                                      data['form_name'],
                                                                                      data['field_name'],
                                                                                      data['select_choices_or_calculations'],
                                                                                      data['text_validation_type_or_show_slider_number']):
            if field_type in ('file', 'notes') or field_name in redcap_excluded_fields:
                continue

            out_list = redcap_columns.setdefault(form_name, [])

            if field_type == 'checkbox':
                num_choices = select_choices.count('|') + 1
                for i in range(1, num_choices + 1):
                    out_list.append((f"{field_name}___{i}", SqlTypes.Bool))
            else:
                if validation_type == 'number':
                    sql_type = SqlTypes.Float
                elif validation_type == 'integer' or field_type in ('radio', 'dropdown'):
                    sql_type = SqlTypes.Integer
                elif field_type == 'yesno':
                    sql_type = SqlTypes.Bool
                elif validation_type == 'date_dmy':
                    sql_type = SqlTypes.Date
                elif field_type == 'text':
                    sql_type = SqlTypes.String
                else:
                    print(f'WARNING: Redcap datadict contains unhandled field type {field_name}')
                    sql_type = SqlTypes.String
                out_list.append((field_name, sql_type))
        return redcap_columns

    def export_instruments(self, **kwargs) -> pd.DataFrame:
        data = {
            'content': 'instrument',
            **kwargs
        }
        return self._post_request(data)

    def export_records(self, date_cols: List[str], **kwargs) -> pd.DataFrame:
        if FAKE_DATA:
            return pd.read_csv('data.csv', parse_dates=date_cols)
        else:
            data = {
                'content': 'record',
                'type': 'flat',
                'csvDelimiter': ',',
                'rawOrLabel': 'raw',
                'rawOrLabelHeaders': 'raw',
                'exportCheckboxLabel': 'false',
                'exportSurveyFields': 'false',
                'exportDataAccessGroups': 'false',
                'decimalCharacter': '.',
                **kwargs
            }
            return self._post_request(data, date_cols)

    def _post_request(self, req, date_cols: Optional[List[str]] = None) -> pd.DataFrame:
        date_cols = [] if date_cols is None else date_cols
        req_dict = {
            'token': self.token,
            'format': 'csv',
            'returnFormat': 'json'
        }
        req_dict.update(req)
        response = requests.post(self.api_url, data=req_dict)
        if not response.ok:
            raise RuntimeError('Invalid redcap http response')
        return pd.read_csv(io.StringIO(response.text), parse_dates=date_cols)
