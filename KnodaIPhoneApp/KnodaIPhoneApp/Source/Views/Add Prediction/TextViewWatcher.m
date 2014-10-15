//
//  TextViewWatcher.m
//  KnodaIPhoneApp
//
//  Created by nick on 10/12/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "TextViewWatcher.h"

@interface TextViewWatcher ()
@property (weak, nonatomic) UITextView *textViewToWatch;
@property (strong, nonatomic) NSMutableSet *prefixesToWatch;

@property (assign, nonatomic) BOOL observingPrefix;
@property (strong, nonatomic) NSString *previousTextViewValue;
@property (strong, nonatomic) NSString *currentPrefix;
@property (strong, nonatomic) NSString *currentTerm;
@end

@implementation TextViewWatcher

- (id)initForTextView:(UITextView *)textViewToWatch delegate:(id<TextViewWatcherDelegate>)delegate {
    self = [super init];
    
    self.prefixesToWatch = [[NSMutableSet alloc] init];
    self.textViewToWatch = textViewToWatch;
    self.delegate = delegate;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    self.previousTextViewValue = self.textViewToWatch.text;
    return self;
}

- (void)textViewChanged:(NSNotification *)object {
    
    if ([self.previousTextViewValue isEqualToString:@"Add a comment..."]) {
        self.previousTextViewValue = @"";
    }
    
    if (self.previousTextViewValue.length > self.textViewToWatch.text.length) {
        
        NSString *deletedCharacters = [self.previousTextViewValue substringWithRange:NSMakeRange(self.textViewToWatch.text.length, self.previousTextViewValue.length - self.textViewToWatch.text.length)];
        
        NSString *foundPrefix = nil;
        
        for (NSString *prefix in self.prefixesToWatch) {
            if ([deletedCharacters rangeOfString:prefix].location != NSNotFound) {
                foundPrefix = prefix;
                break;
            }
        }
        
        if (!foundPrefix) {
            if (self.currentPrefix) {
                self.currentTerm = [self.currentTerm substringWithRange:NSMakeRange(0, self.currentTerm.length - deletedCharacters.length)];
                [self.delegate prefix:self.currentPrefix wasUpdatedInTextViewWatcher:self newValue:self.currentTerm];
            }
        } else {
            if (self.textViewToWatch.text.length < self.currentPrefixLocation && [foundPrefix isEqualToString:self.currentPrefix]) {
                [self endObserving];
            }
        }
        
        
    } else {
        NSString *newCharacters = [self.textViewToWatch.text substringWithRange:NSMakeRange(self.previousTextViewValue.length, self.textViewToWatch.text.length - self.previousTextViewValue.length)];
        if (!self.observingPrefix) {
            if (newCharacters.length == 1) {
                for (NSString *prefix in self.prefixesToWatch) {
                    if ([prefix isEqualToString:newCharacters]) {
                        self.observingPrefix = YES;
                        self.currentPrefix = prefix;
                        self.currentTerm = @"";
                        self.currentPrefixLocation = self.textViewToWatch.text.length;
                        [self.delegate textViewWatcher:self didBeginObservingPrefix:self.currentPrefix];
                        break;
                    }
                }
            }
        } else {
            
            if ([newCharacters isEqualToString:@" "]) {
                [self endObserving];
            }
                self.currentTerm = [self.currentTerm stringByAppendingString:newCharacters];
                [self.delegate prefix:self.currentPrefix wasUpdatedInTextViewWatcher:self newValue:self.currentTerm];
        }
        
    }
    
    self.previousTextViewValue = self.textViewToWatch.text;
    
    
}
- (void)endObserving {
    [self.delegate textViewWatcher:self didEndObservingPrefix:self.currentPrefix];
    self.currentPrefix = nil;
    self.currentPrefixLocation = NSNotFound;
    self.currentTerm = @"";
    self.observingPrefix = NO;
}

- (void)observePrefix:(NSString *)prefix {
    
    [self.prefixesToWatch addObject:prefix];
}

- (void)stopObservingPrefix:(NSString *)prefix {
    [self.prefixesToWatch removeObject:prefix];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeAllObservations];
}



@end
