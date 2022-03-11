

def insert_therapy_day(tableMigrator):
    tableMigrator.out_conn.execute(
        f"ALTER TABLE Robotic_Therapy ADD COLUMN therapy_day int")
    tableMigrator.out_conn.execute(
        f"UPDATE Robotic_Therapy SET therapy_day = (robotic_therapy_session_nu + 1)")
    tableMigrator.out_conn.execute(
        f"ALTER TABLE RoboticAssessment ADD COLUMN therapy_day int")
    tableMigrator.out_conn.execute(
        f"UPDATE RoboticAssessment SET therapy_day= CASE robotic_assessment_session WHEN 1 THEN 1 ELSE 15 END")
    tableMigrator.out_conn.execute(
        f"ALTER TABLE Usability ADD COLUMN therapy_day int")
    tableMigrator.out_conn.execute(
        f"UPDATE Usability SET therapy_day= CASE usability_session_number WHEN 1 THEN 2 WHEN 2 THEN 6 WHEN 3 THEN 10 ELSE 14 END")


def create_therapy_view(tableMigrator):
    # sql_command = f'''
    #             CREATE VIEW TherapyStudyOverview AS
    #                 SELECT Demographics.*, RoboticAssesment.*, Robotic_Therapy.*, Usability.*
    #                 From Demographics, RoboticAssesment,Robotic_Therapy,Usability
    #         '''
    # sql_command = f'''
    #             CREATE VIEW RedCapOverview AS
    #                 * from RoboticAssessment
    #                 LEFT JOIN Demographics ON RoboticAssessment.study_id = Demographics.study_id
    #         '''
    # tableMigrator.create_or_update_table_index_or_view_from_stmt(sql_command)
    return


def create_assessment_view(tableMigrator):
    # sql_command = f'''
    #             CREATE VIEW TherapyStudyOverview AS
    #                 SELECT Demographics.*, RoboticAssesment.*, Robotic_Therapy.*, Usability.*
    #                 From Demographics, RoboticAssesment,Robotic_Therapy,Usability
    #         '''
    return
