module tests;

import bindbc.sdl;
import controller:Client;
import server:Server;
import model:Surface;
import loader = bindbc.loader.sharedlib;
import std.stdio;
import std.socket;
import core.thread.osthread;


private SDLSupport ret;

@("check if file saved and opened successfully")
unittest{
    ret = loadSDL();
    Surface s = new Surface();
    s.UpdateSurfacePixel(100, 200);
    bool saveResult = s.save("testFile");
    assert(saveResult);

    bool openResult = s.open("testFile");
    assert(openResult);
}


@("test networking")
unittest{
    //ret = loadSDL();
    string host = "localhost";
    ushort port = 50001;
    Server server = new Server();
    Socket clientS = new Socket(AddressFamily.INET, SocketType.STREAM);
    clientS.connect(new InternetAddress(host, port));
    auto newClientSocket = server.mListeningSocket.accept();
    newClientSocket.send("Hello friend\0");
    writeln("message sent");

    char[80] buffer;
    auto received = clientS.receive(buffer);
    writeln(buffer[0 .. received]);

    //clientS.close();
    //server.mListeningSocket.close();
    writeln("socket closed");

    //server.mListeningSocket.close();
    //serverthread.join();
    //writeln("socket2 joined");
//    serverthread.join();
    //assert(true);
}

//@("test networking")
//unittest{
//    //ret = loadSDL();
//    string host = "localhost";
//    ushort port = 50001;
//    writeln("server connected");
//    Server server = new Server();
//    writeln("Server created");
//    Socket clientS = new Socket(AddressFamily.INET, SocketType.STREAM);
//    clientS.connect(new InternetAddress(host, port));
//    Thread newthread = new Thread({
//        while (true) {
//            auto newClientSocket = server.mListeningSocket.accept();
//            newClientSocket.send("Hello friend\0");
//            writeln("message sent");
//        }
//    });
//    newthread.start();
//    writeln("Thread started");
//    //port = 50001;

//    char[80] buffer;
//    auto received = clientS.receive(buffer);
//    writeln(buffer[0 .. received]);
//
//    clientS.close();
//    //server.mListeningSocket.close();
//    newthread.join();
//    assert(true);
//}




