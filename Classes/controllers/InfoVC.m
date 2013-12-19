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
{
    IBOutlet UILabel *_nameLabel;
    IBOutlet UILabel *_versionLabel;
    
    IBOutlet UIButton *_purchaseButton;
    IBOutlet UIButton *_helpButton;
    IBOutlet UIButton *_facebookButton;
    IBOutlet UIButton *_sendMailButton;
}

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
    //[AppDelegate trackPageview:@"/InfoViewController"];

    // iOS7 hack
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = _L(@"Info");
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc]
      initWithBarButtonSystemItem:UIBarButtonSystemItemDone
      target:self
      action:@selector(doneAction:)];

#ifdef FREE_VERSION
    [_nameLabel setText:@"CashFlow Free"];
#else
    _purchaseButton.hidden = YES;
#endif
	
    NSString *version = [AppDelegate appVersion];
    [_versionLabel setText:[NSString stringWithFormat:@"Version %@", version]];

    [self _setButtonTitle:_purchaseButton
                    title:_L(@"Purchase Standard Version")];
    [self _setButtonTitle:_helpButton
                    title:_L(@"Show help page")];
    [self _setButtonTitle:_facebookButton
                    title:_L(@"Open facebook page")];
    [self _setButtonTitle:_sendMailButton
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


- (void)doneAction:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)webButtonTapped
{
    //[AppDelegate trackPageview:@"/ViewController/Help"];
    [AppDelegate trackEvent:@"help" action:@"push" label:@"help" value:nil];
    
    NSURL *url = [NSURL URLWithString:_L(@"HelpURL") /*"web help url*/];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)facebookButtonTapped:(id)sender {
    //[AppDelegate trackPageview:@"/ViewController/facebook"];
    [AppDelegate trackEvent:@"help" action:@"push" label:@"facebook" value:nil];

    NSURL *url = [NSURL URLWithString:@"http://facebook.com/CashFlowApp"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)purchaseStandardVersion
{
    //[AppDelegate trackPageview:@"/ViewController/purchaseStandardVersion"];
    [AppDelegate trackEvent:@"help" action:@"push" label:@"purchase" value:nil];
    
    NSURL *url = [NSURL URLWithString:@"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=290776107&mt=8"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)sendSupportMail
{
    [AppDelegate trackEvent:@"help" action:@"push" label:@"sendmail" value:nil];
    
    SupportMail *m = [SupportMail getInstance];
    if (![m sendMail:self]) {
        UIAlertView *v =
            [[UIAlertView alloc]
             initWithTitle:@"Error" message:@"Can't send email" delegate:nil
              cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [v show];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
@end
