from mike_analysis.core.constants import RCCols
from mike_analysis.core.sqlite_migrator import SQLiteMigrator


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