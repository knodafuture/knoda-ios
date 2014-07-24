//
//  AddPredictionViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AddPredictionViewController.h"
#import "LoadingView.h"
#import "WebApi.h"
#import "DatePickerView.h"
#import "UserManager.h"
#import "FacebookManager.h"
#import "UIActionSheet+Blocks.h"
#import "TwitterManager.h"

#define TEXT_FONT        [UIFont fontWithName:@"HelveticaNeue" size:15]
#define PLACEHOLDER_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:15]

static const int kPredictionCharsLimit = 300;

static NSDateFormatter *timeFormatter;
static NSDateFormatter *dateFormatter;

@interface AddPredictionViewController () <DatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *charsLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *groupPicker;
@property (weak, nonatomic) IBOutlet UILabel *groupsLabel;
@property (weak, nonatomic) IBOutlet UIView *groupsBar;
@property (weak, nonatomic) IBOutlet UIView *groupPickerContainerView;

@property (weak, nonatomic) IBOutlet UIView *categoryPickerContainerView;
@property (weak, nonatomic) IBOutlet UIView *expirationBar;
@property (weak, nonatomic) IBOutlet UIView *categoryBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) UIBarButtonItem *predictBarButtonItem;
@property (strong, nonatomic) NSString *previousCategory;

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSString *categoryText;
@property (strong, nonatomic) NSString *placeholderText;
@property (strong, nonatomic) Group *selectedGroup;
@property (assign, nonatomic) BOOL showPlaceholder;

@property (strong, nonatomic) DatePickerView *datePickerView;

@property (weak, nonatomic) DatePickerView *expirationPickerView;
@property (weak, nonatomic) UIView *activePickerView;
@property (assign, nonatomic) BOOL pickersAnimating;

@property (strong, nonatomic) NSDate *expirationDate;

@property (weak, nonatomic) IBOutlet UIImageView *facebookShareImageView;
@property (weak, nonatomic) IBOutlet UIImageView *twitterShareImageView;
@property (weak, nonatomic) IBOutlet UILabel *facebookShareLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterShareLabel;

@property (assign, nonatomic) BOOL shouldShareToFacebook;
@property (assign, nonatomic) BOOL shouldShareToTwitter;

@end

@implementation AddPredictionViewController

- (id)initWithActiveGroup:(Group *)group {
    self = [super initWithNibName:@"AddPredictionViewController" bundle:[NSBundle mainBundle]];
    self.selectedGroup = group;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.placeholderText = NSLocalizedString(@"Make a prediction...", @"");
    self.showPlaceholder = YES;
    
    [[WebApi sharedInstance] getCategoriesCompletion:^(NSArray *categories, NSError *error) {
        if (!error)
            self.categories = categories;
        [self.categoryPicker reloadAllComponents];
    }];
    
    self.predictBarButtonItem.enabled = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancel) color:[UIColor whiteColor]];
    self.predictBarButtonItem = self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self action:@selector(predict) color:[UIColor whiteColor]];
    self.title = @"PREDICT";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:tap];
    
    [[WebApi sharedInstance] getImage:[UserManager sharedInstance].user.avatar.big completion:^(UIImage *image, NSError *error) {
        if (!error)
            self.avatarView.image = image;
    }];
    
    if (self.selectedGroup) {
        [self pickerView:self.groupPicker didSelectRow:[[UserManager sharedInstance].groups indexOfObject:self.selectedGroup] + 1 inComponent:0];
        [self.groupPicker selectRow:[[UserManager sharedInstance].groups indexOfObject:self.selectedGroup] + 1 inComponent:0 animated:NO];
    }
}

