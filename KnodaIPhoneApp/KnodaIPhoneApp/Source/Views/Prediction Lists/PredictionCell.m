//
//  PreditionCell.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionCell.h"
#import "Prediction+Utils.h"
#import "Challenge.h"
#import <QuartzCore/QuartzCore.h>
#import "TTTAttributedLabel.h"

static UINib *nib;
static CGRect initialAgreeImageFrame;
static CGRect initialDisagreeImageFrame;
static CGFloat thresholdPercentage = 0.25f;
static CGFloat iconTrackingDistance = 0.0;
static CGFloat minDistanceForSwipe = 3.0;
static UIFont *defaultBodyLabelFont;
static CGFloat defaultHeight;
static UILabel *defaultBodyLabel;
static PredictionCell *referenceCell;

static CGFloat fullRedR = 254.0/256.0;
static CGFloat fullRedG = 50.0/256.0;
static CGFloat fullRedB = 50.0/256.0;

static CGFloat fullGreenR = 119.0/256.0;
static CGFloat fullGreenG = 188.0/256.0;
static CGFloat fullGreenB = 31.0/256.0;

static NSMutableDictionary *cellHeightCache;
static NSDictionary *linkAttributes;
static inline NSRegularExpression * MentionRegularExpression() {
    static NSRegularExpression *_mentionRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _mentionRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"((?:^|\\s)(?:@){1}[0-9a-zA-Z_]{1,15})" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _mentionRegularExpression;
}

static inline NSRegularExpression * HashtagRegularExpression() {
    static NSRegularExpression *_hashtagRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _hashtagRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"((?:#){1}[\\w\\d]{1,140})" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    
    return _hashtagRegularExpression;
}

@interface PredictionCell ()
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UILabel *metadataLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentCountLabel;
@property (weak, nonatomic) IBOutlet UIView *commentLabelContainer;
@property (weak, nonatomic) IBOutlet UIImageView *voteImage;
@property (weak, nonatomic) IBOutlet UILabel *outcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIView *slidingContainer;
@property (weak, nonatomic) IBOutlet UIView *agreeView;
@property (weak, nonatomic) IBOutlet UIView *agreeImageView;
@property (weak, nonatomic) IBOutlet UIView *disagreeView;
@property (weak, nonatomic) IBOutlet UIView *disagreeImageView;
@property (weak, nonatomic) IBOutlet UIButton *profileButton;
@property (weak, nonatomic) IBOutlet UIImageView *verifiedCheckmark;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@property (weak, nonatomic) IBOutlet UILabel *groupNameLabel;
@property (assign, nonatomic) CGPoint initialTouchLocation;
@property (strong, nonatomic) UITouch *initialTouch;
@property (assign, nonatomic) NSTimeInterval initialTouchTimestamp;
@property (assign, nonatomic) BOOL trackingTouch;
@property (assign, nonatomic) BOOL finishingCellAnimation;
@property (assign, nonatomic) BOOL frameAdjusted;



@property (assign, nonatomic) BOOL touchMoved;
@end

@implementation PredictionCell
@synthesize agreed = agreed;
@synthesize disagreed = disagreed;

+ (void)initialize {
    nib = [UINib nibWithNibName:@"PredictionCell" bundle:[NSBundle mainBundle]];
    
    PredictionCell *tmp = [[nib instantiateWithOwner:nil options:nil] lastObject];
    referenceCell = tmp;
    initialAgreeImageFrame = tmp.agreeImageView.frame;
    initialDisagreeImageFrame = tmp.disagreeImageView.frame;
    defaultBodyLabelFont = tmp.bodyLabel.font;
    defaultHeight = tmp.frame.size.height;
    defaultBodyLabel = tmp.bodyLabel;
    
    cellHeightCache = [[NSMutableDictionary alloc] init];
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName,(id)kCTUnderlineStyleAttributeName, (__bridge NSString *)kCTFontAttributeName, nil];
    NSArray *objects = [[NSArray alloc] initWithObjects:[UIColor colorFromHex:@"77BC1F"],[NSNumber numberWithInt:kCTUnderlineStyleNone], [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0], nil];
    linkAttributes = [[NSDictionary alloc] initWithObjects:objects forKeys:keys];
}

