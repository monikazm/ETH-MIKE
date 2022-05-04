from mike_analysis.core.constants import RCCols
from mike_analysis.core.sqlite_migrator import SQLiteMigrator

###########################################################
# Tables
############################################################

# Can be used to copy e.g. tables needed to copy certain views
# always specify "table_name: table_index"
IMPORT_TABLES = {}

IMPORT_ASSESSMENT_TABLES = {}
IMPORT_THERAPY_TABLES = {}

############################################################
# Views
############################################################

# Copy over the assesment result views. make sure that the tables the views depend on are specified in IMPORT_ADDITIONAL_TABLES.

# Views with one row per trial
IMPORT_ASSESSMENT_RESULTS_FULL_VIEW = False
# Views with average score over all trials of the same exercise
IMPORT_ASSESSMENT_RESULTS_AGGREGATE_VIEW = False

# Copy over the therapy result views:
# Views with one row per trial
IMPORT_THERAPY_RESULTS_FULL_VIEW = False
# Views with average score over all trials of the same exercise
IMPORT_THERAPY_RESULTS_AGGREGATE_VIEW = False

############################################################
# REDCap
############################################################


REDCAP_RECORD_IDENTIFIER = ''
REDCAP_EXCLUDED_COLS = {'example_column'}
REDCAP_NAMES_AND_INDEX_COLS = {
    'Internal Name': ('REDCap Name', ['Identifier'])}


############################################################
# Helper functions
############################################################


def create_study_views(migrator: SQLiteMigrator):
    # Add code to create views custom to your study here
    return

############################################################
# Helper functions
############################################################