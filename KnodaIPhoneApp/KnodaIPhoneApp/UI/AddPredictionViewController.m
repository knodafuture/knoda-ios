//
//  AddPredictionViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "AddPredictionViewController.h"
#import "CategoriesWebRequest.h"
#import "AddPredictionRequest.h"
#import "LoadingView.h"
#import "BindableView.h"
#import "AppDelegate.h"
#import "User.h"

#define TEXT_FONT        [UIFont fontWithName:@"HelveticaNeue" size:15]
#define PLACEHOLDER_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:15]

static const int kPredictionCharsLimit = 300;

static const CGFloat kCategorySectionHeight = 40;

@interface AddPredictionViewController ()

@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UIPickerView* categoryPicker;
@property (nonatomic, strong) IBOutlet UIPickerView* expirationPicker;
@property (nonatomic, strong) IBOutlet UILabel *categoryLabel;
@property (nonatomic, strong) IBOutlet UILabel* expirationLabel;
@property (nonatomic, strong) IBOutlet UILabel* charsLabel;
@property (nonatomic, strong) UIBarButtonItem *predictBarButton;

@property (nonatomic, strong) IBOutlet UIView* expirationPickerContainerView;
@property (nonatomic, strong) IBOutlet UIView* categoryPickerContainerView;
@property (nonatomic, weak) IBOutlet UIView *expirationBar;
@property (nonatomic, weak) IBOutlet UIView *categoryBar;
@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet BindableView *avatarView;

@property (nonatomic, strong) NSString* previousCategory;
@property (nonatomic, strong) NSString* previousExpirationDate;

@property (nonatomic, strong) NSArray* categories;
@property (nonatomic, strong) NSArray* expirationStrings;

@property (nonatomic, strong) NSString* categoryText;
@property (nonatomic, strong) NSString *expirationString;
@property (nonatomic, strong) NSString* placeholderText;

@property (nonatomic, assign) BOOL showPlaceholder;

@end

@implementation AddPredictionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.placeholderText = NSLocalizedString(@"Make a prediction...", @"");
    self.showPlaceholder = YES;
    
    self.expirationStrings = [[self class] expirationStrings];
    
    NSString* categoriesKey = @"Categories";
	
    self.categories = [[NSUserDefaults standardUserDefaults] objectForKey: categoriesKey];
    
    __weak AddPredictionViewController *weakSelf = self;
    
    CategoriesWebRequest* categoriesRequest = [[CategoriesWebRequest alloc] init];
    [categoriesRequest executeWithCompletionBlock: ^
    {
        if (categoriesRequest.errorCode == 0)
        {
            [[NSUserDefaults standardUserDefaults] setObject: categoriesRequest.categories forKey: categoriesKey];
            
            AddPredictionViewController *strongSelf = weakSelf;
            if(strongSelf) {
                strongSelf.categories = categoriesRequest.categories;
                [strongSelf.categoryPicker reloadAllComponents];
            }
        }
    }];
    
    self.predictBarButton.enabled = NO;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancel) color:[UIColor whiteColor]];
    self.predictBarButton = self.navigationItem.rightBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self action:@selector(predict) color:[UIColor whiteColor]];
    self.title = @"PREDICT";
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap)];
    [self.view addGestureRecognizer:tap];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self.avatarView bindToURL:appDelegate.user.thumbImage];
}

- (void)didTap {
    [self.view endEditing:YES];
}

- (void) viewWillAppear: (BOOL) animated
{
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willShowKeyboardNotificationDidRecieve:) name: UIKeyboardWillShowNotification object: nil];
    //[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willHideKeyboardNotificationDidRecieve:) name: UIKeyboardWillHideNotification object: nil];

    [Flurry logEvent: @"Add_Prediction_Screen" withParameters: nil timed: YES];
    
    [super viewWillAppear: animated];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [Flurry endTimedEvent: @"Add_Prediction_Screen" withParameters: nil];
    
    [super viewWillDisappear: animated];
}


- (void) hideExpirationDatePicker
{
    self.previousExpirationDate = nil;
    [self hidePickerViewAndRestore:self.expirationPickerContainerView];
}


- (void) showExpirationDatePicker
{
    [self showPickerView:self.expirationPickerContainerView under:self.expirationBar];
}


- (void) hideCategoryPicker
{
    self.previousCategory = nil;
    [self hidePickerViewAndRestore:self.categoryPickerContainerView];
}


