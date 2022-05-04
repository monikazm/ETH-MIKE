# List of Potential Improvements

- Clean up DataProcessor, FileProcessor and SQLMigrator structure. try to split functionality into small functions (target 20 lines of code, max 50) that achieve 1 clear task at a time. This would improve hthe radability and help ne users to get started.   

- Unify formats between frond end, redcap and analysis software (e.g. time, date, units)

- Eliminate or reduce hard hard coded parameters in constants.py

- complete the 12 unittests in `mike_analysis/tests/test_metric_calculation` that are not impleented yet. Cover aditional code components with unit tests.

- Add continuous testing to github. Through a range of automated tests it gets much easier to assure that any changes to the software do not break combatibility with the longitudinal and therapy study. Ideally this is done by a test job that has acces to the required data and redcap API to test each study. Also the tests in the `mike_analysis/tests` folder should be covered here.  

- Add a warning when therapy/assessment dates are present in the frontend data but are missing on redcap. The opposite will be visible by having NULL entries in the Therapy-/AssessmentCombined views. But having no entries for assessment, therapy or subjectcode in demographics will just in no row being created in the resulting view. 