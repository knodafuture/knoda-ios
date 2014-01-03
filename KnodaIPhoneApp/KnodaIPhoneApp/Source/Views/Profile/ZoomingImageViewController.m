//
//  ZoomingImageViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ZoomingImageViewController.h"

@interface ZoomingImageViewController () <UIScrollViewDelegate>
@property (strong, nonatomic) UIImage *image;
@end

@implementation ZoomingImageViewController

- (id)initWithImage:(UIImage *)image title:(NSString *)title {
    self = [super initWithNibName:@"ZoomingImageViewController" bundle:[NSBundle mainBundle]];
    self.image = image;
    self.title = title;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imageView.image = self.image;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(back)];
    
    self.scrollView.maximumZoomScale = 10;
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
