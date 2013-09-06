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

#define TEXT_FONT        [UIFont fontWithName:@"HelveticaNeue" size:15]
#define PLACEHOLDER_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:15]

static const int kPredictionCharsLimit = 300;

static const CGFloat kCategorySectionHeight = 40;

@interface AddPredictionViewController ()

@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UINavigationBar* navigationBar;
@property (nonatomic, strong) IBOutlet UIPickerView* categoryPicker;
@property (nonatomic, strong) IBOutlet UIPickerView* expirationPicker;
@property (nonatomic, strong) IBOutlet UIButton* categoryButton;
@property (nonatomic, strong) IBOutlet UILabel* expirationLabel;
@property (nonatomic, strong) IBOutlet UILabel* charsLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *predictBarButton;

@property (nonatomic, strong) IBOutlet UIView* expirationPickerContainerView;
@property (nonatomic, strong) IBOutlet UIView* categoryPickerContainerView;

@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UIView* internalContainerView;

@property (nonatomic, strong) NSString* previousCategory;
@property (nonatomic, strong) NSString* previousExpirationDate;

@property (nonatomic, strong) NSArray* categories;
@property (nonatomic, strong) NSArray* expirationStrings;

@property (nonatomic, strong) NSString* categoryText;
@property (nonatomic, strong) NSString* placeholderText;

@property (nonatomic, assign) BOOL showPlaceholder;

@end

@implementation AddPredictionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.placeholderText = NSLocalizedString(@"Type your prediction, enter the expiration deadline when other users will no longer be able to agree or disagree with your prediction and select the category that best matches your prediction.", @"");
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
    
    UIImage *categoryBgImg = [[UIImage imageNamed:@"AP_category_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [self.categoryButton setBackgroundImage:categoryBgImg forState:UIControlStateNormal];
    
    self.predictBarButton.enabled = NO;
}


- (void) viewWillAppear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willShowKeyboardNotificationDidRecieve:) name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willHideKeyboardNotificationDidRecieve:) name: UIKeyboardWillHideNotification object: nil];

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
    [self hidePicker: self.expirationPickerContainerView viewToMoveDown: self.internalContainerView holdCategorySection: YES];
}


- (void) showExpirationDatePicker
{
    [self showPicker: self.expirationPickerContainerView viewToMoveUp: self.internalContainerView holdCategorySection: YES];
}


- (void) hideCategoryPicker
{
    self.previousCategory = nil;
    [self hidePicker: self.categoryPickerContainerView viewToMoveDown: self.containerView holdCategorySection: NO];
}


- (void) showCategoryPicker
{
    [self showPicker: self.categoryPickerContainerView viewToMoveUp: self.containerView holdCategorySection: NO];
}


- (void) showPicker: (UIView*) pickerContainer viewToMoveUp: (UIView*) viewToMove holdCategorySection: (BOOL) holdCategory
{
    if ([self.textView isFirstResponder])
    {
        [self.textView resignFirstResponder];
    }
    
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseInOut;
    NSTimeInterval duration = 0.3;
    
    CGRect newFrame = pickerContainer.frame;
    newFrame.origin.y = pickerContainer.superview.frame.size.height - newFrame.size.height - ((holdCategory) ? kCategorySectionHeight : 0);
    
    [UIView animateWithDuration: duration delay: 0.0 options: (animationCurve << 16) animations:^
     {
         pickerContainer.frame = newFrame;
     } completion: NULL];
    
    [self moveUpOrDown: YES withAnimationDuration: duration animationCurve: animationCurve keyboardFrame: newFrame viewToMove: viewToMove holdCategorySection: holdCategory];
}


- (void) hidePicker: (UIView*) pickerContainer viewToMoveDown: (UIView*) viewToMove holdCategorySection: (BOOL) holdCategory
{
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseInOut;
    NSTimeInterval duration = 0.3;
    
    CGRect newFrame = pickerContainer.frame;
    newFrame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration: duration delay: 0.0 options: (animationCurve << 16) animations:^
     {
         pickerContainer.frame = newFrame;
     } completion: NULL];
    
    [self moveUpOrDown: NO withAnimationDuration: duration animationCurve: animationCurve keyboardFrame: newFrame viewToMove: viewToMove holdCategorySection: holdCategory];
}


