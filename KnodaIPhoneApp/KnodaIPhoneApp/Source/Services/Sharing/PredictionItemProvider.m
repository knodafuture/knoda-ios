//
//  PredictionItemProvider.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionItemProvider.h"
#import "Prediction+Utils.h"
#import "Challenge.h"

const NSInteger MaxChars = 140;

@interface PredictionItemProvider()

@property (strong, nonatomic) Prediction *prediction;

@end


@implementation PredictionItemProvider

- (id)initWithPrediction:(Prediction *)prediction {
    self = [super init];
    self.prediction = prediction;
    return self;
}

- (id)placeholderItem {
    return @"TEST";
}
- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    NSString *shareString;
    
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        
        NSString *suffixString = [NSString stringWithFormat:@"... #knoda %@", self.prediction.shortUrl];
        
        NSInteger max = MaxChars - suffixString.length;
        
        NSString *prefixString = self.prediction.body;
        
        if (prefixString.length >= max)
            prefixString = [prefixString substringToIndex:max-1];
        
        shareString = [NSString stringWithFormat:@"%@ %@", prefixString, suffixString];
        NSLog(@"%d", shareString.length);
        
    } else {
        if (![self.prediction iAgree] && ![self.prediction iDisagree] && !self.prediction.challenge.isOwn)
            shareString = @"Check out this prediction on Knoda";
        else if (!self.prediction.settled && self.prediction.challenge.isOwn)
            shareString = @"Check out my prediction on Knoda";
        else if (self.prediction.settled && self.prediction.challenge.isOwn) {
            if ([self.prediction win])
                shareString = @"I won my prediction on Knoda";
            else
                shareString = @"I lost my prediction on Knoda";
        }
        else if (self.prediction.settled && [self.prediction win]) {
            if ([self.prediction iAgree])
                shareString = @"I won this prediction that I agreed with on Knoda";
            else
                shareString = @"I won this prediction that I disagreed with on Knoda";
        }
        else if (self.prediction.challenge) {
            if ([self.prediction iAgree])
                shareString = @"I agreed with this prediction on Knoda";
            else
                shareString = @"I disagreed with this prediction on Knoda";
        }
        shareString = [NSString stringWithFormat:@"%@ %@.", shareString, self.prediction.shortUrl];
    }
    
    return shareString;
}
- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType; {
    return @"Check out this prediction on Knoda";

}
@end
