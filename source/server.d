// @file multithreaded_chat/server.d
//
// Start server first: rdmd server.d
module server;
import std.socket;
import std.stdio;
import core.thread.osthread;
import core.stdc.string;

/// The purpose of the TCPServer is to accept
/// multiple client connections. 
/// Every client that connects will have its own thread
/// for the server to broadcast information to each client.
class TCPServer{
    /// Constructor
    /// By default I have choosen localhost and a port that is likely to
    /// be free.

    Surface s;
    SDL_Surface* sdlSurface;
    SDLSupport ret;
    ubyte[] pixelByteArr;

    this(string host = "localhost", ushort port=50001, ushort maxConnectionsBacklog=4){
        initializeSDL();
        // Note: AddressFamily.INET tells us we are using IPv4 Internet protocol
        // Note: SOCK_STREAM (SocketType.STREAM) creates a TCP Socket
        //       If you want UDPClient and UDPServer use 'SOCK_DGRAM' (SocketType.DGRAM)
        mListeningSocket = new Socket(AddressFamily.INET, SocketType.STREAM);
        // Set the hostname and port for the socket
        // NOTE: It's possible the port number is in use if you are not able
        //  	 to connect. Try another one.
        // When we 'bind' we are assigning an address with a port to a socket.
        mListeningSocket.bind(new InternetAddress(host,port));
        // 'listen' means that a socket can 'accept' connections from another socket.
        // Allow 4 connections to be queued up in the 'backlog'
        mListeningSocket.listen(maxConnectionsBacklog);
    }

    /// Destructor
    ~this(){
        // Close our server listening socket
        // TODO: If it was never opened, no need to call close
        mListeningSocket.close();
    }

    void initializeSDL() {
        // Handle initialization...
        // SDL_Init
        version(Windows){
            writeln("Searching for SDL on Windows");
            ret = loadSDL("SDL2.dll");
        }
        version(OSX){
            writeln("Searching for SDL on Mac");
            ret = loadSDL();
        }
        version(linux){
            writeln("Searching for SDL on Linux");
            ret = loadSDL();
        }

        // Error if SDL cannot be loaded
        if(ret != sdlSupport){
            writeln("error loading SDL library");

            foreach( info; loader.errors){
                writeln(info.error,':', info.message);
            }
        }
        if(ret == SDLSupport.noLibrary){
            writeln("error no library found");
        }
        if(ret == SDLSupport.badLibrary){
            writeln("Eror badLibrary, missing symbols, perhaps an older or very new version of SDL is causing the problem?");
        }
        if(SDL_Init(SDL_INIT_EVERYTHING) !=0){
            writeln("SDL_Init: ", fromStringz(SDL_GetError()));
        }
        s = new Surface();
        sdlSurface = SDL_CreateRGBSurface(0,640,480,32,0,0,0,0);
        writeln("look here", sdlSurface.pitch * sdlSurface.h);
        pixelByteArr = new ubyte[sdlSurface.pitch * sdlSurface.h];
        if (sdlSurface is null) {
            writeln("Failed to create canvas surface: ", SDL_GetError());
            return;
        }
    }

    void sendInitialCanvasDataToClient() {
        auto pixelData = getCanvasPixelData();

        for (auto j = 0; j < sdlSurface.pitch * sdlSurface.h; j++) {
            pixelByteArr[j] = pixelData[j];
        }

        broadcastCanvasToAllClients();
    }

    //helper method because we will reuse this at many places in future
    auto getCanvasPixelData() {
        return cast(ubyte*) sdlSurface.pixels;
    }

    //helper method because we will reuse this at many places in future
    void broadcastCanvasToAllClients() {
        foreach (client; mClientsConnectedToServer)
        {
            client.send(pixelByteArr);
        }
    }