- (void)didTap {
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [Flurry logEvent: @"CREATE_PREDICTION_START"];
    [super viewDidAppear: animated];
    
    self.datePickerView = [DatePickerView datePickerViewWithPrompt:nil delegate:self];
    self.datePickerView.minimumDate = [NSDate date];
    
    CGRect frame = self.datePickerView.frame;
    frame.origin.y = self.view.frame.size.height;
    self.datePickerView.frame = frame;
    [self.view addSubview:self.datePickerView];
    
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
    
    if (!timeFormatter) {
        timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateStyle:NSDateFormatterNoStyle];
        [timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [Flurry logEvent: @"CREATE_PREDICTION_SUCCESS"];
    
    [super viewWillDisappear: animated];
}

- (void)setShowPlaceholder:(BOOL)showPlaceholder {
    _showPlaceholder = showPlaceholder;
    self.textView.text = _showPlaceholder ? self.placeholderText : @"";
    self.textView.font = _showPlaceholder ? PLACEHOLDER_FONT : TEXT_FONT;
}

- (IBAction)selectExpirationPressed:(id)sender {
    self.expirationPickerView = self.datePickerView;
    
    self.datePickerView.minimumDate = [NSDate date];
    
    [self datePickerView:self.expirationPickerView didChangeToDate:self.expirationPickerView.date];
    
    [self showPickerView:self.expirationPickerView under:self.expirationBar completion:nil];
    
}

- (IBAction)selectCategoryPressed:(id)sender {
    self.previousCategory = self.categoryText;
    
    if (self.categoryText.length == 0) {
        if (self.categories.count != 0) {
            self.categoryText = [[self.categories objectAtIndex: 0] name];
            
            self.categoryLabel.text = self.categoryText;
        }
    }
    else
        [self.categoryPicker selectRow:[self indexOfTopicWithName:self.categoryText] inComponent:0 animated:NO];
    
    [self showPickerView:self.categoryPickerContainerView under:self.categoryBar completion:nil];
}

- (IBAction)selectGroupPressed:(id)sender {
    
    if ([UserManager sharedInstance].groups.count == 0 || ![UserManager sharedInstance].groups)
        return;
    
    if (!self.selectedGroup)
        [self pickerView:self.groupPicker didSelectRow:0 inComponent:0];
    else {
        [self pickerView:self.groupPicker didSelectRow:[[UserManager sharedInstance].groups indexOfObject:self.selectedGroup] + 1 inComponent:0];
        [self.groupPicker selectRow:[[UserManager sharedInstance].groups indexOfObject:self.selectedGroup] + 1 inComponent:0 animated:NO];
    }
    [self showPickerView:self.groupPickerContainerView under:self.groupsBar completion:nil];
}

- (NSInteger)indexOfTopicWithName:(NSString *)name {
    for (Tag *topic in self.categories) {
        if ([topic.name isEqualToString:name])
            return [self.categories indexOfObject:topic];
    }
    
    return 0;
}

- (IBAction)doneCategoryPicker:(id)sender {
    [self hideActivePickerCompletion:nil];
}

- (IBAction)cancelCategoryPicker:(id)sender {
    self.categoryText = self.previousCategory;
    if (self.previousCategory)
        self.categoryLabel.text = self.categoryText;
    else
        self.categoryLabel.text = @"Select a Category";

    [self hideActivePickerCompletion:nil];
}

- (IBAction)cancelGroupsPicker:(id)sender {
    [self hideActivePickerCompletion:nil];
}


- (BOOL)validate {
    NSString *errorMessage = nil;
    
    if (self.textView.text.length == 0 || self.showPlaceholder)
        errorMessage = NSLocalizedString(@"Please enter your prediction", @"");
    else if ([self expirationDate] == nil)
        errorMessage = NSLocalizedString(@"Please select a voting end date", @"");
    else if (self.categoryText.length == 0)
        errorMessage = NSLocalizedString(@"Please select a category", @"");
    else if ([[self expirationDate] timeIntervalSinceNow] < 0)
        errorMessage = @"You can't end voting or resolve your prediction in the past";
    
    if (errorMessage != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message: errorMessage delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [alert show];
        return NO;
    }
    
    return YES;
}
- (void)predict {

    if (![self validate])
        return;
    
    if ([self.textView isFirstResponder])
        [self.textView resignFirstResponder];
    
    [self hideActivePickerCompletion:nil];
    
    [[LoadingView sharedInstance] show];
    
    Prediction *prediction = [[Prediction alloc] init];
    prediction.body = self.textView.text;
    prediction.expirationDate = [self expirationDate];
    prediction.categories = @[self.categoryText];
    
    if (self.selectedGroup)
        prediction.groupId = self.selectedGroup.groupId;
    
    [[WebApi sharedInstance] addPrediction:prediction completion:^(Prediction *prediction, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (!error) {
            if (self.shouldShareToTwitter)
                [[WebApi sharedInstance] postPredictionToTwitter:prediction brag:NO completion:^(NSError *error){}];
            if (self.shouldShareToFacebook)
                [[FacebookManager sharedInstance] share:prediction brag:NO completion:^(NSError *error){}];
            [self.delegate addPredictionViewController:self didCreatePrediction:prediction];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"" message:@"Unable to create prediction at this time" delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil];
            [alert show];
        }
    }];
}


