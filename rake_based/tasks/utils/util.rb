# -*- coding: utf-8 -*-
require 'tempfile'


class String
  def to_path(end_slash=false)
    "#{'/' if self[0]=='\\'}#{self.split('\\').join('/')}#{'/' if end_slash}"
  end
end


# http://stackoverflow.com/questions/2108727/which-in-ruby-checking-if-program-exists-in-path-from-ruby
# Cross-platform way of finding an executable in the $PATH.
#
#   which('ruby') #=> /usr/bin/ruby
def which(cmd)
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each { |ext|
      exe = File.join(path, "#{cmd}#{ext}")
      return exe if File.executable?(exe) && !File.directory?(exe)
    }
  end
  return nil
end


def get_seconds(hour, minute)
  hour * 3600 + minute * 60
end

module OSCheck
  def OSCheck.windows?
    (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OSCheck.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end
end

def is_build_machine()
  return (ENV['BUILD_NUMBER'] != nil)
end

def strip_text(text)
  splited = text.split("\n")
  if splited.count == 1
    return text
  else
    return splited[1..-1].map(&:strip).join
  end
end

def file_edit(filename, regexp, replacement)
  Tempfile.open(".#{File.basename(filename)}", File.dirname(filename)) do |tempfile|
    File.open(filename).each do |line|
      tempfile.puts line.gsub(regexp, replacement)
    end
    tempfile.fdatasync
    tempfile.close
    stat = File.stat(filename)
    FileUtils.chown stat.uid, stat.gid, tempfile.path
    FileUtils.chmod stat.mode, tempfile.path
    FileUtils.mv tempfile.path, filename
  end
end