    /// Call this after the server has been created
    /// to start running the server
    void run(){
        bool serverIsRunning=true;
        while(serverIsRunning){
            // The servers job now is to just accept connections
            writeln("Waiting to accept more connections");
            /// accept is a blocking call.
            auto newClientSocket = mListeningSocket.accept();
            // After a new connection is accepted, let's confirm.
            writeln("Hey, a new client joined!");
            writeln("(me)",newClientSocket.localAddress(),"<---->",newClientSocket.remoteAddress(),"(client)");
            // Now pragmatically what we'll do, is spawn a new
            // thread to handle the work we want to do.
            // Per one client connection, we will create a new thread
            // in which the server will relay messages to clients.
            mClientsConnectedToServer ~= newClientSocket;
            // Set the current client to have '0' total messages received.
            // NOTE: You may not want to start from '0' here if you do not
            //       want to send a client the whole history.
            mCurrentMessageToSend ~= 0;

            writeln("Friends on server = ",mClientsConnectedToServer.length);

            //ubyte* pixelArray = cast(ubyte*)imgSurface.pixels;
            //const void[] buffer = pixelArray[0..strlen(cast(char*) pixelArray)];
            //newClientSocket.send(buffer);


            // sending data to clients
            sendInitialCanvasDataToClient();

            // Now we'll spawn a new thread for the client that
            // has recently joined.
            // The server will now be running multiple threads and
            // handling a chat here with clients.
            //
            // NOTE: The index sent indicates the connection in our data structures,
            //       this can be useful to identify different clients.
            new Thread({
                clientLoop(newClientSocket);
            }).start();

            // After our new thread has spawned, our server will now resume
            // listening for more client connections to accept.
        }
    }

    // Function to spawn from a new thread for the client.
    // The purpose is to listen for data sent from the client
    // and then rebroadcast that information to all other clients.
    // NOTE: passing 'clientSocket' by value so it should be a copy of
    //       the connection.
    void clientLoop(Socket clientSocket){
        writeln("\t Starting clientLoop:(me)",clientSocket.localAddress(),"<---->",clientSocket.remoteAddress(),"(client)");

        bool runThreadLoop = true;

        while(runThreadLoop){
            // Check if the socket isAlive
            if (!clientSocket.isAlive){
                // Then remove the socket
                runThreadLoop=false;
                break ;
            }

            // Message buffer will be 80 bytes
            //char[80] buffer;
            // Server is now waiting to handle data from specific client
            // We'll block the server awaiting to receive a message.
            auto got = clientSocket.receive(pixelByteArr);
            writeln("(incoming data from client) ", pixelByteArr[0 .. $]);
            // TODO: Note, you might want to verify 'got'
            //       is infact 80 bytes

            // Store data that we receive in our server.
            // We append the buffer to the end of our server
            // data structure.
            // NOTE: Probably want to make this a ring buffer,
            //       so that it does not grow infinitely.
           // mServerData ~= buffer;

            /// After we receive a single message, we'll just
            /// immedietely broadcast out to all clients some data.
           // broadcastToAllClients();
        }

    }

    /// The purpose of this function is to broadcast
    /// messages to all of the clients that are currently
    /// connected.
    void broadcastToAllClients(){
        writeln("Broadcasting to :", mClientsConnectedToServer.length);
        foreach (idx,serverToClient; mClientsConnectedToServer){
            // Send whatever the latest data was to all the
            // clients.
            while(mCurrentMessageToSend[idx] <= mServerData.length-1){
                char[80] msg = mServerData[mCurrentMessageToSend[idx]];
                serverToClient.send(msg[0 .. 80]);
                // Important to increment the message only after sending
                // the previous message to as many clients as exist.
                mCurrentMessageToSend[idx]++;
            }
        }
    }

    /// The listening socket is responsible for handling new client connections.
    Socket        mListeningSocket;
    /// Stores the clients that are currently connected to the server.
    Socket[]    mClientsConnectedToServer;

    /// Stores all of the data on the server. Ideally, we'll
    /// use this to broadcast out to clients connected.
    char[80][] mServerData;
    /// Keeps track of the last message that was broadcast out to each client.
    uint[]            mCurrentMessageToSend;
}
