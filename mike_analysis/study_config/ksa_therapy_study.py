from mike_analysis.core.constants import RCCols
from mike_analysis.core.sqlite_migrator import SQLiteMigrator


############################################################
# Tables
############################################################

# Can be used to copy e.g. tables needed to copy certain views
# always specify "table_name: table_index"
IMPORT_TABLES = {
    'Session': "Session_PatientId",
    'Patient': 'Patient_SubjectNr',
    'Exercise': 'Exercise_SessionId',
    'Assessment': 'Assessment_SessionId'}

IMPORT_ASSESSMENT_TABLES = {'RangeOfMotion', 'Force',
                            'TargetFollowing', 'PositionMatch'}
IMPORT_THERAPY_TABLES = {'PassiveMatching', 'TrajectoryPerception',
                         'TeachAndReproduce', 'HapticBump', 'ActiveMatching'}

############################################################
# Views
############################################################

# Copy over the assesment result views. make sure that the tables the views depend on are specified in IMPORT_ADDITIONAL_TABLES.

# Views with one row per trial
IMPORT_ASSESSMENT_RESULTS_FULL_VIEW = False
# Views with average score over all trials of the same exercise
IMPORT_ASSESSMENT_RESULTS_AGGREGATE_VIEW = False

# Copy over the therapy result views:
# Views with one row per trial
IMPORT_THERAPY_RESULTS_FULL_VIEW = True
# Views with average score over all trials of the same exercise
IMPORT_THERAPY_RESULTS_AGGREGATE_VIEW = True

# PassiveMatching, TrajectoryPerception max 4 times
# 'TeachAndReproduce', 'HapticBump', 'ActiveMatching' max 2 times

############################################################
# REDCap
############################################################


REDCAP_RECORD_IDENTIFIER = 'study_id'
REDCAP_EXCLUDED_COLS = {'gender', 'handedness', 'impaired_side',
                        'details_on_stroke', 'date_mri', 'lesion_location_detailed'}
REDCAP_NAMES_AND_INDEX_COLS = {
    'demographics': ('Demographics', ['subject_code']),
    'clinical_assessments': ('ClinicalAssessment', []),
    'robotic_assessments': ('RoboticAssessment', ['robotic_assessment_session']),
    'robotic_therapy': ('Robotic_Therapy', []),
    'usability': ('Usability', []),
    'adverse_events': ('Adverse Events', []),
    'device_deficiency': ('Device Deficiency', []),
    'end_of_study_report': ('End of Study Report', [])
}


############################################################
# Function to create custom views
############################################################


def create_study_views(migrator: SQLiteMigrator):
    __insert_therapy_day(migrator)
    __create_assessment_view(migrator)
    __create_therapy_view(migrator)
    __create_usability_view(migrator)
    return


############################################################
# Helper functions
############################################################


def __create_therapy_day_if_not_exist(migrator, table_name):
    try:
        migrator.out_conn.execute(
            f"SELECT therapy_day FROM {table_name} LIMIT 1;")
    except:
        migrator.out_conn.execute(
            f"ALTER TABLE {table_name} ADD COLUMN therapy_day int")


def __insert_therapy_day(tableMigrator):
    __create_therapy_day_if_not_exist(tableMigrator, "Robotic_Therapy")
    __create_therapy_day_if_not_exist(tableMigrator, "RoboticAssessment")
    __create_therapy_day_if_not_exist(tableMigrator, "Usability")

    tableMigrator.out_conn.execute(
        f"UPDATE Robotic_Therapy SET therapy_day = (robotic_therapy_session_nu + 1)")
    tableMigrator.out_conn.execute(
        f"UPDATE RoboticAssessment SET therapy_day = (CASE robotic_assessment_session WHEN 1 THEN 1 ELSE 15 END);")
    tableMigrator.out_conn.execute(
        f"UPDATE Usability SET therapy_day = CASE usability_session_number WHEN 1 THEN 2 WHEN 2 THEN 6 WHEN 3 THEN 10 ELSE 14 END;")
    tableMigrator.out_conn.commit()


