require 'pikebubbles'
module Pikebubbles
  class Cli
    def self.run
      $stdin.close

      File.mkfifo("/var/run/pikebubbles.fifo", 0666)
      $stderr.puts "Opened FIFO: /var/run/pikebubbles.fifo"
      @fifo = File.open("/var/run/pikebubbles.fifo", 'r')
      while line = @fifo.readline(4096)
        $stdin.print line
      end
    ensure
      begin
        @fifo.close
        File.delete("/var/run/pikebubbles.fifo")
      rescue => e
        $stderr.p e
      end
      $stderr.puts "Termed pikebubbles"
    end
  end
end
