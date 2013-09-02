//
//  PredictionDetailsViewController.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 8/6/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "PredictionDetailsViewController.h"
#import "AnotherUsersProfileViewController.h"
#import "Prediction.h"
#import "Chellange.h"
#import "ProfileViewController.h"
#import "PredictionDetailsCell.h"
#import "PredictionCategoryCell.h"
#import "PredictionStatusCell.h"
#import "MakePredictionCell.h"
#import "OutcomeCell.h"
#import "LoadingCell.h"
#import "User.h"
#import "PredictorsCountCell.h"
#import "PredictorCell.h"

#import "AddPredictionViewController.h"

#import "PredictionUsersWebRequest.h"
#import "BSWebRequest.h"
#import "OutcomeWebRequest.h"
#import "ChellangeByPredictionWebRequest.h"
#import "PredictionAgreeWebRequest.h"
#import "PredictionDisagreeWebRequest.h"
#import "PredictionUpdateWebRequest.h"
#import "CategoryPredictionsViewController.h"
#import "AppDelegate.h"

typedef enum {
    RowEmpty = -1,
    RowPrediction,
    RowCategory,
    RowStatus,
    RowPredictorsCount,
    RowMakePrediction,
    RowOutcome,
    RowPredictor,
    RowLoading,
    TableRowsBaseCount = RowPredictorsCount + 1,
} CellType;

static NSString* const kCategorySegue      = @"CategoryPredictionsSegue";
static NSString* const kUserProfileSegue   = @"UserProfileSegue";
static NSString* const kAddPredictionSegue = @"AddPredictionSegue";
static NSString* const kMyProfileSegue     = @"MyProfileSegue";

static const int kBSAlertTag = 1001;

@interface PredictionDetailsViewController () <UIAlertViewDelegate, AddPredictionViewControllerDelegate, PredictionCellDelegate> {
    BOOL _loadingUsers;
    BOOL _updatingStatus;
}

@property (nonatomic, strong) AppDelegate * appDelegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *pickerViewHolder;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@property (nonatomic) NSArray *agreedUsers;
@property (nonatomic) NSArray *disagreedUsers;

@property (nonatomic) NSMutableArray *requests;

@end

@implementation PredictionDetailsViewController

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.requests = [NSMutableArray array];
    
    _loadingUsers = YES;
    [self updateUsers];
    
    CGRect frame = self.pickerViewHolder.frame;
    frame.origin.y = self.view.frame.size.height;
    self.pickerViewHolder.frame = frame;
    
    if(!self.addPredictionDelegate) {
        self.addPredictionDelegate = self;
    }
}

#pragma mark Actions

- (IBAction)backButtonPressed:(UIButton *)sender {
    [self.requests makeObjectsPerformSelector:@selector(cancel)];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)bsButtonTapped:(UIButton *)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Don't be lame. Tell the truth. It's more fun this way. Is this really the wrong outcome?", @"")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                              otherButtonTitles:NSLocalizedString(@"Yes", @""), nil];
    alertView.tag = kBSAlertTag;
    [alertView show];
}

- (IBAction)agreeButtonTapped:(UIButton *)sender {
    [self sendAgree:YES];
}

- (IBAction)disagreeButtonTapped:(UIButton *)sender {
    [self sendAgree:NO];
}

- (IBAction)yesButtonTapped:(UIButton *)sender {
    [self sendOutcome:YES];
}

- (IBAction)noButtonTapped:(UIButton *)sender {
    [self sendOutcome:NO];
}

- (IBAction)unfinishButtonTapped:(UIButton *)sender {
    self.datePicker.minimumDate = [NSDate dateWithTimeInterval:(10 * 60) sinceDate:[NSDate date]];
    self.datePicker.date = self.datePicker.minimumDate;
    [self showView:self.pickerViewHolder];
}

- (IBAction)hidePicker:(UIBarButtonItem *)sender {
    [self hideView:self.pickerViewHolder];
}

