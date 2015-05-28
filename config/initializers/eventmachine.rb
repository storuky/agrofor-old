# unless EventMachine.reactor_running? && EventMachine.reactor_thread.alive?
#   Thread.new { EventMachine.run }
# end