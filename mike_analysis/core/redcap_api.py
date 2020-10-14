import io
import sys
from typing import Dict, Tuple, List, Set, Optional

import pandas as pd
import requests

from mike_analysis.core.constants import SqlTypes, TColor

# For debugging, if set to true, export_records will read data from a file data.csv in the current working directory instead of
# downloading the data from the redcap API.
FAKE_DATA = False


class RedCap:
    """
    Class which provides a functional interface to retrieve data from the RedCap REST API.

    Only a subset of API calls is supported.
    To support additional APIs simply follow the same implementation pattern as for the other APIs
    (look at the redcap API playground to determine the required request parameters)
    """

    def __init__(self, api_url: str, token: str):
        """
        Create a new RedCap instance

        :param api_url: The url pointing to the redcap server (MAKE SURE TO USE *HTTPS*, NOT PLAIN HTTP, TO ENSURE DATA PRIVACY)
        :param token: RedCap API Token for the project you want to access.
                      Make sure the user account to which this token belongs has sufficient access rights.
        """
        if api_url.strip().startswith('http://'):
            print(f'{TColor.FAIL}WARNING: Your REDCAP_URL uses plain HTTP which is INSECURE in the general case. (USE HTTPS INSTEAD!)\n'
                  f'THIS MEANS THAT ALL THE DATA (INCLUDING YOUR API TOKEN) WILL BE SENT UNENCRYPTED OVER THE NETWORK/INTERNET\n'
                  f'AND CAN THUS BE READ OR TAMPERED WITH BY UNAUTHORIZED THIRD-PARTIES IN ANY NETWORK WHICH THIS CONNECTION TRAVERSES.{TColor.ENDC}')
            if input('\nI know what I am doing (e.g. this is a localhost connection for debugging) and wish to proceed [y/N]:').lower() != 'y':
                sys.exit(-42)

        self.api_url = api_url
        self.token = token

    def export_metadata(self, **kwargs) -> pd.DataFrame:
        """
        Use RedCap EXPORT_METADATA api to retrieve the data dictionary.

        The data dictionary stores metadata for each field defined in any form of the RedCap project.
        (e.g. field_name, form_name, field_type, text_validation_type_or_show_slider_number type, etc...)

        :param kwargs: additional arguments to include in the json request
        :return: dataframe corresponding to data dictionary in csv format
        """
        data = {
            'content': 'metadata',
            **kwargs
        }
        return self._post_request(data)

    def export_columns(self, redcap_excluded_fields: Set[str]) -> Dict[str, List[Tuple[str, str]]]:
        """
        Helper function which determines the database columns for each form table based on the data dictionary retrieved via export_metadata.

        Based on the data dictionary this function determines the sql data types for each redcap record field, to filters out
        unwanted columns (fields with notes and file types are ignored by default, in addition to all fields in redcap_excluded_fields),
        and group the columns by form/instrument (as different forms will be stored in different sql tables).
        Additionally, checkbox fields are replaced by multiple boolean columns which represent the state of the individual checkboxes
        (as is the case when data is retrieved via export_records).

        :param redcap_excluded_fields: fields from the data dict to ignore (apart from notes and file fields which are always ignored)
        :return: dictionary which maps form name to a list of (column name, column sql type) pairs
        """
        return self._columns_from_metadata(self.export_metadata(), redcap_excluded_fields)

    def export_event_map(self, **kwargs) -> pd.DataFrame:
        """
        Use RedCap EXPORT_INSTRUMENT_EVENT_MAP api to retrieve the mapping between instruments (forms) and events.

        e.g. if the event 'test1' contains the forms 'demographics', 'robotic_assessment', 'discharge_evaluation'
        and event 'test2' contains 'robotic_assessment', then the returned data frame will look like this:
        'unique_event_name' | 'form'
        -------------------------------------------
        test1               | demographics
        test1               | robotic_assessment
        test1               | discharge_evaluation
        test2               | robotic_assessment

        :param kwargs: additional arguments to include in the json request
        :return: dataframe which contains the columns ('arm_num', 'unique_event_name', 'form')
        """
        data = {
            'content': 'formEventMapping',
            **kwargs
        }
        return self._post_request(data)

    def export_repeating_events(self, **kwargs) -> pd.DataFrame:
        """
        Use RedCap EXPORT_REPEATING_INSTRUMENTS_AND_EVENTS api to return a dataframe which contains all repeating instruments and events.

        e.g. if the event 'test1' can be repeated and the form 'assessment' can be repeated inside event 'test2',
        then the returned data frame will look like this (blank form name -> repeating event):
        'event_name' | 'form_name'
        --------------------------
        test1        |
        test2        | assessment

        :param kwargs: additional arguments to include in the json request
        :return: dataframe which contains all repeating event and instrument (forms) names
        """

        data = {
            'content': 'repeatingFormsEvents',
            **kwargs
        }
        return self._post_request(data)

    def export_instruments(self, **kwargs) -> pd.DataFrame:
        """
        Use RedCap EXPORT_INSTRUMENTS api to get a list of all instruments used in this RedCap project.

        The resulting data frame contains two columns 'instrument_name' and 'instrument_label',
        where the former is the canonical name of the form which is used in all other API results and the latter
        is the display name of the form in the web interface.

        :param kwargs: additional arguments to include in the json request
        :return: Dataframe mapping instrument name to its display name ('instrument_name' column == all forms in this project)
        """
        data = {
            'content': 'instrument',
            **kwargs
        }
        return self._post_request(data)

    def export_records(self, date_cols: List[str], **kwargs) -> pd.DataFrame:
        """
        Use RedCap EXPORT_RECORDS api to download data records from redcap.

        The returned dataframe has the same rows/columns you get when you export the data to csv from the web interface.

        :param date_cols: which columns should be parsed as dates
        :param kwargs: additional arguments to include in the json request
        :return: dataframe with all redcap records
        """
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

    @staticmethod
    def _columns_from_metadata(data: pd.DataFrame, redcap_excluded_fields: Set[str]) -> Dict[str, List[Tuple[str, str]]]:
        """See documentation of export_columns."""
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
                # If you have e.g. a checkbox field 'handedness' with choices 'left' | 'right',
                # two columns 'handedness___1', 'handedness___2' of boolean type will be added to the columns, as this is how
                # export_records represents the selection
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

    def _post_request(self, req, date_cols: Optional[List[str]] = None) -> pd.DataFrame:
        """Helper function which sends the https request and parses the csv data of successful responses into a dataframe."""
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
