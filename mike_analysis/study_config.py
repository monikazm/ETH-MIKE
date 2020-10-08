# This file may need to be adapted for different studies with different redcap tables
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
        patient_cols = migrator.out_get_all_columns_except('Patient', ['SubjectNr', 'PatientId'])
        demo_cols = migrator.out_get_all_columns_except('Demographics', [REDCAP_RECORD_IDENTIFIER, 'subject_code'])

        def create_redcap_view(view_name, impairedness_match_column):
            return f'''
                CREATE VIEW "{view_name}" AS
                    SELECT ROW_NUMBER() OVER (PARTITION BY {REDCAP_RECORD_IDENTIFIER} ORDER BY robotic_session_number ASC) AS IthSession, *
                    FROM RoboticAssessment
                    LEFT JOIN ClinicalAssessment USING({REDCAP_RECORD_IDENTIFIER}, redcap_event_name)
                    LEFT JOIN Neurophysiology USING({REDCAP_RECORD_IDENTIFIER}, redcap_event_name)
                    WHERE {impairedness_match_column} IS TRUE
            '''
        impaired_view_name = 'ImpairedAssessment'
        migrator.create_or_update_table_index_or_view_from_stmt(create_redcap_view(impaired_view_name, 'measured_hand___1'))
        non_impaired_view_name = 'NonImpairedAssessment'
        migrator.create_or_update_table_index_or_view_from_stmt(create_redcap_view(non_impaired_view_name, 'measured_hand___2'))

        def create_full_data_view(view_name, redcap_view, impairedness_cond):
            redcap_view_cols = f",\n".join([f'V.{col}' for col in
                                            migrator.out_get_all_columns_except(redcap_view, [REDCAP_RECORD_IDENTIFIER, 'redcap_event_name',
                                                                                              'redcap_repeat_instance', 'IthSession'])])
            return f'''
            CREATE VIEW "{view_name}" AS
                SELECT R.SubjectNr, R.LeftHand, R.IthSession, R.PseudoStartTime AS SessionStartDate,
                    D.{REDCAP_RECORD_IDENTIFIER}, V.redcap_event_name, V.redcap_repeat_instance,
                    {f", ".join([f"R.{patient_column}" for patient_column in patient_cols])},
                    {f", ".join([f"D.{demo_col}" for demo_col in demo_cols])},
                    {redcap_view_cols},
                    {metric_names}
                FROM SessionResult AS R
                LEFT JOIN Demographics AS D ON(D.subject_code == R.SubjectNr)
                LEFT JOIN {redcap_view} AS V USING({REDCAP_RECORD_IDENTIFIER}, IthSession)
                WHERE {impairedness_cond}
        '''
        data_impaired_view_name = 'DataImpaired'
        migrator.create_or_update_table_index_or_view_from_stmt(
            create_full_data_view(data_impaired_view_name, impaired_view_name,
                                  '(R.LeftHand AND R.LeftImpaired) OR (NOT R.LeftHand AND R.RightImpaired)')
        )
        data_non_impaired_view_name = 'DataNonImpaired'
        migrator.create_or_update_table_index_or_view_from_stmt(
            create_full_data_view(data_non_impaired_view_name, non_impaired_view_name,
                                  '(R.LeftHand AND NOT R.LeftImpaired) OR (NOT R.LeftHand AND NOT R.RightImpaired)')
        )

        name = 'DataFull'
        create_stmt = f'''
            CREATE VIEW "{name}" AS
                SELECT *
                FROM {data_impaired_view_name}
                UNION ALL
                SELECT *
                FROM {data_non_impaired_view_name}
                ORDER BY SubjectNr, LeftHand, IthSession
        '''
        migrator.create_or_update_table_index_or_view_from_stmt(create_stmt)
