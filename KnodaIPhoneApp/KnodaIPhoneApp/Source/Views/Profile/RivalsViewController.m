//
//  RivalsViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 9/18/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "RivalsViewController.h"
#import "RivalTableViewCell.h"
#import "WebApi.h"
#import "UserManager.h"
#import "HeadToHeadBarView.h"
#import "NoContentCell.h"

@interface RivalsViewController ()
@property (strong, nonatomic) ImageLoader *secondImageLoader;
@property (strong, nonatomic) NSMutableSet *openRows;
@end

@implementation RivalsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pagingDatasource.singlePage = YES;
    self.secondImageLoader = [[ImageLoader alloc] initForTable:self.tableView delegate:self];
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem backButtonWithTarget:self action:@selector(onBack)];
    self.title = @"RIVALS";
    
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.openRows = [[NSMutableSet alloc] init];
}

- (void)onBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    

    if ([self.openRows containsObject:@(indexPath.row)])
        return 214;
    
    return 66.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    User *user = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    RivalTableViewCell *cell = [RivalTableViewCell cellForTableView:tableView];
    
    [cell populateWithLeftUser:[UserManager sharedInstance].user rightUser:user];
    
    cell.barView.leftImageView.image = [_imageLoader lazyLoadImage:[UserManager sharedInstance].user.avatar.small onIndexPath:indexPath];
    cell.barView.rightImageView.image = [self.secondImageLoader lazyLoadImage:user.avatar.small onIndexPath:indexPath];
    cell.clipsToBounds = ![self.openRows containsObject:indexPath];
    
    CGRect frame = cell.frame;
    
    if ([self.openRows containsObject:indexPath])
        frame.size.height = 214;
    else
        frame.size.height = 76.0;
    cell.frame = frame;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.pagingDatasource.objects.count)
        return;
    
    if ([self.openRows containsObject:@(indexPath.row)])
        [self.openRows removeObject:@(indexPath.row)];
    else
        [self.openRows addObject:@(indexPath.row)];
    
    //dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        NSLog(@"%@", self.openRows);
    //});
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    [[WebApi sharedInstance] getRivals:[UserManager sharedInstance].user.userId completion:completionHandler];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    UITableViewCell *cell = [[[UINib nibWithNibName:@"RivalEmptyCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    [self showNoContent:cell];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    RivalTableViewCell *cell = (RivalTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:RivalTableViewCell.class])
        return;
    
    if (loader == self.secondImageLoader) {
        cell.barView.rightImageView.image = image;
    } else {
        cell.barView.leftImageView.image = image;
    }
}

@end
