//
//  PredictionCategoryCell.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionCategoryCell.h"

@interface PredictionCategoryCell()

@property (nonatomic, strong) IBOutlet UIButton* button;
    
@end

@implementation PredictionCategoryCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern.png"]];
        self.backgroundView = bgView;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage *categoryBgImg = [[UIImage imageNamed:@"AP_category_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 12)];
    [self.button setBackgroundImage:categoryBgImg forState:UIControlStateNormal];
}

- (void)setCategory:(NSString *)category {
    [self.button setTitle:category forState:UIControlStateNormal];
    [self.button setTitle:category forState:UIControlStateHighlighted];
}

- (void)setButtonEnabled:(BOOL)buttonEnabled {
    _buttonEnabled = buttonEnabled;
    self.button.userInteractionEnabled = buttonEnabled;
}

+ (CGFloat)cellHeight {
    return 40.0;
}

@end
