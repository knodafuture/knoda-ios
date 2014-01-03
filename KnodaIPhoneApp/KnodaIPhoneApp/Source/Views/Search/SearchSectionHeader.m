//
//  SearchSectionHeader.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SearchSectionHeader.h"

@implementation SearchSectionHeader

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 320, 20)];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.label = [[UILabel alloc] initWithFrame:self.frame];
    
    [self addSubview:self.label];
    
    self.label.font = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.textColor = [UIColor colorFromHex:@"235C37"];
    
    return self;
}

@end
