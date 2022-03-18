def create_therapy_day_if_not_exist(migrator, table_name):
    try:
        migrator.out_conn.execute(
            f"SELECT therapy_day FROM {table_name} LIMIT 1;")
    except:
        migrator.out_conn.execute(
            f"ALTER TABLE {table_name} ADD COLUMN therapy_day int")


def insert_therapy_day(tableMigrator):
    create_therapy_day_if_not_exist(tableMigrator, "Robotic_Therapy")
    tableMigrator.out_conn.execute(
        f"UPDATE Robotic_Therapy SET therapy_day = (robotic_therapy_session_nu + 1)")
    create_therapy_day_if_not_exist(tableMigrator, "RoboticAssessment")
    tableMigrator.out_conn.execute(
        f"UPDATE RoboticAssessment SET therapy_day= CASE robotic_assessment_session WHEN 1 THEN 1 ELSE 15 END")
    create_therapy_day_if_not_exist(tableMigrator, "Usability")
    tableMigrator.out_conn.execute(
        f"UPDATE Usability SET therapy_day= CASE usability_session_number WHEN 1 THEN 2 WHEN 2 THEN 6 WHEN 3 THEN 10 ELSE 14 END")


def create_assessment_view(tableMigrator):
    # sql_command = f'''
    #             CREATE VIEW TherapyStudyOverview AS
    #                 SELECT Demographics.*, RoboticAssesment.*, Robotic_Therapy.*, Usability.*
    #                 From Demographics, RoboticAssesment,Robotic_Therapy,Usability
    #         '''
    tableMigrator.out_conn.execute(f"DROP VIEW IF EXISTS AssessmentCombined;")
    sql_command = f'''
                CREATE VIEW AssessmentCombined 
                AS
                SELECT 
                    RoboticAssessment.*,   
                    Demographics.*
                FROM 
                    RoboticAssessment
                LEFT JOIN Demographics ON Demographics.study_id = RoboticAssessment.study_id
            '''
    tableMigrator.out_conn.execute(
        sql_command)
    return


def create_therapy_view(tableMigrator):
    # sql_command = f'''
    #             CREATE VIEW TherapyStudyOverview AS
    #                 SELECT Demographics.*, RoboticAssesment.*, Robotic_Therapy.*, Usability.*
    #                 From Demographics, RoboticAssesment,Robotic_Therapy,Usability
    #         '''
    return
