//
//  BaseTableViewCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/12/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (NSString *)reuseIdentifier {
    return [[self class] reuseIdentifier];
}

+ (CGFloat)cellHeight {
    return 44.0;
}

@end
