//
//  PredictionDetailsSectionHeader.m
//  KnodaIPhoneApp
//
//  Created by Nick R on 11/15/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsSectionHeader.h"

static UINib *nib;
const CGFloat predictionDetailsSectionHeaderHeight = 55.0;


@implementation PredictionDetailsSectionHeader

+ (void)initialize {
    nib = [UINib nibWithNibName:@"PredictionDetailsSectionHeader" bundle:[NSBundle mainBundle]];
}

+ (PredictionDetailsSectionHeader *)sectionHeaderWithOwner:(id)owner {
    
    PredictionDetailsSectionHeader *header = [[nib instantiateWithOwner:owner options:nil] lastObject];
    
    return header;
}


@end
