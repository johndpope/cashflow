// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import "EditMemoVC.h"
#import "AppDelegate.h"

@interface EditMemoViewController ()
- (void)doneAction;
@end

@implementation EditMemoViewController
{
    id<EditMemoViewDelegate> __unsafe_unretained mDelegate;
    NSString *mText;
    int mIdentifier;
    
    IBOutlet UITextView *mTextView;
}

@synthesize delegate = mDelegate, identifier = mIdentifier, text = mText;

+ (EditMemoViewController *)editMemoViewController:(id<EditMemoViewDelegate>)delegate title:(NSString*)title identifier:(int)id
{
    EditMemoViewController *vc = [[EditMemoViewController alloc]
                                      initWithNibName:@"EditMemoView"
                                      bundle:[NSBundle mainBundle]];
    vc.delegate = delegate;
    vc.title = title;
    vc.identifier = id;

    return vc;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (IS_IPAD) {
        CGSize s = self.contentSizeForViewInPopover;
        s.height = 480;
        self.contentSizeForViewInPopover = s;
    }
    
    //textView.placeholder = self.title;
    mTextView.backgroundColor = [UIColor whiteColor];
	
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                                  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                  target:self
                                                  action:@selector(doneAction)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewWillAppear:(BOOL)animated
{
    mTextView.text = mText;
    [mTextView becomeFirstResponder];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)doneAction
{
    self.text = mTextView.text;
    [mDelegate editMemoViewChanged:self identifier:mIdentifier];

    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (IS_IPAD) return YES;
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
