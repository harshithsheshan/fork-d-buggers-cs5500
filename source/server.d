module server;
import std.socket;
import std.stdio;
import core.thread.osthread;
import std.algorithm;


/**
* The purpose of the Server is to accept multiple client connections.
* Every client that connects will have its own thread for the server to broadcast information to each client.
*
*/
class Server{
    // The listening socket is responsible for handling new client connections.
    Socket        mListeningSocket;

    // Stores the clients that are currently connected to the server.
    private Socket[]  mClientsConnectedToServer;

    // Stores all of the data on the server. Ideally, we'll
    // use this to broadcast out to clients connected.
    private char[80][] mServerData;

    // Keeps track of the last message that was broadcast out to each client.
    private uint[] mCurrentMessageToSend;

    /**
    * This function is constructor for the server class.
    * By default, it opens on localhost and a port 50001.
    * Params:
    *       host = host for the server, localhost by default
    *       port = port for the server, 50001 by default
    *       maxConnectionsBacklog = maximum number of connections, by default 4.
    */
    this(string host = "localhost", ushort port=50001, ushort maxConnectionsBacklog=4){
        writeln("Starting server...");
        writeln("Server must be started before clients may join");
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

    /**
    * This is the destructor for the server class.
    */
    ~this(){
        // Close our server listening socket
        mListeningSocket.close();
    }

    /**
    *This function is used to get all the clients connected to the server.
    *
    *   Returns:
    *          - Socket[] = List of client sockets connected to the server.
    */
    Socket[] getClientsConnectedToServer() {
        return mClientsConnectedToServer.dup;
    }
    /**
    * This function is to to start running the server, call this after the server has been created
    */
    void run(){
        bool serverIsRunning=true;
        while(serverIsRunning){
            // The servers job now is to just accept connections
            writeln("Waiting to accept more connections");
            // accept is a blocking call.
            auto newClientSocket = mListeningSocket.accept();
            // After a new connection is accepted, let's confirm.
            writeln("[Joined] "~newClientSocket.remoteAddress.toString());
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

            writeln("===>Friends on server = ",mClientsConnectedToServer.length);
            // Let's send our new client friend a welcome message
            newClientSocket.send("Hello friend\0");

            // whenever a new client join, we need to sent the latest canvas information to them
            if (mServerData.length != 0 ) {
                broadcastToAllClients();
            }


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

        }
    }

    /**
    * Function to spawn from a new thread for the client.
    * The purpose is to listen for data sent from the client and then rebroadcast that information to all other clients.
    * Params:
    *       clientSocket = Socket where client is connnected
    */
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
            char[80] buffer;
            // Server is now waiting to handle data from specific client
            // We'll block the server awaiting to receive a message.
            auto got = clientSocket.receive(buffer);

            // Store data that we receive in our server.
            // We append the buffer to the end of our server
            // data structure.
            // NOTE: Probably want to make this a ring buffer,
            //       so that it does not grow infinitely.
            mServerData ~= buffer;
            if (buffer[0]=='X' &&buffer[1]=='X'){
                writeln("[LEFT] "~clientSocket.remoteAddress.toString());
                mClientsConnectedToServer = mClientsConnectedToServer.remove!(a => a is clientSocket);
                writeln("===>Friends on server = ",mClientsConnectedToServer.length);
                runThreadLoop = false;
                continue ;
            }
            writeln("[Recieving] message/instruction from <<<<<<< ","(",clientSocket.remoteAddress.toString(),")");
            // After we receive a single message, we'll just
            // immedietely broadcast out to all clients some data.
            broadcastToAllClients();
            return ;
        }
    }



        /**
    * The purpose of this function is to broadcast messages to all of the clients that are currently connected.
    */
        void broadcastToAllClients(){
            foreach (idx,serverToClient; mClientsConnectedToServer){
                // Send whatever the latest data was to all the
                // clients.

                while(serverToClient.isAlive && mCurrentMessageToSend[idx] <= mServerData.length-1){
                    writeln("[Broadcasting] messages/instructions to >>>>>>> ","(",serverToClient.remoteAddress.toString(),")");
                    char[80] msg = mServerData[mCurrentMessageToSend[idx]];
                    serverToClient.send(msg[0 .. 80]);
                    // Important to increment the message only after sending
                    // Important to increment the message only after sending
                    // the previous message to as many clients as exist.
                    mCurrentMessageToSend[idx]++;
                }
            }
        }

}