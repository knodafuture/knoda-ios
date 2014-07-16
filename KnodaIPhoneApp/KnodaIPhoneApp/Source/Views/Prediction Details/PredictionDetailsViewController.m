//
//  PredictionDetailsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "ProfileViewController.h"
#import "CategoryPredictionsViewController.h"
#import "LoadingView.h"
#import "WebApi.h"
#import "DetailsTableViewController.h"
#import "PredictionCell.h"
#import "DatePickerView.h"
#import "CreateCommentView.h"
#import "PredictionItemProvider.h"
#import "PredictionCell.h"
#import "PredictionDetailsHeaderCell.h"
#import "UserManager.h"
#import "GroupPredictionsViewController.h"
#import "UIActionSheet+Blocks.h"
#import "FacebookManager.h"

static const int kBSAlertTag = 1001;

@interface PredictionDetailsViewController () <UIAlertViewDelegate, PredictionCellDelegate, DatePickerViewDelegate, CreateCommentViewDelegate>

@property (strong, nonatomic) Prediction *prediction;

@property (weak, nonatomic) IBOutlet UIImageView *commentsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *otherUsersImageView;
@property (strong, nonatomic) DatePickerView *datePickerView;
@property (strong, nonatomic) DetailsTableViewController *tableViewController;
@property (strong, nonatomic) CreateCommentView *createCommentView;
@property (assign, nonatomic) BOOL appeared;
@property (assign, nonatomic) BOOL composingComment;

@property (strong, nonatomic) UIBarButtonItem *rightSideBarButtonItemBackup;

@end

@implementation PredictionDetailsViewController

- (id)initWithPrediction:(Prediction *)prediction {
    self = [super init];
    self.prediction = prediction;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DETAILS";
    self.navigationController.navigationBar.translucent = NO;
    [self setDefaultBarButtonItems:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
    }
    self.tableViewController = [[DetailsTableViewController alloc] initWithPrediction:self.prediction andOwner:self];
    
    [self.tableViewController willMoveToParentViewController:self];
    
    [self addChildViewController:self.tableViewController];
    
    [self.view addSubview:self.tableViewController.view];
    
    [self showComments:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.appeared) {
        self.createCommentView = [CreateCommentView createCommentViewForPrediction:self.prediction.predictionId withDelegate:self];
        
        CGFloat teaserHeight = [self.createCommentView heightForTeaser];
        CGRect frame = self.tableViewController.view.frame;
        frame.origin.y = 0;
        frame.size.height = self.view.frame.size.height - teaserHeight * 2.0;
        self.tableViewController.view.frame = frame;
        
        frame = self.createCommentView.frame;
        
        frame.origin.y = self.tableViewController.view.frame.size.height;
        
        self.createCommentView.frame = frame;
        
        [self.view addSubview:self.createCommentView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [Flurry logEvent: @"Prediction_Details_Screen" timed: YES];
    
    if (!self.appeared) {
        self.datePickerView = [DatePickerView datePickerViewWithPrompt:@"When will you know?" delegate:self];

        CGRect frame = self.datePickerView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.datePickerView.frame = frame;
        
        [self.view addSubview:self.datePickerView];
    }
    self.appeared = YES;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"Prediction_Details_Screen" withParameters: nil];
}

- (void)setDefaultBarButtonItems:(BOOL)animated {
    
    if (self.rightSideBarButtonItemBackup)
        self.navigationItem.rightBarButtonItem = self.rightSideBarButtonItemBackup;
    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed:)]];
    self.title = @"DETAILS";
}
- (void)composeComment {
    
    if (!self.rightSideBarButtonItemBackup)
        self.rightSideBarButtonItemBackup = [self.navigationItem.rightBarButtonItems lastObject];
    
    UIBarButtonItem *cancelBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self.createCommentView action:@selector(cancel) color:[UIColor whiteColor]];
    
    UIBarButtonItem *submitBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self.createCommentView action:@selector(submit) color:[UIColor whiteColor]];
    self.title = @"COMMENT";
    [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem];
    [self.navigationItem setRightBarButtonItem:submitBarButtonItem];
}

- (IBAction)showComments:(id)sender {
    
    self.commentsImageView.image = [UIImage imageNamed:@"ActionCommentIconActive"];
    self.otherUsersImageView.image = [UIImage imageNamed:@"ActionOtherUsersIcon"];
    
    [self.tableViewController showComments];
}

- (IBAction)showOtherUsers:(id)sender {
    
    self.commentsImageView.image = [UIImage imageNamed:@"ActionCommentIcon"];
    self.otherUsersImageView.image = [UIImage imageNamed:@"ActionOtherUsersIconActive"];
    
    [self.tableViewController showTally];
    
}
- (IBAction)remindMeTapped:(id)sender {
    [self showDatePicker];
}