def __create_theragy_aggregate_day_view(tableMigrator):
    for therapy in IMPORT_THERAPY_TABLES:
        view_name = therapy + "ResultAggregateDaily"
        parent_view_name = therapy + "ResultAggregate"
        tableMigrator.out_conn.execute(f"DROP VIEW IF EXISTS {view_name};")
        if (therapy == 'PassiveMatching' or therapy == 'TrajectoryPerception'):
            sql_command = f'''
                CREATE VIEW {view_name}  
                    AS
                    SELECT 
                        a.SubjectNr AS {therapy}_SubjectNr,
                        date(substr(a.StartTime, 1, 4) || '-' || substr(a.StartTime, 5, 2) || '-' || substr(a.StartTime, 7, 2)) AS {therapy}_date,
                        a.LeftHand AS {therapy}_LeftHand,
                        a.Result AS {therapy}_Result,
                        a.AvgAbsErr AS {therapy}_AvgAbsErr,
                        a.AvgTimeUntilValidate AS {therapy}_AvgTimeUntilValidate,
                        a.Level AS {therapy}_Level,
                        b.Result AS {therapy}_Result,
                        b.AvgAbsErr AS {therapy}_AvgAbsErr,
                        b.AvgTimeUntilValidate AS {therapy}_AvgTimeUntilValidate,
                        b.Level AS {therapy}_Level,
                        c.Result AS {therapy}_Result,
                        c.AvgAbsErr AS {therapy}_AvgAbsErr,
                        c.AvgTimeUntilValidate AS {therapy}_AvgTimeUntilValidate,
                        c.Level AS {therapy}_Level,
                        d.Result AS {therapy}_Result,
                        d.AvgAbsErr AS {therapy}_AvgAbsErr,
                        d.AvgTimeUntilValidate AS {therapy}_AvgTimeUntilValidate,
                        d.Level AS {therapy}_Level
                        
                        FROM {parent_view_name} a
                        Left Join {parent_view_name} b ON b.SubjectNr = a.SubjectNr
                                    AND substr(b.StartTime, 1, 8) = substr(a.StartTime, 1, 8)
                                    AND b.StartTime != a.StartTime  
                        Left Join {parent_view_name} c ON c.SubjectNr = a.SubjectNr
                                    AND substr(c.StartTime, 1, 8) = substr(a.StartTime, 1, 8)
                                    AND c.StartTime != a.StartTime  
                                    AND c.StartTime != b.StartTime 
                        Left Join {parent_view_name} d ON c.SubjectNr = a.SubjectNr
                                    AND substr(d.StartTime, 1, 8) = substr(a.StartTime, 1, 8)
                                    AND d.StartTime != a.StartTime  
                                    AND d.StartTime != b.StartTime
                                    AND d.StartTime != c.StartTime 
                        GROUP BY 
                        {therapy}_SubjectNr,
                        {therapy}_date;
            '''

        else:
            sql_command = f'''
                CREATE VIEW {view_name}  
                    AS
                    SELECT 
                        a.SubjectNr AS {therapy}_SubjectNr,
                        date(substr(a.StartTime, 1, 4) || '-' || substr(a.StartTime, 5, 2) || '-' || substr(a.StartTime, 7, 2)) AS {therapy}_date,
                        a.LeftHand AS {therapy}_LeftHand,
                        a.Result AS {therapy}_Result,
                        a.AvgAbsErr AS {therapy}_AvgAbsErr,
                        a.AvgTimeUntilValidate AS {therapy}_AvgTimeUntilValidate,
                        a.Level AS {therapy}_Level,
                        b.Result AS {therapy}_Result,
                        b.AvgAbsErr AS {therapy}_AvgAbsErr,
                        b.AvgTimeUntilValidate AS {therapy}_AvgTimeUntilValidate,
                        b.Level AS {therapy}_Level
                        
                        FROM {parent_view_name} a
                        Left Join {parent_view_name} b ON b.SubjectNr = a.SubjectNr
                                    AND substr(b.StartTime, 1, 8) = substr(a.StartTime, 1, 8)
                                    AND b.StartTime != a.StartTime  
                        GROUP BY 
                        {therapy}_SubjectNr,
                        {therapy}_date;
            '''
        tableMigrator.out_conn.execute(sql_command)


def __create_therapy_view(tableMigrator):
    __create_theragy_aggregate_day_view(tableMigrator)

    front_end_view_columns_stmt = ""

    front_end_view_join_stmt = ""
    for therapy in IMPORT_THERAPY_TABLES:
        view_name = therapy + "ResultAggregateDaily"
        front_end_view_columns_stmt = front_end_view_columns_stmt + \
            view_name + ".*, "

        front_end_view_join_stmt = front_end_view_join_stmt + 'LEFT JOIN ' + view_name + ''' ON ''' + view_name + '''.''' + therapy + '''_SubjectNr == Demographics.subject_code AND
                ''' + view_name + '''.''' + therapy + '''_date == Robotic_Therapy.date_of_robotic_therapy     
            '''
    front_end_view_columns_stmt = front_end_view_columns_stmt[:-2]

    tableMigrator.out_conn.execute(f"DROP VIEW IF EXISTS TherapyCombined;")
    sql_command = f'''
                CREATE VIEW TherapyCombined 
                AS
                SELECT 
                    Demographics.subject_code,
                    Robotic_Therapy.*,
                    {front_end_view_columns_stmt}
                FROM 
                    Robotic_Therapy
                LEFT JOIN Demographics ON Demographics.study_id == Robotic_Therapy.study_id
                {front_end_view_join_stmt}
                
            '''
    tableMigrator.out_conn.execute(
        sql_command)
    return


def __create_assessment_view(tableMigrator):
    tableMigrator.out_conn.execute(f"DROP VIEW IF EXISTS AssessmentCombined;")
    sql_command = f'''
                CREATE VIEW AssessmentCombined 
                AS
                SELECT 
                    Demographics.*,
                    ClinicalAssessment.*,   
                    RoboticAssessment.*, 
                    AssessmentMetrics.*
                FROM 
                    RoboticAssessment
                LEFT JOIN Demographics ON Demographics.study_id == RoboticAssessment.study_id
                LEFT JOIN AssessmentMetrics ON AssessmentMetrics.SubjectNr == Demographics.subject_code and AssessmentMetrics.SessionStartDate == RoboticAssessment.date_robotic_assessment
                LEFT JOIN ClinicalAssessment ON ClinicalAssessment.study_id == RoboticAssessment.study_id and ClinicalAssessment.date_clinical_assessments == RoboticAssessment.date_robotic_assessment
                
            '''
    tableMigrator.out_conn.execute(
        sql_command)
    return


def __create_usability_view(tableMigrator):
    tableMigrator.out_conn.execute(f"DROP VIEW IF EXISTS UsabilityCombined;")
    sql_command = f'''
                CREATE VIEW UsabilityCombined 
                AS
                SELECT 
                    Demographics.subject_code,
                    Usability.*   
                FROM 
                    Usability
                LEFT JOIN Demographics ON Demographics.study_id == Usability.study_id             
            '''
    tableMigrator.out_conn.execute(
        sql_command)
    return
