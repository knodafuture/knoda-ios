//
//  ImageCropperViewController.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/30/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageCropperDelegate;

@interface ImageCropperViewController : UIViewController

@property (nonatomic) UIImage *image;

@property (nonatomic, weak) id<ImageCropperDelegate> delegate;
@property (nonatomic, assign) CGSize cropSize;

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender;
- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender;

@end

@protocol ImageCropperDelegate <NSObject>

- (void)imageCropperDidCancel:(ImageCropperViewController *)vc;
- (void)imageCropper:(ImageCropperViewController *)vc didCroppedImage:(UIImage *)image;

@end
