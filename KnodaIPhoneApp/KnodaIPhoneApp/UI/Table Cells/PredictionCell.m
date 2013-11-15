//
//  PreditionCell.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionCell.h"
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

const CGFloat defaultCellHeight = 102.0;

static UINib *nib;
static CGRect initialAgreeImageFrame;
static CGRect initialDisagreeImageFrame;
static CGFloat thresholdPercentage = 0.33f;
static CGFloat iconTrackingDistance = 20.0;
static UIFont *defaultBodyLabelFont;
static CGFloat defaultHeight;
static UILabel *defaultBodyLabel;


@interface PredictionCell ()
@property (nonatomic, strong) IBOutlet UILabel* bodyLabel;
@property (nonatomic, strong) IBOutlet UILabel* metadataLabel;
@property (nonatomic, strong) UITapGestureRecognizer* profileGestureRecognizer;
@property (nonatomic, weak) IBOutlet UIImageView *voteImage;
@property (nonatomic, weak) IBOutlet UILabel *outcomeLabel;
@property (nonatomic, strong) IBOutlet UILabel* usernameLabel;
@property (nonatomic, strong) IBOutlet BindableView *avatarView;

@property (weak, nonatomic) IBOutlet UIView *slidingContainer;
@property (weak, nonatomic) IBOutlet UIView *agreeView;
@property (weak, nonatomic) IBOutlet UIImageView *agreeImageView;
@property (weak, nonatomic) IBOutlet UIView *disagreeView;
@property (weak, nonatomic) IBOutlet UIImageView *disagreeImageView;

@property (assign, nonatomic) CGPoint initialTouchLocation;
@property (assign, nonatomic) NSTimeInterval initialTouchTimestamp;
@property (assign, nonatomic) BOOL trackingTouch;
@property (assign, nonatomic) BOOL finishingCellAnimation;

@property (nonatomic, assign) BOOL agreed;
@property (nonatomic, assign) BOOL disagreed;
@end

@implementation PredictionCell
@synthesize agreed = agreed;
@synthesize disagreed = disagreed;

+ (void)initialize {
    nib = [UINib nibWithNibName:@"PredictionCell" bundle:[NSBundle mainBundle]];
    
    PredictionCell *tmp = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    initialAgreeImageFrame = tmp.agreeImageView.frame;
    initialDisagreeImageFrame = tmp.disagreeImageView.frame;
    defaultBodyLabelFont = tmp.bodyLabel.font;
    defaultHeight = tmp.frame.size.height;
    defaultBodyLabel = tmp.bodyLabel;
}

+ (PredictionCell *)predictionCellForTableView:(UITableView *)tableView {
    PredictionCell *cell = (PredictionCell *)[tableView dequeueReusableCellWithIdentifier:@"PredictionCell"];
    
    if (!cell)
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    return cell;
}

+ (CGFloat)heightForPrediction:(Prediction *)prediction {
    
    
    defaultBodyLabel.text = prediction.body;
    
    CGSize textSize = [defaultBodyLabel sizeThatFits:CGSizeMake(defaultBodyLabel.frame.size.width, CGFLOAT_MAX)];
    
    if (textSize.height < defaultBodyLabel.frame.size.height)
        return defaultHeight;
    else
        return defaultHeight + (textSize.height - defaultBodyLabel.frame.size.height);
}

- (void)dealloc {
    [self removeKVO];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.avatarView.layer.shadowRadius = 0.0;
    self.avatarView.layer.shadowOffset = CGSizeZero;
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]init];
    [self setUpUserProfileTapGestures:tapGesture];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.avatarView didStartImageLoading];
}

#pragma mark KVO

