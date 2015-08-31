require 'optparse'
require './classes/server.rb'

# Sets up command line arguments for intializing the server
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

  opts.on('-pPERCENTAGE', '--percentagePERCENTAGE') do |str|
    @options[:percentage] = [str.to_f, 1.0].min
  end

  opts.on("-rROUTINE", '--routineROUTINE') do |str|
    @options[:routine] = str
  end

  opts.on("-eEC2", "--ec2EC2") do |str|
    @options[:ec2] = true if str == 'true'
  end
end.parse!

# Reads in the routine that will be run
@routine = File.readlines(@options[:routine]).map(&:chomp)
# Creates the server and sets up the Amazon EC2 Instances
puts "Running server on #{@options[:host]}:#{@options[:port]}. Waiting for #{ @options[:threads]} bots to connect."
Server.new(@options[:host], @options[:port], @options[:threads], @options[:percentage]).run(@routine)