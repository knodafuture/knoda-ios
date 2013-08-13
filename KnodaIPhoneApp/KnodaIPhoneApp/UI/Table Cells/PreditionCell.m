//
//  PreditionCell.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PreditionCell.h"
#import "Prediction.h"
#import "Chellange.h"


@interface PreditionCell ()

@property (nonatomic, strong) UIPanGestureRecognizer* gestureRecognizer;
@property (nonatomic, assign) BOOL recognizingLeftGesture;
@property (nonatomic, assign) BOOL recognizingRightGesture;

@property (nonatomic, strong) IBOutlet UIView* agreeQuestionView;
@property (nonatomic, strong) IBOutlet UIView* disagreeQuestionView;

@property (nonatomic, strong) IBOutlet UIImageView* agreeImage;
@property (nonatomic, strong) IBOutlet UIImageView* disagreeImage;

@property (nonatomic, strong) IBOutlet UIImageView* guessMarkImage;

@property (nonatomic, strong) IBOutlet UILabel* usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel* expirationDateLabel;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;

@property (nonatomic, strong) Prediction* prediction;

@end


@implementation PreditionCell
{
    BOOL agreed;
    BOOL disagreed;
}


+ (CGFloat)cellHeight {
    return 88.0;
}


#pragma mark Fill data


- (void) fillWithPrediction: (Prediction*) prediction
{
    self.prediction = prediction;
    
    [self resetAgreedDisagreed];
    
    self.usernameLabel.text = prediction.userName;
    self.bodyLabel.text = prediction.body;
    
    BOOL expiresInLowerThen10Minutes = NO;
    NSString* expirationString = [self predictionExpiresIntervalString: self.prediction lowerThen10Minutes: &expiresInLowerThen10Minutes];
    NSString* creationString = [self predictionCreatedIntervalString: self.prediction];
    
    self.metadataLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%@ | %@ | %d%% agree", @""),
                               expirationString,
                               creationString,
                               self.prediction.agreedPercent];
    
    self.expirationDateLabel.text = expirationString;
    self.expirationDateLabel.textColor = (expiresInLowerThen10Minutes) ? ([UIColor redColor]) : (self.metadataLabel.textColor);
    
    CGRect rect = self.bodyLabel.frame;
    CGSize maximumLabelSize = CGSizeMake(218, 37);
    
    CGSize expectedLabelSize = [self.bodyLabel.text sizeWithFont: [UIFont fontWithName: @"HelveticaNeue" size: 15] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
    rect.size.height = expectedLabelSize.height;
    self.bodyLabel.frame = rect;
    
    self.agreed = (prediction.chellange != nil) && (prediction.chellange.agree) && (!self.prediction.chellange.isOwn);
    self.disagreed = (prediction.chellange != nil) && !(prediction.chellange.agree) && (!self.prediction.chellange.isOwn);
}


- (void) updateDates
{
    BOOL expiresInLowerThen10Minutes = NO;
    NSString* expirationString = [self predictionExpiresIntervalString: self.prediction lowerThen10Minutes: &expiresInLowerThen10Minutes];
    NSString* creationString = [self predictionCreatedIntervalString: self.prediction];
    
    self.metadataLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%@ | %@ | %d%% agree", @""),
                               expirationString,
                               creationString,
                               self.prediction.agreedPercent];
    
    self.expirationDateLabel.text = expirationString;
    self.expirationDateLabel.textColor = (expiresInLowerThen10Minutes) ? ([UIColor redColor]) : (self.metadataLabel.textColor);
}


#pragma mark Handle gestures


