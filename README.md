# README #

Work in Progress.

Uses mechanize to simulate user input. Orchestrates across nodes using a TCP based Master/Slave botnet.

# INSTALLATION #
The ruby-botnet currently depends on version 2.1.2.

Install Mechanize by running `gem install mechanize` before using.

# USAGE #

To run the botnet locally on your computer, use the following:

Server:

`ruby start_server.rb --host localhost --port 4567 --threads 10 --percentage 0.9 --routine ./routines/target_app/sample_routine.txt`

Client:

`ruby start_client.rb --host localhost --port 4567 --threads 10`

You must run at least one client and one server.

# ARHITECTURE #

The tasks are distributed in a Master/Slave configuration. The server process acts as the master, coordinating the steps of the routine amongst clients. The client consists of two classes the supervisor, which handles communication between the server and the bots, and bots which perform actions on the website.

The routine begins at step 0. Once the required number of clients have connected, the server broadcasts a command to initiate the step to all clients. Each client's supervisor sends the commands to its bots and then reports back their status to the server once they have completed the step. Once the number of successful reports goes above a certain threshold, the server begins the next step, broadcasting the command to its pool of clients. Once the number of steps in the routine have been exhausted, clients are notified to stop and exit.

# CONTRIBUTING #
To add your own functionality to the ruby-botnet, you will mainly be working in the routines and commands folder.

Routines simply specify methods to be called by the bots in sequential order. These methods are defined in one of the modules in commands.

The command module that comes with the ruby-botnet is designed to test a target app. This is a simple Rails project with Devise, Posts, and Comments.

`www.github.com/jasonwc/target_app`
