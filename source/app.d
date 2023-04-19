import std.stdio;
import controller;
public import server;




void main(string[] args){


	if(args.length != 2){
		writeln("Invalid arguments");
	}
	else{
		try{
			if (args[1]=="server"){
				Server server = new Server();
				server.run();
			}
			else if ( args[1] == "client"){
				Client client = new Client();
				client.run();
			}
		}
		catch(Throwable t){
			writeln(args[1]~" stopped ");
		}
	}
}