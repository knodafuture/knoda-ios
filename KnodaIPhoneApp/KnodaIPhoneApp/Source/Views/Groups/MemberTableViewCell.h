//
//  MemberTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MemberTableViewCell;
@protocol MemberTableViewCellDelegate <NSObject>

- (void)MemberTableViewCell:(MemberTableViewCell *)cell didRemoveOnIndexPath:(NSIndexPath *)indexPath;

@end

@interface MemberTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *removeConfirmButton;

+ (MemberTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<MemberTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath;

@end
