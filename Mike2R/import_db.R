library("RSQLite")

## connect to db
con <- dbConnect(drv=RSQLite::SQLite(), dbname="..\\analysis_db.db")

# Import data
patients = dbGetQuery(conn=con, "SELECT * FROM Patient")
session_results = dbGetQuery(conn=con, "SELECT * FROM SessionResult")

# Same table, but joined with demographics and corresponding robotic sessions
session_results_with_redcap_data = dbGetQuery(conn=con, "
    SELECT * FROM SessionResult AS R
    LEFT JOIN Demographics AS D ON(D.subject_code == R.SubjectNr)
    LEFT JOIN RoboticAssessment AS RA ON(D.study_id == RA.study_id AND R.IthSession == RA.robotic_session_number)
")

# example plots
# hist(patients$Age)
# plot(na.omit(session_results[session_results$SubjectNr=="xqwf" & session_results$LeftHand == 0,]$Rom_Active_ROM_Mean))
impaired_results = session_results[((session_results$LeftHand == 0 & session_results$RightImpaired == 1) 
                                    | ((session_results$LeftHand == 1 & session_results$LeftImpaired == 1))) 
                                   & !is.na(session_results$Rom_Active_ROM_Mean),]
plot(impaired_results$Age, impaired_results$Rom_Active_ROM_Mean)
boxplot(impaired_results$Rom_Active_MaxForce_Mean, impaired_results$Rom_Passive_ROM_Std)


dbDisconnect(con)
