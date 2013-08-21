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

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation BindableView

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    self.activityIndicator.hidden = !_loading;
    if(_loading) {
        [self.activityIndicator startAnimating];
    }
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

@end
