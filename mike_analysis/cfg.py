import os
import importlib.util
from pathlib import Path

from mike_analysis.core.constants import Modes

__this_folder = Path(os.path.dirname(os.path.realpath(__file__)))
with open(os.path.join(__this_folder, 'config.py.template')) as file:
    _TEMPLATE = file.read().replace("'$ALL_MODES'", f', '.join([f"'{mode.name}'" for mode in Modes])).lstrip()

__config_file_path = __this_folder.parent.joinpath('config.py')
if not __config_file_path.exists():
    with open(__config_file_path, 'w') as fout:
        fout.write(_TEMPLATE)

_spec = importlib.util.spec_from_file_location("config", __config_file_path)
config = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(config)
