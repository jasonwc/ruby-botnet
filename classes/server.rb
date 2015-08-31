require 'json'
require "socket"

class Server
  # Initializes the server
  def initialize(ip, port, min_size, percentage)
    @server = TCPServer.open(ip, port)
    @clients = []
    @bot_count = {}
    @responses = Hash.new{|h,k| h[k] = 0}
    @min_size = min_size

    # The minimum percentage of clients that
    # must have succeeded before we can move on to
    # the next step:
    @percentage = percentage
  end
  
  def before(&block)
    @before = block
    self
  end

  def after(&block)
    @after = block
    self
  end

  # Connects with the clients, accepts a handshake from them, and then listens to responses.
  # Once enough clients have connected, it will start the routine
  def connect_clients
    loop do
      puts "Clients: #{@clients.size} | Bots: #{current_bot_count} / #{@min_size}"
      break if current_bot_count == @min_size
      client = @server.accept
      @clients << client
      supervisor_id = accept_handshake(client)
      Thread.new do
        listen_responses(client, supervisor_id)
      end
      break if current_bot_count == @min_size
      sleep 0.0001
    end
  end

  # Accepts handshake from client to determine the Supervisor and the amount of bots its has, return supervisor_id
  def accept_handshake(client)
    handshake = JSON.parse(client.gets)
    supervisor_id = handshake['id']
    bot_count = handshake['bot_count']
    puts "Client connected: #{supervisor_id} with #{bot_count} bots"
    @bot_count[supervisor_id] = bot_count
    supervisor_id
  end

  # Listens to responses from the client and increments the connection count and responses
  def listen_responses(client, supervisor_id)
    loop do 
      begin 
        if a = client.gets
          message = JSON.parse(a)
          puts "Client response: #{ a }"
          if message['status'] == "dead"
            puts "Lost #{message['id']}"
            @bot_count[supervisor_id] -= 1
          else
            @responses[message['step']] += 1
          end
        end
      rescue SystemCallError
        @bot_count[supervisor_id] -= 1
      end
      sleep 0.01
    end
  end

  # Handles stepping through the routine and sending commands to the client as they respond back
  def run(routine)
    @before.call if @before
    @current_step = 0 
    @routine = routine
    @steps = routine.size - 1
    connect_clients
    puts "Begin Operation Lightning Bloodhound"
    broadcast(current_command)
    loop  do
      break if current_bot_count == 0
      puts "Response Ratio: #{ current_response_ratio }/#{ @percentage  } | Supervisors: #{ @clients.size } | Bots: #{ current_bot_count }| Step: #{ @current_step }/ #{ @steps }"
      puts @responses
      if current_response_ratio >= @percentage && @current_step <= (@steps + 1)
        @current_step += 1
        puts "response ratio greater than specified value, incrementing step: #{ @current_step }"
        broadcast(current_command)
      end
      break if @current_step > (@steps) || @connection_count == 0
      sleep 0.5
    end
    puts "Ending Operation Lightning Bloodhound."
    @after.call if @after
  end

  # Broadcasts the current step to the clients
  def broadcast(message)
    puts "Broadcasting message: #{ message }"
    @clients.each do |c|
      begin 
        c.puts message.to_json
      rescue SystemCallError
        puts "connection with client lost"
      end
    end
  end

  # Returns the current step to broadcast to the clients
  def current_command
    if @current_step <= @steps
      {command: "VISIT", method: @routine[@current_step], step: @current_step}
    else
      {command: "STOP"}
    end
  end

  # Retuns the current response ratio
  def current_response_ratio
    if @responses[@current_step] > 0
      @responses[@current_step].to_f / current_bot_count.to_f
    else
      0
    end
  end
 
  # Returns the current bot count for all supervisors
  def current_bot_count
    @bot_count.values.inject(:+)
  end
end