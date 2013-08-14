//
//  MakePredictionCell.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 8/13/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "MakePredictionCell.h"

@interface MakePredictionCell()

@property (nonatomic, weak) IBOutlet UIView *loadingView;

@end

@implementation MakePredictionCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]) {
        UIView *bgView = [[UIView alloc] initWithFrame:self.bounds];
        bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"darkBgPattern.png"]];
        self.backgroundView = bgView;
    }
    return self;
}

- (void)setLoading:(BOOL)loading {
    _loading = loading;
    self.loadingView.hidden = !loading;
}

+ (CGFloat)cellHeight {
    return 60.0;
}


@end
