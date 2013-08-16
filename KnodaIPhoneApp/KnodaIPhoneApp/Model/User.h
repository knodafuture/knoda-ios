//
//  User.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/9/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseModelObject.h"

@interface User : BaseModelObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* email;
@property (nonatomic, strong) UIImage* profileImage;
@property (nonatomic, strong) NSString* token;

@end