- (IBAction)share:(id)sender {
    
    
    
    if (self.prediction.groupName) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Hold on, this is a private group prediction. You won't be able to share it with the world." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (![UserManager sharedInstance].user.facebookAccount && ![UserManager sharedInstance].user.twitterAccount) {
        [self showDefaultShare];
        return;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"How would you like to share?" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (SocialAccount *account in [UserManager sharedInstance].user.socialAccounts) {
        [sheet addButtonWithTitle:account.providerName.capitalizedString];
    }
    
    [sheet addButtonWithTitle:@"Other"];
    __unsafe_unretained PredictionDetailsViewController *this = self;
    sheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == actionSheet.destructiveButtonIndex)
            return;
        
        if (buttonIndex == [UserManager sharedInstance].user.socialAccounts.count)
            [this showDefaultShare];
        else
            [this shareWithSocialAccount:[UserManager sharedInstance].user.socialAccounts[buttonIndex]];
            
    };
    sheet.destructiveButtonIndex = [sheet addButtonWithTitle:@"Cancel"];
    [sheet showInView:[UIApplication sharedApplication].keyWindow];
}

- (void)shareWithSocialAccount:(SocialAccount *)account {
    [[LoadingView sharedInstance] show];
    if ([account.providerName isEqualToString:@"twitter"])
        [[WebApi sharedInstance] postPredictionToTwitter:self.prediction brag:NO completion:^(NSError *error){
            [[LoadingView sharedInstance] hide];
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    else if ([account.providerName isEqualToString:@"facebook"])
        [[FacebookManager sharedInstance] share:self.prediction brag:NO completion:^(NSError *error){
            [[LoadingView sharedInstance] hide];
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unknown error occured." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            }
        }];
    
}

- (void)showDefaultShare {
    PredictionItemProvider *item = [[PredictionItemProvider alloc] initWithPrediction:self.prediction];
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[item] applicationActivities:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        [vc setExcludedActivityTypes:@[UIActivityTypePostToWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo,
                                       UIActivityTypePostToFlickr, UIActivityTypeAssignToContact, UIActivityTypeAirDrop, UIActivityTypeAddToReadingList, UIActivityTypeSaveToCameraRoll, UIActivityTypePrint]];
    else
        [vc setExcludedActivityTypes:@[UIActivityTypePostToWeibo, UIActivityTypeAssignToContact, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll]];
    [UINavigationBar setDefaultAppearance];
    
    [vc setCompletionHandler:^(NSString *act, BOOL done) {
        [UINavigationBar setCustomAppearance];
    }];
    
    [vc setValue:[NSString stringWithFormat:@"%@ shared a Knoda prediction with you", [UserManager sharedInstance].user.name] forKey:@"subject"];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)backPressed:(UIButton *)sender {
    [self.delegate updatePrediction:self.prediction];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)bsButtonTapped:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Don't be lame. Tell the truth. It's more fun this way. Is this really the wrong outcome?", @"")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    alertView.tag = kBSAlertTag;
    [alertView show];
}

- (IBAction)agreeButtonTapped:(UIButton *)sender {
    [Flurry logEvent: @"Agree_Button_Tapped"];
    [self sendAgree:YES];
}

- (IBAction)disagreeButtonTapped:(UIButton *)sender {
    [Flurry logEvent: @"Disagree_Button_Tapped"];
    [self sendAgree:NO];
}

- (IBAction)yesButtonTapped:(UIButton *)sender {
    [self sendOutcome:YES];
}

- (IBAction)noButtonTapped:(UIButton *)sender {
    [self sendOutcome:NO];
}

- (IBAction)categoryButtonTapped:(UIButton *)sender {
    if(self.shouldNotOpenCategory) {
        [self backPressed:nil];
    }
    if (!self.prediction.groupName) {
        CategoryPredictionsViewController *vc = [[CategoryPredictionsViewController alloc] initWithCategory:[self.prediction.categories firstObject]];
        vc.shouldNotOpenProfile = self.shouldNotOpenProfile;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [[LoadingView sharedInstance] show];
        
        [[WebApi sharedInstance] getGroup:self.prediction.groupId completion:^(Group *group, NSError *error) {
            [[LoadingView sharedInstance] hide];
            
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Sorry, something went wrong" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
            } else {
                GroupPredictionsViewController *vc = [[GroupPredictionsViewController alloc] initWithGroup:group];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    }
}

- (void)sendAgree:(BOOL)agree {
    [[LoadingView sharedInstance] show];
    
    if (agree) {
        [self.tableViewController updateTallyForUser:[UserManager sharedInstance].user agree:YES];
        [[WebApi sharedInstance] agreeWithPrediction:self.prediction.predictionId completion:^(Challenge *challenge, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (!error) {
                self.prediction.challenge = challenge;
                self.tableViewController.headerCell.predictionCell.agreed = YES;
                self.tableViewController.prediction = self.prediction;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to agree at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
    else {
        [self.tableViewController updateTallyForUser:[UserManager sharedInstance].user agree:NO];
        [[WebApi sharedInstance] disagreeWithPrediction:self.prediction.predictionId completion:^(Challenge *challenge, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (!error) {
                self.prediction.challenge = challenge;
                self.tableViewController.headerCell.predictionCell.disagreed = YES;
                self.tableViewController.prediction = self.prediction;
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to disagree at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

- (void)sendOutcome:(BOOL)realise {
    
    [[LoadingView sharedInstance] show];
    
    [[WebApi sharedInstance] setPredictionOutcome:self.prediction.predictionId correct:realise completion:^(NSError *error) {
        if (!error) {
            [[WebApi sharedInstance] getPrediction:self.prediction.predictionId completion:^(Prediction *prediction, NSError *error) {
                [[LoadingView sharedInstance] hide];
                if (!error) {
                    self.prediction = prediction;
                    self.tableViewController.prediction = self.prediction;
                }
            }];
        } else {
            [[LoadingView sharedInstance] hide];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to set outcome at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (void)sendBS {
    
    [[LoadingView sharedInstance] show];

    [[WebApi sharedInstance] sendBS:self.prediction.predictionId completion:^(NSError *error) {
        if (!error) {
            [[WebApi sharedInstance] getPrediction:self.prediction.predictionId completion:^(Prediction *prediction, NSError *error) {
                [[LoadingView sharedInstance] hide];
                if (!error) {
                    self.prediction = prediction;
                    self.tableViewController.prediction = prediction;
                }
            }];
        } else {
            [[LoadingView sharedInstance] hide];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to call BS at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (void)sendNewResolutionDate:(NSDate *)date {
    [[LoadingView sharedInstance] show];
    
    self.prediction.resolutionDate = date;
    
    [[WebApi sharedInstance] updatePrediction:self.prediction completion:^(Prediction *prediction, NSError *error) {
        if (!error) {
            [[WebApi sharedInstance] getPrediction:self.prediction.predictionId completion:^(Prediction *prediction, NSError *error) {
                [[LoadingView sharedInstance] hide];
                if (!error) {
                    self.prediction = prediction;
                    self.tableViewController.prediction = prediction;
                }
            }];

        } else {
            [[LoadingView sharedInstance] hide];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to update prediction at this time" delegate: nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
            [alert show];
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == kBSAlertTag && alertView.cancelButtonIndex != buttonIndex) {
        [Flurry logEvent: @"BS_Button_Tapped"];
        [self sendBS];
    }
}

- (void)profileSelectedWithUserId:(NSInteger)userId inCell:(PredictionCell *)cell {
    if (self.shouldNotOpenProfile)
        return;
    
    if (userId == [UserManager sharedInstance].user.userId) {
        ProfileViewController *vc = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:[NSBundle mainBundle]];
        vc.leftButtonItemReturnsBack = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        AnotherUsersProfileViewController *vc = [[AnotherUsersProfileViewController alloc] initWithUserId:userId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)predictionAgreed:(Prediction *)prediction inCell:(PredictionCell *)cell {
    
}

- (void)predictionDisagreed:(Prediction *)prediction inCell:(PredictionCell *)cell {
    
}

- (void)showDatePicker {
    
    self.datePickerView.minimumDate = self.datePickerView.date = [NSDate date];
    
    CGRect frame = self.datePickerView.frame;
    
    frame.origin.y = self.view.frame.size.height - frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.datePickerView.frame = frame;
    }];
}

- (void)hideDatePicker {
    
    CGRect frame = self.datePickerView.frame;
    
    frame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.datePickerView.frame = frame;
    }];
}

- (void)datePickerViewDidCancel:(DatePickerView *)pickerView {
    [self hideDatePicker];
}
- (void)datePickerView:(DatePickerView *)pickerView didFinishWithDate:(NSDate *)date {
    [self sendNewResolutionDate:date];
    [self hideDatePicker];
}

- (void)createCommentViewDidBeginEditing:(CreateCommentView *)createCommentView {
    if (self.composingComment)
        return;
    
    self.composingComment = YES;
    [self composeComment];
}

- (void)createCommentViewDidCancel:(CreateCommentView *)createCommentView {
    if (!self.composingComment)
        return;
    
    self.composingComment = NO;
    [self setDefaultBarButtonItems:NO];
}

- (void)createCommentView:(CreateCommentView *)createCommentView didCreateComment:(Comment *)comment {
    comment.challenge = self.prediction.challenge;
    self.composingComment = NO;
    [self.tableViewController addComment:comment];
    self.prediction.commentCount++;
    self.tableViewController.prediction = self.prediction;

    [self setDefaultBarButtonItems:NO];
}
@end