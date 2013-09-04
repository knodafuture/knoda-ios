//
//  UIViewController+WebRequests.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 03.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "UIViewController+WebRequests.h"

@implementation UIViewController (WebRequests)

- (void)addWebRequest:(BaseWebRequest *)request {
    if(request) {
        [[self getWebRequests] addObject:request];
    }
}

- (void)removeWebRequest:(BaseWebRequest *)request {
    [[self getWebRequests] removeObject:request];
}

- (void)cancelAllRequests {
    [[self getWebRequests] makeObjectsPerformSelector:@selector(cancel)];
    [[self getWebRequests] removeAllObjects];
}

- (NSMutableArray *)getWebRequests {
    DLog(@"this method must be implemented in subclass!");
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (void)executeRequest:(BaseWebRequest *)request withBlock:(RequestCompletionBlock)completion {
    
    RequestCompletionBlock block = completion ? [completion copy] : nil;
    
    [self addWebRequest:request];
    
    __weak UIViewController *weakSelf = self;
    
    [request executeWithCompletionBlock:^{
        UIViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        [strongSelf removeWebRequest:request];
        
        if(block) {
            block();
        }
    }];
}

@end
