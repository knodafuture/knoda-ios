//
//  TextViewWatcher.h
//  KnodaIPhoneApp
//
//  Created by nick on 10/12/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TextViewWatcher;

@protocol TextViewWatcherDelegate <NSObject>

- (void)textViewWatcher:(TextViewWatcher *)textViewWatcher didBeginObservingPrefix:(NSString *)prefix;
- (void)prefix:(NSString *)prefix wasUpdatedInTextViewWatcher:(TextViewWatcher *)textViewWatcher newValue:(NSString *)newValue;
- (void)textViewWatcher:(TextViewWatcher *)textViewWatcher didEndObservingPrefix:(NSString *)prefix;

@end

@interface TextViewWatcher : NSObject

@property (weak, nonatomic) id<TextViewWatcherDelegate> delegate;
@property (assign, nonatomic) NSInteger currentPrefixLocation;

- (id)initForTextView:(UITextView *)textViewToWatch delegate:(id<TextViewWatcherDelegate>)delegate;

- (void)observePrefix:(NSString *)prefix;
- (void)stopObservingPrefix:(NSString *)prefix;
- (void)endObserving;
@end
