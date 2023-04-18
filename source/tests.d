
module tests;

import bindbc.sdl;
import controller;
import server;
import model;
import loader = bindbc.loader.sharedlib;
import std.stdio;
import std.socket;
import core.thread.osthread;
import std.conv;
import std.algorithm;
import core.thread.osthread;
import std.range : repeat;
import std.exception;
import std.string;
private SDLSupport ret;

//@("check if file saved and opened successfully")
//unittest{
//    ret = loadSDL();
//    Surface s = new Surface();
//    s.UpdateSurfacePixel(100, 200);
//    bool saveResult = s.save("testFile");
//    assert(saveResult);
//    bool openResult = s.open("testFile");
//    assert(openResult);
//}

@("test networking")
unittest{
    string host = "localhost";
    ushort port = 50001;
    Server server = new Server();
    Socket clientS = new Socket(AddressFamily.INET, SocketType.STREAM);
    clientS.connect(new InternetAddress(host, port));
    auto newClientSocket = server.mListeningSocket.accept();
    newClientSocket.send("Hello friend ");

    char[80] buffer;
    auto received = clientS.receive(buffer);
    writeln(buffer[0 .. received]);


    server.mListeningSocket.close();
    clientS.close();

    server.destroy();
    string msg = to!string(buffer);
    //writeln(msg);
    assert(msg.canFind("Hello friend"));

}