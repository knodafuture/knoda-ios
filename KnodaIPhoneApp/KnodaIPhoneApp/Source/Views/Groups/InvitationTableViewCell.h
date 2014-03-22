//
//  InvitationTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 3/19/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InvitationTableViewCell;
@protocol InvitationTableViewCellDelegate <NSObject>

- (void)InvitationTableViewCell:(InvitationTableViewCell *)cell didRemoveOnIndexPath:(NSIndexPath *)indexPath;

@end

@interface InvitationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactMethodsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *knodaImageView;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
@property (weak, nonatomic) IBOutlet UIButton *removeConfirmButton;

+ (InvitationTableViewCell *)cellForTableView:(UITableView *)tableView onIndexPath:(NSIndexPath *)indexPath delegate:(id<InvitationTableViewCellDelegate>)delegate;

@end
