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
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;

@end

@implementation ImageCropperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.cropView = [[BJImageCropper alloc] initWithImage:self.image andMaxSize:CGSizeMake(self.view.frame.size.width,
                                                                                           self.view.frame.size.height - 44.0/*nav bar height*/)];
    self.cropView.crop   = CGRectMake(0, 0, self.cropSize.width, self.cropSize.height);    
    self.cropView.center = CGPointMake(self.view.center.x, self.view.center.y);
    
    self.navBar.leftBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancelButtonTapped:) color:[UIColor whiteColor]];
    self.navBar.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Done" target:self action:@selector(doneButtonTapped:) color:[UIColor whiteColor]];
    
    [self.view addSubview:self.cropView];
}

- (IBAction)cancelButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate imageCropperDidCancel:self];
}

- (IBAction)doneButtonTapped:(UIBarButtonItem *)sender {
    [self.delegate imageCropper:self didCroppedImage:[self.cropView getCroppedImage]];
}
@end
