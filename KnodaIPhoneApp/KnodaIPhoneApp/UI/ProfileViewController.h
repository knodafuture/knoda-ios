//
//  ProfileViewController.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseRequestingViewController.h"

@class BindableView;

@interface ProfileViewController : BaseRequestingViewController <UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet BindableView *profileAvatarView;
@property (weak, nonatomic) IBOutlet UITableView *accountDetailsTableView;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UILabel *pointsLabel;

@property (nonatomic, assign) BOOL leftButtonItemReturnsBack;

@end
