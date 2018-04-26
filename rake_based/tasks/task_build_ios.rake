# -*- coding: utf-8 -*-
# Unity3D ios빌드 자동화.
require_relative 'utils/slack.rb'
require_relative 'utils/util.rb'
require_relative 'utils/hockeyapp.rb'



require 'xcodeproj'



###################################
#
# BUILD_IOS
#
###################################
desc "BUILD_IOS"
task :build_ios, [:COUNTRY, :STAGE] do |t, args|
  country, stage = args.COUNTRY, args.STAGE
  output_path = "#{BUILD_ROOT_DIR}/#{NOW}_#{country}_#{stage}"

  bot("[BUILD] #{output_path}") if is_build_machine()
  ## START


  # 기존에 Xcode가 떠 있다면, 킬시켜주고,
  # sh "(kill $(ps aux | grep '[X]code' | awk '{print $2}')) | true"


  ## pre process

  # Unity를 활용하여 XcodeProject를 생성한다.
  FileUtils.touch(UNITY_LOG_FPATH)
  logger = FileLogger.new(UNITY_LOG_FPATH, 1) do |line|
    puts line
  end

  build_cmd = [
    UNITY,
    "-quit -batchmode",
    "-buildTarget ios",
    "-projectPath #{UNITY_PRJ_DIR}",
    "-logFile #{UNITY_LOG_FPATH}",
    "-executeMethod #{UNITY_BUILD_METHOD_IOS}",
    "-CustomArgs:output_path=#{output_path}@country=#{country}@stage=#{stage}"
  ].join(' ');
  sh build_cmd do |ok, res|
    logger.stop()

    if not ok
      bot("[ERROR] #{UNITY_LOG_FPATH}") if is_build_machine()
      abort 'the operation failed'
    end
  end



  xcodeprj_fpath = "#{output_path}/Unity-iPhone.xcodeproj"
  app_name = 'helloworld'
  archive_fpath = "#{ENV['HOME']}/Library/Developer/Xcode/Archives/#{app_name}_#{NOW}_#{country}_#{stage}/Unity-iPhone-#{app_name}.xcarchive"
  ipa_dir = "#{BUILD_IPA_DIR}/#{NOW}_#{country}_#{stage}"
  ipa_fpath = "#{ipa_dir}/Unity-iPhone.ipa"


  # 사용자 스킴 재생성.
  # ref: http://stackoverflow.com/a/20941812
  # 혹시 문제시 다음 방법 시도: http://stackoverflow.com/questions/5304031/where-does-xcode-4-store-scheme-data
  prj = Xcodeproj::Project.open(xcodeprj_fpath)
  prj.recreate_user_schemes()
  prj.save()

  # xcarchive를 생성한다.
  bot("[XARCHIVE] #{output_path}") if is_build_machine()
  sh "xcodebuild -project #{xcodeprj_fpath} -scheme Unity-iPhone archive -archivePath #{archive_fpath}"

  # ipa를 뽑아낸다.
  # bot("[IPA] #{output_path}") if is_build_machine()
  #sh "xcodebuild -exportArchive -archivePath #{archive_fpath} -exportPath #{ipa_fpath} -exportFormat ipa -exportProvisioningProfile #{PROVISIONING_NAME}"
  sh "xcodebuild -exportArchive -archivePath #{archive_fpath} -exportPath #{ipa_dir} -exportOptionsPlist #{EXPORT_OPTION_ADHOC_PLIST}"

  ## distribute
  # bot("[DIST] #{output_path}") if is_build_machine()
  if is_build_machine()
    case stage
    when 'DEV'
      service_token = config.hockey.service_token
      app_id = config.hockey.app_id
      hockey_distribute(service_token, app_id, ipa_fpath, GIT_VERSION)
    end
  end

  file_size = '%.2fmb' % (File.size(ipa_fpath).to_f / 2**20)

  bot("[DONE] #{output_path} - #{file_size}") if is_build_machine()
  ## END
end
