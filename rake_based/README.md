rake-based
==========

## bootstrap

```sh
gem install bundler
bundle install
rake -T

```

## access config

```ruby
require_relative 'utils/Global.rb'
Global.config.A
```

# ref
* ruby
  - https://www.ruby-lang.org/

* install
  - https://github.com/rbenv/rbenv
  - https://rubyinstaller.org/

* package manager
  - http://bundler.io/

# don't forget T_T

```ruby
require
require_relative
Rake.add_rakelib

Rake::Task
```

# TODO
* ext_api/aws
* ext_api/hockeyapp
* ext_api/google drive
* file/ftp
* file/sftp
* file/log file tail
* file/http file download
* file/hash - md5, json
* web api/ post api server
* web api/slack
* web api/jenkins
