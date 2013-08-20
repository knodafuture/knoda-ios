//
//  SelectPictureViewController.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 19.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectPictureDelegate;

@interface SelectPictureViewController : UIViewController

@property (nonatomic, weak) id<SelectPictureDelegate> delegate;

@property (weak, nonatomic) IBOutlet UIButton *pictureButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)backButtonPressed:(UIButton *)sender;
- (IBAction)pictureButtonTapped:(id)sender;
- (IBAction)doneButtontapped:(id)sender;

@end

@protocol SelectPictureDelegate <NSObject>

- (void)hideViewController:(SelectPictureViewController *)vc;

@end
