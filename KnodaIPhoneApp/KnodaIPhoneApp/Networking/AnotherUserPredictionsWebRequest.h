//
//  AnotherUserPredictionsWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Vyacheslav Nechiporenko on 8/22/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface AnotherUserPredictionsWebRequest : BaseWebRequest

@property (nonatomic, readonly) NSArray* predictions;

- (id)initWithUserId:(NSInteger)userId;
- (id) initWithLastId: (NSInteger) lastId andUserID : (NSInteger) userId;
+ (NSInteger) limitByPage;

@end