- (void)addKVO {
    if(![self isMemberOfClass:[PredictionCell class]]) {
        return;
    }
    for(int i = 0; i < kObserverKeyCount; i++) {
        [self.prediction addObserver:self forKeyPath:PREDICTION_OBSERVER_KEYS[i] options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeKVO {
    if(![self isMemberOfClass:[PredictionCell class]]) {
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
    
    self.metadataLabel.text = [self.prediction metaDataString];
    
    self.agreed = [self.prediction iAgree];
    self.disagreed = [self.prediction iDisagree];
    
    [self updateVoteImage];
    
    [self.avatarView bindToURL:self.prediction.smallAvatar withCornerRadius:0.0];
    
}

- (void)updateVoteImage {
    if ([self.prediction.expirationDate compare: [NSDate date]] == NSOrderedAscending && self.prediction.chellange.isOwn && !self.prediction.settled)
        self.voteImage.image = [UIImage imageNamed:@"exclamation"];
    else
        self.voteImage.image = [self.prediction statusImage];
    
    self.outcomeLabel.text = self.prediction.settled ? [self.prediction outcomeString] : @"";

}
- (void) fillWithPrediction: (Prediction*) prediction
{
    self.prediction = prediction;
    
    CGRect frame = self.frame;
    frame.size.height = [PredictionCell heightForPrediction:self.prediction];
    self.frame = frame;
    [self update];
}


- (void) updateDates
{
    self.metadataLabel.text = [self.prediction metaDataString];
    
    [self updateVoteImage];
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
            self.voteImage.image = [UIImage imageNamed:@"AgreeMarkerActive"];
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
            self.voteImage.image = [UIImage imageNamed:@"DisagreeMarkerActive"];
            
    }
}


#pragma mark UIGestureRecognizerDelegate

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    
    self.initialTouchLocation = [touch locationInView:self];
    self.initialTouchTimestamp = event.timestamp;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (self.finishingCellAnimation)
        return;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentLocation = [touch locationInView:self];
    
    if (abs(self.initialTouchLocation.x - currentLocation.x) > abs(self.initialTouchLocation.y - currentLocation.y)) {
        [[self parentTableView] setScrollEnabled:NO];
        self.trackingTouch = YES;
    }
    
    
    if (self.agreed || self.disagreed || self.prediction.chellange.isOwn || self.prediction.isExpired)
        return;

    
    CGFloat xDelta = currentLocation.x - self.initialTouchLocation.x;
    
    CGRect slidingFrame = self.slidingContainer.frame;
    
    slidingFrame.origin.x = xDelta;
    
    if (abs(slidingFrame.origin.x) < 4)
        slidingFrame.origin.x = 0;
    
    CGFloat xThreshold = slidingFrame.size.width * thresholdPercentage;
    
    CGFloat percentage = abs(slidingFrame.origin.x) / xThreshold;
    
    self.slidingContainer.frame = slidingFrame;

    self.agreeView.backgroundColor = [UIColor colorWithRed:0.0 green:percentage blue:0.0 alpha:1.0];
    self.disagreeView.backgroundColor = [UIColor colorWithRed:percentage green:0 blue:0 alpha:1.0];
    
    CGRect agreeImageFrame = self.agreeImageView.frame;
    CGRect disagreeImageFrame = self.disagreeImageView.frame;
    
    if (slidingFrame.origin.x > 0) {
        self.disagreeView.hidden = YES;
        self.agreeView.hidden = NO;
        if (slidingFrame.origin.x > initialAgreeImageFrame.origin.x + agreeImageFrame.size.width + iconTrackingDistance) {
            agreeImageFrame.origin.x = slidingFrame.origin.x - iconTrackingDistance - agreeImageFrame.size.width;
            self.agreeImageView.frame = agreeImageFrame;
        }
    }
    
    if (slidingFrame.origin.x < 0) {
        self.disagreeView.hidden = NO;
        self.agreeView.hidden = YES;
        
        if (slidingFrame.origin.x + slidingFrame.size.width < initialDisagreeImageFrame.origin.x - iconTrackingDistance) {
            disagreeImageFrame.origin.x = slidingFrame.origin.x + slidingFrame.size.width + iconTrackingDistance;
            self.disagreeImageView.frame = disagreeImageFrame;
        }
    }
    
}
- (void)doAgreeAnimation:(NSTimeInterval)swipeDuration {
    self.finishingCellAnimation = YES;
    
    CGRect slidingFrame = self.slidingContainer.frame;
    
    CGFloat delta = slidingFrame.size.width - slidingFrame.origin.x;
    
    slidingFrame.origin.x = slidingFrame.size.width;
    
    CGRect imageFrame = self.agreeImageView.frame;
    imageFrame.origin.x += delta;
    
    
    CGRect closedSlidingFrame = self.slidingContainer.frame;
    closedSlidingFrame.origin.x = 0;
    
    CGRect closedAgreeImageFrame = initialAgreeImageFrame;
    closedAgreeImageFrame.origin.x = 0 - closedAgreeImageFrame.origin.x - closedAgreeImageFrame.size.width;
    
    
    CGFloat rate = self.slidingContainer.frame.origin.x / swipeDuration;
    
    CGFloat timeTofinish = (self.slidingContainer.frame.size.width - self.slidingContainer.frame.origin.x) / rate;
    
    if (timeTofinish > 0.5)
        timeTofinish = 0.5;
    if (timeTofinish < 0.1)
        timeTofinish = 0.1;
    
    [UIView animateWithDuration:timeTofinish animations:^{
        self.slidingContainer.frame = slidingFrame;
        self.agreeImageView.frame = imageFrame;
    } completion:^(BOOL finished) {
        [self flashBackgroundColorOnView:self.agreeView duration:0.1 completion:^{
            [UIView animateWithDuration:.5 animations:^{
                self.slidingContainer.frame = closedSlidingFrame;
                self.agreeImageView.frame = closedAgreeImageFrame;
            } completion:^(BOOL finished) {
                [self resetFrames:0.1 completion:^{
                    self.finishingCellAnimation = NO;
                }];
            }];
        }];
    }];
    
    self.agreed = YES;
    
    if ([self.delegate respondsToSelector:@selector(predictionAgreed:inCell:)]) {
        [Flurry logEvent: @"Swiped_Agree"];
        [self.delegate predictionAgreed: self.prediction inCell: self];
    }
    
}

- (void)doDisagreeAnimation:(NSTimeInterval)swipeDuration {
    
    self.finishingCellAnimation = YES;
    
    CGRect slidingFrame = self.slidingContainer.frame;
    
    CGFloat delta = (0 - slidingFrame.size.width ) - slidingFrame.origin.x;
    
    slidingFrame.origin.x = 0 - slidingFrame.size.width;
    
    CGRect imageFrame = self.disagreeImageView.frame;
    imageFrame.origin.x += delta;
    
    
    CGRect closedSlidingFrame = self.slidingContainer.frame;
    closedSlidingFrame.origin.x = 0;
    
    CGRect closedDisagreeImageFrame = initialDisagreeImageFrame;
    closedDisagreeImageFrame.origin.x = slidingFrame.size.width + (slidingFrame.size.width - initialDisagreeImageFrame.origin.x);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.slidingContainer.frame = slidingFrame;
        self.disagreeImageView.frame = imageFrame;
    } completion:^(BOOL finished) {
        [self flashBackgroundColorOnView:self.disagreeView duration:0.1 completion:^{
            [UIView animateWithDuration:.5 animations:^{
                self.slidingContainer.frame = closedSlidingFrame;
                self.disagreeImageView.frame = closedDisagreeImageFrame;
            } completion:^(BOOL finished) {
                [self resetFrames:0.1 completion:^{
                    self.finishingCellAnimation = NO;
                }];
            }];
        }];
    }];
    
    self.disagreed = YES;
    
    if ([self.delegate respondsToSelector: @selector(predictionDisagreed:inCell:)]) {
        [Flurry logEvent: @"Swiped_Disagree"];
        [self.delegate predictionDisagreed: self.prediction inCell: self];
    }
}

