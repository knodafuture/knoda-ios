//
//  HomeHeaderView.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "HomeHeaderView.h"


@interface HomeHeaderView ()
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *name1;
@end
@implementation HomeHeaderView

- (id)initWithDelegate:(id<HomeHeaderViewDelegate>)delegate firstName:(NSString *)name secondName:(NSString *)name2 {
    self = [[[UINib nibWithNibName:@"HomeHeaderView" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    self.delegate = delegate;
    self.name = name;
    self.name1 = name2;
    
    [self updateLabelWithLeftSideSelected:YES];
    
    return self;
}

- (void)updateLabelWithLeftSideSelected:(BOOL)leftSideSelected {
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] init];
    
    NSDictionary *leftAttributes;
    NSDictionary *rightAttributes;
        
    NSDictionary *middleAttributes = @{NSForegroundColorAttributeName: [UIColor colorFromHex:@"235C37"], UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size: 13]};
    if (leftSideSelected) {
        leftAttributes = @{NSForegroundColorAttributeName: [UIColor colorFromHex:@"235C37"], UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size: 13]};
        rightAttributes = @{NSForegroundColorAttributeName: [UIColor colorFromHex:@"62a325"], UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size: 13]};
    } else {
        rightAttributes = @{NSForegroundColorAttributeName: [UIColor colorFromHex:@"235C37"], UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size: 13]};
        leftAttributes = @{NSForegroundColorAttributeName: [UIColor colorFromHex:@"62a325"], UITextAttributeFont : [UIFont fontWithName:@"HelveticaNeue-Medium" size: 13]};
    }
    
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:self.name attributes:leftAttributes]];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:@" | " attributes:middleAttributes]];
    [text appendAttributedString:[[NSAttributedString alloc] initWithString:self.name1 attributes:rightAttributes]];
    NSMutableParagraphStyle *style = NSMutableParagraphStyle.new;
    style.alignment = NSTextAlignmentCenter;
    [text addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, text.length)];
    self.label.attributedText = text;
}

- (IBAction)leftTapped:(id)sender {
    [self updateLabelWithLeftSideSelected:YES];
    [self.delegate leftSideTappedInHeaderView:self];
}

- (IBAction)rightTapped:(id)sender {
    [self updateLabelWithLeftSideSelected:NO];
    [self.delegate rightSideTappedInHeaderView:self];
}
@end
