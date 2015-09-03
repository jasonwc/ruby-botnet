require 'optparse'
require 'json'

class Supervisor
  MAX_RETRIES = 2
  attr_accessor :bots

  # Opens a connection with the server and sets up bots and a responses queue
  def initialize(host, port, threads)
    begin
      @id = "Supervisor-" + SecureRandom.uuid
      @socket = TCPSocket.new(host, port)
      @responses = Queue.new
      @retry_count = 0
      @threads = threads
      @bots = initialize_bots
    rescue Exception => e
      puts "Issue connecting to server, retrying in 5 seconds"
      puts "Exception was: #{e}"
      sleep 5
      retry
    end
    send_handshake
    run
  end

  # Creates bots with the responses queue, and a unique queue to pass commands to the bots
  def initialize_bots
    @threads.times.map do
      queue = Queue.new
      Bot.new(@responses, queue)
    end
  end

  # Sends an initial handshake to the server to identify itself and establish its
  # bot count
  def send_handshake
    @socket.puts({id: @id, bot_count: @bots.size }.to_json)
  end

  # Starts a thread to monitor responses from the bots and broadcasts commands from
  # the server to the bots
  def run
    Thread.new {monitor_responses}
    until (curr = get_current_command) && curr['command'] == 'STOP'
      @bots.each{|b| b.queue << curr}
    end
  end

  # Montiors responses from the bots and passes them to the server
  def monitor_responses
    loop do
      response = @responses.pop
      response[:supervisor_id] = @id
      puts response
      @socket.puts(response.to_json)
      check_bot_status
    end
  end

  # Gets commands from the server
  def get_current_command
    command = JSON.parse(@socket.gets)
    puts "Received: #{command} "
    command
  end

  # Checks to see if any bots are alive. If all have died, aborts.
  def check_bot_status
    unless any_bots_alive?
      abort("All bots have died. Exiting.")
    end
  end

  # Grabs eachs bots thread and checks if it's alive
  def any_bots_alive?
    @bots.map{|b| b.thread.alive?}.include? true
  end
end