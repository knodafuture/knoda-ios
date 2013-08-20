//
//  NavigationViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "NavigationViewController.h"
#import "AppDelegate.h"

#import "NavigationSegue.h"

#import "SelectPictureViewController.h"

static NSString* const kHomeSegue = @"HomeSegue";
static NSString* const kSelectPictureSegue = @"SelectPictureSegue";

@interface NavigationViewController () <SelectPictureDelegate>

@property (nonatomic, strong) IBOutlet UIView* masterView;
@property (nonatomic, strong) IBOutlet UIView* detailsView;
@property (nonatomic, strong) IBOutlet UIView* movingView;
@property (nonatomic, assign) BOOL appeared;

@property (nonatomic, assign) BOOL masterShown;

@end

@implementation NavigationViewController


- (void) viewDidLoad {
    [super viewDidLoad];

	[self performSegueWithIdentifier: kHomeSegue sender: self];
//    if([[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] profileImage]) {
//        [self performSegueWithIdentifier: kHomeSegue sender: self];
//    }
//    else {
//        [self performSegueWithIdentifier: kSelectPictureSegue sender: self];
//    }
}


- (void) viewDidUnload
{
    self.masterView = nil;
    self.detailsView = nil;
    self.movingView = nil;
    
    [super viewDidUnload];
}


- (void) viewDidAppear: (BOOL) animated
{
    self.appeared = YES;
}


- (void) prepareForSegue: (UIStoryboardSegue*) segue sender: (id) sender
{
    if([segue isKindOfClass:[NavigationSegue class]]) {
        ((NavigationSegue*)segue).detailsView = self.detailsView;
        ((NavigationSegue*)segue).completion = ^{[self moveToDetailsAnimated: self.appeared];};
    }
    else if([segue.identifier isEqualToString:kSelectPictureSegue]) {
        SelectPictureViewController *vc = (SelectPictureViewController *)segue.destinationViewController;
        vc.delegate = self;
    }
}



- (void) moveToDetailsAnimated: (BOOL) animated
{
    if (animated)
    {
        [UIView animateWithDuration: 0.3 animations: ^
         {
             [self moveToDetails];
         }];
    }
    else
    {
        [self moveToDetails];
    }
}


- (void) moveToDetails
{
    self.masterShown = NO;
    
    CGRect newFrame = self.movingView.frame;
    newFrame.origin.x -= self.masterView.frame.size.width;
    self.movingView.frame = newFrame;
}


- (void) moveToMaster
{
    self.masterShown = YES;
    
    [UIView animateWithDuration: 0.3 animations: ^
     {
         CGRect newFrame = self.movingView.frame;
         newFrame.origin.x += self.masterView.frame.size.width;
         self.movingView.frame = newFrame;
     }];
}


- (void) toggleNavigationPanel
{
    if (self.masterShown)
    {
        [self moveToDetailsAnimated: YES];
    }
    else
    {
        [self moveToMaster];
    }
}


#pragma mark - UITableViewDataSource


- (NSInteger) numberOfSectionsInTableView: (UITableView*) tableView
{
    return 1;
}


- (NSInteger) tableView: (UITableView*) tableView numberOfRowsInSection: (NSInteger) section
{
    return 5;
}


- (UITableViewCell*) tableView: (UITableView*) tableView cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
    NSString* identefier = @"";
    
    switch (indexPath.row) {
        case 0:
            identefier = @"HomeCell";
            break;
        case 1:
            identefier = @"HistoryCell";
            break;
        case 2:
            identefier = @"AlertsCell";
            break;
        case 3:
            identefier = @"BadgesCell";
            break;
        case 4:
            identefier = @"ProfileCell";
            break;
            
        default:
            break;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: identefier];
    
    return cell;
}

#pragma mark SelectPictureDelegate

- (void)hideViewController:(SelectPictureViewController *)vc {
    [vc.navigationController popViewControllerAnimated:NO];
    [self performSegueWithIdentifier: kHomeSegue sender: self];
}

@end
