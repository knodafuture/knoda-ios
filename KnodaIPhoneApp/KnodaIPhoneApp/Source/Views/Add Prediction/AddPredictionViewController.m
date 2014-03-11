//
//  AddPredictionViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AddPredictionViewController.h"
#import "LoadingView.h"
#import "AppDelegate.h"
#import "WebApi.h"
#import "DatePickerView.h"

#define TEXT_FONT        [UIFont fontWithName:@"HelveticaNeue" size:15]
#define PLACEHOLDER_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:15]

static const int kPredictionCharsLimit = 300;

static const CGFloat kCategorySectionHeight = 40;

static NSDateFormatter *timeFormatter;
static NSDateFormatter *dateFormatter;

@interface AddPredictionViewController () <DatePickerViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIPickerView *categoryPicker;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *expirationLabel;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLabel;
@property (weak, nonatomic) IBOutlet UILabel *charsLabel;

@property (weak, nonatomic) IBOutlet UIView *categoryPickerContainerView;
@property (weak, nonatomic) IBOutlet UIView *expirationBar;
@property (weak, nonatomic) IBOutlet UIView *categoryBar;
@property (weak, nonatomic) IBOutlet UIView *resolutionBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarView;
@property (weak, nonatomic) UIBarButtonItem *predictBarButtonItem;
@property (strong, nonatomic) NSString *previousCategory;

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSString *categoryText;
@property (strong, nonatomic) NSString *placeholderText;

@property (assign, nonatomic) BOOL showPlaceholder;

@property (strong, nonatomic) DatePickerView *datePickerView;

@property (weak, nonatomic) DatePickerView *expirationPickerView;
@property (weak, nonatomic) DatePickerView *resolutionPickerView;
@property (weak, nonatomic) UIView *activePickerView;
@property (assign, nonatomic) BOOL pickersAnimating;

@property (strong, nonatomic) NSDate *expirationDate;
@property (strong, nonatomic) NSDate *resolutionDate;

@end

@implementation AddPredictionViewController

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
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [[WebApi sharedInstance] getImage:appDelegate.currentUser.avatar.big completion:^(UIImage *image, NSError *error) {
        if (!error)
            self.avatarView.image = image;
    }];
}

- (void)didTap {
    [self.view endEditing:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [Flurry logEvent: @"Add_Prediction_Screen" withParameters: nil timed: YES];
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
    
    [Flurry endTimedEvent: @"Add_Prediction_Screen" withParameters: nil];
    
    [super viewWillDisappear: animated];
}

- (void)setShowPlaceholder:(BOOL)showPlaceholder {
    _showPlaceholder = showPlaceholder;
    self.textView.text = _showPlaceholder ? self.placeholderText : @"";
    self.textView.font = _showPlaceholder ? PLACEHOLDER_FONT : TEXT_FONT;
}

- (IBAction)selectResolutionPressed:(id)sender {
    self.expirationPickerView = nil;
    self.resolutionPickerView = self.datePickerView;
    
    if (self.expirationDate)
        self.datePickerView.minimumDate = [NSDate dateWithTimeInterval:60 sinceDate:self.expirationDate];
    else
        self.datePickerView.minimumDate = [NSDate date];

    
    [self datePickerView:self.resolutionPickerView didChangeToDate:self.resolutionPickerView.date];
    
    [self showPickerView:self.resolutionPickerView under:self.resolutionBar completion:nil];
}

- (IBAction)selectExpirationPressed:(id)sender {
    self.resolutionPickerView = nil;
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

- (BOOL)validate {
    NSString *errorMessage = nil;
    
    if (self.textView.text.length == 0 || self.showPlaceholder)
        errorMessage = NSLocalizedString(@"Please enter your prediction", @"");
    else if ([self expirationDate] == nil)
        errorMessage = NSLocalizedString(@"Please select a voting end date", @"");
    else if ([self resolutionDate] == nil)
        errorMessage = @"Please select a resolution date";
    else if (self.categoryText.length == 0)
        errorMessage = NSLocalizedString(@"Please select a category", @"");
    else if ([[self expirationDate] timeIntervalSince1970] > [[self resolutionDate] timeIntervalSince1970])
        errorMessage = @"You can't Knoda Future before the voting deadline";
    else if ([[self expirationDate] timeIntervalSinceNow] < 0 || [[self resolutionDate] timeIntervalSinceNow] < 0)
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
    prediction.resolutionDate = [self resolutionDate];
    prediction.categories = @[self.categoryText];
    
    [[WebApi sharedInstance] addPrediction:prediction completion:^(Prediction *prediction, NSError *error) {
        [[LoadingView sharedInstance] hide];
        if (!error) {
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
    
    int len = textView.text.length - range.length + text.length;
    
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    
    if(len <= kPredictionCharsLimit) {
        self.charsLabel.text = [NSString stringWithFormat:@"%d", (self.showPlaceholder ? kPredictionCharsLimit : (kPredictionCharsLimit - len))];
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
    return (self.categories.count == 0) ? 1 : self.categories.count;
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
    }
    
    return result;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.categoryText = [[self.categories objectAtIndex: row] name];
    self.categoryLabel.text = self.categoryText;
}

- (void)datePickerView:(DatePickerView *)pickerView didChangeToDate:(NSDate *)date {
    if (pickerView == self.expirationPickerView) {
        self.expirationDate = date;
        self.expirationLabel.text = [NSString stringWithFormat:@"Voting ends on %@ at %@", [dateFormatter stringFromDate:date], [timeFormatter stringFromDate:date]];
    } else {
        self.resolutionDate = date;
        self.resolutionLabel.text = [NSString stringWithFormat:@"I'll know on %@ at %@", [dateFormatter stringFromDate:date], [timeFormatter stringFromDate:date]];
    }
}

- (void)datePickerViewDidCancel:(DatePickerView *)pickerView {
    if (pickerView == self.expirationPickerView) {
        self.expirationDate = nil;
        self.expirationLabel.text = @"Voting Ends On...";
    } else {
        self.resolutionDate = nil;
        self.resolutionLabel.text = @"I'll Knoda Result On...";
    }
    
    [self hideActivePickerCompletion:nil];
}

- (void)datePickerView:(DatePickerView *)pickerView didFinishWithDate:(NSDate *)date {
    [self datePickerView:pickerView didChangeToDate:date];
    [self hideActivePickerCompletion:nil];
}



@end
