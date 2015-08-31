require 'optparse'
require './classes/supervisor.rb'
require './classes/bot.rb'

# Sets up command line arguments for initializing the supervisor and its bots
@options = {}
OptionParser.new do |opts|
  opts.on('-hHOST', '--host=HOST') do |str|
    @options[:host] = str
  end

  opts.on('-pPORT', '--portPORT') do |str|
    @options[:port] = str
  end

  opts.on('-tTHREADS', '--threadsTHREADS') do |str|
    @options[:threads] = [str.to_i, 1].max
  end

  opts.on('-oTIMEOUT', '--timeoutTIMEOUT') do |str|
    @options[:timeout] = [str.to_f, 300].min
  end
end.parse!

# Creates the supervisor
Thread.abort_on_exception = false
Supervisor.new(@options[:host], @options[:port], @options[:threads], @options[:timeout])