- (NSDate*) expirationDate
{
    NSDate* result = nil;
    
    if (![self.expirationLabel.text isEqualToString: NSLocalizedString(@"Set Time", @"")])
    {
        result = [[self class] dateForExpirationString:self.expirationLabel.text];
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
            
            [self.categoryButton setTitle:self.categoryText forState:UIControlStateNormal];
            
            [self.categoryButton.titleLabel sizeToFit];
            
            CGRect newButtonFrame = self.categoryButton.frame;
            newButtonFrame.size.width = self.categoryButton.titleLabel.frame.size.width + 40;
            self.categoryButton.frame = newButtonFrame;
            
            self.categoryButton.hidden = NO;
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
    
    self.previousExpirationDate = self.expirationLabel.text;
    
    if ([self.expirationLabel.text isEqualToString: NSLocalizedString(@"Set Time", @"")])
    {
        self.expirationLabel.text = [self.expirationStrings objectAtIndex: 0];
    }
    else
    {
        [self.expirationPicker selectRow: [self.expirationStrings indexOfObject: self.expirationLabel.text] inComponent: 0 animated: NO];
    }
    
    [self showExpirationDatePicker];
}


- (IBAction) doneExpirationPicker: (id) sender
{
    [self hideExpirationDatePicker];
}


- (IBAction) cancelExpirationPicker: (id) sender
{
    self.expirationLabel.text = self.previousExpirationDate;
    [self hideExpirationDatePicker];
}


- (IBAction) doneCategoryPicker: (id) sender
{
    [self hideCategoryPicker];
}


- (IBAction) cancelCategoryPicker: (id) sender
{
    self.categoryText = self.previousCategory;
    [self.categoryButton setTitle:self.categoryText forState:UIControlStateNormal];
    
    [self.categoryButton.titleLabel sizeToFit];
    
    CGRect newButtonFrame = self.categoryButton.frame;
    newButtonFrame.size.width = self.categoryButton.titleLabel.frame.size.width + 40;
    self.categoryButton.frame = newButtonFrame;
    
    self.categoryButton.hidden = self.categoryText.length == 0;
    
    NSLog(@"self.categoryButton.hidden = %@", (self.categoryButton.hidden) ? @"YES" : @"NO");
    
    [self hideCategoryPicker];
}


- (IBAction) predict: (id) sender
{
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
        [Flurry logEvent: @"Add_Prediction" withParameters: @{@"Category": self.categoryText, @"ExpirationDate": self.expirationLabel.text}];
        
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


- (IBAction) cancel: (id) sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
}


#pragma mark UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {    
    
    int len = textView.text.length - range.length + text.length;
    
    if(len <= kPredictionCharsLimit) {
        self.charsLabel.text = [NSString stringWithFormat:@"%d", (self.showPlaceholder ? kPredictionCharsLimit : (kPredictionCharsLimit - len))];
        self.predictBarButton.enabled = !self.showPlaceholder && len > 0;
        
        return YES;
    }
    
    return NO;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
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


- (void) willShowKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    if ([self.textView isFirstResponder])
    {
        [self hideCategoryPicker];
        [self hideExpirationDatePicker];
        
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown: YES withAnimationDuration: animationDuration animationCurve: animationCurve keyboardFrame: endFrame viewToMove: self.containerView holdCategorySection: NO];
    }
}

- (void) willHideKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    if ([self.textView isFirstResponder])
    {
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown:NO withAnimationDuration: animationDuration animationCurve: animationCurve keyboardFrame: endFrame viewToMove: self.containerView holdCategorySection: NO];
    }
}


- (void) moveUpOrDown: (BOOL) up
withAnimationDuration: (NSTimeInterval) animationDuration
       animationCurve: (UIViewAnimationCurve) animationCurve
        keyboardFrame: (CGRect) keyboardFrame
           viewToMove: (UIView*) viewToMove
  holdCategorySection: (BOOL) holdCategorySection
{
    CGRect newContainerFrame = viewToMove.frame;
    
    if (up)
    {
        newContainerFrame.size.height = viewToMove.superview.frame.size.height -
            [viewToMove.superview convertRect: keyboardFrame fromView: self.view.window].size.height -
        ((holdCategorySection) ? kCategorySectionHeight : 0) -
        ((viewToMove.superview == self.view) ? self.navigationBar.frame.size.height : 0);
    }
    else
    {
        newContainerFrame.size.height = viewToMove.superview.frame.size.height - ((viewToMove.superview == self.view) ? self.navigationBar.frame.size.height : 0) - ((holdCategorySection) ? kCategorySectionHeight : 0);
    }
    
    [UIView animateWithDuration: animationDuration delay: 0.0 options: (animationCurve << 16) animations:^
     {
         viewToMove.frame = newContainerFrame;
     } completion: NULL];
}


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
        [self.categoryButton setTitle:self.categoryText forState:UIControlStateNormal];
        
        [self.categoryButton.titleLabel sizeToFit];
        
        CGRect newButtonFrame = self.categoryButton.frame;
        newButtonFrame.size.width = self.categoryButton.titleLabel.frame.size.width + 40;
        self.categoryButton.frame = newButtonFrame;
        
        self.categoryButton.hidden = NO;
    }
    else if (pickerView == self.expirationPicker)
    {
        self.expirationLabel.text = [self.expirationStrings objectAtIndex: row];
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
