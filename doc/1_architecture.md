# Architecture

## Table of Contents
[[_TOC_]]


## Introduction

The main components of the pipeline can be seen in the data flow diagram and will be explained in more detail below. 

![](doc/mike_data_analysis.png)

main.py copies assessment, session and patient data from the frontend database with the front-end migration module, uses the RedcapImporter to download and parse the data from the RedCap API and the DataProcessor to process the TDMS files (import, preprocessing, metric computation).

The DataProcessor loops over all relevant TDMS files (1 TDMS file == 1 assessment) and processes them in parallel (import and preprocessing using file_processing.py, metric computation using the MetricEvaluator corresponding to the assessment's mode).

The metric evaluator iterates over all trial metric objects defined in its *trial_metrics* field and uses them to compute metric values for all trials. The trial metric values (1 per metric and trial) are passed into the aggregator metrics objects in *aggregator_metrics* to obtain the corresponding aggregate values (1 per metric). Similarly, the metric evaluator then also iterates over its *summary_metrics* and *diff_metrics* and uses them to compute the metrics they represent.

If a metric evaluator has sub (series) evaluators defined in *series_metric_evaluators*, it uses the function *get_series_idx* (needs to be implemented when creating a new evaluator for a new assessment type with multiple series) to partition the raw data (lists with one element per trial -> lists with one element per trial of that series) and then adds the metrics which are obtained by running the corresponding sub-evaluators on the respective data partitions to its own metrics.

Each metric evaluator returns a dictionary which maps metric names (prefixed with the evaluator's name) to the corresponding scalar metric values. For the top-level evaluator of a certain assessment type, this directly corresponds to the row to be inserted into the corresponding database result table, which is then done by the DataProcessor.

## Frontend Migration

This part of the code directly copies tables, indicies and views, that are specified in the study config, from the front end database so that they can be used for analysis. 

[file_processing.py]: ../mike_analysis/core/frontend_migration.py


## Data Processor

The DataProcessor is responsible for:
1. Creating database tables to store the computed metrics
2. Creating database views which make it easier to work with the data in an ad-hoc fashion (e.g. from an R console) or to export the data in a human-readable format
3. Importing raw data, preprocessing the data (running [precomputers](#precomputer), changing sign for right-hand data, splitting into trials)) and obtaining metrics by running the mode-specific metric evaluator for every relevant TDMS file
4. Storing the obtained metrics in the database

The metric column names and types which are needed to create the tables in 1. are obtained from the respective root metric evaluator for each assessment mode.

The list of relevant TDMS file paths (i.e. TDMS files corresponding to finished assessments) can be reconstructed from the assessment, patient and session metadata tables which are copied over from the frontend database.

The helper functions used for importing and preprocessing individual TDMS files are located in [file_processing.py].

To improve performance, all TDMS files are processed in parallel.

[file_processing.py]: ../mike_analysis/core/file_processing.py

### Metrics
A Metric class defines how a certain metric is computed.
There are four different kinds of metrics:
- **Trial Metric**: A metric which is computed for every single trial. Each `TrialMetric` subclass has to implement a function which gets as input the raw data corresponding to a single trial (with Time starting at 0.0, only rows of the same trial and where TargetState == True) and produces a single scalar value as output.  
 *Examples*: Maximum Force, NIJ
- **Aggregate Metric**: An aggregate metric takes trials metric values for all trials as input and produces a single scalar value for each trial metric.  
  *Examples*: Mean, StdTop3
- **Summary Metric**: A metric which is computed based on all trials. Each `SummaryMetric` subclass has to implement a function which gets as input the raw data corresponding to all trials and produces a single scalar value.  
  *Example*: Position Matching RMSE
- **Diff Metric**: A special metric type which takes two aggregated trial (i.e. with e.g. "Mean" suffix), summary or diff metric names as input and returns the difference between those two metrics as a new metric.

It is possible to add new metrics to the system by implementing additional `TrialMetric/AggregateMetric/SummaryMetric` subclasses.

### Metric Evaluator

A Metric Evaluator class defines which metrics are to be computed for a particular assessment mode (e.g. Force, Range of Motion) or subseries of an assessment mode (e.g. Flexion/Extension for Force, Active/Passive/Auto for ROM).

[metric evaluators]: ../mike_analysis/evaluators

### Evaluation Logic

During evaluation, the evaluator receives three lists as input, which have as many elements as there are assessment trials which need to be processed by this evaluator.
- all_trials: List of data frames which contain the preprocessed (filtered position, rows with TargetState=False removed, Time starts at 0.0) raw data for each trial
- all_precomputed: List of dictionaries which map Precomputer objects to their corresponding precomputed columns/values (see [Precomputer](#precomputer)) for each trial
- db_results: List which contains for each trial a dictionary with data from the frontend database's result table corresponding to the assessment's type. Which columns are included in this data depends on the evaluator's `db_result_columns_to_select` field, which specifies the columns to SELECT from the table. A Metric Evaluator should include all columns in this field, which either cannot be inferred from the raw TDMS data (e.g. `indicated` position value from the `PositionMatchResult` table) or which are required to determine to which data series the trial belongs (e.g. `Flexion` column for `ForceResult` table).

#### Metric Computation
1. The evaluator will build a data frame (rows == trials, columns == metrics), which contains for each `TrialMetric` in its `trial_metrics` field, a corresponding computed metric value for every trial.

2. This data frame is then used as input to all `AggregateMetrics` in `aggregator_metrics`, to obtain one scalar aggregate value per `AggregateMetric` and `TrialMetric` combination. If `aggregator_metrics` is not redefined, the default aggregate metrics `Mean` and `Std` are used.

3. The evaluator then also computes all `summary_metrics` using the data for all trials as input (*Examples*: RMSE in position matching, PercentageOfTrialsWithTargetNotReached for target reaching), and all `diff_metrics`, which compute the absolute difference between two of the other metrics (*Example*: Difference between active and passive ROM).

#### Delegation for sub data-series (e.g. Flexion/Extension)
An evaluator can also delegate metric computation for subsets of the trials to different sub/"series" evaluators. This is useful if you want to compute metrics separately for some of the trials (e.g. You want different means for flexion/extension trials, or you want a different set of metrics for active/passive/automatic range of motion).

This works by specifying the evaluator objects for the different series (e.g. Flexion/Extension) in the `series_metric_evaluators` list field.
You then have to implement the function `get_series_idx` which should return for any trial (or rather for any `db_result`), the index of the evaluator in `series_metric_evaluator` which should be used to process that particular trial.

At runtime, the evaluator then splits the trials into subsets according to `get_series_idx` and uses each sub/series evaluator to compute the metrics of the corresponding subset.

Each evaluator returns all its computed summary, diff and aggregated trial metric values (including those computed by sub/series evaluators) in the form of a dictionary which maps metric names (prepended with the evaluator's name) to the corresponding metric values.

### Defining a new MetricEvaluator
Most of the evaluation logic is contained in the base class `MetricEvaluator` and does not have to be touched. Concrete evaluators are thus created in a mostly declarative way.

To define an evaluator for a new task, simply:
1. Create a class which inherits from `MetricEvaluator`
2. Define the name it should prepend to all metrics by specifying `name_prefix: str = 'YourNamePrefix'`
3. List all columns which are needed from the frontend result table in `db_result_columns_to_select` (can also be SQL expressions, not just column names, as this will be used in the SELECT part of the query 1:1)
4. Redefine `trial_metrics`, `summary_metrics`, `diff_metrics` and `aggregator_metics` as desired
5. (only if there are multiple data series):
    1. Repeat steps 1-4 for each series (you might be able to reuse a class for multiple series, if they share the same metrics)
    2. Redefine `series_metric_evaluators` to include instances of these series metric evaluator classes (one per series).
    3. Override the `get_series_idx` function such that it assigns trials to the correct series evaluator.  

See existing [metric evaluators] implementations for examples.

### Precomputer

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
    def compute_single_trial(self, trial_data: pd.DataFrame, precomputed: PrecomputeDict, db_trial_result: RowDict) -> Scalar:
        velocity = precomputed[Velocity]
        # ...
```

It's important that the same precomputer object is used in all locations where the precomputed value/column is required. Different instances of the same precomputer class (e.g. vel1 = VelocityPrecomputer(), vel2 = VelocityPrecomputer()) are treated as different precomputers (-> same precomputation is performed twice).

Finally, Precomputers classes can also have a `requires` field with which they can depend on other Precomputers. (e.g. AbsVelocity precomputer depends on Velocity precomputer). The system will automatically ensure that the precomputers on which a precomputer depends are computed before the precomputer itself, but it is up to the user to ensure that there are no cyclic dependencies (e.g. precomputer a requiring precomputer b which requires a).

## RedCap Importer

The RedCap importer is responsible for:
1. Creating database tables which match the data model of the redcap project (i.e. 1 table per form/instrument with columns corresponding to the form fields)
2. Downloading data from the RedCap REST (https) API

To achieve 1. certain information about the data fields in the RedCap project is required.
While some information cannot be inferred from the API (e.g. mapping of redcap form names to table names, name of the main identifier field, which columns to ignore...) and needs to be manually specified in [study_config.py], most of the necessary information is retrieved directly from RedCap (data dictionary, list of repeating events, etc.).

The RedCap data_dictionary is used determine the field/columns names of the different forms.
The data types of these columns are determined via some heuristics (e.g. based on the field type or text validation type). See the function `export_columns` in [redcap_api.py].

What remains is to determine the primary key for each form table (i.e. fields which identify a single table row / form instance). In all cases, the main redcap record identifer is part of the primary key ('study_id' by default). If a form/instrument appears in multiple events of a longitudinal study, the `redcap_event_name` also needs to be included (and in case of repeating events or instruments also `redcap_repeat_instrument` or `redcap_repeat_instance`). All of this can be determined dynamically from the API.

Example: Demographics form appears only in one event, no repetitions => `primary key == 'study_id'`. RoboticAssessment form appears in several events and is also part of at least one repeating event => `primary key == ('study_id', 'redcap_event_name', 'redcap_repeat_instance')`.

For 2. the data can be retrieved using the RedCap `export_records` API, which returns one giant table with all the data for all forms from which the individual rows to insert into the database tables can then be extracted.

[redcap_importer.py]: ../mike_analysis/core/redcap_importer.py

[redcap_api.py]: ../mike_analysis/core/redcap_api.py

## Study config

The study configuration is used to determine, what is copied from the frontend, what is imported from REDCap and how all the information is combined into additional study specific views in the output database. If you want to create a new study you can copy the template and fill in all the required information. Add the code needed for additional study specific views or modifications to the output database to the `create_study_views(migrator: SQLiteMigrator)` function. This function will be called in the end and has therefore acces to everything that was already transfered into the output database. 

[study_config.py]: ../mike_analysis/study_config.py

