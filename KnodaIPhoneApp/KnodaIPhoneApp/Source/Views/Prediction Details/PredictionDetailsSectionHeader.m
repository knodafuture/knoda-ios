//
//  PredictionDetailsSectionHeader.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/15/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsSectionHeader.h"
#import "Prediction.h"

static UINib *nib;
const CGFloat PredictionDetailsSectionHeaderHeight = 55.0;

@interface PredictionDetailsSectionHeader ()
@property (weak, nonatomic) IBOutlet UILabel *similarLabel;
@property (weak, nonatomic) IBOutlet UIImageView *similarImageView;
@end
@implementation PredictionDetailsSectionHeader

+ (void)initialize {
    nib = [UINib nibWithNibName:@"PredictionDetailsSectionHeader" bundle:[NSBundle mainBundle]];
}

+ (PredictionDetailsSectionHeader *)sectionHeaderWithOwner:(id)owner forPrediction:(Prediction *)prediction {
    
    PredictionDetailsSectionHeader *header = [[nib instantiateWithOwner:owner options:nil] lastObject];
    
    if (prediction.groupName) {
        header.similarLabel.text = prediction.groupName;
        header.similarImageView.image = [UIImage imageNamed:@"ActionGroupIcon"];
    }
    
    return header;
}


@end
