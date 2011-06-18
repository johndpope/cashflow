// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "AppDelegate.h"
#import "InfoVC.h"
#import "SupportMail.h"

@implementation InfoVC


- (id)init
{
    self = [super initWithNibName:@"InfoView" bundle:nil];
    return self;
}

/*
// Implement loadView to create a view hierarchy programmatically.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [AppDelegate trackPageview:@"/InfoViewController"];
    
    self.title = _L(@"Info");
    self.navigationItem.rightBarButtonItem =
    [[[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target:self
      action:@selector(doneAction:)] autorelease];

#ifdef FREE_VERSION
    [mNameLabel setText:@"CashFlow Free"];
#else
    mPurchaseButton.hidden = YES;
#endif
	
    NSString *version = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    [mVersionLabel setText:[NSString stringWithFormat:@"Version %@", version]];

    [self _setButtonTitle:mPurchaseButton
                    title:_L(@"Purchase Standard Version")];
    [self _setButtonTitle:mHelpButton
                    title:_L(@"Show help page")];
    [self _setButtonTitle:mSendMailButton
                    title:_L(@"Send support mail")];
}

- (void)_setButtonTitle:(UIButton*)button title:(NSString*)title
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)webButtonTapped
{
    [AppDelegate trackPageview:@"/ViewController/Help"];
    
    NSURL *url = [NSURL URLWithString:_L(@"HelpURL") /*"web help url*/];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)purchaseStandardVersion
{
    [AppDelegate trackPageview:@"/ViewController/purchaseStandardVersion"];
    
    NSURL *url = [NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=290776107&mt=8"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)sendSupportMail
{
    SupportMail *m = [[SupportMail alloc] init];
    if (![m sendMail:self]) {
        UIAlertView *v =
            [[[UIAlertView alloc]
             initWithTitle:@"Error" message:@"Can't send email" delegate:nil
              cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
        [v show];
    }
    [m release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
