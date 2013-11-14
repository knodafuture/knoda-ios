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
    @"smallAvatar",
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

@property (nonatomic, weak) IBOutlet UIImageView *voteImage;
@property (nonatomic, weak) IBOutlet UIImageView *agreeImage;
@property (nonatomic, weak) IBOutlet UIImageView *disagreeImage;

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
    return 102.0;
}

- (void)dealloc {
    [self removeKVO];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarView.layer.shadowRadius = 0.0;
    self.avatarView.layer.shadowOffset = CGSizeZero;
}
- (void)prepareForReuse {
    [super prepareForReuse];
    [self.avatarView didStartImageLoading];
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

- (void)updateGuessMark {
    if ([self.prediction.expirationDate compare: [NSDate date]] == NSOrderedAscending && self.prediction.chellange.isOwn)
    {
        self.guessMarkImage.image = [UIImage imageNamed: ((!self.prediction.settled) ? @"exclamation" : ((self.prediction.outcome) ? @"check" : @"x_lost"))];
    }
    else
    {
        self.guessMarkImage.image = nil;
    }
}

- (void)update {
    [self resetAgreedDisagreed];
    
    self.usernameLabel.text = self.prediction.userName;
    self.bodyLabel.text = self.prediction.body;
        
    
    self.metadataLabel.text = [self.prediction metaDataString];
    
    //self.expirationDateLabel.text = expirationString;
    //self.expirationDateLabel.textColor = (expiresInLowerThen10Minutes) ? ([UIColor redColor]) : (self.metadataLabel.textColor);
    
    CGRect rect = self.bodyLabel.frame;
    CGSize maximumLabelSize = CGSizeMake(218, 37);
    
    CGSize expectedLabelSize = [self.bodyLabel.text sizeWithFont: [UIFont fontWithName: @"HelveticaNeue" size: 15] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
    rect.size.height = expectedLabelSize.height;
    self.bodyLabel.frame = rect;
    
    [self updateGuessMark];
    
    self.agreed = [self.prediction iAgree];
    self.disagreed = [self.prediction iDisagree];
    self.voteImage.image = [self.prediction statusImage];

    
    [self.avatarView bindToURL:self.prediction.smallAvatar withCornerRadius:0.0];
    
}

- (void) fillWithPrediction: (Prediction*) prediction
{
    self.prediction = prediction;
    
    [self update];
}


- (void) updateDates
{
    self.metadataLabel.text = [self.prediction metaDataString];
    
    //self.expirationDateLabel.text = expirationString;
    
    if ([self.prediction.expirationDate compare: [NSDate date]] == NSOrderedAscending && self.prediction.chellange.isOwn)
    {
        self.guessMarkImage.image = [UIImage imageNamed: ((!self.prediction.settled) ? @"exclamation" : ((self.prediction.outcome) ? @"check" : @"x_lost"))];
    }
    else
    {
        self.guessMarkImage.image = nil;
    }
    
    self.voteImage.image = [self.prediction statusImage];
}


#pragma mark Handle gestures


- (void) handlePanFrom: (UIPanGestureRecognizer*) recognizer
{
    if([self.prediction isExpired]) {
        return;
    }
    
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
                
                if (location > self.contentView.frame.size.width / 2)
                    self.voteImage.image = [UIImage imageNamed:@"AgreeMarker"];
                else
                    self.voteImage.image = nil;
                //self.agreeImage.hidden = location < self.contentView.frame.size.width / 2;
            }
        }
        else if (self.recognizingRightGesture)
        {
            if (location > self.contentView.frame.size.width - self.disagreeQuestionView.frame.size.width)
            {
                CGRect newDisagreeFrame = self.disagreeQuestionView.frame;
                newDisagreeFrame.origin.x = location;
                
                self.disagreeQuestionView.frame = newDisagreeFrame;
                
                if (location < self.contentView.frame.size.width / 2)
                    self.voteImage.image = [UIImage imageNamed:@"DisagreeMarker"];
                else
                    self.voteImage.image = nil;
                //self.disagreeImage.hidden = location > self.contentView.frame.size.width / 2;
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
                [Flurry logEvent: @"Swiped_Agree"];
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
                [Flurry logEvent: @"Swiped_Disagree"];
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
    
    self.voteImage.image = nil;
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
        if (agreed)
            self.voteImage.image = [UIImage imageNamed:@"AgreeMarker"];
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
        if (disagreed)
            self.voteImage.image = [UIImage imageNamed:@"DisagreeMarker"];
            
    }
}


#pragma mark UIGestureRecognizerDelegate


- (BOOL) gestureRecognizerShouldBegin: (UIGestureRecognizer*) gestureRecognizer
{
    self.recognizingLeftGesture = ([gestureRecognizer locationInView: self.contentView].x <= 150 && !self.agreed && !self.disagreed && !self.prediction.chellange.isOwn);
    self.recognizingRightGesture = ([gestureRecognizer locationInView: self.contentView].x >= CGRectGetWidth(self.contentView.frame) - 150 && !self.agreed && ! self.disagreed && !self.prediction.chellange.isOwn);
    
    return (self.recognizingLeftGesture || self.recognizingRightGesture);
}




@end