+ (PredictionCell *)predictionCellForTableView:(UITableView *)tableView {
    PredictionCell *cell;
    
    if (!cell) {
        cell = [[nib instantiateWithOwner:nil options:nil] lastObject];
        cell.bodyLabel.delegate = cell;
        cell.bodyLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        cell.bodyLabel.activeLinkAttributes = nil;
    }
    
    cell.swipeEnabled = YES;
    
    return cell;
}

+ (CGFloat)heightForPrediction:(Prediction *)prediction {
    
    CGFloat height = [[cellHeightCache objectForKey:@(prediction.predictionId)] floatValue];
    
    if (height)
        return height;
    
    defaultBodyLabel.text = prediction.body;
    
    CGSize textSize = [defaultBodyLabel sizeThatFits:CGSizeMake(defaultBodyLabel.frame.size.width, CGFLOAT_MAX)];
    
    if (textSize.height < defaultBodyLabel.frame.size.height)
        height = defaultHeight;
    else
        height = defaultHeight + (textSize.height - defaultBodyLabel.frame.size.height);
    
    if (prediction.groupName || prediction.contestName)
        height = height + referenceCell.groupNameLabel.frame.size.height;
    
    [cellHeightCache setObject:@(height) forKey:@(prediction.predictionId)];
    
    return height;
}

- (void)updateBodyLabel:(NSString *)text {
//    [self.bodyLabel setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
//        NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);
//        
//        NSRegularExpression *regexp = MentionRegularExpression();
//        NSRange nameRange = [regexp rangeOfFirstMatchInString:[mutableAttributedString string] options:0 range:stringRange];
//        UIFont *boldSystemFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
//        CTFontRef boldFont = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
//        if (boldFont) {
//            [mutableAttributedString removeAttribute:(__bridge NSString *)kCTFontAttributeName range:nameRange];
//            [mutableAttributedString addAttribute:(__bridge NSString *)kCTFontAttributeName value:(__bridge id)boldFont range:nameRange];
//            CFRelease(boldFont);
//        }
//        
//        [mutableAttributedString replaceCharactersInRange:nameRange withString:[[[mutableAttributedString string] substringWithRange:nameRange] uppercaseString]];
//        
//        regexp = ParenthesisRegularExpression();
//        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, __unused NSMatchingFlags flags, __unused BOOL *stop) {
//            UIFont *italicSystemFont = [UIFont italicSystemFontOfSize:kEspressoDescriptionTextFontSize];
//            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)italicSystemFont.fontName, italicSystemFont.pointSize, NULL);
//            if (italicFont) {
//                [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:result.range];
//                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:result.range];
//                CFRelease(italicFont);
//                
//                [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:result.range];
//                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[[UIColor grayColor] CGColor] range:result.range];
//            }
//        }];
//        
//        return mutableAttributedString;
//    }];
    self.bodyLabel.text = text;
    
    NSRegularExpression *mentionExpression = MentionRegularExpression();
    
    NSArray *matches = [mentionExpression matchesInString:text
                                                  options:0
                                                    range:NSMakeRange(0, [text length])];
    for (NSTextCheckingResult *match in matches) {
        [self.bodyLabel addLinkWithTextCheckingResult:match attributes:linkAttributes];
    }
    
    NSRegularExpression *hashTagExpression = HashtagRegularExpression() ;
    matches = [hashTagExpression matchesInString:text options:0 range:NSMakeRange(0, text.length)];
    
    for (NSTextCheckingResult *match in matches) {
        [self.bodyLabel addLinkWithTextCheckingResult:match attributes:linkAttributes];
    }
}

