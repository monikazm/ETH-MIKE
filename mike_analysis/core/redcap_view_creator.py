def create_therapy_day_if_not_exist(migrator, table_name):
    try:
        migrator.out_conn.execute(
            f"SELECT therapy_day FROM {table_name} LIMIT 1;")
    except:
        migrator.out_conn.execute(
            f"ALTER TABLE {table_name} ADD COLUMN therapy_day int")


def insert_therapy_day(tableMigrator):
    create_therapy_day_if_not_exist(tableMigrator, "Robotic_Therapy")
    create_therapy_day_if_not_exist(tableMigrator, "RoboticAssessment")
    create_therapy_day_if_not_exist(tableMigrator, "Usability")

    tableMigrator.out_conn.execute(
        f"UPDATE Robotic_Therapy SET therapy_day = (robotic_therapy_session_nu + 1)")
    tableMigrator.out_conn.execute(
        f"UPDATE RoboticAssessment SET therapy_day = (CASE robotic_assessment_session WHEN 1 THEN 1 ELSE 15 END);")
    tableMigrator.out_conn.execute(
        f"UPDATE Usability SET therapy_day = CASE usability_session_number WHEN 1 THEN 2 WHEN 2 THEN 6 WHEN 3 THEN 10 ELSE 14 END;")
    tableMigrator.out_conn.commit()


def compute_therapy_day(tableMigrator, view_name):
    tableMigrator.out_conn.execute(
        f"ALTER TABLE {view_name} ADD COLUMN therapy_date date;")
    tableMigrator.out_conn.execute(
        f"UPDATE {view_name}  SET therapy_date = substr( StartTime, 1, 8) ")
    date_conversion = "SELECT date(substr(PassiveMatchingResultAggregate.StartTime, 1, 4) | | '-' | | substr(PassiveMatchingResultAggregate.StartTime, 5, 2) | | '-' | | substr(PassiveMatchingResultAggregate.StartTime, 7, 2))  FROM PassiveMatchingResultAggregate"


def create_theragy_aggregate_day_view(tableMigrator, cfg):
    for therapy in cfg.IMPORT_THERAPY_TABLES:
        view_name = therapy + "ResultAggregateDaily"
        parent_view_name = therapy + "ResultAggregate"
        tableMigrator.out_conn.execute(f"DROP VIEW IF EXISTS {view_name};")
        sql_command = f'''
            CREATE VIEW {view_name}  
                AS
                SELECT 
                    a.SubjectNr AS {therapy}_SubjectNr,
					date(substr(a.StartTime, 1, 4) || '-' || substr(a.StartTime, 5, 2) || '-' || substr(a.StartTime, 7, 2)) AS {therapy}_date,
                    a.Result AS {therapy}_Result,
					a.AvgAbsErr AS {therapy}_AvgAbsErr,
					a.AvgTimeUntilValidate AS {therapy}_AvgTimeUntilValidate,
					a.Level AS {therapy}_Level,
                    (SELECT b.Result FROM {parent_view_name} b 
                                WHERE b.SubjectNr = a.SubjectNr
                                AND substr(b.StartTime, 1, 8) = substr(a.StartTime, 1, 8)
                                AND b.StartTime != a.StartTime LIMIT 3) AS {therapy}_Result,
					(SELECT b.AvgAbsErr FROM {parent_view_name} b 
                                WHERE b.SubjectNr = a.SubjectNr
                                AND substr(b.StartTime, 1, 8) = substr(a.StartTime, 1, 8)
                                AND b.StartTime != a.StartTime LIMIT 3) AS {therapy}_AvgAbsErr,
					(SELECT b.AvgTimeUntilValidate FROM {parent_view_name} b 
                                WHERE b.SubjectNr = a.SubjectNr
                                AND substr(b.StartTime, 1, 8) = substr(a.StartTime, 1, 8)
                                AND b.StartTime != a.StartTime LIMIT 3) AS {therapy}_AvgTimeUntilValidate,
					(SELECT b.Level FROM {parent_view_name} b 
                                WHERE b.SubjectNr = a.SubjectNr
                                AND substr(b.StartTime, 1, 8) = substr(a.StartTime, 1, 8)
                                AND b.StartTime != a.StartTime LIMIT 3) AS {therapy}_Level
                    FROM {parent_view_name} a 
                    GROUP BY a.SubjectNr
        '''
        tableMigrator.out_conn.execute(sql_command)


def create_therapy_view(tableMigrator, cfg):
    # compute_therapy_day(tableMigrator, "PassiveMatchingResultAggregate")
    create_theragy_aggregate_day_view(tableMigrator, cfg)

    front_end_view_columns_stmt = ""

    front_end_view_join_stmt = ""
    for therapy in cfg.IMPORT_THERAPY_TABLES:
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
                    Demographics.*,
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


def create_assessment_view(tableMigrator):
    tableMigrator.out_conn.execute(f"DROP VIEW IF EXISTS AssessmentCombined;")
    sql_command = f'''
                CREATE VIEW AssessmentCombined 
                AS
                SELECT 
                    Demographics.*,
                    RoboticAssessment.*,    
                    AssessmentMetrics.*
                FROM 
                    RoboticAssessment
                LEFT JOIN Demographics ON Demographics.study_id == RoboticAssessment.study_id
                LEFT JOIN AssessmentMetrics ON AssessmentMetrics.SubjectNr == Demographics.subject_code
                
            '''
    tableMigrator.out_conn.execute(
        sql_command)
    return


def create_usability_view(tableMigrator):
    tableMigrator.out_conn.execute(f"DROP VIEW IF EXISTS UsabilityCombined;")
    sql_command = f'''
                CREATE VIEW UsabilityCombined 
                AS
                SELECT 
                    Demographics.*,
                    Usability.*   
                FROM 
                    Usability
                LEFT JOIN Demographics ON Demographics.study_id == Usability.study_id             
            '''
    tableMigrator.out_conn.execute(
        sql_command)
    return
