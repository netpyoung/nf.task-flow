invoke-based
============

## bootstrap

```sh
export PATH_PYENV="$(pyenv root)/shims"
export PATH="$PATH_PYENV:$PATH"
pip install -r requirements.txt
inv -l
```


``` sh
# upgrade
pip install --upgrade --force-reinstall -r requirements.txt
```

## access config

```python
from . utils import Global
Global.config.A
```

# python
* https://github.com/pyenv/pyenv
* http://www.pyinvoke.org/

# TODO
* aws
* google drive
* hockeyapp
* ftp
* api server
* log file tail
* bot
* jenkins

# gitlab

``` python
pip install python-gitlab

gl = gitlab.Gitlab('https://hello.world', private_token=private_token)
project = gl.projects.get(project_id)
mr = project.mergerequests.create({'source_branch': branch_name,
                                   'target_branch': 'develop',
                                   'title': f'title',
                                   'labels': []})
mr.save()
```

`
