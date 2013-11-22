//
//  BindableView.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BindableView.h"
#import "ImageBindable.h"


@interface BindableView : UIView <ImageBindable>

@property (nonatomic, weak) IBOutlet UIImageView *imageView;

@property (nonatomic, assign) BOOL loading;

- (void)bindToURL:(NSString *)imgUrl withCornerRadius:(CGFloat)radius;
- (void)bindToURL:(NSString *)imgUrl;

@end