- (IBAction)unfinishPrediction:(UIBarButtonItem *)sender {
    _updatingStatus = YES;
    
    NSDate *expDate = self.datePicker.date;
    
    __weak PredictionDetailsViewController *weakSelf = self;
    
    PredictionUpdateWebRequest *request = [[PredictionUpdateWebRequest alloc] initWithPredictionId:self.prediction.ID extendTill:expDate];
    [request executeWithCompletionBlock:^{
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf.requests removeObject:request];
            
            if(request.isSucceeded) {
                
                PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:strongSelf.prediction.ID];
                [strongSelf.requests addObject:updateRequest];
                
                [updateRequest executeWithCompletionBlock:^{
                    [strongSelf.requests removeObject:updateRequest];
                    
                    strongSelf->_updatingStatus = NO;
                    
                    if(updateRequest.isSucceeded) {
                        [strongSelf.prediction updateWithObject:updateRequest.prediction];
                    }
                    else {
                        [strongSelf showErrorFromRequest:request];
                    }
                    
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[strongSelf indexPathForCellType:RowOutcome], [strongSelf indexPathForCellType:RowPrediction]]
                                                withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }
            else {
                strongSelf->_updatingStatus = NO;
                [strongSelf showErrorFromRequest:request];
                [strongSelf.tableView reloadRowsAtIndexPaths:@[[strongSelf indexPathForCellType:RowOutcome]] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
    }];
    [self.requests addObject:request];
    
    [self.tableView reloadRowsAtIndexPaths:@[[self indexPathForCellType:RowOutcome]] withRowAnimation:UITableViewRowAnimationNone];
    [self hideView:self.pickerViewHolder];
}

- (IBAction)categoryButtonTapped:(UIButton *)sender {
    [self performSegueWithIdentifier:kCategorySegue sender:nil];
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kAddPredictionSegue]) {
        ((AddPredictionViewController*)segue.destinationViewController).delegate = self.addPredictionDelegate;
    }
    else if([segue.identifier isEqualToString:kCategorySegue]) {
        CategoryPredictionsViewController *vc = (CategoryPredictionsViewController *)segue.destinationViewController;
        vc.category = self.prediction.category;
    }
    else if ([segue.identifier isEqualToString:kUserProfileSegue]) {
        ((AnotherUsersProfileViewController*)segue.destinationViewController).userId = self.prediction.userId;
    }
    else if([segue.identifier isEqualToString:kMyProfileSegue]) {
        ProfileViewController *vc = (ProfileViewController *)segue.destinationViewController;
        vc.leftButtonItemReturnsBack = YES;
    }
}

#pragma mark Private

- (void)updatePredictionUsers:(NSArray *)users agreed:(BOOL)agreed {
    if(agreed) {
        self.agreedUsers = [users arrayByAddingObject:self.prediction.userName];
    }
    else {
        self.disagreedUsers = users;
    }
    
    if(self.agreedUsers && self.disagreedUsers) {
        _loadingUsers = NO;
        
        //update prediction counters in case they're out of date
        self.prediction.agreeCount    = self.agreedUsers.count;
        self.prediction.disagreeCount = self.disagreedUsers.count;
        
        [self.tableView reloadData];
    }
}

- (BaseTableViewCell *)cellForCellType:(CellType)cellType {
    return (BaseTableViewCell *)[self.tableView cellForRowAtIndexPath:[self indexPathForCellType:cellType]];
}

- (NSIndexPath *)indexPathForCellType:(CellType)cellType {
    switch (cellType) {
        case RowOutcome:
        case RowMakePrediction:
            return [NSIndexPath indexPathForRow:RowStatus inSection:0];
            
        case RowEmpty:
        case RowLoading:
        case RowPredictor:
            return nil;
            
        default:
            return [NSIndexPath indexPathForRow:cellType inSection:0];
    }
}

- (CellType)cellTypeForIndexpath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0: return RowPrediction;
        case 1: return RowCategory;
        case 2:
            if(self.prediction.hasOutcome) {
                return RowStatus;
            }
            else if((self.prediction.chellange.isOwn && [self.prediction isExpired]) || [self.prediction passed72HoursSinceExpiration]) {
                return RowOutcome;
            }
            else if(!self.prediction.chellange) {
                return RowMakePrediction;
            }
            return RowEmpty;
        case 3:  return RowPredictorsCount;
        default: return _loadingUsers ? RowLoading : RowPredictor;
    }
}

