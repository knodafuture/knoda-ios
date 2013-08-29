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

#define TEXT_FONT        [UIFont fontWithName:@"HelveticaNeue" size:15]
#define PLACEHOLDER_FONT [UIFont fontWithName:@"HelveticaNeue-Italic" size:15]

static const int kPredictionCharsLimit = 300;

@interface AddPredictionViewController ()

@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UINavigationBar* navigationBar;
@property (nonatomic, strong) IBOutlet UIPickerView* categoryPicker;
@property (nonatomic, strong) IBOutlet UIPickerView* expirationPicker;
@property (nonatomic, strong) IBOutlet UIButton* categoryButton;
@property (nonatomic, strong) IBOutlet UILabel* expirationLabel;
@property (nonatomic, strong) IBOutlet UIView* activityView;
@property (nonatomic, strong) IBOutlet UILabel* charsLabel;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *predictBarButton;

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
    
    self.placeholderText = NSLocalizedString(@"Type your prediction, enter between 1-5 topics associated with your prediction and enter the deadline date when other users can no longer agree or disagree with your prediction.", @"");
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
    
    [super viewWillAppear: animated];
}


- (void) viewWillDisappear: (BOOL) animated
{
    [[NSNotificationCenter defaultCenter] removeObserver: self];
    
    [super viewWillDisappear: animated];
}


- (void) showPicker: (UIPickerView*) picker
{
    if ([self.textView isFirstResponder])
    {
        [self.textView resignFirstResponder];
    }
    
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseInOut;
    NSTimeInterval duration = 0.3;
    
    CGRect newFrame = picker.frame;
    newFrame.origin.y = self.view.frame.size.height - newFrame.size.height;
    
    [UIView animateWithDuration: duration delay: 0.0 options: (animationCurve << 16) animations:^
     {
         picker.frame = newFrame;
     } completion: NULL];
    
    [self moveUpOrDown: YES withAnimationDuration: duration animationCurve: animationCurve keyboardFrame: newFrame];
}


- (void) hidePicker: (UIPickerView*) picker
{
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseInOut;
    NSTimeInterval duration = 0.3;
    
    CGRect newFrame = picker.frame;
    newFrame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration: duration delay: 0.0 options: (animationCurve << 16) animations:^
     {
         picker.frame = newFrame;
     } completion: NULL];
    
    [self moveUpOrDown: NO withAnimationDuration: duration animationCurve: animationCurve keyboardFrame: newFrame];
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
    [self hidePicker: self.expirationPicker];
    
    if (self.categoryText.length == 0)
    {
        if (self.categories.count != 0)
        {
            self.categoryText = [self.categories objectAtIndex: 0];
            
            [self.categoryButton setTitle:self.categoryText forState:UIControlStateNormal];
            
            [self.self.categoryButton.titleLabel sizeToFit];
            
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
    
    [self showPicker: self.categoryPicker];
}


- (IBAction) selectExpirationPressed: (id) sender
{
    [self hidePicker: self.categoryPicker];
    
    if ([self.expirationLabel.text isEqualToString: NSLocalizedString(@"Set Time", @"")])
    {
        self.expirationLabel.text = [self.expirationStrings objectAtIndex: 0];
    }
    else
    {
        [self.expirationPicker selectRow: [self.expirationStrings indexOfObject: self.expirationLabel.text] inComponent: 0 animated: NO];
    }
    
    [self showPicker: self.expirationPicker];
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
        if ([self.textView isFirstResponder])
        {
            [self.textView resignFirstResponder];
        }
        
        [self hidePicker: self.categoryPicker];
        [self hidePicker: self.expirationPicker];
        
        self.activityView.hidden = NO;
        
        AddPredictionRequest* request = [[AddPredictionRequest alloc] initWithBody:self.textView.text
                                                                    expirationDate:[self expirationDate]
                                                                          category:self.categoryText];
        [request executeWithCompletionBlock: ^
        {
            self.activityView.hidden = YES;
            
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
        [self hidePicker: self.categoryPicker];
        [self hidePicker: self.expirationPicker];
        
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown: YES withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
    }
}

- (void) willHideKeyboardNotificationDidRecieve: (NSNotification*) notification
{
    if ([self.textView isFirstResponder])
    {
        NSTimeInterval animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        CGRect endFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
        
        [self moveUpOrDown:NO withAnimationDuration:animationDuration animationCurve:animationCurve keyboardFrame:endFrame];
    }
}


- (void) moveUpOrDown: (BOOL) up
withAnimationDuration: (NSTimeInterval)animationDuration
       animationCurve: (UIViewAnimationCurve)animationCurve
        keyboardFrame: (CGRect)keyboardFrame
{
    CGRect newContainerFrame = self.containerView.frame;
    
    if (up)
    {
        newContainerFrame.size.height = self.view.frame.size.height - [self.containerView.superview convertRect: keyboardFrame fromView: self.view.window].size.height - self.navigationBar.frame.size.height;
    }
    else
    {
        newContainerFrame.size.height = self.view.frame.size.height - self.navigationBar.frame.size.height;
    }
    
    [UIView animateWithDuration: animationDuration delay: 0.0 options: (animationCurve << 16) animations:^
     {
         self.containerView.frame = newContainerFrame;
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
