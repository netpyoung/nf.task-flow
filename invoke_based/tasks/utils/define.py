import time
import git
import pathlib
import os
import subprocess
import tasks
import yaml
from . import Global


#####################
# Common
#####################
NOW = time.strftime("%Y%m%d_%H%m%S")
GIT_ROOT = pathlib.PurePath(git.Repo('.', search_parent_directories=True).working_tree_dir).as_posix()
ROOT_DIR = GIT_ROOT

#####################
# Unity
#####################
UNITY_PRJ_DIR = ROOT_DIR
UNITY_VERSION = yaml.load(open(f'{UNITY_PRJ_DIR}/ProjectSettings/ProjectVersion.txt', 'r'))['m_EditorVersion']
UNITY = Global.config.Unity.macOs.format(unity_version=UNITY_VERSION)
UNITY_LOG_DIR = f'{Global.config.Dir.Log}/{os.environ.get("CI_JOB_ID")}_{NOW}'
UNITY_LOG_FPATH = f"{UNITY_LOG_DIR}/unity_engine.log"
UNITY_TEST_FPATH = f"{UNITY_LOG_DIR}/unit_test.xml"
