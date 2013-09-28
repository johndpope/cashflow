// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "ExportVC.h"
#import "AppDelegate.h"

@implementation ExportVC
{
    IBOutlet UIButton *_exportButton;
    IBOutlet UISegmentedControl *_formatControl;
    IBOutlet UISegmentedControl *_rangeControl;
    IBOutlet UISegmentedControl *_methodControl;
    IBOutlet UILabel *_formatLabel;
    IBOutlet UILabel *_rangeLabel;
    IBOutlet UILabel *_methodLabel;

    ExportCsv *_csv;
    ExportOfx *_ofx;
}

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
    
    //[AppDelegate trackPageview:@"/ExportViewController"];

    // Localization
    [self setTitle:_L(@"Export")];

    _formatLabel.text = _L(@"Data format");
    [_formatControl setTitle:_L(@"OFX") forSegmentAtIndex:1];

    _rangeLabel.text = _L(@"Export data within");
    [_rangeControl setTitle:_L(@"7 days") forSegmentAtIndex:0];
    [_rangeControl setTitle:_L(@"30 days") forSegmentAtIndex:1];
    [_rangeControl setTitle:_L(@"90 days") forSegmentAtIndex:2];
    [_rangeControl setTitle:_L(@"All") forSegmentAtIndex:3];
    
    _methodLabel.text = _L(@"Export method");
    [_methodControl setTitle:_L(@"Mail") forSegmentAtIndex:0];
    
    NSString *exportString = _L(@"Export");
    [_exportButton setTitle:exportString forState:UIControlStateNormal];
    [_exportButton setTitle:exportString forState:UIControlStateHighlighted];

    //UIImage *bg = [[UIImage imageNamed:@"redButton.png"] stretchableImageWithLeftCapWidth:12.0 topCapHeight:0];
    //[_exportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[_exportButton setBackgroundImage:bg forState:UIControlStateNormal];
	
#ifdef FREE_VERSION
//    formatLabel.hidden = YES;
//    formatControl.hidden = YES;
//    methodLabel.hidden = YES;
//    methodControl.hidden = YES;
#endif

    //noteTextView.font = [UIFont systemFontOfSize:12.0];

    // load defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    _formatControl.selectedSegmentIndex = [defaults integerForKey:@"exportFormat"];
    _rangeControl.selectedSegmentIndex = [defaults integerForKey:@"exportRange"];
    _methodControl.selectedSegmentIndex = [defaults integerForKey:@"exportMethod"];	

    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
             target:self
             action:@selector(doneAction:)];
}

- (void)doneAction:(id)sender
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:@(_formatControl.selectedSegmentIndex) 
              forKey:@"exportFormat"];
    [defaults setObject:@(_rangeControl.selectedSegmentIndex) 
              forKey:@"exportRange"];
    [defaults setObject:@(_methodControl.selectedSegmentIndex) 
              forKey:@"exportMethod"];
    [defaults synchronize];
}

- (IBAction)doExport
{
    //[[DataModel instance] saveToStorage]; // for safety...
	
    int range;
    switch (_rangeControl.selectedSegmentIndex) {
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
        date = [NSDate new];
        date = [date dateByAddingTimeInterval:(- range * 24.0 * 60 * 60)];
    }
	
    BOOL result;
    ExportBase *ex;
    UIAlertView *v;
    
    NSArray *assets;
    if (_asset != nil) {
        assets = @[_asset];
    } else {
        assets = [DataModel instance].ledger.assets;
    }

    switch (_formatControl.selectedSegmentIndex) {
        case 0:
        default:
            if (_csv == nil) {
                _csv = [ExportCsv new];
            }
            _csv.assets = assets;
            ex = _csv;
            break;

        case 1:
            if (_ofx == nil) {
                _ofx = [ExportOfx new];
            }
            _ofx.assets = assets;
            ex = _ofx;
            break;
    }
    ex.firstDate = date;

	NSError *error = nil;
    
    switch (_methodControl.selectedSegmentIndex) {
        case 0:
        default:
            result = [ex sendMail:self error:&error];
            break;

        case 1:
            result = [ex sendToDropbox:self error:&error];
            break;

        case 2:
            result = [ex sendWithWebServer];
            break;
    }
	
    if (!result) {
        NSString *title, *message;
        
        if (!error) {
            title = _L(@"No data");
            message = _L(@"No data to be exported.");
        } else {
            title = error.domain;
            message = error.localizedDescription;
        }
        v = [[UIAlertView alloc] initWithTitle:title message:message
                delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [v show];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