- (void)cancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPickerView:(UIView *)pickerView under:(UIView *)importantView completion:(void(^)(void))completionHandler {
    if ([self.textView isFirstResponder])
        [self.textView resignFirstResponder];
    
    if (self.pickersAnimating)
        return;
    
    if (self.activePickerView)
        [self hideActivePickerCompletion:^{
            [self _showPickerView:pickerView under:importantView completion:completionHandler];
        }];
    else
        [self _showPickerView:pickerView under:importantView completion:completionHandler];
}

- (void)_showPickerView:(UIView *)pickerView under:(UIView *)importantView completion:(void(^)(void))completionHandler {
    
    self.pickersAnimating = YES;
    self.activePickerView = pickerView;
    CGRect newFrame = pickerView.frame;
    CGRect containerFrame = self.containerView.frame;
    newFrame.origin.y = self.view.frame.size.height - newFrame.size.height;
    
    CGFloat difference = newFrame.origin.y - (importantView.frame.size.height + importantView.frame.origin.y);
    
    if (difference < 0)
        containerFrame.origin.y += difference;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        pickerView.frame = newFrame;
        self.containerView.frame = containerFrame;
    } completion:^(BOOL finished){
        self.pickersAnimating = NO;
        if (completionHandler)
            completionHandler();
    }];
}

- (void)hidePickerViewAndRestore:(UIView *)pickerView completion:(void(^)(void))completionHandler {
    
    CGRect newFrame = pickerView.frame;
    newFrame.origin.y = self.view.frame.size.height;
    
    CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        pickerView.frame = newFrame;
        self.containerView.frame = containerFrame;
    } completion:^(BOOL finished){
        if (completionHandler)
            completionHandler();
    }];
    
}

- (void)hideActivePickerCompletion:(void(^)(void))completionHandler {
    if (self.pickersAnimating)
        return;
    if (!self.activePickerView) {
        if (completionHandler)
            completionHandler();
    }
    else {
        self.pickersAnimating = YES;
        [self hidePickerViewAndRestore:self.activePickerView completion:^{
            self.activePickerView = nil;
            self.pickersAnimating = NO;
            if (completionHandler)
                completionHandler();
        }];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSInteger len = textView.text.length - range.length + text.length;
    
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    
    if(len <= kPredictionCharsLimit) {
        self.charsLabel.text = [NSString stringWithFormat:@"%ld", (long)(self.showPlaceholder ? kPredictionCharsLimit : (kPredictionCharsLimit - len))];
        self.predictBarButtonItem.enabled = !self.showPlaceholder && len > 0;
        
        return YES;
    }

    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self hideActivePickerCompletion:nil];
    if(self.showPlaceholder) {
        self.showPlaceholder = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(!textView.text.length)
        self.showPlaceholder = YES;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.categoryPicker)
        return (self.categories.count == 0) ? 1 : self.categories.count;
    else if (pickerView == self.groupPicker)
        return ([UserManager sharedInstance].groups.count == 0) ? 1 : [UserManager sharedInstance].groups.count + 1;
    
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *result = @"";
    
    if (pickerView == self.categoryPicker) {
        if (self.categories.count == 0)
            return NSLocalizedString(@"Loading Categories...", @"");
        else {
            Tag *topic = [self.categories objectAtIndex:row];
            return topic.name;
        }
    } else if (pickerView == self.groupPicker) {
        if ([UserManager sharedInstance].groups.count == 0) {
            return NSLocalizedString(@"You aren't a member of any groups", @"");
        }
        if (row == 0)
            return @"Public";
        Group *group = [UserManager sharedInstance].groups[row-1];
        return group.name;
    }
    
    return result;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (pickerView == self.categoryPicker) {
        self.categoryText = [[self.categories objectAtIndex: row] name];
        self.categoryLabel.text = self.categoryText;
    } else if (pickerView == self.groupPicker) {
        if (row == 0) {
            self.selectedGroup = nil;
            self.groupsLabel.text = @"Public";
        } else {
            self.selectedGroup = [UserManager sharedInstance].groups[row-1];
            self.groupsLabel.text = self.selectedGroup.name;
        }
    }
}

- (void)setSelectedGroup:(Group *)selectedGroup {
    _selectedGroup = selectedGroup;
    self.shouldShareToTwitter = NO;
    self.shouldShareToFacebook = NO;
    
}

- (void)datePickerView:(DatePickerView *)pickerView didChangeToDate:(NSDate *)date {
    if (pickerView == self.expirationPickerView) {
        self.expirationDate = date;
        self.expirationLabel.text = [NSString stringWithFormat:@"Voting ends on %@ at %@", [dateFormatter stringFromDate:date], [timeFormatter stringFromDate:date]];
    }
}

