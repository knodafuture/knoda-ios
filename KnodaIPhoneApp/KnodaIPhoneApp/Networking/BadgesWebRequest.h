//
//  BadgesWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/19/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

extern NSString* const NewBadgeNotification;
extern NSString* const kNewBadgeImages;

@interface BadgesWebRequest : BaseWebRequest

+ (void)checkNewBadges;

@property (nonatomic, strong) NSMutableArray *badgesImagesArray;

@end
