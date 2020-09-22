library("RSQLite")
library("dplyr")

## connect to db
con <- dbConnect(drv=RSQLite::SQLite(), dbname="..\\analysis_db.db")

## Import data

# Patient metadata (joined with demographics from redcap)
patients = dbGetQuery(conn=con, "SELECT *
                                 FROM Patient AS P
                                 JOIN Demographics AS D ON(P.SubjectNr == D.subject_code)")

# Metrics for single task
force_metrics = dbGetQuery(conn=con, "SELECT *
                                      FROM ForceResultFull")
# "", pre-joined with patient data
force_metrics_w_patient = dbGetQuery(conn=con, "SELECT *
                                                FROM ForceResultFull
                                                JOIN Patient AS P USING(PatientId)
                                                JOIN Demographics AS D ON(P.SubjectNr == D.subject_code)")
# Perform a join in R instead of SQL
force_metrics_w_patient_v2 = merge(force_metrics, patients, by = "PatientId")

# All Metrics pre-joined with patient data
session_results = dbGetQuery(conn=con, "SELECT *
                                        FROM SessionResult")

# All data (patient metadata + metrics + redcap data, ordered by patient name, left hand, ith_session)
all_data = dbGetQuery(conn=con, "SELECT *
                                 FROM DataFull")
impaired_data = dbGetQuery(conn=con, "SELECT *
                                      FROM DataImpaired")
nonimpaired_data = dbGetQuery(conn=con, "SELECT *
                                         FROM DataNonImpaired")

ccat = function(vec1, vec2) {
  n <- max(length(vec1), length(vec2))
  length(vec1) <- n
  length(vec2) <- n
  return(matrix(c(vec1, vec2), ncol=2))
}

long_plot_metric <- function(user, metric) {
  imp = impaired_data[impaired_data$SubjectNr == user,] # Trailing comma is important
  nimp = nonimpaired_data[nonimpaired_data$SubjectNr == user,]

  imp_x = imp$robotic_session_number
  imp_y = imp[[metric]]

  nimp_x = nimp$robotic_session_number
  nimp_y = nimp[[metric]]

  matplot(ccat(imp_x, nimp_x), ccat(imp_y, nimp_y), type = "b", pch=1,
          main=paste("Longitudinal Plot for", user), xlab="Session Nr", ylab=metric)
  legend('bottomright',legend = c("impaired", "non-impaired"), col=1:2, lty = 1:2, lwd = 1 )
}

box_plot_metric <- function(metric_name) {
  boxplot(impaired_data[impaired_data$IthSession == 1,][[metric_name]],
          nonimpaired_data[nonimpaired_data$IthSession == 1,][[metric_name]],
          main=paste("Compare", metric_name, "distributions"),
          names = c("impaired", "non-impaired"),
          ylab=metric_name)
}

# create longitudinal plot for one user, hand and metric
{
  hist(2020-patients$year_of_birth, main = "Histogram of Age")
  plot(density(2020-patients$year_of_birth), main = "Density of Age")
  long_plot_metric("gmvu", "Rom_Active_ROM_Mean")
  box_plot_metric("TrajectoryFollowing_Slow_NIJ_Mean")
  box_plot_metric("TrajectoryFollowing_Fast_MAPR_Mean")
}


dbDisconnect(con)
