//
//  SearchBar.m
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SearchBar.h"
#import <QuartzCore/QuartzCore.h>

@interface SearchBarTextField : UITextField

@end

@implementation SearchBarTextField

- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 20, 5);
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset(bounds, 20, 5);
}

@end



@interface SearchBar () <UITextFieldDelegate>
@property (strong, nonatomic) SearchBarTextField *customTextField;
@end

@implementation SearchBar

- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 290, 44)];
    
    self.customTextField = [[SearchBarTextField alloc] initWithFrame:CGRectMake(10, self.frame.size.height / 2.0 - 15.0, self.frame.size.width - 20, 30)];
    [self addSubview:self.customTextField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *buttonImage = [UIImage imageNamed:@"SearchClearIcon"];

    CGRect frame = button.frame;
    frame.size = buttonImage.size;
    frame.origin.x = self.frame.size.width - frame.size.width - 20.0;
    frame.origin.y = self.frame.size.height / 2.0 - frame.size.height / 2.0;
    
    button.frame = frame;
    
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [self addSubview:button];
    
    [button addTarget:self action:@selector(clear) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchIcon"]];
    frame = imageView.frame;
    frame.origin.x = self.customTextField.frame.origin.x + 4.0;
    frame.origin.y = self.frame.size.height / 2.0 - frame.size.height / 2.0;
    imageView.frame = frame;
    
    [self addSubview:imageView];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0"))
        self.customTextField.tintColor = [UIColor colorFromHex:@"77BC1F"];
    
    self.customTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.customTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.customTextField.enablesReturnKeyAutomatically = YES;
    self.customTextField.returnKeyType = UIReturnKeySearch;
    self.customTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    self.customTextField.borderStyle = UITextBorderStyleNone;
    self.customTextField.delegate = self;
    self.customTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Search Knoda" attributes:@{NSForegroundColorAttributeName: [UIColor colorFromHex:@"77BC1F"]}];
    self.customTextField.backgroundColor = [UIColor colorFromHex:@"235C37"];
    self.customTextField.textColor = [UIColor whiteColor];
    self.customTextField.layer.cornerRadius = 5.0;
    self.customTextField.layer.masksToBounds = YES;
    return self;
}

- (UITextField *)textField {
    return self.customTextField;
}

- (void)clear {
    [self.delegate searchBarDidClearText:self];
    self.textField.text = @"";
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.text.length) {
        [textField resignFirstResponder];
        [self.delegate searchBar:self didSearchForText:textField.text];
        return YES;
    }
    return NO;
}
@end