- (Class)cellClassForIndexpath:(NSIndexPath *)indexPath {
    switch ([self cellTypeForIndexpath:indexPath]) {
        case RowPrediction:         return [PredictionDetailsCell class];
        case RowCategory:           return [PredictionCategoryCell class];
        case RowStatus:             return [PredictionStatusCell class];
        case RowMakePrediction:     return [MakePredictionCell class];
        case RowOutcome:            return [OutcomeCell class];
        case RowPredictorsCount:    return [PredictorsCountCell class];
        case RowPredictor:          return [PredictorCell class];
        case RowEmpty:              return [BaseTableViewCell class];
        case RowLoading:            return [LoadingCell class];
    }
}

#pragma mark Requests

- (void)showErrorFromRequest:(BaseWebRequest *)request {
    [[[UIAlertView alloc] initWithTitle:@""
                                message:request.localizedErrorDescription
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
}

- (void)updateUsers {
    if(self.prediction.agreeCount || self.prediction.disagreeCount) {
        
        __weak PredictionDetailsViewController *weakSelf = self;
        
        PredictionUsersWebRequest *requestAgreed = [[PredictionUsersWebRequest alloc] initWithPredictionId:self.prediction.ID forAgreedUsers:YES];
        [requestAgreed executeWithCompletionBlock:^{
            PredictionDetailsViewController *strongSelf = weakSelf;
            if(strongSelf) {
                [strongSelf updatePredictionUsers:requestAgreed.users agreed:YES];
                [strongSelf.requests removeObject:requestAgreed];
            }
        }];
        [self.requests addObject:requestAgreed];
        
        PredictionUsersWebRequest *requestDisagreed = [[PredictionUsersWebRequest alloc] initWithPredictionId:self.prediction.ID forAgreedUsers:NO];
        [requestDisagreed executeWithCompletionBlock:^{
            PredictionDetailsViewController *strongSelf = weakSelf;
            if(strongSelf) {
                [strongSelf updatePredictionUsers:requestDisagreed.users agreed:NO];
                [strongSelf.requests removeObject:requestDisagreed];
            }
        }];
        [self.requests addObject:requestDisagreed];
    }
}

- (void)sendAgree:(BOOL)agree {
    
    _updatingStatus = YES;
    
    BaseWebRequest *request;
    
    if(agree) {
        request = [[PredictionAgreeWebRequest alloc] initWithPredictionID:self.prediction.ID];
    }
    else {
        request = [[PredictionDisagreeWebRequest alloc] initWithPredictionID:self.prediction.ID];
    }
    
    [self.requests addObject:request];
    
    __weak PredictionDetailsViewController *weakSelf = self;
    
    [request executeWithCompletionBlock:^{
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf.requests removeObject:request];
            
            if(request.isSucceeded) {
                ChellangeByPredictionWebRequest *challengeRequest = [[ChellangeByPredictionWebRequest alloc] initWithPredictionID:strongSelf.prediction.ID];
                [strongSelf.requests addObject:challengeRequest];
                
                [challengeRequest executeWithCompletionBlock:^{
                    [strongSelf.requests removeObject:challengeRequest];
                    
                    strongSelf->_updatingStatus = NO;
                    
                    strongSelf.prediction.chellange = challengeRequest.chellange;
                    
                    if(challengeRequest.isSucceeded) {
                        [strongSelf updateUsers];
                    }
                    else {
                        [strongSelf showErrorFromRequest:request];
                    }
                    
                    //update related cells
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[strongSelf indexPathForCellType:RowMakePrediction], [strongSelf indexPathForCellType:RowPrediction]]
                                                withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }
            else {
                [strongSelf showErrorFromRequest:request];
                strongSelf->_updatingStatus = NO;
            }
            [strongSelf.tableView reloadRowsAtIndexPaths:@[[strongSelf indexPathForCellType:RowMakePrediction]] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];
    [self.tableView reloadRowsAtIndexPaths:@[[self indexPathForCellType:RowMakePrediction]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)sendOutcome:(BOOL)realise {
    
    _updatingStatus = YES;
    
    OutcomeWebRequest *outcomeRequest = [[OutcomeWebRequest alloc] initWithPredictionId:self.prediction.ID realise:realise];
    [self.requests addObject:outcomeRequest];
    
    __weak PredictionDetailsViewController *weakSelf = self;
    
    [outcomeRequest executeWithCompletionBlock:^{
        
        PredictionDetailsViewController *strongSelf = weakSelf;        
        if(strongSelf) {
            
            [strongSelf.requests removeObject:outcomeRequest];
            
            if(outcomeRequest.isSucceeded) {
                
                PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:strongSelf.prediction.ID];
                [strongSelf.requests addObject:updateRequest];
                
                [updateRequest executeWithCompletionBlock:^{
                    [strongSelf.requests removeObject:updateRequest];
                    
                    strongSelf->_updatingStatus = NO;
                    
                    if(updateRequest.isSucceeded) {
                        [strongSelf.prediction updateWithObject:updateRequest.prediction];
                    }
                    else {
                        [strongSelf showErrorFromRequest:outcomeRequest];
                    }
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[strongSelf indexPathForCellType:RowOutcome], [strongSelf indexPathForCellType:RowPrediction]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }
            else {
                strongSelf->_updatingStatus = NO;
                
                [strongSelf.tableView reloadRowsAtIndexPaths:@[[strongSelf indexPathForCellType:RowOutcome]] withRowAnimation:UITableViewRowAnimationNone];
                
                [strongSelf showErrorFromRequest:outcomeRequest];
            }
        }
    }];
    [self.tableView reloadRowsAtIndexPaths:@[[self indexPathForCellType:RowOutcome]] withRowAnimation:UITableViewRowAnimationNone];
}

- (void)sendBS {    
    
    _updatingStatus = YES;
    
    __weak PredictionDetailsViewController *weakSelf = self;

    BSWebRequest *bsRequest = [[BSWebRequest alloc] initWithPredictionId:self.prediction.ID];
    [bsRequest executeWithCompletionBlock:^{
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(strongSelf) {
            [strongSelf.requests removeObject:bsRequest];
            if(bsRequest.isSucceeded) {
                PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:strongSelf.prediction.ID];
                [strongSelf.requests addObject:updateRequest];
                
                [updateRequest executeWithCompletionBlock:^{
                    [strongSelf.requests removeObject:updateRequest];
                    
                    strongSelf->_updatingStatus = NO;
                    
                    if(updateRequest.isSucceeded) {
                        [strongSelf.prediction updateWithObject:updateRequest.prediction];
                    }
                    else {
                        [strongSelf showErrorFromRequest:updateRequest];
                    }
                    [strongSelf.tableView reloadRowsAtIndexPaths:@[[strongSelf indexPathForCellType:RowStatus]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }];
            }
            else {
                strongSelf->_updatingStatus = NO;
                [strongSelf showErrorFromRequest:bsRequest];
                [strongSelf.tableView reloadRowsAtIndexPaths:@[[strongSelf indexPathForCellType:RowStatus]] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }
    }];
    [self.requests addObject:bsRequest];
    [self.tableView reloadRowsAtIndexPaths:@[[self indexPathForCellType:RowStatus]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark AddPredictionViewControllerDelegate

- (void) predictionWasMadeInController:(AddPredictionViewController *)vc {
    [vc dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return TableRowsBaseCount + (_loadingUsers ? 1 : MAX(self.agreedUsers.count, self.disagreedUsers.count));
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Class cellClass = [self cellClassForIndexpath:indexPath];    
    BaseTableViewCell *baseCell = (BaseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:[cellClass reuseIdentifier]];
    
    if([baseCell isKindOfClass:[PredictionDetailsCell class]]) {
        PredictionDetailsCell *cell = (PredictionDetailsCell *)baseCell;
        [cell fillWithPrediction:self.prediction];
        cell.delegate = self;
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]init];
        [cell setUpUserProfileTapGestures:tapGesture];
    }
    else if([baseCell isKindOfClass:[PredictionCategoryCell class]]) {
        PredictionCategoryCell *cell = (PredictionCategoryCell *)baseCell;
        [cell setCategory:self.prediction.category];
        cell.buttonEnabled = !self.shouldNotOpenCategory;
    }
    else if([baseCell isKindOfClass:[PredictionStatusCell class]]) {
        PredictionStatusCell *cell = (PredictionStatusCell *)baseCell;
        [cell setupCellWithPrediction:self.prediction];
        cell.loading = _updatingStatus;
    }
    else if([baseCell isKindOfClass:[MakePredictionCell class]]) {
        MakePredictionCell *cell = (MakePredictionCell *)baseCell;
        cell.loading = _updatingStatus;
    }
    else if([baseCell isKindOfClass:[PredictorsCountCell class]]) {
        PredictorsCountCell *cell = (PredictorsCountCell *)baseCell;
        cell.agreedCount    = self.prediction.agreeCount;
        cell.disagreedCount = self.prediction.disagreeCount;
    }
    else if([baseCell isKindOfClass:[PredictorCell class]]) {
        PredictorCell *cell = (PredictorCell *)baseCell;
        int idx = indexPath.row - TableRowsBaseCount;
        cell.agreedUserName.text    = self.agreedUsers.count > idx ? self.agreedUsers[idx] : @"";
        cell.disagreedUserName.text = self.disagreedUsers.count > idx ? self.disagreedUsers[idx] : @"";
    }
    else if([baseCell isKindOfClass:[OutcomeCell class]]) {
        OutcomeCell *cell = (OutcomeCell *)baseCell;
        [cell setupCellWithPrediction:self.prediction];
        cell.loading = _updatingStatus;
    }
    
    return baseCell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch ([self cellTypeForIndexpath:indexPath]) {
        case RowStatus:
            return [PredictionStatusCell cellHeightForPrediction:self.prediction];
        case RowPrediction:
            return [PredictionDetailsCell cellHeightForPrediction:self.prediction];
        case RowOutcome:
            return [OutcomeCell cellHeightForPrediction:self.prediction];
        case RowEmpty:
            return 0.0;
        case RowLoading:
            return 44.0;
        default:
            return [[self cellClassForIndexpath:indexPath] cellHeight];
    }
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == kBSAlertTag && alertView.cancelButtonIndex != buttonIndex) {
        [self sendBS];
    }
}

#pragma mark - Date Picker

- (void)showView:(UIView *)view {
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseInOut;
    NSTimeInterval duration = 0.3;
    
    CGRect newFrame = view.frame;
    newFrame.origin.y = self.view.frame.size.height - newFrame.size.height;
    
    [UIView animateWithDuration: duration delay: 0.0 options: (animationCurve << 16) animations:^
     {
         view.frame = newFrame;
     } completion: NULL];
    
    [self moveUpOrDown: YES withAnimationDuration: duration animationCurve: animationCurve keyboardFrame: newFrame];
}


- (void)hideView:(UIView *)view {
    UIViewAnimationCurve animationCurve = UIViewAnimationCurveEaseInOut;
    NSTimeInterval duration = 0.3;
    
    CGRect newFrame = view.frame;
    newFrame.origin.y = self.view.frame.size.height;
    
    [UIView animateWithDuration: duration delay: 0.0 options: (animationCurve << 16) animations:^{
        view.frame = newFrame;
    } completion: NULL];
    
    [self moveUpOrDown: NO withAnimationDuration: duration animationCurve: animationCurve keyboardFrame: newFrame];
}

- (void) moveUpOrDown: (BOOL) up
withAnimationDuration: (NSTimeInterval)animationDuration
       animationCurve: (UIViewAnimationCurve)animationCurve
        keyboardFrame: (CGRect)keyboardFrame
{
    CGRect newContainerFrame = self.tableView.frame;
    
    if(up) {
        newContainerFrame.size.height = self.view.frame.size.height - [self.tableView.superview convertRect: keyboardFrame fromView: self.view.window].size.height;
    }
    else {
        newContainerFrame.size.height = self.view.frame.size.height;
    }
    
    [UIView animateWithDuration: animationDuration delay: 0.0 options: (animationCurve << 16) animations:^{
        self.tableView.frame = newContainerFrame;
    } completion:^(BOOL finished) {
        [self.tableView scrollToRowAtIndexPath:[self indexPathForCellType:RowOutcome] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }];
}

#pragma mark - Prediction Cell delegate

- (void) profileSelectedWithUserId:(NSInteger)userId inCell:(PreditionCell *)cell {
    if (self.appDelegate.user.userId == userId) {
        [self performSegueWithIdentifier:kMyProfileSegue sender:self];
    }
    else {
        [self performSegueWithIdentifier:kUserProfileSegue sender:[NSNumber numberWithInteger:userId]];
    }}

#pragma mark - AppDelegate

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

@end