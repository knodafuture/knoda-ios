//
//  NotificationSettings.h
//  KnodaIPhoneApp
//
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "WebObject.h"

@interface NotificationSettings : WebObject
@property (assign, nonatomic) NSInteger Id;
@property (strong, nonatomic) NSString *setting;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *settingDescription;
@property (assign, nonatomic) BOOL active;
@end
