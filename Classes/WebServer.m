// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/* 
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <arpa/inet.h>
#import <fcntl.h>
#import <unistd.h>

#import "WebServer.h"

#define PORT_NUMBER		8888

@implementation WebServer
{
    int _listenSock;
    struct sockaddr_in _servAddr;
	
    NSThread *_thread;
}

- (void)dealloc
{
    [self stopServer];
}

/**
   Start web server
*/
- (BOOL)startServer
{
    int on;
    struct sockaddr_in addr;

    _listenSock = socket(AF_INET, SOCK_STREAM, 0);
    if (_listenSock < 0) {
        return NO;
    }

    on = 1;
    setsockopt(_listenSock, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));

    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(INADDR_ANY);
    addr.sin_port = htons(PORT_NUMBER);

    if (bind(_listenSock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
        close(_listenSock);
        return NO;
    }
	
    socklen_t len = sizeof(_servAddr);
    if (getsockname(_listenSock, (struct sockaddr *)&_servAddr, &len)  < 0) {
        close(_listenSock);
        return NO;
    }

    if (listen(_listenSock, 16) < 0) {
        close(_listenSock);
        return NO;
    }

    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadMain:) object:nil];
    [_thread start];
     // ###
	
    return YES;
}

/**
   Stop web server
*/
- (void)stopServer
{
    if (_listenSock >= 0) {
        close(_listenSock);
    }
    _listenSock = -1;
}

/**
   Decide server URL
*/
- (NSString*)serverUrl
{
    // connect dummy UDP socket to get local IP address.
    int s = socket(AF_INET, SOCK_DGRAM, 0);
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr.s_addr = htonl(0x01010101); // dummy address
    addr.sin_port = htons(80);
	
    if (connect(s, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
        close(s);
        return nil;
    }
	
    socklen_t len = sizeof(addr);
    getsockname(s, (struct sockaddr*)&addr, &len);
    close(s);

    if (addr.sin_addr.s_addr == inet_addr("127.0.0.1")) {
        return nil;
    }
    
    char addrstr[64];
    inet_ntop(AF_INET, (void*)&addr.sin_addr.s_addr, addrstr, sizeof(addrstr));

    NSString *url;
    if (PORT_NUMBER == 80) {
        url = [NSString stringWithFormat:@"http://%s", addrstr];
    } else {
        url = [NSString stringWithFormat:@"http://%s:%d", addrstr, PORT_NUMBER];
    }
    return url;
}

/**
   Server thread
*/
- (void)threadMain:(id)dummy
{	
    @autoreleasepool {
	
        int s;
        socklen_t len;
        struct sockaddr_in caddr;
	
        for (;;) {
            len = sizeof(caddr);
            s = accept(_listenSock, (struct sockaddr *)&caddr, &len);
            if (s < 0) {
                break;
            }

            [self handleHttpRequest:s];

            close(s);
        }

        if (_listenSock >= 0) {
            close(_listenSock);
        }
        _listenSock = -1;
	
    }

    [NSThread exit];
}

/**
   Read http header line
*/
- (BOOL)readLine:(int)s line:(char *)line size:(int)size
{
    char *p = line;

    while (p < line + size) {
        int len = read(s, p, 1);
        if (len <= 0) {
            return NO;
        }
        if (p > line && *p == '\n' && *(p-1) == '\r') {
            *(p-1) = 0; // null terminate;
            return YES;
        }
        p++;
    }
    return NO; // not reach here...
}

/**
   Recv http body
*/
- (char *)readBody:(int)s contentLength:(int)contentLength
{
    char *buf, *p;
    int len, remain;

    if (contentLength < 0) {
        len = 1024*10; // ad hoc
    } else {
        len = contentLength;
    }
    
    buf = malloc(len + 1);
    p = buf;
    remain = len;

    while (remain > 0) {
        int rlen = read(s, p, remain);
        if (rlen < 0) {
            free(buf);
            return NULL;
        }
        if (contentLength < 0) break;

        p += rlen;
        remain -= rlen;
    }

    *p = 0; // null terminate;
    return buf;
}

/**
   Handle http request
*/
- (void)handleHttpRequest:(int)s
{
    char line[1024];
    int lineno = 0;
    NSString *filereq = @"/";
    int contentLength = -1;

    // read headers
    for (;;) {
        if (![self readLine:s line:line size:1024]) {
            return; // error
        }
        NSLog(@"%s", line);
        
        if (strlen(line) == 0) {
            break; // end of header
        }

        if (lineno == 0) {
            // request line
            char *p, *p2 = NULL;
            p = strtok(line, " ");
            if (p) p2 = strtok(NULL, " ");
            if (p2) filereq = @(p2);
        }

        else if (strncasecmp(line, "Content-Length:", 15) == 0) {
            contentLength = atoi(line + 15);
        }

        lineno++;
    }

    // read body
    char *body = NULL;
    if (contentLength > 0) {
        body = [self readBody:s contentLength:contentLength];
    }

    [self requestHandler:(int)s filereq:(NSString*)filereq body:body bodylen:contentLength];

    free(body);
}

/**
   Request handler

   @note You need to override this method
*/
- (void)requestHandler:(int)s filereq:(NSString*)filereq body:(char *)body bodylen:(int)bodylen
{
    // must be override
}

/**
   Send reply in string
*/
- (void)send:(int)s string:(NSString *)string
{
    write(s, [string UTF8String], [string length]);
}

@end
