import os
import importlib.util

from mike_analysis.core.meta import Modes

with open(os.path.join(os.path.dirname(os.path.realpath(__file__)), 'config.py.template')) as file:
    _TEMPLATE = file.read().replace("'$ALL_MODES'", f', '.join([f"'{mode.name}'" for mode in Modes])).lstrip()

if not os.path.exists('config.py'):
    with open('config.py', 'w') as fout:
        fout.write(_TEMPLATE)

_spec = importlib.util.spec_from_file_location("config", './config.py')
config = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(config)
