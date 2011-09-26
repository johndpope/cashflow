// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
/*
 * CashFlow for iOS
 * Copyright (C) 2008-2011, Takuya Murakami, All rights reserved.
 * For conditions of distribution and use, see LICENSE file.
 */

#import <UIKit/UIKit.h>

@interface InfoVC : UIViewController {
    IBOutlet UILabel *mNameLabel;
    IBOutlet UILabel *mVersionLabel;

    IBOutlet UIButton *mPurchaseButton;
    IBOutlet UIButton *mHelpButton;
    IBOutlet UIButton *mFacebookButton;
    IBOutlet UIButton *mSendMailButton;
}

- (void)doneAction:(id)sender;
- (IBAction)webButtonTapped;
- (IBAction)facebookButtonTapped:(id)sender;
- (IBAction)purchaseStandardVersion;
- (IBAction)sendSupportMail;

- (void)_setButtonTitle:(UIButton*)button title:(NSString*)title;

@end
