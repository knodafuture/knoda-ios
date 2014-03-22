//
//  CreateGroupViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 3/21/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "CreateGroupViewController.h"
#import "WebApi.h"
#import "LoadingView.h"
#import "UserManager.h"

@interface CreateGroupViewController ()
@property (strong, nonatomic) Group *group;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTextField;
@property (weak, nonatomic) IBOutlet UITextView *groupDescriptionTextView;
@property (weak, nonatomic) IBOutlet UILabel *messageCounterLabel;
@property (weak, nonatomic) IBOutlet UIView *groupImagePrompt;
@property (weak, nonatomic) IBOutlet UIImageView *groupImageView;
@end

@implementation CreateGroupViewController

- (id)initWithGroup:(Group *)group {
    self = [super initWithNibName:@"CreateGroupViewController" bundle:[NSBundle mainBundle]];
    self.group = group;
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"NEW GROUP";
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancel) color:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self action:@selector(submit) color:[UIColor whiteColor]];
    
    if (self.group) {
        self.groupNameTextField.text = self.group.name;
        self.groupDescriptionTextView.text = self.group.groupDescription;
        self.groupImagePrompt.hidden = YES;
        [[WebApi sharedInstance] getImage:self.group.avatar.big completion:^(UIImage *image, NSError *error) {
            if (image && !error)
                self.groupImageView.image = image;
        }];
    }
}

- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)submit {
    
    [[LoadingView sharedInstance] show];
    
    if (self.group) {
        self.group.name = self.groupNameTextField.text;
        self.group.groupDescription = self.groupDescriptionTextView.text;
        
        [[WebApi sharedInstance] updateGroup:self.group completion:^(Group *group, NSError *error) {
            [[LoadingView sharedInstance] hide];
            [self cancel];
        }];
    } else {
        Group *group = [[Group alloc] init];
        group.name = self.groupNameTextField.text;
        group.groupDescription = self.groupDescriptionTextView.text;
        
        [[WebApi sharedInstance] createGroup:group completion:^(Group *group, NSError *error) {
            [[LoadingView sharedInstance] hide];
            [self cancel];
        }];
    }
    
}


@end
