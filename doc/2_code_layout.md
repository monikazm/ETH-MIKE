# Project Layout
## Root Folder
- **[requirements.txt]**: Python library dependencies
- **[metric_metadata_defaults.csv]**: CSV file where you can define healthy avg and Srd values for different metrics
- **[mike_analysis]**: Source code folder
- **config.py** (generated after first run): configuration file to specify settings 
- **[main.py]**: Entry point

## Code Folder (mike_analysis) 
### Files

- **[config.py.template]**: When there is no config.py, a new one is generated based on the contents of this file
- **[cfg.py]**: Loads config.py at runtime (code can then access the values in config.py via the cfg.config variable)
- **[study_config.py]**: Contains stuff which is specific to your redcap structure. Change in redcap structure (form names, new form, rename of some key fields like subject_code) => need to adjust study_config.py.

### Packages
- **[core]**: Implementation of the data analysis framework (all general functionality + abstract base classes for evaluators, metrics and precomputers)
- **[evaluators]**: One evaluator per assessment type. Evaluators specify the different sub series, which columns from the frontend result table are needed, and which metrics need to be evaluated.
- **[metrics]**: Implementations of different metrics. The different files correspond to different categories of metrics and each contains the definitions of several metrics.
- **[precomputers]**: Implementations of "precomputers", which are objects that precompute additional columns or intermediate results which are required to compute certain metrics.
- **[tests]**: Unit tests for the data analysis framework code


[//]: # (Links below here)

[requirements.txt]: ../requirements.txt
[metric_metadata_defaults.csv]: ../metric_metadata_defaults.csv
[mike_analysis]: ../mike_analysis

[main.py]: ../mike_analysis/main.py
[config.py.template]: ../mike_analysis/config.py.template
[cfg.py]: ../mike_analysis/cfg.py
[study_config.py]: ../mike_analysis/study_config.py

[core]: ../mike_analysis/core
[evaluators]: ../mike_analysis/evaluators
[metrics]: ../mike_analysis/metrics
[precomputers]: ../mike_analysis/precomputers
[tests]: ../mike_analysis/tests