- (void)flashBackgroundColorOnView:(UIView *)view duration:(NSTimeInterval)duration completion:(void(^)(void))completion {
    
    UIColor *colorToRestore = view.backgroundColor;
    
    [UIView animateWithDuration:duration/2.0 animations:^{
        view.backgroundColor = [UIColor whiteColor];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:duration/2.0 animations:^{
            view.backgroundColor = colorToRestore;
        } completion:^(BOOL finished) {
            completion();
        }];
    }];
    
    
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesCancelled:touches withEvent:event];
    
    self.initialTouchLocation = CGPointZero;
    self.trackingTouch = NO;
    [[self parentTableView] setScrollEnabled:YES];

    if (!self.finishingCellAnimation)
        [self resetFrames:0.5 completion:nil];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.trackingTouch) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    

    
    CGRect slidingFrame = self.slidingContainer.frame;
    
    
    if (abs(slidingFrame.origin.x) > slidingFrame.size.width * thresholdPercentage) {
        if (slidingFrame.origin.x < 0)
            [self doDisagreeAnimation:event.timestamp - self.initialTouchTimestamp];
        if (slidingFrame.origin.x > 0)
            [self doAgreeAnimation:event.timestamp - self.initialTouchTimestamp];
    } else
        [self resetFrames:0.5 completion:nil];
    
    
    
    [[self parentTableView] setScrollEnabled:YES];
    self.trackingTouch = NO;
    self.initialTouchLocation = CGPointZero;
    self.initialTouchTimestamp = 0;
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)resetFrames:(NSTimeInterval)duration completion:(void(^)(void))completion {
    CGRect frame = self.slidingContainer.frame;
    frame.origin.x = 0;
    
    [UIView animateWithDuration:duration animations:^{
        self.slidingContainer.frame = frame;
        
        CGRect imageFrame = self.agreeImageView.frame;
        imageFrame.origin.x = initialAgreeImageFrame.origin.x;
        self.agreeImageView.frame = imageFrame;
        
        imageFrame = self.disagreeImageView.frame;
        imageFrame.origin.x = initialDisagreeImageFrame.origin.x;
        self.disagreeImageView.frame = imageFrame;
        
        self.agreeView.backgroundColor = [UIColor blackColor];
        self.disagreeView.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        if (completion)
            completion();
    }];

    

}

- (UITableView *)parentTableView {
    if (SYSTEM_VERSION_GREATER_THAN(@"7.0"))
        return (UITableView *)self.superview.superview;
    else
        return (UITableView *)self.superview;
}



@end
