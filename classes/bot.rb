# Libraries/Gems
# If you wish to go with something besides mechanize, just add a different gem
require 'mechanize'
# Command Modules for Bot class
require './commands/target_app.rb'

class Bot
  # This is the command module that is included. Write your own with the specific user actions you wish to simulate and include it here.
  include TargetApp
  attr_accessor :queue, :thread

  # Initializes a bot with a unique id, mechanize agent, variable to keep track of
  # state, queues to send responses to and receive commands from the supervisor
  # and starts the run command in a new thread
  def initialize(responses, queue)
    @id = "Bot-" + SecureRandom.uuid
    @responses = responses
    @queue = queue
    @agent = Mechanize.new
    @state = {}
    @thread = Thread.new {run}
  end

  # Waits for new commands from the supervisor, executes them, and reports back to the
  # supervisor
  def run
    begin
      loop do
        command = @queue.pop
        start_time = Time.now
        # Commands are defined in command modules
        command['command'] == 'STOP' ? break : self.send(command['method'].to_sym, @agent, @state)
        end_time = Time.now
        diff = end_time - start_time
        @responses << {id: @id, command: command['command'], method: command['method'], step: command['step'], status: @agent.page.code, time: diff}
        break unless ['200', '301', '302'].include? @agent.page.code
      end
    rescue Exception => e
      puts "Something went wrong! Bot: #{@id}, #{e}"
      @responses << {id: @id, status: 'dead'}
    end
  end
end