- (void)datePickerViewDidCancel:(DatePickerView *)pickerView {
    if (pickerView == self.expirationPickerView) {
        self.expirationDate = nil;
        self.expirationLabel.text = @"Voting Ends On...";
    }
    
    [self hideActivePickerCompletion:nil];
}

- (void)datePickerView:(DatePickerView *)pickerView didFinishWithDate:(NSDate *)date {
    [self datePickerView:pickerView didChangeToDate:date];
    [self hideActivePickerCompletion:nil];
}

- (IBAction)facebookShare:(id)sender {
    
    User *user = [UserManager sharedInstance].user;
    
    if (!user.facebookAccount) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"In order to share instantly, you need a Facebook account associated in your profile. Would you like to add one now?" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"No"];
        [sheet addButtonWithTitle:@"Yes"];
        sheet.didDismissBlock = ^(UIActionSheet *sheet, NSInteger buttonIndex) {
            if (buttonIndex == sheet.cancelButtonIndex)
                return;
            [self addFacebook];
            
        };
        
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    
    
    if (!self.shouldShareToFacebook && self.selectedGroup) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot share private group predictions." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    self.shouldShareToFacebook = !self.shouldShareToFacebook;
}

- (void)addFacebook {
    [[LoadingView sharedInstance] show];
    [[FacebookManager sharedInstance] openSession:^(NSDictionary *data, NSError *error) {
        if (error) {
            [[LoadingView sharedInstance] hide];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        SocialAccount *request = [[SocialAccount alloc] init];
        request.providerName = @"facebook";
        request.providerId = data[@"id"];
        request.accessToken = [[FacebookManager sharedInstance] accessTokenForCurrentSession];
        
        
        [[UserManager sharedInstance] addSocialAccount:request completion:^(User *user, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (error)
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:error.localizedDescription
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                  otherButtonTitles:nil] show];
            else
                [self facebookShare:nil];
        }];
    }];
}

- (IBAction)twitterShare:(id)sender {
    User *user = [UserManager sharedInstance].user;
    
    if (!user.twitterAccount) {
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"In order to share instantly, you need a Twitter account associated in your profile. Would you like to add one now?" delegate:nil cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"No"];
        [sheet addButtonWithTitle:@"Yes"];
        sheet.didDismissBlock = ^(UIActionSheet *sheet, NSInteger buttonIndex) {
            if (buttonIndex == sheet.cancelButtonIndex)
                return;
            [self addTwitter];
            
        };
        
        [sheet showInView:[UIApplication sharedApplication].keyWindow];
        return;
    }
    
    
    if (!self.shouldShareToTwitter && self.selectedGroup) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You cannot share private group predictions." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    self.shouldShareToTwitter = !self.shouldShareToTwitter;
}
- (void)setShouldShareToFacebook:(BOOL)shouldShareToFacebook {
    _shouldShareToFacebook = shouldShareToFacebook;
    
    if (self.shouldShareToFacebook) {
        self.facebookShareImageView.image = [UIImage imageNamed:@"FacebookShareActive"];
        self.facebookShareLabel.textColor = [UIColor colorFromHex:@"3B5998"];
    } else {
        self.facebookShareImageView.image = [UIImage imageNamed:@"FacebookShare"];
        self.facebookShareLabel.textColor = [UIColor colorFromHex:@"666666"];
    }
}

- (void)setShouldShareToTwitter:(BOOL)shouldShareToTwitter {
    _shouldShareToTwitter = shouldShareToTwitter;
    
    if (self.shouldShareToTwitter) {
        self.twitterShareImageView.image = [UIImage imageNamed:@"TwitterShareActive"];
        self.twitterShareLabel.textColor = [UIColor colorFromHex:@"2BA9E1"];
    } else {
        self.twitterShareImageView.image = [UIImage imageNamed:@"TwitterShare"];
        self.twitterShareLabel.textColor = [UIColor colorFromHex:@"666666"];
    }
}

- (void)addTwitter {
    [[LoadingView sharedInstance] show];
    [[TwitterManager sharedInstance] performReverseAuth:^(SocialAccount *request, NSError *error) {
        if (error) {
            [[LoadingView sharedInstance] hide];
            return;
        }
        
        [[UserManager sharedInstance] addSocialAccount:request completion:^(User *user, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (error)
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:error.localizedDescription
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                  otherButtonTitles:nil] show];
            else
                [self twitterShare:nil];
        }];
    }];
}


@end
