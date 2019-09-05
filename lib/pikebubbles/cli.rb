require 'pikebubbles'
module Pikebubbles
  class Cli
    def self.run
      $stdin.close

      File.mkfifo("/var/run/pikebubbles.fifo", 0666)
      $stderr.puts "Opened FIFO: /var/run/pikebubbles.fifo"
      @fifo = File.open("/var/run/pikebubbles.fifo", 'r')
      loop do
        lines = @fifo.readlines(4096)
        unless lines.empty?
          lines.each do |line|
            $stdout.print line
          end
        end
      end
    ensure
      begin
        @fifo.close
        File.delete("/var/run/pikebubbles.fifo")
      rescue => e
        $stderr.print e.inspect
      end
      $stderr.puts "Termed pikebubbles"
    end
  end
end
