//
//  NoContentCell.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;


+ (NoContentCell *)noContentWithMessage:(NSString *)message forTableView:(UITableView *)tableView;
+ (NoContentCell *)noContentWithMessage:(NSString *)message forTableView:(UITableView *)tableView height:(CGFloat)height;
@end
