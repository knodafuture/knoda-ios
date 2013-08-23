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
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UITapGestureRecognizer * gestureRecognizer;

@end

@implementation BindableView

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    self.activityIndicator.hidden = !_loading;
}

- (void)bindToURL:(NSString *)imgUrl {
    [[ImageCache instance] bindImage:imgUrl toView:self];
}

#pragma mark ImageBindable

- (void)didLoadImage:(UIImage *)img error:(NSError *)error {
    //DLog(@"");
    self.loading = NO;
    self.imageView.image = img;
}

- (void)didStartImageLoading {
    //DLog(@"");
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
