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

#import <QuartzCore/QuartzCore.h>

static const int kObserverKeyCount = 12;
static NSString* const PREDICTION_OBSERVER_KEYS[kObserverKeyCount] = {
    @"doNotObserve",
    @"expirationDate",
    @"agreedPercent",
    @"expired",
    @"outcome",
    @"settled",
    @"smallImage",
    @"chellange",
    @"chellange.seen",
    @"chellange.agree",
    @"chellange.isRight",
    @"chellange.isFinished"
};

@interface PreditionCell ()

@property (nonatomic, strong) UIPanGestureRecognizer* gestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer* profileGestureRecognizer;
@property (nonatomic, assign) BOOL recognizingLeftGesture;
@property (nonatomic, assign) BOOL recognizingRightGesture;

@property (nonatomic, strong) IBOutlet UIView* agreeQuestionView;
@property (nonatomic, strong) IBOutlet UIView* disagreeQuestionView;

@property (nonatomic, strong) IBOutlet UIImageView* agreeImage;
@property (nonatomic, strong) IBOutlet UIImageView* disagreeImage;

@property (nonatomic, strong) IBOutlet UIImageView* guessMarkImage;

@property (nonatomic, strong) IBOutlet UILabel* usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel* expirationDateLabel;

@property (nonatomic, strong) IBOutlet BindableView *avatarView;

@end

@implementation PreditionCell
{
    BOOL agreed;
    BOOL disagreed;
}


+ (CGFloat)cellHeight {
    return 88.0;
}

- (void)dealloc {
    [self removeKVO];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.avatarView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.avatarView.bounds cornerRadius:self.avatarView.layer.cornerRadius].CGPath;
    self.avatarView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
}

#pragma mark KVO

- (void)addKVO {
    if(![self isMemberOfClass:[PreditionCell class]]) {
        return;
    }
    for(int i = 0; i < kObserverKeyCount; i++) {
        [self.prediction addObserver:self forKeyPath:PREDICTION_OBSERVER_KEYS[i] options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeKVO {
    if(![self isMemberOfClass:[PreditionCell class]]) {
        return;
    }
    for(int i = 0; i < kObserverKeyCount; i++) {
        [self.prediction removeObserver:self forKeyPath:PREDICTION_OBSERVER_KEYS[i]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([object isKindOfClass:[Prediction class]]) {
        if(![(Prediction *)object doNotObserve]) {
            [self update];
        }
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Accessors

- (void)setPrediction:(Prediction *)prediction {
    if(_prediction != prediction) {
        if(_prediction) {
            [self removeKVO];
        }
        _prediction = prediction;
        if(_prediction) {
            [self addKVO];
        }
    }
}

#pragma mark Fill data

- (void)update {
    [self resetAgreedDisagreed];
    
    self.usernameLabel.text = self.prediction.userName;
    self.bodyLabel.text = self.prediction.body;
    
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
    
    if ([self.prediction.expirationDate compare: [NSDate date]] == NSOrderedAscending && self.prediction.chellange.isOwn)
    {
        self.guessMarkImage.image = [UIImage imageNamed: ((!self.prediction.settled) ? @"exclamation" : ((self.prediction.outcome) ? @"check" : @"x_lost"))];
    }
    else
    {
        self.guessMarkImage.image = nil;
    }
    
    self.agreed = (self.prediction.chellange != nil) && (self.prediction.chellange.agree) && (!self.prediction.chellange.isOwn);
    self.disagreed = (self.prediction.chellange != nil) && !(self.prediction.chellange.agree) && (!self.prediction.chellange.isOwn);
    
    if (self.agreed)
    {
        self.agreeImage.image = [UIImage imageNamed: (!self.prediction.settled) ? @"agree" : ((self.prediction.outcome == YES) ? @"agree_win" : @"agree_lose")];
    }
    else if (self.disagreed)
    {
        self.disagreeImage.image = [UIImage imageNamed: (!self.prediction.settled) ? @"disagree" : ((self.prediction.outcome == NO) ? @"disagree_win" : @"disagree_lose")];
    }
    
    [self.avatarView bindToURL:self.prediction.smallAvatar withCornerRadius:self.avatarView.layer.cornerRadius];
    
}

- (void) fillWithPrediction: (Prediction*) prediction
{
    self.prediction = prediction;
    
    [self update];
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
    
    if ([self.prediction.expirationDate compare: [NSDate date]] == NSOrderedAscending && self.prediction.chellange.isOwn)
    {
        self.guessMarkImage.image = [UIImage imageNamed: ((!self.prediction.settled) ? @"exclamation" : ((self.prediction.outcome) ? @"check" : @"x_lost"))];
    }
    else
    {
        self.guessMarkImage.image = nil;
    }
    
    if (self.agreed)
    {
        self.agreeImage.image = [UIImage imageNamed: (!self.prediction.settled) ? @"agree" : ((self.prediction.outcome == YES) ? @"agree_win" : @"agree_lose")];
    }
    else if (self.disagreed)
    {
        self.disagreeImage.image = [UIImage imageNamed: (!self.prediction.settled) ? @"disagree" : ((self.prediction.outcome == NO) ? @"disagree_win" : @"disagree_lose")];
    }
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

- (void) setUpUserProfileTapGestures : (UITapGestureRecognizer*) recognizer {
    UITapGestureRecognizer * gestRec = [[UITapGestureRecognizer alloc]init];
    [self.avatarView setUserInteractionEnabled:YES];
    [self.avatarView addImageViewGestureRecognizer:gestRec];
    self.avatarView.delegate = self;
    
    [self.usernameLabel setUserInteractionEnabled:YES];
    self.profileGestureRecognizer = recognizer;
    [self.usernameLabel addGestureRecognizer:recognizer];
    [self.profileGestureRecognizer addTarget: self action: @selector(userAvatarLoginTapped)];
}

- (void) userAvatarLoginTapped {
    if ([self.delegate respondsToSelector:@selector(profileSelectedWithUserId:inCell:)]) {
        [self.delegate profileSelectedWithUserId:self.prediction.userId inCell:self];
    }
}

#pragma mark - Bindable View delegate

- (void) userAvatarTappedWithGestureRecognizer:(UITapGestureRecognizer *)gestureRecognizer {
    [self userAvatarLoginTapped];
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
