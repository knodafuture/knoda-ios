//
//  ServerError.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 29.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerError : NSError

@property (nonatomic, readonly) NSArray *localizedDescriptionsArray;
@property (nonatomic, readonly) BOOL shouldNotifyUser;

- (id)initWithCode:(NSInteger)code andInfo:(NSDictionary *)dict;

@end
