//
//  CategoryPredictionsViewController.m
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 22.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "CategoryPredictionsViewController.h"
#import "WebApi.h"

@interface CategoryPredictionsViewController ()
@property (strong, nonatomic) NSString *category;

@end

@implementation CategoryPredictionsViewController

- (id)initWithCategory:(NSString *)category {
    self = [super initWithStyle:UITableViewStylePlain];
    self.category = category;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.category uppercaseString];
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(backButtonPressed:)];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    [Flurry logEvent: @"Predictions_By_Category_Screen" withParameters: @{@"Category": self.category} timed: YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear: animated];
    [Flurry endTimedEvent: @"Predictions_By_Category_Screen" withParameters: @{@"Category": self.category}];
}

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    Prediction *prediction = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    PredictionDetailsViewController *vc = [[PredictionDetailsViewController alloc] initWithPrediction:prediction];
    vc.delegate = self;
    vc.shouldNotOpenProfile = self.shouldNotOpenProfile;
    vc.shouldNotOpenCategory = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Prediction *)object predictionId];
    [[WebApi sharedInstance] getPredictionsAfter:lastId tag:self.category completion:completionHandler];
}

- (void)profileSelectedWithUserId:(NSInteger)userId inCell:(PredictionCell *)cell {
    if (self.shouldNotOpenProfile)
        return;
    
    [super profileSelectedWithUserId:userId inCell:cell];

}

@end
