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
#import "UserManager.h"

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
        NSString *prefixString = self.prediction.body;

        shareString = [self shortenString:prefixString forMaxChars:MaxChars withSuffix:suffixString];
        
    } else if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        shareString = [NSString stringWithFormat:@"%@ via Knoda.com", self.prediction.body];
    } else if ([activityType isEqualToString:UIActivityTypeMessage]) {
        NSString *suffix = [NSString stringWithFormat:@"... %@ via Knoda.com", self.prediction.shortUrl];
        shareString = [self shortenString:self.prediction.body forMaxChars:MaxChars withSuffix:suffix];
    } else if ([activityType isEqualToString:UIActivityTypeMail]) {
        NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"<html>"];
        [string appendString:self.prediction.body];
        [string appendFormat:@" %@", self.prediction.shortUrl];
        [string appendFormat:@"\n <a href=\"https://itunes.apple.com/us/app/knoda/id764642995?ls=1&mt=8\">Download Knoda</a></html>"];
        
        return string;
    }
    else {
        return [NSString stringWithFormat:@"%@ %@ via Knoda", self.prediction.body, self.prediction.shortUrl];
    }
    
    return shareString;
}
- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType; {    
    return [NSString stringWithFormat:@"%@ shared a Knoda prediction with you", [UserManager sharedInstance].user.name];

}

- (NSString *)shortenString:(NSString *)string forMaxChars:(NSInteger)maxChars withSuffix:(NSString *)suffix {
    
    NSInteger max = maxChars - suffix.length;
    
    
    if (string.length >= max)
        string = [string substringToIndex:max-1];
    
    return [NSString stringWithFormat:@"%@ %@", string, suffix];
}
@end
