//
//  ImageBindable.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageBindable <NSObject>

- (void)didLoadImage:(UIImage *)img error:(NSError *)error;
- (void)didStartImageLoading;

@end
