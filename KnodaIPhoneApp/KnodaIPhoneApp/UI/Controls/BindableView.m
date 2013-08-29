//
//  BindableView.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BindableView.h"
#import "ImageCache.h"

@interface BindableView()

@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) UITapGestureRecognizer * gestureRecognizer;

@end

@implementation BindableView

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    self.activityIndicator.hidden = !_loading;
}

- (void)bindToURL:(NSString *)imgUrl withCornerRadius:(CGFloat)radius {
    [[ImageCache instance] bindImage:imgUrl toView:self withCornerRadius:radius];
}

- (void)bindToURL:(NSString *)imgUrl {
    [self bindToURL:imgUrl withCornerRadius:0.0];
}

#pragma mark ImageBindable

- (void)didLoadImage:(UIImage *)img error:(NSError *)error {
    self.loading = NO;
    self.imageView.image = img;
}

- (void)didStartImageLoading {
    self.loading = YES;
}

#pragma mark - Gesture Recognizing

- (void) addImageViewGestureRecognizer : (UITapGestureRecognizer *) recognizer {
    [self addGestureRecognizer:recognizer];
    [self setUserInteractionEnabled:YES];
    self.gestureRecognizer = recognizer;
    [self.gestureRecognizer addTarget:self action:@selector(userAvatarTappedWithRecognizer:)];
}

- (void) userAvatarTappedWithRecognizer : (UITapGestureRecognizer *) recognizer {
    if ([self.delegate respondsToSelector:@selector(userAvatarTappedWithGestureRecognizer:)]) {
        [self.delegate userAvatarTappedWithGestureRecognizer:recognizer];
    }
}

@end
