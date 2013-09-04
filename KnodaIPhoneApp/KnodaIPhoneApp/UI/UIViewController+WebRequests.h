//
//  UIViewController+WebRequests.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 03.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseWebRequest.h"

@interface UIViewController (WebRequests)

- (void)addWebRequest:(BaseWebRequest *)request;
- (void)removeWebRequest:(BaseWebRequest *)request;
- (void)cancelAllRequests;
- (NSMutableArray *)getWebRequests;
- (void)executeRequest:(BaseWebRequest *)request withBlock:(RequestCompletionBlock)completion;

@end
