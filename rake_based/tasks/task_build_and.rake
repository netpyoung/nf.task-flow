# -*- coding: utf-8 -*-
require_relative 'utils/util.rb'
require_relative 'utils/slack.rb'
require_relative 'utils/hockeyapp.rb'
require_relative 'utils/Global.rb'

require 'rake'

desc "ff"
task :ff do
  puts Global.config.Jenkins.url
  a = 10
  puts Global.config.Unity.windows
  puts Global.config.Project
  puts Global.config['Project']

end

###################################
#
# BUILD_AND
#
###################################
desc "build android"
task :build_and, [:COUNTRY, :STAGE] do |t, args|
  country, stage = args.COUNTRY, args.STAGE
  build_number = ENV['BUILD_NUMBER']
  output_path = "#{BUILD_ROOT_DIR}/#{NOW}_#{country}_#{stage}.apk"

  puts "OUTPUT PATH: #{output_path}"
  bot("[BUILD] #{output_path}") if is_build_machine()
  ## START

  ## pre process

  ## Unity를 활용하여 APK를 생성한다.
  FileUtils.touch(UNITY_LOG_FPATH)
  logger = FileLogger.new(UNITY_LOG_FPATH, 10)

  # ref: http://docs.unity3d.com/Manual/CommandLineArguments.html
  build_cmd = [
    UNITY,
    "-quit -batchmode",
    "-nographics",
    "-buildTarget android",
    "-projectPath #{UNITY_PRJ_DIR}",
    "-logFile #{UNITY_LOG_FPATH}",
    "-executeMethod #{UNITY_BUILD_METHOD_AND}",
    "-CustomArgs:output_path=#{output_path}@country=#{country}@stage=#{stage}"
  ].join(' ');
  sh build_cmd do |ok, res|
    logger.stop()

    if not ok
      bot("[ERROR] #{UNITY_LOG_FPATH}") if is_build_machine()

      abort 'the operation failed'
    end
  end

  # bot("[DIST] #{output_path}") if is_build_machine()

  ## distribute
  if is_build_machine()
    case stage
    when 'DEV'
      service_token = config.hockey.service_token
      app_id = config.hockey.app_id
      hockey_distribute(service_token, app_id, output_path, GIT_VERSION)
    end
  end

  file_size = '%.2fmb' % (File.size(output_path).to_f / 2**20)

  bot("[DONE] #{output_path} - #{file_size}") if is_build_machine()
  ## END
end
