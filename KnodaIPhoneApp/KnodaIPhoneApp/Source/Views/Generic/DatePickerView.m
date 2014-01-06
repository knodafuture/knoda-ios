//
//  DatePickerView.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "DatePickerView.h"

static UINib *nib;

@interface DatePickerView ()

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@end

@implementation DatePickerView

+ (void)initialize {
    nib = [UINib nibWithNibName:@"DatePickerView" bundle:[NSBundle mainBundle]];
}

+ (DatePickerView *)datePickerViewWithPrompt:(NSString *)prompt delegate:(id<DatePickerViewDelegate>)delegate {
    DatePickerView *pickerView = [[nib instantiateWithOwner:nil options:nil] lastObject];
    
    pickerView.datePicker.date = [NSDate date];
    pickerView.promptLabel.text = prompt;
    pickerView.delegate = delegate;
    return pickerView;
}

- (void)setDate:(NSDate *)date {
    self.datePicker.date = date;
}

- (NSDate *)date {
    return self.datePicker.date;
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    self.datePicker.minimumDate = minimumDate;
}

- (NSDate *)minimumDate {
    return self.datePicker.minimumDate;
}


- (IBAction)datePickerValueChanged:(id)sender {
    if ([self.delegate respondsToSelector:@selector(datePickerView:didChangeToDate:)])
        [self.delegate datePickerView:self didChangeToDate:self.datePicker.date];
}

- (IBAction)cancel:(id)sender {
    [self.delegate datePickerViewDidCancel:self];
}

- (IBAction)done:(id)sender {
    [self.delegate datePickerView:self didFinishWithDate:self.datePicker.date];
}


@end
