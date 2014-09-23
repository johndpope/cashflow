// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2012, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportServer.h"
#import <arpa/inet.h>
#import <unistd.h>

@implementation ExportServer

#define BUFSZ   4096

- (void)requestHandler:(int)s filereq:(NSString*)filereq body:(char *)body bodylen:(NSInteger)bodylen
{
    const char *p;
    
    // Request to '/' url.
    // Return redirect to target file name.
    if ([filereq isEqualToString:@"/"])
    {
        NSString *outcontent = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n"];
        p = [outcontent UTF8String];
        write(s, p, strlen(p));
		
        outcontent = [NSString stringWithFormat:@"<html><head><meta http-equiv=\"refresh\" content=\"0;url=%@\"></head></html>", _filename];
        p = [outcontent UTF8String];
        write(s, p, strlen(p));
		
        return;
    }
		
    // Ad hoc...
    // No need to read request... Just send only one file!
    NSString *content = [NSString stringWithFormat:@"HTTP/1.0 200 OK\r\nContent-Type: %@\r\n\r\n", _contentType];
    p = [content UTF8String];
    write(s, p, strlen(p));
	
    NSInteger clen = [_contentBody length];
    if (clen > 0) {
        write(s, [_contentBody bytes], clen);
    }

}

@end
