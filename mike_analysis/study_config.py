# This file may need to be adapted for different studies with different redcap tables
from mike_analysis.core.constants import RCCols
from mike_analysis.core.table_migrator import TableMigrator

REDCAP_RECORD_IDENTIFIER = 'study_id'
REDCAP_EXCLUDED_COLS = {'gender', 'handedness', 'impaired_side', 'details_on_stroke', 'date_mri', 'lesion_location_detailed'}
REDCAP_NAMES_AND_INDEX_COLS = {
    'demographics_5760': ('Demographics', ['subject_code']),
    'clinical_assessments': ('ClinicalAssessment', []),
    'robotic_assessments': ('RoboticAssessment', ['robotic_session_number']),
    'neurophysiology': ('Neurophysiology', []),
}


def create_additional_views(migrator: TableMigrator, metric_names: str):
    """In this function you can create additional views in the output database if needed."""

    # Create additional views
    if migrator.out_has_tables([val[0] for _, val in REDCAP_NAMES_AND_INDEX_COLS.items()]):
        def create_redcap_view(view_name, where_cond):
            return view_name, f'''
                CREATE VIEW "{view_name}" AS
                    SELECT ROW_NUMBER() OVER (PARTITION BY {REDCAP_RECORD_IDENTIFIER} ORDER BY robotic_session_number ASC) AS IthSession, *
                    FROM RoboticAssessment
                    LEFT JOIN ClinicalAssessment USING({REDCAP_RECORD_IDENTIFIER}, {RCCols.EventName})
                    LEFT JOIN Neurophysiology USING({REDCAP_RECORD_IDENTIFIER}, {RCCols.EventName})
                    WHERE {where_cond}
            '''
        impaired_rc_view, create_stmt = create_redcap_view('RedCapDataImpaired', where_cond='measured_hand___1')
        migrator.create_or_update_table_index_or_view_from_stmt(create_stmt)
        non_impaired_rc_view, create_stmt = create_redcap_view('RedCapDataNonImpaired', where_cond='measured_hand___2')
        migrator.create_or_update_table_index_or_view_from_stmt(create_stmt)

        def create_full_data_view(view_name, redcap_view, where_cond):
            return view_name, f'''
            CREATE VIEW "{view_name}" AS
                SELECT R.SubjectNr, R.LeftHand, R.IthSession, R.SessionStartDate,
                    D.{REDCAP_RECORD_IDENTIFIER}, V.{RCCols.EventName}, V.{RCCols.RepeatInst},
                    {migrator.columns_except('Patient', 'R', ['SubjectNr', 'PatientId'])},
                    {migrator.columns_except('Demographics', 'D', [REDCAP_RECORD_IDENTIFIER, 'subject_code'])},
                    {migrator.columns_except(redcap_view, 'V', [REDCAP_RECORD_IDENTIFIER, RCCols.EventName, RCCols.RepeatInst, 'IthSession'])},
                    {metric_names}
                FROM SessionResult AS R
                LEFT JOIN Demographics AS D ON(D.subject_code == R.SubjectNr)
                LEFT JOIN {redcap_view} AS V USING({REDCAP_RECORD_IDENTIFIER}, IthSession)
                WHERE {where_cond}
        '''
        data_impaired_view, create_stmt = \
            create_full_data_view('DataImpaired', impaired_rc_view,
                                  where_cond='(R.LeftHand AND R.LeftImpaired) OR (NOT R.LeftHand AND R.RightImpaired)')
        migrator.create_or_update_table_index_or_view_from_stmt(create_stmt)
        data_non_impaired_view, create_stmt = \
            create_full_data_view('DataNonImpaired', impaired_rc_view,
                                  where_cond='(R.LeftHand AND NOT R.LeftImpaired) OR (NOT R.LeftHand AND NOT R.RightImpaired)')
        migrator.create_or_update_table_index_or_view_from_stmt(create_stmt)

        name = 'DataFull'
        create_stmt = f'''
            CREATE VIEW "{name}" AS
                SELECT 1 AS impaired, *
                FROM {data_impaired_view}
                UNION ALL
                SELECT 0 AS impaired, *
                FROM {data_non_impaired_view}
                ORDER BY SubjectNr, LeftHand, IthSession
        '''
        migrator.create_or_update_table_index_or_view_from_stmt(create_stmt)
