# Architecture
## Metric
A Metric class defines how a certain metric is computed.
There are four different kinds of metrics:
- **Trial Metric**: A metric which is computed for every single trial. Each TriaMetric subclass has to implement a function which gets as input the raw data corresponding to a single trial (with Time starting at 0.0, only rows of the same trial and where TargetState == True) and produces a single scalar value as output. Example: Maximum Force
- **Aggregate Metric**: An aggregate metric takes trials metric values for all trials as input and produces a single scalar value for each trial metric. Example: Mean
- **Summary Metric**: A metric which is computed based on all trials. Each SummaryMetric subclass has to implement a function which gets as input the raw data corresponding to all trials and produces a single scalar value. Example: Position Matching RMSE
- **Diff Metric**: A special metric type which takes two aggregated trial (i.e. with e.g. "Mean" suffix), summary or diff metric names as input and returns the difference between those two metrics as a new metric.

It is possible to add new metrics to the system by implementing additional TrialMetric/AggregateMetric/SummaryMetric subclasses.

## Metric Evaluator

A MetricEvaluator defines which Metric

## Precomputer

TODO

## Data Processor

The DataProcessor is responsible for:
1. Creating database tables to store the computed metrics
2. Creating database views which make it easier to work with the data in an ad-hoc fashion (e.g. from an R console) or to export the data in a human-readable format
3. Importing raw data and obtaining metrics by running the mode-specific metric evaluator for every relevant tdms file
4. Storing the obtained metrics in the database

The metric column names and types which are needed to create the tables in 1. are obtained from the respective root metric evaluator for each assessment mode.

The list of relevant tdms file paths (i.e. tdms files corresponding to finished assessments) can be reconstructed from the assessment, patient and session metadata tables which are copied over from the frontend database.

The helper functions used for importing and preprocessing individual tdms files are located in [file_processing.py].

To improve performance, all tdms files are processed in parallel.

## RedCap Importer

TODO

## The Big Picture

main.py copies assessment, session and patient data from the frontend database, uses the RedcapImporter to download and parse the data from the RedCap API and the DataProcessor to process the TDMS files (import, preprocessing, metric computation).

The DataProcessor loops over all relevant tdms files (1 tdms file == 1 assessment) and processes them in parallel (import and preprocessing using file_processing.py, metric computation using the MetricEvaluator corresponding to the assessment's mode).

The metric evaluator iterates over all trial metric objects defined in its *trial_metrics* field and uses them to compute metric values for all trials. The trial metric values (1 per metric and trial) are passed into the aggregator metrics objects in *aggregator_metrics* to obtain the corresponding aggregate values (1 per metric). Similarly, the metric evaluator then also iterates over its *summary_metrics* and *diff_metrics* and uses them to compute the metrics they represent.

If a metric evaluator has sub (series) evaluators defined in *series_metric_evaluators*, it uses the function *get_series_idx* (needs to be implemented when creating a new evaluator for a new assessment type with multiple series) to partition the raw data (lists with one element per trial -> lists with one element per trial of that series) and then adds the metrics which are obtained by running the corresponding sub-evaluators on the respective data partitions to its own metrics.


[file_processing.py]: ../mike_analysis/core/file_processing.py