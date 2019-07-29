# -*- coding: utf-8 -*-
require_relative 'utils/util.rb'
require_relative 'utils/api_server.rb'
require_relative 'utils/file_logger.rb'

require 'rake'
require 'hash_validator'
require 'open3'


# require 'oga' # for xml


########################################
#
# PATCH_ASSETBUNDLE
#
########################################

desc "PATCH_ASSETBUNDLE"
task :patch_assetbundle, [:TARGET] do |t, args|
  puts ENV['BUILD_NUMBER']
  Rake::Task["_patch_assetbundle"].invoke('JPN', 'DEV', args.TARGET)
end


task :_patch_assetbundle, [:COUNTRY, :STAGE, :TARGET] do |t, args|
  ## Validation
  validations = {
    :COUNTRY => ['KOR', 'JPN', 'ENG'],
    :STAGE => ['DEV'],
    :TARGET => ['ANDROID', 'IOS'],
  }

  validator = HashValidator.validate(args.to_hash, validations)
  if not validator.valid?
    bot("[DATAPATCH][FAIL] invalidate : #{args} | #{validations} | #{validator.errors}")
    exit(1)
  end

  # ref: http://blog.naver.com/3takugarden/220397979971
  # Adreno, Mali, Tegra


  # Power VR | RGB PVRTC 4bit | RGBA PVRTC 4bit
  # Adreno   | RGB ATC 4bit   | RGBA ATC 8bit
  # Mali-ARM | RGB ETC 4bit   | RGBA 32bit
  # Mali-T624| TGB ASTC 6*6   | RGBA ASTC 4x4
  # Tegra    | DXT1           | DXT5


  # Systeminfo.deviceModel
  # UnityEngine.iOS.Device.generation


  ## args
  country, stage, target = args.COUNTRY, args.STAGE, args.TARGET

  bot("[START] patch_assetbundle #{target}") if is_build_machine()

  ## Start
  FileUtils.touch(UNITY_LOG_FPATH)
  logger = FileLogger.new(UNITY_LOG_FPATH, 10)

  backup_root = "#{ASSETBUNDLE_DIR}/#{NOW}"
  FileUtils.mkdir_p backup_root
  # ref: http://docs.unity3d.com/Manual/CommandLineArguments.html
  build_cmd = [
    UNITY,
    "-quit -batchmode",
    "-nographics",
    "-buildTarget #{target.downcase}",
    "-projectPath #{UNITY_PRJ_DIR}",
    "-logFile #{UNITY_LOG_FPATH}",
    "-executeMethod #{UNITY_BUILD_METHOD_BUNDLE}",
    "-CustomArgs:country=#{country}@stage=#{stage}@target=#{target}@backup_root=#{backup_root}"
  ].join(' ');
  sh build_cmd do |ok, res|
    logger.stop()

    if not ok
      bot("[ERROR] #{UNITY_LOG_FPATH}") if is_build_machine()

      abort 'the operation failed'
    end
  end

  pre_ver, nxt_ver = APIServer.new(URL_DEV).with_bundle(target) do |pre_ver, nxt_ver|
    version = 0 # 0 is latest
    cmd = "aws s3 sync #{BUNDLE_UPLOAD_DIR} #{S3_BUCKET_JPN_DEV}/resource_#{target.downcase}/#{version}/ --acl public-read  --region ap-northeast-1"
    puts cmd

    # ref: http://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html
    Open3.popen3({"AWS_CONFIG_FILE" => AWS_CONFIG_FILE}, cmd) do |stdin, stdout, stderr, wait_thr|
      puts ENV['cd ']
      if stderr
	puts stderr.read
      end
      output = stdout.read
      puts output
      bot(output) if is_build_machine()
    end
    puts BUNDLE_UPLOAD_DIR
  end

  puts "#{pre_ver}, #{nxt_ver}"
  bot("[DONE] patch_assetbundle #{target}") if is_build_machine()
  puts "DONE"
  ## end
end
