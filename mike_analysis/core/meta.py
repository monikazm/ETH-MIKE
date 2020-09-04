# Standardized column names
from enum import IntEnum

TimeCol = 'Time'
TrialCol = 'Trial'
TSCol = 'TargetState'
RStateCol = 'RomState'
PosCol = 'Pos'
SPosCol = 'StartingPos'
TPosCol = 'TargetPos'
ForceCol: str = 'Force'
VelCol = 'Velocity'
DfDtCol = 'dFdT'

col_names = [TimeCol, TrialCol, TSCol, RStateCol, PosCol, SPosCol, TPosCol, ForceCol]

# Matching columns names in csv and tdms files
csv_cols = ['Time', 'TrialNr', 'TargetState', 'RomState', 'Position', 'StartingPosition', 'TargetPosition', 'Force']
tdms_cols = ['Time [s]', 'Trial Nr', 'Target state?', 'ROM State 0-Active 1-Passive 2-Automatic', 'Position [deg]', 'Starting position [deg]', 'Target Position [deg]', 'Force filtered [N] ']


# Names of these enum entries must match result table names
class Modes(IntEnum):
    RangeOfMotion = 0
    Force = 1
    TargetReaching = 2
    TargetFollowing = 3
    PositionMatch = 4
    PreciseReaching = 5


# Assessment mode descriptions (== name of assessment folders in data folder)
ModeDescs = {
    Modes.RangeOfMotion: 'Range Of Motion Task',
    Modes.Force: 'Force Task',
    Modes.TargetReaching: 'Motor Task',
    Modes.TargetFollowing: 'Sensorimotor Task',
    Modes.PositionMatch: 'Position Matching Task',
    Modes.PreciseReaching: 'Precise Reaching Task'
}


class AssessmentState(IntEnum):
    InProgress = 0
    Aborted = 1
    Discarded = 2
    Finished = 3


class RomPhase(IntEnum):
    Active = 0
    Passive = 1
    AutomaticPassive = 2


class Tables:
    Patient = 'Patient'
    Assessment = 'Assessment'
    Session = 'Session'
    Results = {m: f'{m.name}Result' for m in Modes}