- (void)update {
    self.usernameLabel.text = self.prediction.username;
    [self updateBodyLabel:self.prediction.body];
    self.metadataLabel.text = [self.prediction metaDataString];
    
    agreed = [self.prediction iAgree];
    disagreed = [self.prediction iDisagree];
    
    
    CGSize metaDataSize = [self.metadataLabel sizeThatFits:self.metadataLabel.frame.size];
    
    CGRect commentsFrame = self.commentLabelContainer.frame;
    
    commentsFrame.origin.x = self.metadataLabel.frame.origin.x + metaDataSize.width + 5.0;
    
    self.commentLabelContainer.frame = commentsFrame;
    
    self.commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.prediction.commentCount];
    
    
    if (!self.prediction.verifiedAccount)
        
        self.verifiedCheckmark.hidden = YES;
    else {
        self.verifiedCheckmark.hidden = NO;
        
        CGSize usernameSize = [self.usernameLabel sizeThatFits:self.usernameLabel.frame.size];
        CGRect frame = self.verifiedCheckmark.frame;
        frame.origin.x = self.usernameLabel.frame.origin.x + usernameSize.width + 5.0;
        self.verifiedCheckmark.frame = frame;
    }
    
    
    [self updateVoteImage];
}

- (void)updateVoteImage {
    if (self.prediction.isReadyForResolution && self.prediction.challenge.isOwn && !self.prediction.settled)
        self.voteImage.image = [UIImage imageNamed:@"PredictionAlertIcon"];
    else
        self.voteImage.image = [self.prediction statusImage];
    
    if (self.prediction.settled && self.prediction.challenge) {
        if ([self.prediction win]) {
            self.outcomeLabel.text = @"W";
            self.outcomeLabel.textColor = [UIColor colorWithRed:fullGreenR green:fullGreenG blue:fullGreenB alpha:1.0];
        } else {
            self.outcomeLabel.text = @"L";
            self.outcomeLabel.textColor = [UIColor colorWithRed:fullRedR green:fullRedG blue:fullRedB alpha:1.0];
        }
    } else
        self.outcomeLabel.text = @"";
    
    CGRect frame = self.outcomeLabel.frame;
    
    if (self.voteImage.image) {
        frame.origin.x = self.voteImage.frame.origin.x - 25.0;
    } else
        frame.origin.x = self.frame.size.width - 30.0;
    
    self.outcomeLabel.frame = frame;

}

- (void)fillWithPrediction:(Prediction *)prediction {
    
    if (self.prediction && self.prediction.predictionId != prediction.predictionId)
        return;
    
    self.prediction = prediction;
    
    CGRect frame = self.frame;
    frame.size.height = [PredictionCell heightForPrediction:self.prediction];
    self.frame = frame;
    
    if (!self.prediction.groupName && !self.prediction.contestName) {
        self.groupImageView.hidden = YES;
        self.groupNameLabel.hidden = YES;
        
        if (!self.frameAdjusted) {
            CGRect imageFrame = self.agreeImageView.frame;
            imageFrame.origin.x = initialAgreeImageFrame.origin.x;
            imageFrame.origin.y = (self.slidingContainer.frame.size.height / 2.0) - (initialAgreeImageFrame.size.height / 2.0);
            self.agreeImageView.frame = imageFrame;
            
            imageFrame = self.disagreeImageView.frame;
            imageFrame.origin.x = initialDisagreeImageFrame.origin.x;
            imageFrame.origin.y = (self.slidingContainer.frame.size.height / 2.0) - (initialDisagreeImageFrame.size.height / 2.0);
            self.disagreeImageView.frame = imageFrame;
            self.frameAdjusted = YES;
        }
        
    } else {
            if (!self.frameAdjusted) {
                frame = self.metadataLabel.frame;
                frame.origin.y -= self.groupNameLabel.frame.size.height;
                self.metadataLabel.frame = frame;
                frame = self.commentLabelContainer.frame;
                frame.origin.y -= self.groupNameLabel.frame.size.height;
                self.commentLabelContainer.frame = frame;
                frame = self.bodyLabel.frame;
                frame.size.height -= self.groupNameLabel.frame.size.height;
                self.bodyLabel.frame = frame;
                self.groupNameLabel.hidden = NO;
                self.groupImageView.hidden = NO;
                
                
                if (self.prediction.groupName) {
                    self.groupImageView.image = [UIImage imageNamed:@"PredictGroupsIcon"];
                    self.groupNameLabel.text = self.prediction.groupName;
                } else {
                    self.groupNameLabel.text = self.prediction.contestName;
                    self.groupImageView.image = [UIImage imageNamed:@"ContestPredictionBadge"];
                }
                

                self.frameAdjusted = YES;
            }
    }
    
    [self update];
}


