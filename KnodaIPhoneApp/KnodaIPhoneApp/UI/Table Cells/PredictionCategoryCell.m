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
    
    [self.button.titleLabel sizeToFit];
    
    CGRect newButtonFrame = self.button.frame;
    newButtonFrame.size.width = self.button.titleLabel.frame.size.width + 40;
    self.button.frame = newButtonFrame;
    
    [self.button setImageEdgeInsets:UIEdgeInsetsMake(2, newButtonFrame.size.width - self.button.imageView.image.size.width - 17, 0, 0)];
}

- (void)setButtonEnabled:(BOOL)buttonEnabled {
    _buttonEnabled = buttonEnabled;
    self.button.userInteractionEnabled = buttonEnabled;
}

+ (CGFloat)cellHeight {
    return 40.0;
}

@end
