import os
import importlib.util

_TEMPLATE = '''
ENABLE_MULTICORE = True

REDCAP_IMPORT = False
REDCAP_URL = 'https://redcap.ethz.ch/api/'
RECAP_API_TOKEN = ''

REDCAP_RECORD_IDENTIFIER = 'study_id'
REDCAP_EXCLUDED_COLS = {'gender', 'handedness', 'impaired_side', 'details_on_stroke', 'date_mri', 'lesion_location_detailed'}
REDCAP_NAMES_AND_INDEX_COLS = {
    'demographics_5760': ('Demographics', ['subject_code']),
    'clinical_assessments': ('ClinicalAssessment', []),
    'robotic_assessments': ('RoboticAssessment', ['robotic_session_number']),
    'neurophysiology': ('Neurophysiology', []),
}
'''

if not os.path.exists('config.py'):
    with open('config.py', 'w') as fout:
        fout.write(_TEMPLATE)

_spec = importlib.util.spec_from_file_location("config", './config.py')
config = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(config)
