//
//  ContestNoContentCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 8/12/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContestNoContentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

+ (ContestNoContentCell *)cellWithMessage:(NSString *)message;

@end
