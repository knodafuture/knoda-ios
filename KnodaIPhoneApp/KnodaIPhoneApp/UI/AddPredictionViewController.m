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


@interface AddPredictionViewController ()

@property (nonatomic, strong) IBOutlet UIView* containerView;
@property (nonatomic, strong) IBOutlet UITextView* textView;
@property (nonatomic, strong) IBOutlet UINavigationBar* navigationBar;
@property (nonatomic, strong) IBOutlet UIPickerView* categoryPicker;
@property (nonatomic, strong) IBOutlet UIPickerView* expirationPicker;
@property (nonatomic, strong) IBOutlet UIButton* categoryButton;
@property (nonatomic, strong) IBOutlet UILabel* categoryLabel;
@property (nonatomic, strong) IBOutlet UILabel* expirationLabel;
@property (nonatomic, strong) IBOutlet UIView* activityView;

@property (nonatomic, strong) NSArray* categories;
@property (nonatomic, strong) NSArray* expirationStrings;

@end

@implementation AddPredictionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.expirationStrings = [[self class] expirationStrings];
    
    NSString* categoriesKey = @"Categories";
	
    self.categories = [[NSUserDefaults standardUserDefaults] objectForKey: categoriesKey];
    
    CategoriesWebRequest* categoriesRequest = [[CategoriesWebRequest alloc] init];
    [categoriesRequest executeWithCompletionBlock: ^
    {
        if (categoriesRequest.errorCode == 0)
        {
            self.categories = categoriesRequest.categories;
            
            [[NSUserDefaults standardUserDefaults] setObject: self.categories forKey: categoriesKey];
            [self.categoryPicker reloadAllComponents];
        }
    }];
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
        NSInteger index = [self.expirationStrings indexOfObject: self.expirationLabel.text];
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
        
        result = [NSDate dateWithTimeIntervalSinceNow: timeInterval];
    }
    
    return result;
}


#pragma mark Actions


- (IBAction) selectCategoryPressed: (id) sender
{
    [self hidePicker: self.expirationPicker];
    
    if (self.categoryLabel.text.length == 0)
    {
        if (self.categories.count != 0)
        {
            self.categoryLabel.text = [self.categories objectAtIndex: 0];
            [self.categoryLabel sizeToFit];
            
            CGRect newButtonFrame = self.categoryButton.frame;
            newButtonFrame.size.width = self.categoryLabel.frame.size.width + 40;
            self.categoryButton.frame = newButtonFrame;
            
            self.categoryButton.hidden = NO;
        }
    }
    else
    {
        [self.categoryPicker selectRow: [self.categories indexOfObject: self.categoryLabel.text] inComponent: 0 animated: NO];
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
        [self.expirationPicker selectRow: [self.expirationStrings indexOfObject: self.categoryLabel.text] inComponent: 0 animated: NO];
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
    else if (self.categoryLabel.text.length == 0)
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
        
        NSCalendar* gregorian = [[NSCalendar alloc] initWithCalendarIdentifier: NSGregorianCalendar];
        [gregorian setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
        NSDateComponents* dateComponents = [gregorian components: NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit fromDate: [self expirationDate]];
        
        AddPredictionRequest* request = [[AddPredictionRequest alloc] initWithBody: self.textView.text expirationDay: dateComponents.day expirationMonth: dateComponents.month expirationYear: dateComponents.year expirationHour: dateComponents.hour expirationMinute: dateComponents.minute category: self.categoryLabel.text];
        [request executeWithCompletionBlock: ^
        {
            self.activityView.hidden = YES;
            
            if (request.errorCode == 0)
            {
                [self.delegate predictinMade];
            }
            else if (request.errorCode == kRequestTimeoutError)
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"No internet connection. Please try again later.", @"") delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"" message: NSLocalizedString(@"Unknown error. Please try again later.", @"") delegate: nil cancelButtonTitle: NSLocalizedString(@"OK", @"") otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}


- (IBAction) cancel: (id) sender
{
    [self dismissViewControllerAnimated: YES completion: nil];
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
        self.categoryLabel.text = [self.categories objectAtIndex: row];
        [self.categoryLabel sizeToFit];
        
        CGRect newButtonFrame = self.categoryButton.frame;
        newButtonFrame.size.width = self.categoryLabel.frame.size.width + 40;
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

@end
