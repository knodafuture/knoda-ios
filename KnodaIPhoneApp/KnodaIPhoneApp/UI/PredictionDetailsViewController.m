//
//  PredictionDetailsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsViewController.h"

#import "PreditionCell.h"
#import "PredictionCategoryCell.h"


@interface PredictionDetailsViewController ()

@end

@implementation PredictionDetailsViewController

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
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString*) predictionCreatedIntervalString: (Prediction*) prediciton
{
    NSString* result;
    
    NSDate* now = [NSDate date];
    
    NSTimeInterval interval = [now timeIntervalSinceDate: prediciton.creationDate];
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: NSLocalizedString(@"made %ds ago", @""), (NSInteger)interval];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = ((NSInteger)interval / secondsInMinute) % minutesInHour;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: NSLocalizedString(@"made %@%@%@ ago", @""), hoursString, space, minutesString];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dd ago", @""), days];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dmth ago", @""), month];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear));
        result = [NSString stringWithFormat: NSLocalizedString(@"made %dyr%@ ago", @""), year, (year != 1) ? @"s" : @""];
    }
    
    return result;
}


- (NSString*) predictionExpiresIntervalString: (Prediction*) prediciton
{
    NSString* result;
    
    NSTimeInterval interval = 0;
    NSDate* now = [NSDate date];
    BOOL expired = NO;
    
    if ([now compare: prediciton.expirationDate] == NSOrderedAscending)
    {
        interval = [prediciton.expirationDate timeIntervalSinceDate: now];
    }
    else
    {
        interval = [now timeIntervalSinceDate: prediciton.expirationDate];
        expired = YES;
    }
    
    NSInteger secondsInMinute = 60;
    NSInteger minutesInHour = 60;
    NSInteger hoursInDay = 24;
    NSInteger daysInMonth = 30;
    NSInteger monthInYear = 12;
    
    if (interval < secondsInMinute)
    {
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %ds%@", @""), (NSInteger)interval, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay))
    {
        NSInteger minutes = ((NSInteger)interval / secondsInMinute) % minutesInHour;
        NSInteger hours = (NSInteger)interval / (secondsInMinute * minutesInHour);
        
        NSString* hoursString = (hours != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dh", @""), hours] : @"";
        NSString* minutesString = (minutes != 0) ? [NSString stringWithFormat: NSLocalizedString(@"%dm", @""), minutes] : @"";
        NSString* space = (hours != 0 && minutes != 0) ? @" " : @"";
        
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %@%@%@%@", @""), hoursString, space, minutesString, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth))
    {
        NSInteger days = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay));
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dd%@", @""), days, (expired) ? @" ago" : @""];
    }
    else if (interval < (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear))
    {
        NSInteger month = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth));
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dmth%@", @""), month, (expired) ? @" ago" : @""];
    }
    else
    {
        NSInteger year = ((NSInteger)interval / (secondsInMinute * minutesInHour * hoursInDay * daysInMonth * monthInYear));
        result = [NSString stringWithFormat: NSLocalizedString(@"exp %dyr%@", @""), year, (year != 1) ? @"s" : @"", (expired) ? @" ago" : @""];
    }
    
    return result;
}


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return 3;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    UITableViewCell* tableCell;
    
    if (indexPath.row == 0)
    {
        PreditionCell* cell = [tableView dequeueReusableCellWithIdentifier: @"PredictionBreifCell"];
/*
        cell.usernameLabel.text = self.prediction.userName;
        cell.bodyLabel.text = self.prediction.body;
        cell.metadataLabel.text = [NSString stringWithFormat: NSLocalizedString(@"%@ | %@ | %d%% agree", @""),
                                   [self predictionExpiresIntervalString: self.prediction],
                                   [self predictionCreatedIntervalString: self.prediction],
                                   self.prediction.agreedPercent];
        
        CGRect rect = cell.bodyLabel.frame;
        CGSize maximumLabelSize = CGSizeMake(218, 37);
        
        CGSize expectedLabelSize = [cell.bodyLabel.text sizeWithFont: [UIFont fontWithName: @"HelveticaNeue" size: 15] constrainedToSize: maximumLabelSize lineBreakMode: NSLineBreakByWordWrapping];
        rect.size.height = expectedLabelSize.height;
        cell.bodyLabel.frame = rect;
*/        
        UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] init];
        [cell addPanGestureRecognizer: recognizer];
        
        tableCell = cell;
    }
    else if (indexPath.row == 1)
    {
        PredictionCategoryCell* cell = [tableView dequeueReusableCellWithIdentifier: @"CategoryCell"];
        
        cell.label.text = self.prediction.category;
        [cell.label sizeToFit];
        
        CGRect newButtonFrame = cell.button.frame;
        newButtonFrame.size.width = cell.label.frame.size.width + 40;
        cell.button.frame = newButtonFrame;
        
        tableCell = cell;
    }
    else
    {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: @"OutcomeCell"];
        tableCell = cell;
    }
    
    return tableCell;
}


#pragma mark - UITableViewDelegate


- (CGFloat) tableView: (UITableView*) tableView heightForRowAtIndexPath: (NSIndexPath*) indexPath
{
    if (indexPath.row == 0)
    {
        return 88;
    }
    else if (indexPath.row == 1)
    {
        return 44;
    }
    else
    {
        return 92;
    }
}


@end
