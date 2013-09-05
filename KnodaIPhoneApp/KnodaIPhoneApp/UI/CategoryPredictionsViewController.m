//
//  CategoryPredictionsViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 22.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CategoryPredictionsViewController.h"
#import "PreditionCell.h"
#import "LoadingCell.h"

static NSString* const kPredictionDetailsSegue = @"PredictionDetailsSegue";

@interface CategoryPredictionsViewController ()

@end

@implementation CategoryPredictionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.category uppercaseString];
}

- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if([segue.identifier isEqualToString:kPredictionDetailsSegue]) {
        PredictionDetailsViewController *vc = (PredictionDetailsViewController *)segue.destinationViewController;
        vc.prediction = sender;
        vc.addPredictionDelegate = self;
        vc.shouldNotOpenCategory = YES;
        vc.shouldNotOpenProfile = self.shouldNotOpenProfile;
        vc.delegate = self;
    }
    else {
        [super prepareForSegue:segue sender:sender];
    }
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSString *)predictionsCategory {
    return self.category;
}

#pragma mark - PredictionCellDelegate

- (void) profileSelectedWithUserId:(NSInteger)userId inCell:(PreditionCell *)cell {
    if(!self.shouldNotOpenProfile) {
        [super profileSelectedWithUserId:userId inCell:cell];
    }
}

@end
