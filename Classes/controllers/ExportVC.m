// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportVC.h"
#import "AppDelegate.h"

@implementation ExportVC

@synthesize asset = mAsset;

- (id)initWithAsset:(Asset *)as
{
    self = [super initWithNibName:@"ExportView" bundle:nil];
    self.asset = as;
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [AppDelegate trackPageview:@"/ExportViewController"];

    // Localization
    [self setTitle:_L(@"Export")];

    mFormatLabel.text = _L(@"Data format");
    [mFormatControl setTitle:_L(@"OFX") forSegmentAtIndex:1];

    mRangeLabel.text = _L(@"Export data within");
    [mRangeControl setTitle:_L(@"7 days") forSegmentAtIndex:0];
    [mRangeControl setTitle:_L(@"30 days") forSegmentAtIndex:1];
    [mRangeControl setTitle:_L(@"90 days") forSegmentAtIndex:2];
    [mRangeControl setTitle:_L(@"All") forSegmentAtIndex:3];
    
    mMethodLabel.text = _L(@"Export method");
    [mMethodControl setTitle:_L(@"Mail") forSegmentAtIndex:0];
    
    NSString *exportString = _L(@"Export");
    [mExportButton setTitle:exportString forState:UIControlStateNormal];
    [mExportButton setTitle:exportString forState:UIControlStateHighlighted];

    UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
    [mExportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mExportButton setBackgroundImage:bg forState:UIControlStateNormal];
	
#ifdef FREE_VERSION
//    formatLabel.hidden = YES;
//    formatControl.hidden = YES;
//    methodLabel.hidden = YES;
//    methodControl.hidden = YES;
#endif

    //noteTextView.font = [UIFont systemFontOfSize:12.0];

    // load defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    mFormatControl.selectedSegmentIndex = [defaults integerForKey:@"exportFormat"];
    mRangeControl.selectedSegmentIndex = [defaults integerForKey:@"exportRange"];
    mMethodControl.selectedSegmentIndex = [defaults integerForKey:@"exportMethod"];	

    self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)] autorelease];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:[NSNumber numberWithInt:mFormatControl.selectedSegmentIndex] 
              forKey:@"exportFormat"];
    [defaults setObject:[NSNumber numberWithInt:mRangeControl.selectedSegmentIndex] 
              forKey:@"exportRange"];
    [defaults setObject:[NSNumber numberWithInt:mMethodControl.selectedSegmentIndex] 
              forKey:@"exportMethod"];
    [defaults synchronize];
}

- (IBAction)doExport
{
    //[[DataModel instance] saveToStorage]; // for safety...
	
    int range;
    switch (mRangeControl.selectedSegmentIndex) {
    case 0:
        range = 7;
        break;
    case 1:
        range = 30;
        break;
    case 2:
        range = 90;
        break;
    default:
        range = -1;
        break;
    }
	
    NSDate *date = nil;
    if (range > 0) {
        date = [[[NSDate alloc] init] autorelease];
        date = [date dateByAddingTimeInterval:(- range * 24.0 * 60 * 60)];
    }
	
    BOOL result;
    ExportBase *ex;
    UIAlertView *v;
    
    NSArray *assets;
    if (mAsset != nil) {
        assets = [NSArray arrayWithObject:mAsset];
    } else {
        assets = [DataModel instance].ledger.assets;
    }

    switch (mFormatControl.selectedSegmentIndex) {
        case 0:
        default:
            if (mCsv == nil) {
                mCsv = [[ExportCsv alloc] init];
            }
            mCsv.assets = assets;
            ex = mCsv;
            break;

//#ifndef FREE_VERSION
        case 1:
            if (mOfx == nil) {
                mOfx = [[ExportOfx alloc] init];
            }
            mOfx.assets = assets;
            ex = mOfx;
            break;
//#endif
    }
    ex.firstDate = date;
	
    switch (mMethodControl.selectedSegmentIndex) {
    case 0:
    default:
        result = [ex sendMail:self];
        break;

    case 1:
        result = [ex sendToDropbox:self];
        break;

//#ifndef FREE_VERSION
    case 2:
        result = [ex sendWithWebServer];
        break;
//#endif
    }
	
    if (!result) {
        v = [[UIAlertView alloc] 
                initWithTitle:_L(@"No data")
                message:_L(@"No data to be exported.")
                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [v show];
        [v autorelease];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
