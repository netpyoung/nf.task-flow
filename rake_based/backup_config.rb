# -*- coding: utf-8 -*-
# TODO(pyoung): backup
require 'date'
require 'fileutils'

#####################
# Common
#####################
NOW = Time.now.strftime("%Y%m%d_%H%M%S")
GIT_ROOT = `git rev-parse --show-toplevel`.strip
GIT_VERSION = `git rev-parse HEAD`.strip
ROOT_DIR = GIT_ROOT
URL_DEV = "http://dev"

#####################
# Unity
#####################
UNITY = which('unity')
#UNITY = '/Applications/Unity2017.1.0f3/Unity2017.1.0f3.app/Contents/MacOS/Unity'
#UNITY = '/Applications/Unity2017.2.0b8/Unity.app/Contents/MacOS/Unity'
#UNITY = '/Applications/Unity2017.1.0p4/Unity.app/Contents/MacOS/Unity'
UNITY = '"C:/Program Files/Unity2017.1.0f3/Editor/Unity.exe"'

UNITY_PRJ_DIR = "#{ROOT_DIR}/unity_project"
BUNDLE_UPLOAD_DIR = "#{ROOT_DIR}/unity_project/__LATEST"
BUILD_ROOT_DIR = "#{ROOT_DIR}/BUILD" # "#{ROOT_DIR}/BUILD"
BUILD_IPA_DIR = "#{BUILD_ROOT_DIR}/ipa"
UNITY_LOG_FPATH = "#{BUILD_ROOT_DIR}/log/#{NOW}.log"
ASSETBUNDLE_DIR = "#{ROOT_DIR}/__ASSETBUNDLE"

EXPORT_OPTION_ADHOC_PLIST = "#{ROOT_DIR}/build_resources/apple/export_option_adhoc.plist"


FileUtils.mkdir BUILD_ROOT_DIR          unless File.exist?(BUILD_ROOT_DIR)
FileUtils.mkdir BUILD_IPA_DIR          unless File.exist?(BUILD_IPA_DIR)
FileUtils.mkdir "#{BUILD_ROOT_DIR}/log" unless File.exist?("#{BUILD_ROOT_DIR}/log")
FileUtils::mkdir_p ASSETBUNDLE_DIR

UNITY_BUILD_METHOD_AND = 'NFEditor.Batch.ExecuteMethods.BuildAnd'
UNITY_BUILD_METHOD_IOS = 'NFEditor.Batch.ExecuteMethods.BuildIOS'
UNITY_BUILD_METHOD_WIN = 'ExecuteMethods.WINDOWS_DEV'
UNITY_BUILD_METHOD_BUNDLE = 'NFEditor.Batch.ExecuteMethods.BuildPatchResource'

S3_BUCKET = 's3://'
AWS_CONFIG_FILE = "#{ROOT_DIR}/build_resources/s3_access_credentials"
## Unity - iOS
PROVISIONING_NAME = "" # TODO: country, stage, market별 분기 처리.


## ref: http://dobiho.com/?p=7192
# 용량 부족시 정리.
#  Xcode > Preference > Locations
# ~/Library/Developer/Xcode/DerivedData
# ~/Library/Developer/Xcode/Archives
# ~/Library/Developer/Xcode/iOS Device Logs
# ~/Library/Developer/Xcode/ iOS DeviceSupport





#####################
# Jenkins
#####################
JENKINS_ROOT_URL = 'http://JENKINS_URL:8080'
JENKINS_JOB_AND = "#{JENKINS_ROOT_URL}/job/BUILD_AND"
JENKINS_JOB_IOS = "#{JENKINS_ROOT_URL}/job/BUILD_IOS"

#####################
# Etc
#####################

DRIP_MESSAGE = <<EOS
(ノಠ益ಠ)ノ ┻━┻
EOS

# https://get.slack.help/hc/en-us/articles/206870177-Creating-custom-emoji
# https://get.slack.help/hc/en-us/articles/202931348-Emoji-and-emoticons
