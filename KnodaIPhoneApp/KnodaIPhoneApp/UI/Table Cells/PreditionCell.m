//
//  PreditionCell.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PreditionCell.h"


@interface PreditionCell ()

@property (nonatomic, strong) UIPanGestureRecognizer* gestureRecognizer;
@property (nonatomic, assign) BOOL recognizingLeftGesture;
@property (nonatomic, assign) BOOL recognizingRightGesture;

@property (nonatomic, strong) IBOutlet UIView* agreeQuestionView;
@property (nonatomic, strong) IBOutlet UIView* disagreeQuestionView;

@property (nonatomic, strong) IBOutlet UIImageView* agreeImage;
@property (nonatomic, strong) IBOutlet UIImageView* disagreeImage;

@property (nonatomic, strong) IBOutlet UIImageView* guessMarkImage;

@end


@implementation PreditionCell
{
    BOOL agreed;
    BOOL disagreed;
}


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
    self.recognizingLeftGesture = ([gestureRecognizer locationInView: self.contentView].x <= 50 && !self.agreed && !self.disagreed);
    self.recognizingRightGesture = ([gestureRecognizer locationInView: self.contentView].x >= CGRectGetWidth(self.contentView.frame) - 50 && !self.agreed && ! self.disagreed);
    
    return (self.recognizingLeftGesture || self.recognizingRightGesture);
}


@end
