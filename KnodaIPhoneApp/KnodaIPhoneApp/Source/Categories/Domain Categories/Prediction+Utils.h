//
//  NewPrediction+Utils.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "Prediction.h"

@interface Prediction (Utils)

+ (NSArray *)arrayFromHistoryData:(NSData *)data;

- (BOOL)isExpired;
- (BOOL)isFinished;
- (BOOL)passed72HoursSinceExpiration;
- (BOOL)canSetOutcome;

- (NSString *)metaDataString;
- (NSString *)pointsString;
- (NSInteger)totalPoints;

- (BOOL)iAgree;
- (BOOL)iDisagree;
- (UIImage *)statusImage;
- (NSString *)outcomeString;
- (BOOL)win;
@end
