//
//  ZoomingImageViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/11/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomingImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

- (id)initWithImage:(UIImage *)image title:(NSString *)title;

@end
