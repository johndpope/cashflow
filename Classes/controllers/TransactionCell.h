// -*-  Mode:ObjC; c-basic-offset:4; tab-width:8; indent-tabs-mode:nil -*-
//
//  TransactionCell.h
//

#import <UIKit/UIKit.h>
#import "AssetEntry.h"

@interface TransactionCell : UITableViewCell {
    IBOutlet UILabel *mDescLabel;
    IBOutlet UILabel *mDateLabel;
    IBOutlet UILabel *mValueLabel;
    IBOutlet UILabel *mBalanceLabel;
}

+ (TransactionCell *)transactionCell:(UITableView *)tableView;

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)identifier;
- (TransactionCell *)updateWithAssetEntry:(AssetEntry *)entry;
- (void)setDescriptionLabel:(NSString *)desc;
- (void)setDateLabel:(NSDate *)date;
- (void)setValueLabel:(double)value;
- (void)setBalanceLabel:(double)balance;
- (void)clearBalanceLabel;

@end
