
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



unittest
{
    // Mock server
    auto server = new Thread({
        // Create a server socket
        auto serverSocket = new TcpSocket();
        serverSocket.bind(new InternetAddress("127.0.0.1", 50001));
        serverSocket.listen(1);

        // Wait for a client to connect
        auto clientSocket = serverSocket.accept();

        // Send a message to the client confirming the connection
        clientSocket.send("Hello friend\0".dup);

        // Listen for incoming messages from the client
        while (true)
        {
            // Note: It's important to recreate or 'zero out' the buffer so that you do not
            // 			 get previous data leftover in the buffer.
            char[80] buffer;
            auto received = clientSocket.receive(buffer);

            // Interpret the message and respond accordingly
            auto str = to!string(buffer[0 .. received]);
            auto parts = str.split(' ');
            if (parts[0] == "_i")
            {
                if (parts[1] == "open")
                {
                    // Respond with a confirmation message
                    clientSocket.send("Opened\0".dup);
                }
                else
                {
                    // Respond with a confirmation message
                    clientSocket.send("Performed\0".dup);
                }
            }
            else
            {
                // Respond with the message received
                clientSocket.send(buffer[0 .. received]);
            }
        }
    });

    // Mock client
    auto client = new Client("127.0.0.1", 50001);
    scope(exit) client.destroy();

    // Start a new thread to receive chat messages from the server
    auto receiver = new Thread(&client.receiveChatFromServer);
    scope(exit) receiver.join();

    // Assert that the client is connected to the server
    assert(client.getSocket().isAlive);

    // Test the open function
    server.start();
    client.getSocket().send("_i open test.bmp\0".dup);
    char[80] buffer;
    auto received = client.getSocket().receive(buffer);
    assert(buffer[0 .. received] == "Opened\0".dup);

    // Test the perform function
    client.getSocket().send("_i 10 10 255 0 0 5\0".dup);
    received = client.getSocket().receive(buffer);
    assert(buffer[0 .. received] == "Performed\0".dup);

}