- (void) showCategoryPicker
{
    [self showPickerView:self.categoryPickerContainerView under:self.categoryBar];
}
- (void)showPickerView:(UIView *)pickerView under:(UIView *)importantView {
    if ([self.textView isFirstResponder])
        [self.textView resignFirstResponder];
    
    CGRect newFrame = pickerView.frame;
    CGRect containerFrame = self.containerView.frame;
    newFrame.origin.y = self.view.frame.size.height - newFrame.size.height;
    
    CGFloat difference = newFrame.origin.y - (importantView.frame.size.height + importantView.frame.origin.y);
    
    if (difference < 0)
        containerFrame.origin.y += difference;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        pickerView.frame = newFrame;
        self.containerView.frame = containerFrame;
    } completion:^(BOOL finished){}];
        
}

- (void)hidePickerViewAndRestore:(UIView *)pickerView {
    
    CGRect newFrame = pickerView.frame;
    newFrame.origin.y = self.view.frame.size.height;
    
    CGRect containerFrame = self.containerView.frame;
    containerFrame.origin.y = 0;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:0 animations:^{
        pickerView.frame = newFrame;
        self.containerView.frame = containerFrame;
    } completion:^(BOOL finished){}];
    
}

- (NSDate*) expirationDate
{
    NSDate* result = nil;
    
    if (self.expirationString)
    {
        result = [[self class] dateForExpirationString:self.expirationString];
    }
    
    return result;
}


- (void)setShowPlaceholder:(BOOL)showPlaceholder {
    _showPlaceholder = showPlaceholder;
    self.textView.text = _showPlaceholder ? self.placeholderText : @"";
    self.textView.font = _showPlaceholder ? PLACEHOLDER_FONT : TEXT_FONT;
}

#pragma mark Actions


- (IBAction) selectCategoryPressed: (id) sender
{
    [self hideExpirationDatePicker];
    
    self.previousCategory = self.categoryText;
    
    if (self.categoryText.length == 0)
    {
        if (self.categories.count != 0)
        {
            self.categoryText = [self.categories objectAtIndex: 0];
            
            self.categoryLabel.text = self.categoryText;
        }
    }
    else
    {
        [self.categoryPicker selectRow: [self.categories indexOfObject: self.categoryText] inComponent: 0 animated: NO];
    }
    
    [self showCategoryPicker];
}


- (IBAction) selectExpirationPressed: (id) sender
{
    [self hideCategoryPicker];
    
    self.previousExpirationDate = self.expirationString;
    
    if (!self.expirationString)
    {
        self.expirationString = [self.expirationStrings objectAtIndex: 0];
    }
    else
    {
        [self.expirationPicker selectRow: [self.expirationStrings indexOfObject: self.expirationString] inComponent: 0 animated: NO];
    }
    
    [self showExpirationDatePicker];
}

- (void)setExpirationString:(NSString *)expirationString {
    _expirationString = expirationString;
    self.expirationLabel.text = [NSString stringWithFormat:@"Expires in %@", expirationString];
}

- (IBAction) doneExpirationPicker: (id) sender
{
    [self hideExpirationDatePicker];
}


- (IBAction) cancelExpirationPicker: (id) sender
{
    self.expirationString = nil;
    self.expirationLabel.text = @"Expires in...";
    [self hideExpirationDatePicker];
}


- (IBAction) doneCategoryPicker: (id) sender
{
    [self hideCategoryPicker];
}


- (IBAction) cancelCategoryPicker: (id) sender
{
    self.categoryText = self.previousCategory;
    if (self.previousCategory)
        self.categoryLabel.text = self.categoryText;
    else
        self.categoryLabel.text = @"Select a Category";

    [self hideCategoryPicker];
}


- (void)predict {
    NSString* errorMessage = nil;
    
    if (self.textView.text.length == 0)
    {
        errorMessage = NSLocalizedString(@"Please enter your prediction", @"");
    }
    else if ([self expirationDate] == nil)
    {
        errorMessage = NSLocalizedString(@"Please select an expiration date", @"");
    }
    else if (self.categoryText.length == 0)
    {
        errorMessage = NSLocalizedString(@"Please select a category", @"");
    }
    
    if (errorMessage != nil)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: errorMessage delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
        [alert show];
    }
    else
    {
        [Flurry logEvent: @"Add_Prediction" withParameters: @{@"Category": self.categoryText, @"ExpirationDate": self.expirationString}];
        
        if ([self.textView isFirstResponder])
        {
            [self.textView resignFirstResponder];
        }
        
        [self hideCategoryPicker];
        [self hideExpirationDatePicker];
        
        [[LoadingView sharedInstance] show];
        
        AddPredictionRequest* request = [[AddPredictionRequest alloc] initWithBody:self.textView.text
                                                                    expirationDate:[self expirationDate]
                                                                          category:self.categoryText];
        [request executeWithCompletionBlock: ^
        {
            [[LoadingView sharedInstance] hide];
            
            if (request.errorCode == 0)
            {
                [self.delegate predictionWasMadeInController:self];
            }
            else if (request.errorCode == kRequestTimeoutError)
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"No internet connection. Please try again later.", @"") delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: request.localizedErrorDescription delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
                [alert show];
                
            }
        }];
    }
}


