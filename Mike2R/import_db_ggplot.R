library(RSQLite)
library(dplyr)
library(ggplot2)

# connect to db
con <- dbConnect(drv = RSQLite::SQLite(), dbname = "..\\analysis_db.db")

## Import data from database

# Metric metadata
metric_info <- dbGetQuery(conn = con, "SELECT *
                                       FROM MetricInfo")
numtrial_metrics <- metric_info[endsWith(metric_info$Name, "NumTrials"),]

# Patient metadata (joined with demographics from redcap)
patients <- dbGetQuery(conn = con, "SELECT *
                                    FROM Patient AS P
                                    JOIN Demographics AS D ON(P.SubjectNr == D.subject_code)")

# All data (patient metadata + metrics + redcap data, ordered by patient name, left hand, ith_session)
all_data <- dbGetQuery(conn = con, "SELECT *
                                    FROM DataFull")
impaired_data <- dbGetQuery(conn = con, "SELECT *
                                         FROM DataImpaired")
nonimpaired_data <- dbGetQuery(conn = con, "SELECT *
                                            FROM DataNonImpaired")

dbDisconnect(con)


get_pretty_name <- function(metric) {
  return(paste(gsub("_", " ", metric)))
}

get_metric_info <- function(metric) {
  m_info <- metric_info[metric_info$Name == metric,]
  if (nrow(m_info) == 0) {
    m_info <- data.frame("Name" = metric, "Unit" = "", "DataType" = NA,
                         "BiggerIsBetter" = TRUE, "HealthyAvg" = NA, "SrdImpaired" = NA, "SrdNonImpaired" = NA)
  }
  return(m_info)
}

get_unit <- function(metric_info) {
  unit <- metric_info$Unit
  if (unit != '') unit <- paste0("[", unit, "]")
  return(unit)
}

# https://stackoverflow.com/questions/23937193/modifying-ggplot2-y-axis-to-use-integers-without-enforcing-an-upper-limit
integer_breaks <- function(x)
  seq(floor(min(x)), ceiling(max(x)))

# Plot longitudinal data
long_plot_metric <- function(user, metric, show_std = TRUE) {
  m_info <- get_metric_info(metric)
  pretty_metric_name <- get_pretty_name(metric)
  pretty_name_with_unit <- paste(pretty_metric_name, get_unit(m_info))

  user_data <- all_data[all_data$SubjectNr == user,]
  user_data$impaired <- ifelse(user_data$impaired == 0, "non-impaired", "impaired")
  graph <- ggplot(user_data, aes_string(x = "robotic_session_number", y = metric, color = "impaired")) +
    geom_point(size = 5) +
    geom_line(size = 1.2) +
    scale_x_continuous(breaks = integer_breaks) +
    labs(title = paste("Longitudinal Plot for:", user), x = "Session Nr", y = pretty_name_with_unit) +
    coord_cartesian(clip = "off")

  if (nrow(m_info) > 0) {
    healthy_avg <- m_info$HealthyAvg
    if (!is.na(healthy_avg)) {
      graph <- graph +
        geom_hline(yintercept = healthy_avg, colour = "darkgreen", size = 1.1) +
        annotate(geom = "text", label = "Healthy Avg", x = max(user_data$robotic_session_number), y = healthy_avg, hjust = 1, vjust = -1, colour = "darkgreen")
    }
  }

  if (!m_info$BiggerIsBetter) {
    graph <- graph + scale_y_reverse()
  }

  # for srd arrows
  # need to build frame first with x and y of arrows
  # graph + geom_segment(data=, aes(x=x, xend=x, y=y_cent - y_offset * 0.5, yend=y_cent + y_offset, colour=arrow_col))

  print(graph)
}

update_plot <- function(metric, start_date = '2020-10-02', end_date = '2020-10-08') {
  m_info <- get_metric_info(metric)
  pretty_metric_name <- get_pretty_name(metric)
  pretty_name_with_unit <- paste(pretty_metric_name, get_unit(m_info))

  # Limit to impaired results
  metric_data <- all_data[all_data$impaired == 1,]
  metric_data <- metric_data[!is.na(metric_data$study_id),]

  # Exclude future results (results after end_date)
  metric_data <- metric_data[metric_data$SessionStartDate <= end_date,]

  # Add for every user whether a new data point was added in the selected time span
  metric_data <- metric_data %>%
    group_by(SubjectNr) %>%
    mutate(in_range = any(SessionStartDate >= start_date & SessionStartDate <= end_date)) %>%
    mutate(new_data = SessionStartDate >= start_date & SessionStartDate <= end_date)

  ## Create plot
  graph <- ggplot(subset(metric_data, in_range == TRUE), aes_string(x = "IthSession", y = metric, color = "SubjectNr"))

  if (!m_info$BiggerIsBetter) {
    graph <- graph + scale_y_reverse()
  }

  # Add gray lines for series out of date range
  for (val in group_split(metric_data)) {
    if (!any(val$in_range)) {
      graph <- graph +
        geom_line(data = val, aes_string(x = "IthSession", y = metric), color = "darkgray", size = 1.1) #, linetype="dashed")
    }
  }
  graph <- graph +
    geom_point(size = 3.5) +
    geom_line(size = 1.5) +

    # Add bigger points and circles for new data points
    geom_point(data = subset(metric_data, new_data == TRUE), aes_string(x = "IthSession", y = metric, color = "SubjectNr"), size = 5) +
    geom_point(data = subset(metric_data, new_data == TRUE), aes_string(x = "IthSession", y = metric, color = "SubjectNr"), shape = 1, size = 7) +

    # Add gray points for series out of range
    geom_point(data = subset(metric_data, in_range == FALSE), aes_string(x = "IthSession", y = metric), color = "darkgray", size = 3) +

    # Ensure only integer values in x-axis
    scale_x_continuous(breaks = integer_breaks) +

    # Add labels
    labs(title = paste("Update Plot for:", pretty_metric_name), subtitle = paste0("from ", start_date, " to ", end_date), x = "Session Nr", y = pretty_name_with_unit)
  #coord_cartesian(clip = "off")

  print(graph)
}