- (void)updateDates {
    self.metadataLabel.text = [self.prediction metaDataString];
    
    CGSize metaDataSize = [self.metadataLabel sizeThatFits:self.metadataLabel.frame.size];
    
    CGRect commentsFrame = self.commentLabelContainer.frame;
    
    commentsFrame.origin.x = self.metadataLabel.frame.origin.x + metaDataSize.width + 5.0;
    
    self.commentLabelContainer.frame = commentsFrame;
    
    self.commentCountLabel.text = [NSString stringWithFormat:@"%ld", (long)self.prediction.commentCount];
}

- (IBAction)profileTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(profileSelectedWithUserId:inCell:)])
        [self.delegate profileSelectedWithUserId:self.prediction.userId inCell:self];
}

- (BOOL) agreed {
    return agreed;
}

- (void)setAgreed:(BOOL)newAgreed {
    
    if (agreed == newAgreed)
        return;
    
    if (newAgreed) {
        if (self.disagreed) { //if if disagreed, subractfromcount
            disagreed = NO;
            self.prediction.disagreeCount--;
        }
        self.voteImage.image = [UIImage imageNamed:@"AgreeMarker"];
        self.prediction.agreeCount++;
        [self updateDates];
    }
    agreed = newAgreed;
}


- (BOOL)disagreed {
    return disagreed;
}

