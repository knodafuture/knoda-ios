//
//  DatePickerView.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatePickerView;
@protocol DatePickerViewDelegate <NSObject>

- (void)datePickerViewDidCancel:(DatePickerView *)pickerView;
- (void)datePickerView:(DatePickerView *)pickerView didFinishWithDate:(NSDate *)date;
@optional
- (void)datePickerView:(DatePickerView *)pickerView didChangeToDate:(NSDate *)date;

@end

@interface DatePickerView : UIView

@property (weak, nonatomic) id<DatePickerViewDelegate> delegate;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDate *minimumDate;

+ (DatePickerView *)datePickerViewWithPrompt:(NSString *)prompt delegate:(id<DatePickerViewDelegate>)delegate;

@end
