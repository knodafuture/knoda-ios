//
//  MyPicksViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "MyPicksViewController.h"
#import "PreditionCell.h"
#import "HistoryMyPicksWebRequest.h"


@interface MyPicksViewController ()

@property (nonatomic, strong) NSArray* predictions;

@end


@implementation MyPicksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    HistoryMyPicksWebRequest* request = [[HistoryMyPicksWebRequest alloc] init];
    [request executeWithCompletionBlock: ^
     {
         if (request.errorCode == 0)
         {
             self.predictions = request.predictions;
         }
     }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return 30;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    
    PreditionCell* cell = [tableView dequeueReusableCellWithIdentifier:[PreditionCell reuseIdentifier]];
    
    if (indexPath.row % 2 != 0)
    {
        cell.agreed = YES;
    }
    else
    {
        cell.disagreed = YES;
    }
    
    
    return cell;
}


@end