- (void)setDisagreed:(BOOL)newDisagreed {

    if (disagreed == newDisagreed)
        return;
    
    if (newDisagreed) {
        if (self.agreed) {
            agreed = NO;
            self.prediction.agreeCount--;
        }
        self.voteImage.image = [UIImage imageNamed:@"DisagreeMarker"];
        self.prediction.disagreeCount++;
        [self updateDates];
    }
    
    disagreed = newDisagreed;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesBegan:touches withEvent:event];

    self.touchMoved = NO;

    UITouch *touch = [touches anyObject];
    
    self.initialTouch = touch;
    self.initialTouchLocation = [touch locationInView:self];
    self.initialTouchTimestamp = event.timestamp;
    
    [self.bodyLabel touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [super touchesMoved:touches withEvent:event];
    [self.bodyLabel touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    
    CGPoint currentLocation = [touch locationInView:self];
    
    if (currentLocation.x < 20)
        return;
    
    CGFloat maxDelta = MAX(abs(self.initialTouchLocation.x - currentLocation.x), abs(self.initialTouchLocation.y - currentLocation.y));
    
    if (maxDelta > minDistanceForSwipe)
        self.touchMoved = YES;
    else
        self.touchMoved = NO;
    
    if (self.finishingCellAnimation || !self.swipeEnabled)
        return;
    
    if (abs(self.initialTouchLocation.x - currentLocation.x) > abs(self.initialTouchLocation.y - currentLocation.y)) {
        [[self parentTableView] setScrollEnabled:NO];
        self.trackingTouch = YES;
    }
    
    if (self.prediction.challenge.isOwn || self.prediction.isExpired)
        return;

    
    CGFloat xDelta = currentLocation.x - self.initialTouchLocation.x;
    
    CGRect slidingFrame = self.slidingContainer.frame;
    
    slidingFrame.origin.x = xDelta;
    
    if (abs(slidingFrame.origin.x) > slidingFrame.size.width / 2.0)
        return;
    
    if (abs(slidingFrame.origin.x) < 4)
        slidingFrame.origin.x = 0;
    
    CGFloat xThreshold = slidingFrame.size.width * thresholdPercentage;
    
    CGFloat percentage = MIN(abs(slidingFrame.origin.x) / xThreshold, 1);
    
    
    self.slidingContainer.frame = slidingFrame;
    
    self.disagreeView.backgroundColor = [UIColor colorWithRed:percentage  *fullRedR green:percentage  *fullRedG blue:percentage  *fullRedB alpha:1.0];
    
    self.agreeView.backgroundColor = [UIColor colorWithRed:percentage  *fullGreenR green:percentage  *fullGreenG blue:percentage  *fullGreenB alpha:1.0];
    CGRect agreeImageFrame = self.agreeImageView.frame;
    CGRect disagreeImageFrame = self.disagreeImageView.frame;
    
    if (slidingFrame.origin.x > 0) {
        self.disagreeView.backgroundColor = [UIColor clearColor];
        if (slidingFrame.origin.x > initialAgreeImageFrame.origin.x + agreeImageFrame.size.width + iconTrackingDistance) {
            agreeImageFrame.origin.x = slidingFrame.origin.x - iconTrackingDistance - agreeImageFrame.size.width;
            self.agreeImageView.frame = agreeImageFrame;
        }
    }
    
    if (slidingFrame.origin.x < 0) {
        self.agreeView.backgroundColor = [UIColor clearColor];
        if (slidingFrame.origin.x + slidingFrame.size.width < (self.slidingContainer.frame.size.width - self.disagreeImageView.frame.size.width - 5.0) - iconTrackingDistance) {
            disagreeImageFrame.origin.x = slidingFrame.origin.x + slidingFrame.size.width + iconTrackingDistance;
            self.disagreeImageView.frame = disagreeImageFrame;
        }
    }
    
}
- (void)doAgreeAnimation:(NSTimeInterval)swipeDuration {
    self.finishingCellAnimation = YES;
    
    CGRect closedSlidingFrame = self.slidingContainer.frame;
    closedSlidingFrame.origin.x = 0;
    
    CGRect closedAgreeImageFrame = initialAgreeImageFrame;
    closedAgreeImageFrame.origin.x = 5.0;
    closedAgreeImageFrame.origin.y = (self.slidingContainer.frame.size.height / 2.0) - (closedAgreeImageFrame.size.height / 2.0);

    [UIView animateWithDuration:.5 animations:^{
        self.slidingContainer.frame = closedSlidingFrame;
        self.agreeImageView.frame = closedAgreeImageFrame;
    } completion:^(BOOL finished) {
        [self resetFrames:0.1 completion:^{
            self.finishingCellAnimation = NO;
        }];
    }];
    
    self.agreed = YES;
    
    if ([self.delegate respondsToSelector:@selector(predictionAgreed:inCell:)]) {
        [Flurry logEvent: @"Swiped_Agree"];
        [self.delegate predictionAgreed: self.prediction inCell: self];
    }
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
//    if ([self.bodyLabel hitTest:point withEvent:event] == self.bodyLabel)
//        return self.bodyLabel;
//    
//    return [super hitTest:point withEvent:event];
//}

- (void)doDisagreeAnimation:(NSTimeInterval)swipeDuration {
    
    self.finishingCellAnimation = YES;
    
    CGRect closedSlidingFrame = self.slidingContainer.frame;
    closedSlidingFrame.origin.x = 0;
    
    CGRect closedDisagreeImageFrame = initialDisagreeImageFrame;
    closedDisagreeImageFrame.origin.x = self.slidingContainer.frame.size.width - closedDisagreeImageFrame.size.width - 5.0;
    closedDisagreeImageFrame.origin.y = (self.slidingContainer.frame.size.height / 2.0) - (closedDisagreeImageFrame.size.height / 2.0);
    [UIView animateWithDuration:.5 animations:^{
        self.slidingContainer.frame = closedSlidingFrame;
        self.disagreeImageView.frame = closedDisagreeImageFrame;
    } completion:^(BOOL finished) {
        [self resetFrames:0.1 completion:^{
            self.finishingCellAnimation = NO;
        }];
    }];
    
    self.disagreed = YES;
    
    if ([self.delegate respondsToSelector: @selector(predictionDisagreed:inCell:)]) {
        [Flurry logEvent: @"Swiped_Disagree"];
        [self.delegate predictionDisagreed: self.prediction inCell: self];
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {

    [super touchesCancelled:touches withEvent:event];
    
    if (!self.swipeEnabled)
        return;
    
    self.initialTouchLocation = CGPointZero;
    self.trackingTouch = NO;
    [[self parentTableView] setScrollEnabled:YES];

    if (!self.finishingCellAnimation)
        [self resetFrames:0.5 completion:nil];
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
 
    if (!self.touchMoved) {
        if ([self.profileButton hitTest:self.initialTouchLocation withEvent:event]) {
            [self.profileButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            [self cleanupFromSwipe];
            [self resetFrames:0.5 completion:nil];
            return;
        } else if (self.bodyLabel.activeLink){
            [self.bodyLabel touchesEnded:touches withEvent:event];
            [self cleanupFromSwipe];
            [self resetFrames:0.5 completion:nil];
            return;
        }

    }
    
    if (!self.trackingTouch) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    CGRect slidingFrame = self.slidingContainer.frame;
    
    
    if (abs(slidingFrame.origin.x) > slidingFrame.size.width  *thresholdPercentage) {
        if (slidingFrame.origin.x < 0)
            [self doDisagreeAnimation:event.timestamp - self.initialTouchTimestamp];
        if (slidingFrame.origin.x > 0)
            [self doAgreeAnimation:event.timestamp - self.initialTouchTimestamp];
    } else
        [self resetFrames:0.5 completion:nil];
    
    [self cleanupFromSwipe];
    
    [super touchesCancelled:touches withEvent:event];
}

- (void)cleanupFromSwipe {
    [[self parentTableView] setScrollEnabled:YES];
    self.trackingTouch = NO;
    self.initialTouchLocation = CGPointZero;
    self.initialTouchTimestamp = 0;
    self.initialTouch = nil;
}
- (void)resetFrames:(NSTimeInterval)duration completion:(void(^)(void))completion {
    CGRect frame = self.slidingContainer.frame;
    frame.origin.x = 0;
    
    [UIView animateWithDuration:duration animations:^{
        self.slidingContainer.frame = frame;
        
        CGRect imageFrame = self.agreeImageView.frame;
        imageFrame.origin.x = 5.0;
        imageFrame.origin.y = (self.slidingContainer.frame.size.height / 2.0) - (initialAgreeImageFrame.size.height / 2.0);
        self.agreeImageView.frame = imageFrame;
        
        imageFrame = self.disagreeImageView.frame;
        imageFrame.origin.x = self.slidingContainer.frame.size.width - imageFrame.size.width - 5.0;
        imageFrame.origin.y = (self.slidingContainer.frame.size.height / 2.0) - (initialDisagreeImageFrame.size.height / 2.0);
        self.disagreeImageView.frame = imageFrame;
        
        self.agreeView.backgroundColor = [UIColor blackColor];
        self.disagreeView.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        if (completion)
            completion();
    }];
}

- (UITableView *)parentTableView {
    
    UIView *superview = self.superview;
    
    while (superview != nil) {
        if ([superview isKindOfClass:UITableView.class])
            return (UITableView *)superview;
        superview = superview.superview;
    }
    
    return nil;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.layer removeAllAnimations];
    self.avatarImageView.image = nil;
    self.prediction = nil;
}


- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithTextCheckingResult:(NSTextCheckingResult *)result  {
    NSString *selectedText = [self.prediction.body substringWithRange:result.range];
    NSLog(@"clicked %@", selectedText);
}
@end
