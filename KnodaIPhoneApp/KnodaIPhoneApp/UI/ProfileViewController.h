//
//  ProfileViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseRequestingViewController.h"

@class BindableView;

@interface ProfileViewController : BaseRequestingViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (nonatomic, assign) BOOL leftButtonItemReturnsBack;

@end
