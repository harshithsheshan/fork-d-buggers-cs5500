import std.stdio;
import controller;
public import server;




void main(string[] args){

	//TCPServer server = new TCPServer;
	//server.run();

	//TCPClient client = new TCPClient();
	//client.run();
	//writeln("args:"~args[]~"and"~args[1]);
	if(args.length != 2){
		writeln("Invalid arguments");
	}
	else{
		if(args[1]=="server"){
			TCPServer server = new TCPServer();
			server.run();
		}
		else if( args[1] == "client"){
			Client client = new Client();
			client.run();
		}
		//Client myApp = new Client();
		//myApp.MainApplicationLoop();
	}
	//SDLApp myApp = new SDLApp();
	//myApp.MainApplicationLoop();
}