//
//  SocialContactsTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/25/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SocialContactsTableViewCell;

@protocol SocialContactsTableViewCellDelegate <NSObject>

- (void)contactSelectedInCell:(SocialContactsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)contactUnselectedInCell:(SocialContactsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
@end


@interface SocialContactsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactMethodsLabel;
@property (weak, nonatomic) IBOutlet UIButton *inviteButton;

@property (strong, nonatomic) NSIndexPath *indexPath;
@property (weak, nonatomic) id<SocialContactsTableViewCellDelegate> delegate;
@property (assign, nonatomic) BOOL contactSelected;


+ (SocialContactsTableViewCell *)cellForTableView:(UITableView *)tableView delegate:(id<SocialContactsTableViewCellDelegate>)delegate indexPath:(NSIndexPath *)indexPath;

@end
