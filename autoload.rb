require 'active_support/core_ext'

require 'listen'

Dir["#{File.dirname(__FILE__)}/**/*.rb"].each do |path|
  load path unless path == __FILE__
end
@callow_factotum_listener = Listen.to(File.dirname(__FILE__)) do |modified, added, removed|
  (modified + added).each {|path| load path}
end

@callow_factotum_listener.only /\.rb$/
@callow_factotum_listener.start
at_exit {@callow_factotum_listener.stop}
