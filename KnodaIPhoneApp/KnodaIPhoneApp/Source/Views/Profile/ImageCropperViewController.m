//
//  ImageCropperViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/30/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "ImageCropperViewController.h"
#import "BJImageCropper.h"

@interface ImageCropperViewController ()

@property (nonatomic, strong) BJImageCropper *cropView;

@end

@implementation ImageCropperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.cropView = [[BJImageCropper alloc] initWithImage:self.image andMaxSize:CGSizeMake(self.view.frame.size.width,
                                                                                           self.view.frame.size.height - 44.0/*nav bar height*/)];
    self.cropView.crop   = CGRectMake(0, 0, self.cropSize.width, self.cropSize.height);
    self.cropView.center = CGPointMake(self.view.center.x, self.view.center.y - 100.0);
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancelButtonTapped:) color:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Done" target:self action:@selector(doneButtonTapped:) color:[UIColor whiteColor]];
    self.title = @"CROP";
    self.navigationController.navigationBar.translucent = NO;
    [self.view addSubview:self.cropView];
}

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate imageCropperDidCancel:self];
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate imageCropper:self didCroppedImage:[self.cropView getCroppedImage]];
}
@end
