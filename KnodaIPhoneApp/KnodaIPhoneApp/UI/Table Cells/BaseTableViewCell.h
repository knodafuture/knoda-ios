//
//  BaseTableViewCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

+ (NSString *)reuseIdentifier;
+ (CGFloat)cellHeight;

@end
