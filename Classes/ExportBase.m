// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportBase.h"
#import "DropboxSDK.h"

@implementation ExportBase

@synthesize firstDate = mFirstDate;
@synthesize assets = mAssets;

- (NSString *)mailSubject { return nil; }
- (NSString *)fileName { return nil; }
- (NSString *)mimeType { return nil; }
- (NSString *)contentType { return nil; }
- (NSData*)generateBody { return nil; }

- (void)dealloc
{
    [mFirstDate release];
    [mWebServer release];
    [super dealloc];
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Email

- (BOOL)sendMail:(UIViewController *)parent
{
    // generate OFX data
    NSData *data = [self generateBody];
    if (data == nil) {
        return NO;
    }
    
    if (![MFMailComposeViewController canSendMail]) {
        return NO;
    }
    
    MFMailComposeViewController *vc = [[MFMailComposeViewController alloc] init];
    vc.mailComposeDelegate = self;
    
    [vc setSubject:[self mailSubject]];

    [vc addAttachmentData:data mimeType:[self mimeType] fileName:[self fileName]];
    [parent presentModalViewController:vc animated:YES];
    [vc release];
    return YES;
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [controller dismissModalViewControllerAnimated:YES];
}

/////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Web server

- (BOOL)sendWithWebServer
{
    NSData *contentBody = [self generateBody];
    if (contentBody == nil) {
        return NO;
    }

    BOOL result = NO;
    NSString *message = nil;

    if (mWebServer == nil) {
        mWebServer = [[ExportServer alloc] init];
    }
    mWebServer.contentBody = contentBody;
    mWebServer.contentType = [self contentType];
    mWebServer.filename = [self fileName];
	
    NSString *url = [mWebServer serverUrl];
    if (url != nil) {
        result = [mWebServer startServer];
    } else {
        message = NSLocalizedString(@"Network is unreachable.", @"");
    }

    UIAlertView *v;
    if (!result) {
        if (message == nil) {
            NSLocalizedString(@"Cannot start web server.", @"");
        }

        // error!
        v = [[UIAlertView alloc]
                initWithTitle:@"Error"
                message:message
                delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"WebExportNotation", @""), url];
	
        v = [[UIAlertView alloc] 
                initWithTitle:NSLocalizedString(@"Export", @"")
                message:message
                delegate:self cancelButtonTitle:NSLocalizedString(@"Dismiss", @"") otherButtonTitles:nil];
    }

    [v show];
    [v release];

    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [mWebServer stopServer];
}

////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Dropbox

- (BOOL)sendToDropbox:(UIViewController*)parent
{
    NSData *data = [self generateBody];
    if (data == nil) {
        return NO;
    }

    // save to temporary file
    NSString *path = [[Database instance] dbPath:[self fileName]];
    if (![data writeToFile:path atomically:NO]) {
        NSLog(@"Error: can't save temporary file!");
        return NO;
    }

    DBSession *session = [DBSession sharedSession];
    if (![session isLinked]) {
        DBLoginController *controller = [[DBLoginController new] autorelease];
        controller.delegate = self;
        [controller presentFromController:parent];
    } else {
        [self _sendToDropbox];
    }

    return YES;
}

- (void)_sendToDropbox
{
    NSString *srcPath = [[Database instance] dbPath:[self fileName]];

    [self.restClient uploadFile:[self fileName] toPath:@"/" fromPath:srcPath];
}

- (DBRestClient *)restClient
{
    if (mRestClient == nil) {
    	mRestClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	mRestClient.delegate = self;
    }
    return mRestClient;
}

#pragma mark DBLoginControllerDelegate methods

- (void)loginControllerDidLogin:(DBLoginController*)controller {
    [self _sendToDropbox];
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
    // do nothing...
}

#pragma mark DBRestClientDelegate

// backup finished
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
{
    [self _showResult:@"Export done."];
}

// backup failed
- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error
{
    [self _showResult:@"Export failed!"];
}

- (void)_showResult:(NSString *)message
{
    [[[[UIAlertView alloc] 
       initWithTitle:@"Backup" message:message
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
        autorelease]
        show];
}

@end
