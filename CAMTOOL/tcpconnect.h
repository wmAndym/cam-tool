/*
 * tcpconnect.h
 * TCPHelper
 *
 
*/

#ifndef __TCPCONNECT_H__
#define __TCPCONNECT_H__

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <ifaddrs.h>


    
int tcpconnect_start_client_via_interface(const char *hostname,const char *port,const char *description); //description like "en0,en1,fw0.."
    
/*
  Returns a socket file descriptor,
  from/to which one can read() or write().
  To be close()'d after use.
  Useful for clients wanting to connect to a specific server
  The server must be already listening using connect_to_client().
  This function does not return until a server
  accepted the connection on the specified port.
*/

int tcpconnect_start_client(const char *hostname, const char *port);

/*
  Returns a socket file descriptor,
  from/to which one can read() or write().
  To be close()'d after use.
  Useful for servers wanting to accept an incoming
  connection from any client.
  This function does not return until a client
  has successfully connected on the specified port.
*/

int check_network_connection(const char *hostname,unsigned int timeout);
    
int tcpconnect_start_server(const char *port);

/*
  Returns a file descriptor, which can be supplied to tcpconnect_accept_single in order to retrieve
  a read()able-write()able socket file descriptor.
*/

int tcpconnect_start_multiple(const char *port);

/*
  Takes a socket file descriptor returned by tcpconnect_start_multiple(). This blocks until a
  client connects to the other end of the socket.
  Returns a readable-writable socket file descriptor on success or negative on error.
*/

int tcpconnect_accept_single(int stubfd);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* !__TCPCONNECT_H__ */

