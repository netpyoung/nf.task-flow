require 'file-tail'
require 'thread'
require 'tempfile'

# http://flori.github.io/file-tail
class FileLogger

  def initialize(filename, interval)
    @thread = Thread.new do
      File.open(filename) do |log|
        log.extend(File::Tail)
        log.interval = interval
        log.backward(0)
        log.tail { |line| puts line }
      end
    end
  end

  def stop()
    sleep(1)
    @thread.exit
  end
end
