//
//  CommentWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/17/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"

@interface CommentWebRequest : BaseWebRequest

@property (nonatomic, strong) NSMutableArray* comments;

+ (NSInteger) limitByPage;

- (id)initWithOffset:(NSInteger)offset forPredictionId:(NSInteger)predictionId;
- (id)initWithLastId:(NSInteger)lastId forPredictionId:(NSInteger)predictionId;
@end
