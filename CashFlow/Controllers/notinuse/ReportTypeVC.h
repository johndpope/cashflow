// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  ReportTypeViewController.h
//

#import <UIKit/UIKit.h>
#import "Report.h"
#import "Asset.h"

@interface ReportTypeViewController : UITableViewController
{
    Asset *mAsset;
}

@property(nonatomic,retain) Asset *asset;

- (void)doneAction:(id)sender;
- (NSString *)_getTitle:(int)index;

@end