- (void) handlePanFrom: (UIPanGestureRecognizer*) recognizer
{
    CGFloat location = [recognizer locationInView: self.contentView].x;
    
    if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (self.recognizingLeftGesture)
        {
            if (location < self.agreeQuestionView.frame.size.width)
            {
                CGRect newAgreeFrame = self.agreeQuestionView.frame;
                newAgreeFrame.origin.x = location - newAgreeFrame.size.width;
                
                self.agreeQuestionView.frame = newAgreeFrame;
                
                self.agreeImage.hidden = location < self.contentView.frame.size.width / 2;
            }
        }
        else if (self.recognizingRightGesture)
        {
            if (location > self.contentView.frame.size.width - self.disagreeQuestionView.frame.size.width)
            {
                CGRect newDisagreeFrame = self.disagreeQuestionView.frame;
                newDisagreeFrame.origin.x = location;
                
                self.disagreeQuestionView.frame = newDisagreeFrame;
                
                self.disagreeImage.hidden = location > self.contentView.frame.size.width / 2;
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (self.recognizingLeftGesture)
        {
            [UIView animateWithDuration: 0.4 animations: ^
            {
                CGRect newAgreeFrame = self.agreeQuestionView.frame;
                newAgreeFrame.origin.x = -newAgreeFrame.size.width;
                
                self.agreeQuestionView.frame = newAgreeFrame;
            }];
            
            self.agreed = location > self.contentView.frame.size.width / 2;
            
            if (self.agreed && [self.delegate respondsToSelector: @selector(predictionAgreed:inCell:)])
            {
                [self.delegate predictionAgreed: self.prediction inCell: self];
            }
            
            self.recognizingLeftGesture = NO;
        }
        else if (self.recognizingRightGesture)
        {
            [UIView animateWithDuration: 0.4 animations: ^
            {
                CGRect newDisagreeFrame = self.disagreeQuestionView.frame;
                newDisagreeFrame.origin.x = self.contentView.frame.size.width;
                
                self.disagreeQuestionView.frame = newDisagreeFrame;
            }];
            
            self.disagreed = location < self.contentView.frame.size.width / 2;
            
            if (self.disagreed && [self.delegate respondsToSelector: @selector(predictionDisagreed:inCell:)])
            {
                [self.delegate predictionDisagreed: self.prediction inCell: self];
            }
            
            self.recognizingRightGesture = NO;
        }
    }
}


- (void) addPanGestureRecognizer: (UIPanGestureRecognizer*) recognizer
{
    [self addGestureRecognizer: recognizer];
    self.gestureRecognizer = recognizer;
    self.gestureRecognizer.delegate = self;
    [self.gestureRecognizer addTarget: self action: @selector(handlePanFrom:)];
}


#pragma mark Properties


- (void) resetAgreedDisagreed
{
    agreed = NO;
    disagreed = NO;
    
    self.agreeImage.hidden = YES;
    self.disagreeImage.hidden = YES;
}


- (BOOL) agreed
{
    return agreed;
}


- (void) setAgreed: (BOOL) newAgreed
{
    if (!self.agreed && !self.disagreed)
    {
        agreed = newAgreed;
        self.agreeImage.hidden = !agreed;
    }
}


- (BOOL) disagreed
{
    return disagreed;
}


- (void) setDisagreed: (BOOL) newDisagreed
{
    if (!self.agreed && !self.disagreed)
    {
        disagreed = newDisagreed;
        self.disagreeImage.hidden = !disagreed;
    }
}


#pragma mark UIGestureRecognizerDelegate


- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer*) gestureRecognizer
{
    self.recognizingLeftGesture = ([gestureRecognizer locationInView: self.contentView].x <= 50 && !self.agreed && !self.disagreed && !self.prediction.chellange.isOwn);
    self.recognizingRightGesture = ([gestureRecognizer locationInView: self.contentView].x >= CGRectGetWidth(self.contentView.frame) - 50 && !self.agreed && ! self.disagreed && !self.prediction.chellange.isOwn);
    
    return (self.recognizingLeftGesture || self.recognizingRightGesture);
}


#pragma mark Calculate dates


- (NSString*) predictionCreatedIntervalString: (Prediction*) prediciton
{
    NSString* result;
    
    NSDate* now = [NSDate date];
    
    NSTimeInterval interval = [now timeIntervalSinceDate: prediciton.creationDate];
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: NSLocalizedString(@"made %ds ago", @""), (NSInteger)interval];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = ((NSInteger)interval / secondsInMinute) % minutesInHour;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: NSLocalizedString(@"made %@%@%@ ago", @""), hoursString, space, minutesString];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dd ago", @""), days];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dmth ago", @""), month];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dyr%@ ago", @""), year, (year != 1) ? @"s" : @""];
    }
    
    return result;
}


- (NSString*) predictionExpiresIntervalString: (Prediction*) prediciton lowerThen10Minutes: (BOOL*) lowerThen10Minutes
{
    NSString* result;
    
    NSTimeInterval interval = 0;
    NSDate* now = [NSDate date];
    BOOL expired = NO;
    
    if ([now compare: prediciton.expirationDate] == NSOrderedAscending)
    {
        interval = [prediciton.expirationDate timeIntervalSinceDate: now];
    }
    else
    {
        interval = [now timeIntervalSinceDate: prediciton.expirationDate];
        expired = YES;
    }
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %ds%@", @""), (NSInteger)interval, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = ((NSInteger)interval / secondsInMinute) % minutesInHour;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %@%@%@%@", @""), hoursString, space, minutesString, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dd%@", @""), days, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dmth%@", @""), month, (expired) ? @" ago" : @""];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear)) + 1;
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dyr%@", @""), year, (year != 1) ? @"s" : @"", (expired) ? @" ago" : @""];
    }
    
    if (interval < (secondsInMinute * 10) && !expired)
    {
        *lowerThen10Minutes = YES;
    }
    
    return result;
}


@end
