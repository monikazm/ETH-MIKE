import os
import importlib.util

from mike_analysis.core.meta import Modes

_TEMPLATE = r'''
ENABLE_MULTICORE = True

# Polybox upload directory
# (on your local file system, where the polybox client synchronizes the directory with the uploaded results)
# This should point to the 'study name' directory, which contains the 'Session Results' and 'Database Backups' subdirectories
PATH_TO_POLYBOX_UPLOAD_DIR = r'C:\Path\To\Polybox\DataUploadFileDropDir\StudyName'

# Data directory
# This should be the directory where the frontend tdms and csv logs on this pc are saved / where the zips from Polybox upload dir should be extracted to
# This directory normally contains subdirectories with the subject names
PATH_TO_DATA_ROOT_DIR = r'C:\Users\SomeUser\Desktop\StudyName'

# If not set, mike_analysis will try to use:
# a) The path supplied as an argument to the mike_analysis script
# b) The latest database found in '$PATH_TO_POLYBOX_UPLOAD_DIR\Database Backups' (only if USE_DB_FROM_UPLOAD_DIR is set to True)
# c) The file db.db in the current directory
DB_PATH = r''
USE_DB_FROM_UPLOAD_DIR = True

IMPORT_ASSESSMENTS = {''' + f', '.join([f"'{mode.name}'" for mode in Modes]) + '''}

# If True, this script will download all data from redcap whenever it is run
REDCAP_IMPORT = False
REDCAP_URL = 'https://redcap.ethz.ch/api/'

# Put your API token here
RECAP_API_TOKEN = ''

REDCAP_RECORD_IDENTIFIER = 'study_id'
REDCAP_EXCLUDED_COLS = {'gender', 'handedness', 'impaired_side', 'details_on_stroke', 'date_mri', 'lesion_location_detailed'}
REDCAP_NAMES_AND_INDEX_COLS = {
    'demographics_5760': ('Demographics', ['subject_code']),
    'clinical_assessments': ('ClinicalAssessment', []),
    'robotic_assessments': ('RoboticAssessment', ['robotic_session_number']),
    'neurophysiology': ('Neurophysiology', []),
}
'''.lstrip()

if not os.path.exists('config.py'):
    with open('config.py', 'w') as fout:
        fout.write(_TEMPLATE)

_spec = importlib.util.spec_from_file_location("config", './config.py')
config = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(config)
