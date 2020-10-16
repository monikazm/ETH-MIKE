# Architecture

## Table of Contents
[[_TOC_]]

## Metric
A Metric class defines how a certain metric is computed.
There are four different kinds of metrics:
- **Trial Metric**: A metric which is computed for every single trial. Each TriaMetric subclass has to implement a function which gets as input the raw data corresponding to a single trial (with Time starting at 0.0, only rows of the same trial and where TargetState == True) and produces a single scalar value as output. Example: Maximum Force
- **Aggregate Metric**: An aggregate metric takes trials metric values for all trials as input and produces a single scalar value for each trial metric. Example: Mean
- **Summary Metric**: A metric which is computed based on all trials. Each SummaryMetric subclass has to implement a function which gets as input the raw data corresponding to all trials and produces a single scalar value. Example: Position Matching RMSE
- **Diff Metric**: A special metric type which takes two aggregated trial (i.e. with e.g. "Mean" suffix), summary or diff metric names as input and returns the difference between those two metrics as a new metric.

It is possible to add new metrics to the system by implementing additional TrialMetric/AggregateMetric/SummaryMetric subclasses.

## Metric Evaluator

For each assessment mode, a hierarchy of metric evaluators (main evaluator + optional series evaluators in case of multiple series) is used to define how metrics are computed for assessments of that type.

When defining a new MetricEvaluator, the fields `trial_metrics`, `diff_metrics` and `summary_metrics` can be used to define the list of Trial/Diff/Summary metrics which should be evaluated for all trial data passed into that evaluator.
If one of those lists is not assigned, it is assumed to be empty.

There is an additional field `aggregator_metrics`, which can be set if it is necessary to override the default aggregator metrics (Mean, StdDev) which are used to aggregate the trial metric values over all trials.

Since some of the metrics might require data which is only present in the frontend database and not in the tdms files (e.g. position matching indicated position), it is possible to specify the list of column names to import from the assessment mode's result table in the frontend database via the `db_result_columns_to_select` field.
The `DataProcessor` will automatically collect those column values from the input database (as list of dictionaries, one element per trial, each dictionary maps column names to the corresponding values) and the `process_tdms` function later passes this information along to the evaluator, which passes it to the metrics (db_trial_results parameter).

Each MetricEvaluator can reference multiple sub/series evaluators using the field `series_metric_evaluators`. In that case, the function get_series_idx should be overridden to return for each db_trial_result (above mentioned dict with columns from frontend result table) the index of the matching evaluator in `series_metric_evaluators` which should process that trial.

The actual evaluation logic is implemented in the MetricEvaluator base class.
The `compute_assessment_metrics` function of each evaluator gets the data for all trials it needs to process as input (raw tdms data, precomputed dictionary (see below) and db_trial_result).
For each series evaluator in `series_metric_evaluators`, the metrics corresponding to the series are computed by calling that evaluators `compute_assessment_metrics` function with all trials as input for which get_series_idx(db_trial_result) matches the evaluators index in the list.
The evaluator then computes the metrics which are defined in its own metric lists and adds them to the metrics obtained from the sub series evaluators.

The final metric values are returned as a dictionary which maps metric name (with evaluator name prepended) to the corresponding scalar metric value.

## Precomputer

It is often the case, that the same intermediate results are required to compute several different metrics. An important example would be the movement velocity, which is not part of the raw data and needs to be computed from derivative of the position.

This framework makes it possible to define custom Precomputer objects, which allow the precomputation, and thus the sharing of such intermediate results between several metrics.

There are two kinds of precomputers:
- `ValuePrecomputer`: For each trial, it gets the raw data rows with matching TrialNr and where TargetState == 1 as input and produces an arbitrary value (scalar/vector/matrix/...) as output.
- `ColumnPrecomputer`: It gets the entire raw data (all rows for all trials and no matter if TargetState) as input and produces another column with the same number of rows

Some examples of ColumnPrecomputers are `VelocityComputer` or `JerkComputer`.

Each metric class can define a list of Precomputer objects in its `requires` field. The system ensures that all Precomputers which are required by any metric of a particular metric evaluator, are precomputed before the metric evaluation, and passes the Precomputed columns or values to the metrics using the `precomputed` parameter, which is a dictionary mapping
Precomputer Object -> PrecomputedValue.

The precomputed value can then be accessed in the metric e.g. like this:
```python
# somewhere else Velocity = VelocityPrecomputer()

class SomeMetric(TrialMetric):
    # ...
    requires = (Velocity,)
    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowType) -> Scalar:
        velocity = precomputed[Velocity]
        # ...
```

It's important that the same precomputer object is used in all locations where the precomputed value/column is required. Different instances of the same precomputer class (e.g. vel1 = VelocityPrecomputer(), vel2 = VelocityPrecomputer()) are treated as different precomputers (-> same precomputation is performed twice).

Finally, Precomputers classes can also have a `requires` field with which they can depend on other Precomputers. (e.g. AbsVelocity precomputer depends on Velocity precomputer). The system will automatically ensure that the precomputers on which a precomputer depends are computed before the precomputer itself, but it is up to the user to ensure that there are no cyclic dependencies (e.g. precomputer a requiring precomputer b which requires a).
## Data Processor

The DataProcessor is responsible for:
1. Creating database tables to store the computed metrics
2. Creating database views which make it easier to work with the data in an ad-hoc fashion (e.g. from an R console) or to export the data in a human-readable format
3. Importing raw data, preprocessing the data (running [precomputers](#precomputer), changing sign for right-hand data, splitting into trials)) and obtaining metrics by running the mode-specific metric evaluator for every relevant tdms file
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