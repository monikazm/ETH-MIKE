ENABLE_MULTICORE = True

# Polybox upload directory
# (on your local file system, where the polybox client synchronizes the directory with the uploaded results)
# This should point to the 'study name' directory, which contains the 'Session Results' and 'Database Backups' subdirectories
PATH_TO_POLYBOX_UPLOAD_DIR = r'C:\Users\monikaz\polybox\KSA Longitudinal Study Data\KSA Longitudinal Study'

# Data directory
# This should be the directory where the frontend tdms and csv logs on this pc are saved / where the zips from Polybox upload dir should be extracted to
# This directory normally contains subdirectories with the subject names
PATH_TO_DATA_ROOT_DIR = r'C:\Users\monikaz\Documents\RELab\Data\KSA Longitudinal Study Extracted Data'

# If not set, mike_analysis will try to use:
# a) The path supplied as an argument to the mike_analysis script
# b) The latest database found in '$PATH_TO_POLYBOX_UPLOAD_DIR\Database Backups' (only if USE_DB_FROM_UPLOAD_DIR is set to True)
# c) The file db.db in the current directory
DB_PATH = r''
USE_DB_FROM_UPLOAD_DIR = True

IMPORT_ASSESSMENTS = {'RangeOfMotion', 'Force', 'TargetReaching', 'TargetFollowing', 'PositionMatch'} #, 'PreciseReaching'}

# If True, this script will download all data from redcap whenever it is run
REDCAP_IMPORT = True
REDCAP_URL = 'https://redcap.ethz.ch/api/'

# Put your API token here
RECAP_API_TOKEN = '7703C47999B8DFBA0C5082CC62456865'

