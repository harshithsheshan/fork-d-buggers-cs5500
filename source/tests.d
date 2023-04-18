
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

@("check if file saved and opened successfully")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    s.updateSurfacePixel(100, 200);
    bool saveResult = s.save("testFile");
    auto savedPixelColor = s.getPixelColor(100, 200);
    assert(saveResult);

    // when you open it update the surface pixel data with the opened file's pixel data
    bool openResult = s.open("testFile");
    auto openedPixelColor = s.getPixelColor(100, 200);
    assert(openResult);

    // this shows that the opened image has same pixel values as the saved one
    assert(savedPixelColor == openedPixelColor);

}

@("test networked chat")
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
    server.mListeningSocket.close();
    clientS.close();

    server.destroy();
    string msg = to!string(buffer);
    assert(msg.canFind("Hello friend"));

}


@("testing instruction sent to client successfully")
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
    server.mListeningSocket.close();
    clientS.close();

    server.destroy();
    string msg = to!string(buffer);
    assert(msg.canFind("Hello friend"));

}

