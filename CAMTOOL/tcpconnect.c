/*
 * tcpconnect.c
 * TCPHelper
 
*/

#include "tcpconnect.h"
#include<sys/ioctl.h>

int check_network_connection(const char *hostname,unsigned int timeout)
{
    int status = 0; /* return status of the inet/socket functions */
    
	struct addrinfo hints;
	struct addrinfo *servinfo = NULL;  /* will point to the results */
	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_INET; /* AF_INET or AF_INET6 for IPv or IPv6 */
	hints.ai_socktype = SOCK_STREAM; /* TCP protocol */
    
	status = getaddrinfo(hostname, "80", &hints, &servinfo);
    
	if (status < 0)
	{
		return -1;
	}
	
	struct addrinfo *tmp = NULL;
	int sockfd = 0;
    unsigned long ul = 1;
    unsigned int connect_error_code = 0;
	for (tmp = servinfo; tmp != NULL; tmp = tmp->ai_next)
	{
		sockfd = socket(tmp->ai_family, tmp->ai_socktype, tmp->ai_protocol);
		if (sockfd < 0)
		{
			/* error, couldn't create socket, so try another */
			continue;
		}
        
		ioctl(sockfd,FIONBIO,&ul);
        
		status = connect(sockfd, tmp->ai_addr, tmp->ai_addrlen);
        if (status == -1) {
            struct timeval tv;
            fd_set set;
            FD_ZERO(&set);
            FD_SET(sockfd, &set);
            
            tv.tv_sec = (timeout * 1000) / 1000000;
            tv.tv_usec = (timeout * 1000) % 1000000;
            int ret = select(sockfd+1, NULL, &set, NULL, &tv);
            if (ret == 0) {
                //printf("connect to %s timeout!\n",hostname);
                connect_error_code =1;
                close(sockfd);
                break;
                
            }
        }
        
		break;
	}
	freeaddrinfo(servinfo);
    ul =0;
    ioctl(sockfd, FIONBIO,&ul);
    close(sockfd);
    
	if (!tmp || connect_error_code !=0)
	{
		/* couldn't connect anywhere */
        
		return 0;
	}
	return 1;
    
    
}
int tcpconnect_start_client_via_interface(const char *hostname,const char *port,const char *description)
{
    
     /*struct sockaddr_in nativeAddr;
    
    struct ifaddrs *addrs;
    const struct ifaddrs *cursor;
    if(getifaddrs(&addrs) == 0){
        cursor = addrs;
        while (cursor !=NULL) {
            memcpy(&nativeAddr, cursor->ifa_addr, sizeof(nativeAddr));
           
             // show ip on each interface.
            uint32_t ip = ntohl(nativeAddr.sin_addr.s_addr);
            unsigned ip1=ip >> 24 & 0x000000ff;
            unsigned ip2=ip >> 16 & 0x000000ff;
            unsigned ip3=ip >> 8 & 0x000000ff;
            unsigned ip4=ip  & 0x000000ff;
            printf("%s ==> %u.%u.%u.%u\n",cursor->ifa_name,ip1,ip2,ip3,ip4);
            
            if (strcmp(description, cursor->ifa_name) == 0) {
                nativeAddr.sin_port=atoi(port);
            }
            cursor=cursor->ifa_next;
        }
    }
    freeifaddrs(addrs);
     */
    
    return tcpconnect_start_client(hostname, port);
}

int tcpconnect_start_client(const char *hostname, const char *port)
{
	int status = 0; /* return status of the inet/socket functions */
    
	struct addrinfo hints;
	struct addrinfo *servinfo = NULL;  /* will point to the results */
	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_INET; /* AF_INET or AF_INET6 for IPv or IPv6 */
	hints.ai_socktype = SOCK_STREAM; /* TCP protocol */
	status = getaddrinfo(hostname, port, &hints, &servinfo);
	if (status < 0)
	{
		return -1;
	}
	
	struct addrinfo *tmp = NULL;
	int sockfd = 0;
	for (tmp = servinfo; tmp != NULL; tmp = tmp->ai_next)
	{
		sockfd = socket(tmp->ai_family, tmp->ai_socktype, tmp->ai_protocol);
		if (sockfd < 0)
		{
			/* error, couldn't create socket, so try another */
			continue;
		}
		
		status = connect(sockfd, tmp->ai_addr, tmp->ai_addrlen);
		if (status < 0)
		{
			/* error, couldn't connect, so try another */
			close(sockfd);
			continue;
		}
		break;
	}
	freeaddrinfo(servinfo);
	if (!tmp)
	{
		/* couldn't connect anywhere */
		return -1;
	}
    
	return sockfd;
    
}

int tcpconnect_start_multiple(const char *port)
{
	int status = 0; /* return status of the inet/socket functions */
	struct addrinfo *servinfo = NULL;
	struct addrinfo hints;
	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_UNSPEC; /* AF_INET or AF_INET6 for IPv or IPv6 */
	hints.ai_socktype = SOCK_STREAM; /* TCP protocol */
	hints.ai_flags = AI_PASSIVE; /* use my own IP address automagically */
	status = getaddrinfo(NULL, port, &hints, &servinfo);
	if (status < 0)
	{
		/* error, cannot get own info */
		return -1;
	}
	
	struct addrinfo *tmp = NULL;
	int sockfd = 0;
	for (tmp = servinfo; tmp != NULL; tmp = tmp->ai_next)
	{
		sockfd = socket(tmp->ai_family, tmp->ai_socktype, tmp->ai_protocol);
		if (sockfd < 0)
		{
			/* error, can't create socket */
			continue;
		}
		
		int optval = 1;
		status = setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));
		if (status < 0)
		{
			/* error, cannot make address reusable */
			close(sockfd);
			continue;
		}

		status = bind(sockfd, tmp->ai_addr, tmp->ai_addrlen);
		if (status < 0)
		{
			/* error, cannot bind socket to address */
			close(sockfd);
			continue;
		}
		
		break;
	}
	
	freeaddrinfo(servinfo);
	if (!tmp)
	{
		/* error: couldn't connect to any address */
		return -1;
	}

	status = listen(sockfd, 10); /* 10: on most systems, maximum number of parallel connections */
	if (status < 0)
	{
		close(sockfd);
		return -1;
	}
	
	return sockfd;
}

int tcpconnect_accept_single(int stubfd)
{
	struct sockaddr_storage client_addr; /* client's address info */
	socklen_t clientaddr_size = sizeof(client_addr);
	int newsockfd = accept(stubfd, (struct sockaddr *)&client_addr, &clientaddr_size);
	if (newsockfd < 0)
	{
		return -1;
	}
	return newsockfd;
}

int tcpconnect_start_server(const char *port)
{
	int stubfd = tcpconnect_start_multiple(port);
	if (stubfd < 0)
	{
		return -1;
	}
	int sockfd = tcpconnect_accept_single(stubfd);
	close(stubfd);
	if (sockfd < 0)
	{
		return -1;
	}
	return sockfd;
}

