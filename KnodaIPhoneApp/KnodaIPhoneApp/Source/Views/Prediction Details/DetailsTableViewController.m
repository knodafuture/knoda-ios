//
//  DetailsTableViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "DetailsTableViewController.h"
#import "PredictionDetailsHeaderCell.h"
#import "PredictionDetailsSectionHeader.h"
#import "Prediction.h"
#import "CommentsDatasource.h"
#import "TallyDatasource.h"
#import "WebApi.h"
#import "NoContentCell.h"
#import "CommentCell.h"
#import "AppDelegate.h"

static const float parallaxRatio = 0.5;

@interface DetailsTableViewController () <TallyDatasourceDelegate, CommentCellDelegate>
@property (strong, nonatomic) PredictionDetailsSectionHeader *sectionHeader;
@property (assign, nonatomic) BOOL showingComments;
@property (weak, nonatomic) id<PredictionCellDelegate> owner;
@property (strong, nonatomic) UITableViewCell *noContentCell;

@property (strong, nonatomic) CommentsDatasource *commentsDatasource;
@property (strong, nonatomic) TallyDatasource *tallyDatasource;

@end

@implementation DetailsTableViewController

- (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (id)initWithPrediction:(Prediction *)prediction andOwner:(id<PredictionCellDelegate>)owner {
    self = [super initWithStyle:UITableViewStylePlain];
    _prediction = prediction;
    self.owner = owner;
    return self;
}

- (void)setPrediction:(Prediction *)prediction {
    _prediction = prediction;
    [self.headerCell configureWithPrediction:prediction];
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    self.showingComments = YES;
    self.pagingDatasource = self.commentsDatasource = [[CommentsDatasource alloc] initWithTableView:self.tableView];
    
    [super viewDidLoad];
    self.headerCell = [PredictionDetailsHeaderCell predictionCellWithOwner:self.owner];
    self.sectionHeader = [PredictionDetailsSectionHeader sectionHeaderWithOwner:self.owner];
    
    [self.headerCell configureWithPrediction:self.prediction];
}

- (void)showComments {
    if (self.showingComments)
        return;
    
    self.showingComments = YES;
    
    if (!self.commentsDatasource)
        self.commentsDatasource = [[CommentsDatasource alloc] initWithTableView:self.tableView];
    
    self.commentsDatasource.delegate = self;
    self.pagingDatasource = self.commentsDatasource;
    
    [self restoreContent];
    [self.pagingDatasource loadPage:0 completion:^{
        [self.tableView reloadData];
    }];
}

- (void)showTally {
    
    if (!self.showingComments)
        return;
    
    self.showingComments = NO;
    
    if (!self.tallyDatasource)
        self.tallyDatasource = [[TallyDatasource alloc] initWithTableView:self.tableView];
    
    self.tallyDatasource.delegate = self;
    self.pagingDatasource = self.tallyDatasource;
    
    [self restoreContent];
    [self.pagingDatasource loadPage:0 completion:^{
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return PredictionDetailsSectionHeaderHeight;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return self.sectionHeader;
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return self.headerCell.frame.size.height;
    
    if (self.noContentCell)
        return self.noContentCell.frame.size.height;
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.headerCell update];
        return self.headerCell;
    }
    
    if (self.noContentCell)
        return self.noContentCell;
    
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (self.showingComments && [cell isKindOfClass:CommentCell.class]) {
        ((CommentCell *)cell).delegate = self;
        Comment *comment = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
        if (comment.userId == self.appDelegate.currentUser.userId)
            ((CommentCell *)cell).avatarView.image = [_imageLoader lazyLoadImage:self.appDelegate.currentUser.smallImageUrl onIndexPath:indexPath];
        else
            ((CommentCell *)cell).avatarView.image = [_imageLoader lazyLoadImage:comment.smallUserImage onIndexPath:indexPath];
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentOffset.y < 0)
        return;
    
    UITableViewCell *stickyCell = self.headerCell;
    
    CGRect frame = stickyCell.frame;
    
    frame.origin.y = scrollView.contentOffset.y * parallaxRatio;
    
    stickyCell.frame = frame;
    [stickyCell.superview sendSubviewToBack:stickyCell];
    [stickyCell.superview sendSubviewToBack:self.refreshControl];

}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    if (!self.showingComments)
        return;
    
    CommentCell *cell = (CommentCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (![cell isKindOfClass:CommentCell.class])
        return;
    
    cell.avatarView.image = image;
}

- (void)requestTallyCompletion:(void (^)(NSArray *, NSArray *, NSError *))completionHandler {
    
    [[WebApi sharedInstance] getAgreedUsers:self.prediction.predictionId completion:^(NSArray *agreed, NSError *error) {
        if (!error)
            [[WebApi sharedInstance] getDisagreedUsers:self.prediction.predictionId completion:^(NSArray *disagreed, NSError *error) {
                if (!error)
                    completionHandler(agreed, disagreed, error);
                else
                    completionHandler(nil, nil, error);
            }];
        else
            completionHandler(nil, nil, error);
    }];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSInteger lastId = [(Comment *)object commentId];
    [[WebApi sharedInstance] getCommentsForPrediction:self.prediction.predictionId last:lastId completion:completionHandler];
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    if (self.showingComments) {
        NoContentCell *cell = [NoContentCell noContentWithMessage:@"Be the first to comment." forTableView:self.tableView height:self.tableView.frame.size.height - ([self.headerCell heightForPrediction:self.prediction] + PredictionDetailsSectionHeaderHeight)];
        [self showNoContent:cell];
    }
}

- (void)showNoContent:(UITableViewCell *)noContentCell {
    self.noContentCell = noContentCell;
    [self.tableView reloadData];
}

- (void)restoreContent {
    if (!self.noContentCell)
        return;
    self.noContentCell = nil;
    [self.tableView reloadData];
}

- (void)addComment:(Comment *)newComment {
    [self.commentsDatasource insertNewObject:newComment atIndex:self.commentsDatasource.objects.count reload:self.showingComments];
    if (self.showingComments) {
        [self restoreContent];
    }
}

- (void)updateTallyForUser:(NSString *)username agree:(BOOL)agree {
    [self.tallyDatasource updateTallyForUser:username agree:agree];
}

- (void)userClickedInCommentCellWithUserId:(NSInteger)userId {
    [self.owner profileSelectedWithUserId:userId inCell:nil];
}

@end