- (void)cancel {
    [self.delegate predictionWasMadeInController:self];
}


#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {    
    
    int len = textView.text.length - range.length + text.length;
    
    if ([text isEqualToString:@"\n"]) {
        [self.view endEditing:YES];
        return NO;
    }
    
    if(len <= kPredictionCharsLimit) {
        self.charsLabel.text = [NSString stringWithFormat:@"%d", (self.showPlaceholder ? kPredictionCharsLimit : (kPredictionCharsLimit - len))];
        self.predictBarButton.enabled = !self.showPlaceholder && len > 0;
        
        return YES;
    }
    

    
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [self hideCategoryPicker];
    [self hideExpirationDatePicker];
    if(self.showPlaceholder) {
        self.showPlaceholder = NO;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(!textView.text.length) {
        self.showPlaceholder = YES;
    }
}


#pragma mark - Keyboard show/hide handlers

#pragma mark - UIPickerViewDataSource


- (NSInteger) numberOfComponentsInPickerView: (UIPickerView*) pickerView
{
    return 1;
}


- (NSInteger) pickerView: (UIPickerView*) pickerView numberOfRowsInComponent: (NSInteger) component
{
    NSInteger result = 0;
    
    if (pickerView == self.categoryPicker)
    {
        result = (self.categories.count == 0) ? 1 : self.categories.count;
    }
    else if (pickerView == self.expirationPicker)
    {
        result = self.expirationStrings.count;
    }
    
    return result;
}


#pragma mark UIPickerViewDelegate


- (NSString*) pickerView: (UIPickerView*) pickerView titleForRow: (NSInteger) row forComponent: (NSInteger) component
{
    NSString* result = @"";
    
    if (pickerView == self.categoryPicker)
    {
        result = (self.categories.count == 0) ? NSLocalizedString(@"Loading Categories...", @"") : [self.categories objectAtIndex: row];
    }
    else if (pickerView == self.expirationPicker)
    {
        result = [self.expirationStrings objectAtIndex: row];
    }
    
    return result;
}


- (void) pickerView: (UIPickerView*) pickerView didSelectRow: (NSInteger) row inComponent: (NSInteger) component
{
    if (pickerView == self.categoryPicker)
    {
        self.categoryText = [self.categories objectAtIndex: row];

        self.categoryLabel.text = self.categoryText;
        
//        CGRect newButtonFrame = self.categoryButton.frame;
//        newButtonFrame.size.width = self.categoryButton.titleLabel.frame.size.width + 40;
//        self.categoryButton.frame = newButtonFrame;
//        
//        self.categoryButton.hidden = NO;
    }
    else if (pickerView == self.expirationPicker)
    {
        self.expirationString = [self.expirationStrings objectAtIndex: row];
    }
}

#pragma mark Expiration strings

+ (NSArray *)expirationStrings {
    static NSArray *expStrings = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expStrings = @[NSLocalizedString(@"10 minutes", @""),
                       NSLocalizedString(@"1 hour", @""),
                       NSLocalizedString(@"3 hours", @""),
                       NSLocalizedString(@"6 hours", @""),
                       NSLocalizedString(@"1 day", @""),
                       NSLocalizedString(@"3 days", @""),
                       NSLocalizedString(@"1 week", @"")];
    });
    return expStrings;
}

+ (NSDate *)dateForExpirationString:(NSString *)expString {
    NSInteger index = [[self expirationStrings] indexOfObject:expString];
    NSTimeInterval timeInterval = 0;
    
    switch (index) {
        case 0:
            // 10 minutes
            timeInterval = 10*60;
            break;
        case 1:
            // 1 hour
            timeInterval = 1 * 60 * 60;
            break;
        case 2:
            // 3 hours
            timeInterval = 3 * 60 * 60;
            break;
        case 3:
            // 6 hours
            timeInterval = 6 * 60 * 60;
            break;
        case 4:
            // 1 day
            timeInterval = 1 * 24 * 60 * 60;
            break;
        case 5:
            // 3 days
            timeInterval = 3 * 24 * 60 * 60;
            break;
        case 6:
            // 1 week
            timeInterval = 7 * 24 * 60 * 60;
            break;
            
        default:
            break;
    }
    
    return [NSDate dateWithTimeIntervalSinceNow: timeInterval];
}

@end
