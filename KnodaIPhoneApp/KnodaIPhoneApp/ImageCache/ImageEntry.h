//
//  ImageEntry.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ImageLoadCompletionBlock) (void);

@interface ImageEntry : NSObject

@property (nonatomic, readonly) UIImage *image;

@property (nonatomic, readonly) NSString *imgUrl;
@property (nonatomic, readonly) NSError *error;
@property (nonatomic, readonly) NSDate *creationDate;

@property (atomic, assign, readonly) BOOL isLoading;

- (id)initWithURL:(NSString *)imgURL;

- (void)loadImageWithCompletion:(ImageLoadCompletionBlock)completion;

- (void)unload;
- (void)clear;

@end
