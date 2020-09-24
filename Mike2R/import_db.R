library(RSQLite)
library(dplyr)
library(RColorBrewer)

# Set color palette
get_palette <- colorRampPalette(brewer.pal(5, "Set1"))
palette(get_palette(8))

# connect to db
con <- dbConnect(drv=RSQLite::SQLite(), dbname="..\\analysis_db.db")

## Import data from database

# Metric metadata
metric_info <- dbGetQuery(conn=con, "SELECT *
                                     FROM MetricInfo")

# Patient metadata (joined with demographics from redcap)
patients <- dbGetQuery(conn=con, "SELECT *
                                  FROM Patient AS P
                                  JOIN Demographics AS D ON(P.SubjectNr == D.subject_code)")

# Metrics for single task
force_metrics <- dbGetQuery(conn=con, "SELECT *
                                       FROM ForceResultFull")
# "", pre-joined with patient data
force_metrics_w_patient <- dbGetQuery(conn=con, "SELECT *
                                                 FROM ForceResultFull
                                                 JOIN Patient AS P USING(PatientId)
                                                 JOIN Demographics AS D ON(P.SubjectNr == D.subject_code)")
# Perform a join in R instead of SQL
force_metrics_w_patient_v2 <- merge(force_metrics, patients, by = "PatientId")

# All Metrics pre-joined with patient data
session_results <- dbGetQuery(conn=con, "SELECT *
                                         FROM SessionResult")

# All data (patient metadata + metrics + redcap data, ordered by patient name, left hand, ith_session)
all_data <- dbGetQuery(conn=con, "SELECT *
                                  FROM DataFull")
impaired_data <- dbGetQuery(conn=con, "SELECT *
                                       FROM DataImpaired")
nonimpaired_data <- dbGetQuery(conn=con, "SELECT *
                                          FROM DataNonImpaired")

dbDisconnect(con)

## HELPER FUNCTIONS

ccat = function(...) {
  vecs <- list(...)
  n <- max(sapply(vecs, length))
  vecs <- lapply(vecs, function(vec) {length(vec) <- n;vec})
  res <- matrix(unlist(vecs), ncol=length(vecs))
  return(res)
}

get_pretty_name <- function(metric) {
  return(paste(gsub("_", " ", metric)))
}

get_unit <- function(metric_info) {
  unit = metric_info$Unit
  if (unit != '') unit = paste("[", unit, "]", sep="")
  return(unit)
}

plot_srd_arrows <- function(srd, bigger_is_better, height, data_x, data_y) {
  if (length(data_x) == 1 || is.na(srd)) return()

  diff_data = diff(data_y)
  for (i in 1:length(diff_data)) {
    dy = diff_data[i]
    x = (data_x[i+1] + data_x[i]) / 2.0
    y_cent = (data_y[i+1] + data_y[i]) / 2.0
    y_offset = height * 0.04
    arrow_col = 'gray42' #if ((dy > srd && bigger_is_better) || (dy < -srd && !bigger_is_better)) 'springgreen3' else 'red'
    if (dy > srd) {
      arrows(x, y_cent - y_offset * 0.5, x, y_cent + y_offset, col=arrow_col, lwd=2.5, length=0.10)
    }
    else if (dy < -srd) {
      arrows(x, y_cent+y_offset * 0.5, x, y_cent - y_offset, col=arrow_col, lwd=2.5, length=0.10)
    }
  }
}

## PLOTTING FUNCTIONS

plot_metric_for_all_series <- function(title, metric, series_data, series_names, series_srd_names, x_col = 'IthSession') {
  m_info = metric_info[metric_info$Name == metric,]
  pretty_metric_name <- get_pretty_name(metric)
  pretty_name_with_unit <- paste(pretty_metric_name, get_unit(m_info))
  
  n <- nrow(series_names)
  palette(get_palette(n))
  
  all_x <- do.call(ccat, lapply(series_data, function(data) data[[x_col]]))
  all_y <- do.call(ccat, lapply(series_data, function(data) data[[metric]]))
  
  max_x <- max(all_x, na.rm = TRUE)
  min_y <- min(all_y, na.rm = TRUE)
  max_y <- max(all_y, na.rm = TRUE)
  y_vals <- range(min_y, max_y)
  if (!m_info$BiggerIsBetter) {
    y_vals <- rev(y_vals)
  }
  
  par(mar=c(5.1, 6.1, 4.1, 13.1))
  matplot(all_x, all_y, type = "b", pch=1, lwd=2, ylim = y_vals, lty = 1:n, col=1:n,
          main=paste(title, pretty_metric_name), xlab="Session Nr", ylab=pretty_name_with_unit)
  legend('bottomright',inset=c(-0.2,0), legend = do.call(c, series_names), col=1:n, lty = 1:n, lwd = 2, xpd=TRUE)
  
  healthy_avg = m_info$HealthyAvg
  if (!is.na(healthy_avg)) {
    abline(h=healthy_avg, col="darkgreen", lwd=2, lty=1)
    text(max_x, healthy_avg, "healthy avg \U2191", col = "darkgreen", xpd=TRUE, adj=-0.5)
  }
  
  mapply(function(data, srd_name) plot_srd_arrows(m_info[[srd_name]], m_info$BiggerIsBetter, max_y - min_y, data[[x_col]], data[[metric]]), series_data, series_srd_names)
}

long_plot_metric <- function(user, metric) {
  m_info = metric_info[metric_info$Name == metric,]
  pretty_metric_name <- get_pretty_name(metric)
  pretty_name_with_unit <- paste(pretty_metric_name, get_unit(m_info))
  
  imp <- impaired_data[impaired_data$SubjectNr == user,] # Trailing comma is important
  nimp <- nonimpaired_data[nonimpaired_data$SubjectNr == user,]
  
  x <- ccat(imp$robotic_session_number, nimp$robotic_session_number)
  y <- ccat(imp[[metric]], nimp[[metric]])
  max_x <- max(x, na.rm = TRUE)
  
  matplot(x, y, type = "b", pch=1, lwd=2,
          main=paste("Longitudinal Plot for", user), xlab="Session Nr", ylab=pretty_name_with_unit)
  legend('topright', legend = c("impaired", "non-impaired"), col=1:2, lty = 1:2, lwd = 1)
  
  healthy_avg <- m_info$HealthyAvg
  if (!is.na(healthy_avg)) {
    abline(h=healthy_avg, col="darkgreen", lwd=2)
    text(max_x, healthy_avg*1.05, "healthy avg", col = "darkgreen", adj=1)
  }
}

all_user_long_plot_metric <- function(metric) {
  by_user <- impaired_data[!is.na(impaired_data$robotic_session_number),] %>% group_by(SubjectNr)
  data_per_user <- group_split(by_user)
  users <- group_keys(by_user)
  plot_metric_for_all_series("Impaired hand:", metric, data_per_user, users, as.list(rep('SrdImpaired', nrow(users))))
}

box_plot_metric <- function(metric) {
  m_info = metric_info[metric_info$Name == metric,]
  pretty_metric_name <- get_pretty_name(metric)
  pretty_name_with_unit <- paste(pretty_metric_name, get_unit(m_info))

  boxplot(impaired_data[impaired_data$IthSession == 1,][[metric]],
          nonimpaired_data[nonimpaired_data$IthSession == 1,][[metric]],
          main=paste("Compare", pretty_metric_name, "distributions"),
          names = c("impaired", "non-impaired"),
          ylab=pretty_name_with_unit)
}

plot_all_metrics_with_healthy_avg <- function(filename) {
  if (!missing(filename)) {
    cairo_pdf(paste(filename, ".pdf", sep=""), width = 12, height=7, onefile = TRUE)
  }
  infos = metric_info[!is.na(metric_info$HealthyAvg),]
  for (i in rownames(infos)) {
    all_user_long_plot_metric(infos[i, 'Name'])
  }
  if (!missing(filename)) {
    dev.off()
  }
}

# example plots
{
  hist(2020-na.omit(patients$year_of_birth), main = "Histogram of Age")
  plot(density(2020-na.omit(patients$year_of_birth)), main = "Density of Age")
  long_plot_metric("eojo", "Rom_Active_ROM_Mean")
  box_plot_metric("TrajectoryFollowing_Slow_NIJ_Mean")
  box_plot_metric("TrajectoryFollowing_Fast_MAPR_Mean")
  all_user_long_plot_metric("Rom_Active_ROM_Mean")
  all_user_long_plot_metric("Rom_Passive_ROM_Mean")
  all_user_long_plot_metric("Force_Flexion_MaxForce_Mean")
}
