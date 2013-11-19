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
#import "Challenge.h"
#import "ProfileViewController.h"
#import "LoadingCell.h"
#import "User.h"
#import "PredictorCell.h"
#import "PredictionUsersWebRequest.h"
#import "BSWebRequest.h"
#import "OutcomeWebRequest.h"
#import "ChellangeByPredictionWebRequest.h"
#import "PredictionAgreeWebRequest.h"
#import "PredictionDisagreeWebRequest.h"
#import "PredictionUpdateWebRequest.h"
#import "CategoryPredictionsViewController.h"
#import "AppDelegate.h"
#import "CreateCommentWebRequest.h"
#import "BigDaddyPredictionCell.h"
#import "PredictionDetailsSectionHeader.h"
#import "LoadingView.h"
#import "Comment.h"
#import "CommentWebRequest.h"
#import "CommentCell.h"

static NSString* const kCategorySegue      = @"CategoryPredictionsSegue";
static NSString* const kUserProfileSegue   = @"UserProfileSegue";
static NSString* const kMyProfileSegue     = @"MyProfileSegue";

static NSString *const defaultCommentText = @"Add a comment...";

static const int kBSAlertTag = 1001;
static const int kCommentMaxChars = 300;
static const float parallaxRatio = 0.5;

static const float otherUsersCellHeight = 44.0;

@interface PredictionDetailsViewController () <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate, PredictionCellDelegate, UITextViewDelegate> {
    BOOL _loadingUsers;
    BOOL _updatingStatus;
}

@property (nonatomic, strong) AppDelegate * appDelegate;

@property (nonatomic) NSArray *agreedUsers;
@property (nonatomic) NSArray *disagreedUsers;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) BigDaddyPredictionCell *predictionCell;
@property (strong, nonatomic) PredictionDetailsSectionHeader *sectionHeader;

@property (assign, nonatomic) CGPoint previousContentOffset;

@property (weak, nonatomic) IBOutlet UIView *addCommentContainer;
@property (weak, nonatomic) IBOutlet UITextView *commentTextView;
@property (weak, nonatomic) IBOutlet UILabel *textCounterLabel;
@property (weak, nonatomic) IBOutlet UIView *textViewContainer;

@property (weak, nonatomic) IBOutlet UIImageView *commentsImageView;
@property (weak, nonatomic) IBOutlet UIImageView *otherUsersImageView;


@property (strong, nonatomic) NSMutableArray *comments;
@property (assign, nonatomic) BOOL composingComment;
@property (assign, nonatomic) BOOL loadingComments;
@property (assign, nonatomic) BOOL showingComments;
@end

@implementation PredictionDetailsViewController

#pragma mark View lifecycle

- (void)dealloc {
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] removeObserver:self forKeyPath:@"smallImage"];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[(AppDelegate *)[[UIApplication sharedApplication] delegate] user] addObserver:self forKeyPath:@"smallImage" options:NSKeyValueObservingOptionNew context:nil];
    self.title = @"DETAILS";
    
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.navigationController.navigationBar.translucent = NO;
    [self setDefaultBarButtonItems:YES];
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"basicCell"];
    
    self.predictionCell = [BigDaddyPredictionCell predictionCellWithOwner:self];
    self.sectionHeader = [PredictionDetailsSectionHeader sectionHeaderWithOwner:self];
    
    [self.predictionCell configureWithPrediction:self.prediction];
    
    [self showComments:nil];
    [self.tableView reloadData];
    
}


- (void) viewDidAppear: (BOOL) animated
{
    [super viewDidAppear: animated];
    [Flurry logEvent: @"Prediction_Details_Screen" timed: YES];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willShowKeyBoard:) name: UIKeyboardWillShowNotification object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(willHideKeyBoard:) name: UIKeyboardWillHideNotification object: nil];
    
    if (self.addCommentContainer.frame.origin.y < 500)
        return;
    
    CGSize textSize = [defaultCommentText sizeWithFont:self.commentTextView.font forWidth:self.commentTextView.frame.size.width lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGRect frame = self.tableView.frame;
    frame.size.height -= textSize.height * 2.0;
    self.tableView.frame = frame;
    
    frame = self.addCommentContainer.frame;
    
    frame.origin.y = self.tableView.frame.size.height;
    
    self.addCommentContainer.frame = frame;
}
- (void) viewDidDisappear: (BOOL) animated
{
    [super viewDidDisappear: animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [Flurry endTimedEvent: @"Prediction_Details_Screen" withParameters: nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isKindOfClass:NSNull.class])
        return;
    if([object isKindOfClass:[User class]] && [keyPath isEqualToString:@"smallImage"]) {
        self.prediction.smallAvatar = [(User *)object smallImage];
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)setDefaultBarButtonItems:(BOOL)animated {
    [self.navigationItem setLeftBarButtonItem:[UIBarButtonItem backButtonWithTarget:self action:@selector(backPressed:)] animated:animated];
    [self.navigationItem setRightBarButtonItem:[UIBarButtonItem addPredictionBarButtonItem] animated:animated];
}
- (void)composeComment {
    UIBarButtonItem *cancelBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Cancel" target:self action:@selector(cancelComment) color:[UIColor whiteColor]];
    
    UIBarButtonItem *submitBarButtonItem = [UIBarButtonItem styledBarButtonItemWithTitle:@"Submit" target:self action:@selector(submitComment) color:[UIColor whiteColor]];
    
    [self.navigationItem setLeftBarButtonItem:cancelBarButtonItem animated:YES];
    [self.navigationItem setRightBarButtonItem:submitBarButtonItem animated:YES];
}

- (IBAction)showComments:(id)sender {
    self.showingComments = YES;
    
    self.commentsImageView.image = [UIImage imageNamed:@"ActionCommentIconActive"];
    self.otherUsersImageView.image = [UIImage imageNamed:@"ActionOtherUsersIcon"];
    
    [self.tableView reloadData];
    
    [self updateComments];
}

- (IBAction)showOtherUsers:(id)sender {
    
    self.showingComments = NO;
    self.commentsImageView.image = [UIImage imageNamed:@"ActionCommentIcon"];
    self.otherUsersImageView.image = [UIImage imageNamed:@"ActionOtherUsersIconActive"];
    
    [self.tableView reloadData];
    
    [self updateUsers];
    
}
- (void)submitComment {
    [[LoadingView sharedInstance] show];
    
    Comment *comment = [[Comment alloc] init];
    comment.body = self.commentTextView.text;
    comment.createdDate = [NSDate date];
    comment.predictionId = self.prediction.ID;
    
    CreateCommentWebRequest *request = [[CreateCommentWebRequest alloc] initWithComment:comment];
    
    __weak PredictionDetailsViewController *weakSelf = self;
    
    [self executeRequest:request withBlock:^{
        
        [[LoadingView sharedInstance] hide];
        [self cancelComment];
        
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if (request.isSucceeded)
            self.prediction.commentCount++;
        
        else
            [self showErrorFromRequest:request];
        
        [self updateComments];
        
    }];
    
}
- (void)cancelComment {
    self.commentTextView.text = defaultCommentText;
    [self setDefaultBarButtonItems:YES];
    [self.commentTextView resignFirstResponder];
}

#pragma mark Actions
- (IBAction)share:(id)sender {
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[self.prediction.body] applicationActivities:nil];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)backPressed:(UIButton *)sender {
    if(self.delegate && [self getWebRequests].count) { //update prediction in case if some changes weren't handled
        [self.delegate updatePrediction:self.prediction];
    }
    [self cancelAllRequests];
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
    [Flurry logEvent: @"Agree_Button_Tapped"];
    [self sendAgree:YES];
}

- (IBAction)disagreeButtonTapped:(UIButton *)sender {
    [Flurry logEvent: @"Disagree_Button_Tapped"];
    [self sendAgree:NO];
}

- (IBAction)yesButtonTapped:(UIButton *)sender {
    [self sendOutcome:YES];
}

- (IBAction)noButtonTapped:(UIButton *)sender {
    [self sendOutcome:NO];
}

- (IBAction)categoryButtonTapped:(UIButton *)sender {
    if(self.shouldNotOpenCategory) {
        [self backPressed:nil];
    }
    else {
        [self performSegueWithIdentifier:kCategorySegue sender:nil];
    }
}

#pragma mark Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:kCategorySegue]) {
        CategoryPredictionsViewController *vc = (CategoryPredictionsViewController *)segue.destinationViewController;
        vc.category             = self.prediction.category;
        vc.shouldNotOpenProfile = self.shouldNotOpenProfile;
    }
    else if ([segue.identifier isEqualToString:kUserProfileSegue]) {
        ((AnotherUsersProfileViewController*)segue.destinationViewController).userId = self.prediction.userId;
    }
    else if([segue.identifier isEqualToString:kMyProfileSegue]) {
        ProfileViewController *vc    = (ProfileViewController *)segue.destinationViewController;
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
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0)
        return self.predictionCell.frame.size.height;
    else {
        if (self.showingComments && self.loadingComments)
            return loadingCellHeight;
        else if (self.showingComments && indexPath.row != self.comments.count)
            return [CommentCell heightForComment:[self.comments objectAtIndex:indexPath.row]];
        else if (!self.showingComments && !_loadingUsers)
            return otherUsersCellHeight;
        
    }
    
    return loadingCellHeight;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return predictionDetailsSectionHeaderHeight;
    else
        return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1)
        return self.sectionHeader;
    else
        return nil;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;
    else {
        if (self.showingComments && self.loadingComments)
            return 1;
        else if (self.showingComments && !self.loadingComments) {
            return self.comments.count + 1;
        }
        else if(!self.showingComments && _loadingUsers)
            return 1;
        else if (!self.showingComments && !_loadingUsers)
            return MAX(self.agreedUsers.count, self.disagreedUsers.count) + 1;
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [self.predictionCell update];
        return self.predictionCell;
    }
    
    if (self.showingComments) {
        
        if (indexPath.row == self.comments.count)
            return [LoadingCell loadingCellForTableView:tableView];
        
        Comment *comment = [self.comments objectAtIndex:indexPath.row];
        
        CommentCell *cell = [CommentCell commentCellForTableView:tableView];
        
        [cell fillWithComment:comment];
        
        return cell;
    } else {
        
        if (_loadingUsers)
            return [LoadingCell loadingCellForTableView:self.tableView];
        
        if (indexPath.row == 0)
            return [tableView dequeueReusableCellWithIdentifier:@"PredictorHeaderCell"];
        
        
        PredictorCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PredictorCell" forIndexPath:indexPath];

        int idx = indexPath.row - 1;
        cell.agreedUserName.text    = self.agreedUsers.count > idx ? self.agreedUsers[idx] : @"";
        cell.disagreedUserName.text = self.disagreedUsers.count > idx ? self.disagreedUsers[idx] : @"";

        return cell;
    }
}

- (void) tableView: (UITableView*) tableView willDisplayCell: (UITableViewCell*) cell forRowAtIndexPath: (NSIndexPath*) indexPath
{
    if (indexPath.row == self.comments.count) {
        if ((self.comments.count >= [CommentWebRequest limitByPage]))
            {
                __weak PredictionDetailsViewController *weakSelf = self;
                
                CommentWebRequest* request = [[CommentWebRequest alloc] initWithLastId: ((Comment*)[self.comments lastObject])._id forPredictionId:self.prediction.ID];
                
                [self executeRequest:request withBlock:^{
                    PredictionDetailsViewController *strongSelf = weakSelf;
                    if(!strongSelf) {
                        return;
                    }
                    
                    if (request.errorCode == 0 && request.comments.count != 0)
                    {
                        [strongSelf.comments addObjectsFromArray: request.comments];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }
                    else
                    {
                        [strongSelf.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row - 1 inSection: 1] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
                    }
                }];
            } else {
                [self.tableView scrollToRowAtIndexPath: [NSIndexPath indexPathForRow: indexPath.row - 1 inSection: 1] atScrollPosition: UITableViewScrollPositionBottom animated: YES];
            }
    }

}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    UITableViewCell *stickyCell = self.predictionCell;
    CGRect frame = stickyCell.frame;
    frame.origin.y = scrollView.contentOffset.y * parallaxRatio;
    
    stickyCell.frame = frame;
    [self.tableView sendSubviewToBack:stickyCell];
    
    
    CGFloat difference = scrollView.contentOffset.y - self.previousContentOffset.y;
    
    BOOL scrollingUp = difference < 0;
    
    CGFloat height = [self tableView:self.tableView heightForHeaderInSection:1];
    
    UIEdgeInsets tableViewInsets = self.tableView.contentInset;
    if (self.tableView.contentInset.top > -height && scrollView.contentOffset.y > 0 && !scrollingUp) {
        tableViewInsets.top  = tableViewInsets.top - difference;
    } else if (self.tableView.contentInset.top <= -height && !scrollingUp) {
        tableViewInsets.top = -height;
    } else if (self.tableView.contentInset.top >= -height && self.tableView.contentInset.top < 0 && scrollingUp) {
        tableViewInsets.top = tableViewInsets.top - difference;
    } else if (self.tableView.contentInset.top >= 0 && scrollingUp) {
        tableViewInsets.top = 0;
    }
    
    self.tableView.contentInset = tableViewInsets;
    self.previousContentOffset = scrollView.contentOffset;


}
#pragma mark Requests

- (void)showErrorFromRequest:(BaseWebRequest *)request {
    [[[UIAlertView alloc] initWithTitle:@""
                                message:request.localizedErrorDescription
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
}

- (void)updateComments {
    __weak PredictionDetailsViewController *weakSelf = self;
    
    self.loadingComments = YES;
    CommentWebRequest *request = [[CommentWebRequest alloc] initWithOffset:0 forPredictionId:self.prediction.ID];
    
    [self executeRequest:request withBlock:^{
        PredictionDetailsViewController *strongSelf = weakSelf;
        if (!strongSelf)
            return;
        
        self.comments = request.comments;
        self.loadingComments = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        NSLog(@"TABLE SIZE %f", self.tableView.contentSize.height);
    }];
}

- (void)updateUsers {
    if(self.prediction.agreeCount || self.prediction.disagreeCount) {
        
        __weak PredictionDetailsViewController *weakSelf = self;
        
        PredictionUsersWebRequest *requestAgreed = [[PredictionUsersWebRequest alloc] initWithPredictionId:self.prediction.ID forAgreedUsers:YES];
        [self executeRequest:requestAgreed withBlock:^{
            
            PredictionDetailsViewController *strongSelf = weakSelf;
            if(!strongSelf) return;
            [strongSelf updatePredictionUsers:requestAgreed.users agreed:YES];
        }];
        
        PredictionUsersWebRequest *requestDisagreed = [[PredictionUsersWebRequest alloc] initWithPredictionId:self.prediction.ID forAgreedUsers:NO];
        [self executeRequest:requestDisagreed withBlock:^{
            
            PredictionDetailsViewController *strongSelf = weakSelf;
            if(!strongSelf) return;
            [strongSelf updatePredictionUsers:requestDisagreed.users agreed:NO];
        }];
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
    
    __weak PredictionDetailsViewController *weakSelf = self;
    
    [self executeRequest:request withBlock:^{
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if(request.isSucceeded) {
            ChellangeByPredictionWebRequest *challengeRequest = [[ChellangeByPredictionWebRequest alloc] initWithPredictionID:strongSelf.prediction.ID];
            [strongSelf executeRequest:challengeRequest withBlock:^{
                
                strongSelf->_updatingStatus = NO;
                strongSelf.prediction.chellange = challengeRequest.chellange;
                
                if(challengeRequest.isSucceeded) {
                    [strongSelf updateUsers];
                }
                else {
                    [strongSelf showErrorFromRequest:request];
                }
                [self.tableView reloadData];
            }];
        }
        else {
            [strongSelf showErrorFromRequest:request];
            strongSelf->_updatingStatus = NO;
        }
        [self.tableView reloadData];
    }];
    
    [self.tableView reloadData];
}

- (void)sendOutcome:(BOOL)realise {
    
    _updatingStatus = YES;
    
    OutcomeWebRequest *outcomeRequest = [[OutcomeWebRequest alloc] initWithPredictionId:self.prediction.ID realise:realise];
    
    __weak PredictionDetailsViewController *weakSelf = self;
    
    [self executeRequest:outcomeRequest withBlock:^{        
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if(outcomeRequest.isSucceeded) {            
            PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:strongSelf.prediction.ID];
            [strongSelf executeRequest:updateRequest withBlock:^{
                
                strongSelf->_updatingStatus = NO;
                
                if(updateRequest.isSucceeded) {
                    [strongSelf.prediction updateWithObject:updateRequest.prediction];
                }
                else {
                    [strongSelf showErrorFromRequest:outcomeRequest];
                }
                [self.tableView reloadData];
            }];
        }
        else {
            strongSelf->_updatingStatus = NO;
            
            [self.tableView reloadData];
            [strongSelf showErrorFromRequest:outcomeRequest];
        }
    }];

    [self.tableView reloadData];
}

- (void)sendBS {
    
    _updatingStatus = YES;
    
    __weak PredictionDetailsViewController *weakSelf = self;

    BSWebRequest *bsRequest = [[BSWebRequest alloc] initWithPredictionId:self.prediction.ID];
    [self executeRequest:bsRequest withBlock:^{
        PredictionDetailsViewController *strongSelf = weakSelf;
        if(!strongSelf) return;
        
        if(bsRequest.isSucceeded) {
            PredictionUpdateWebRequest *updateRequest = [[PredictionUpdateWebRequest alloc] initWithPredictionId:strongSelf.prediction.ID];
            [strongSelf executeRequest:updateRequest withBlock:^{
                
                strongSelf->_updatingStatus = NO;
                
                if(updateRequest.isSucceeded) {
                    [strongSelf.prediction updateWithObject:updateRequest.prediction];
                }
                else {
                    [strongSelf showErrorFromRequest:updateRequest];
                }
                [self.tableView reloadData];
            }];
        }
        else {
            strongSelf->_updatingStatus = NO;
            [strongSelf showErrorFromRequest:bsRequest];
            [self.tableView reloadData];
        }
    }];

    [self.tableView reloadData];
}

#pragma mark UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == kBSAlertTag && alertView.cancelButtonIndex != buttonIndex)
    {
        [Flurry logEvent: @"BS_Button_Tapped"];
        [self sendBS];
    }
}
#pragma mark - Prediction Cell delegate

- (void)profileImageTapped:(id)sender {
    if (self.appDelegate.user.userId == self.prediction.userId)
        [self performSegueWithIdentifier:kMyProfileSegue sender:self];
    else
        [self performSegueWithIdentifier:kUserProfileSegue sender:[NSNumber numberWithInt:self.prediction.userId]];
}
#pragma mark - AppDelegate

- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if (!self.composingComment)
        [self composeComment];
    
    textView.text = @"";
}

- (void)willShowKeyBoard:(NSNotification *)object {
    
    NSTimeInterval animationDuration = [self keyboardAnimationDurationForNotification:object];
    
    CGRect frame = self.addCommentContainer.frame;
    frame.origin.y = 0;
    
    CGSize keyboardSize = [[[object userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect internalFrame = self.textViewContainer.frame;
    
    internalFrame.origin.y = (frame.size.height - keyboardSize.height) / 2.0 - (internalFrame.size.height / 2.0);
    
    [UIView animateWithDuration:animationDuration * 0.8 animations:^{
        self.addCommentContainer.frame = frame;
        self.textViewContainer.frame = internalFrame;
    }];
}

- (void)willHideKeyBoard:(NSNotification *)object {
    NSTimeInterval animationDuration = [self keyboardAnimationDurationForNotification:object];
    
    CGRect frame = self.addCommentContainer.frame;
    frame.origin.y = self.tableView.frame.size.height;
    
    CGRect internalFrame = self.textViewContainer.frame;
    
    internalFrame.origin.y = 0;
    
    [UIView animateWithDuration:animationDuration * 0.8 animations:^{
        self.addCommentContainer.frame = frame;
        self.textViewContainer.frame = internalFrame;
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    int len = textView.text.length - range.length + text.length;
    
    if ([text isEqualToString:@"\n"]) {
        [self submitComment];
        return NO;
    }
    
    if(len <= kCommentMaxChars) {
        self.textCounterLabel.text = [NSString stringWithFormat:@"%d", kCommentMaxChars - len];
        return YES;
    }

    return NO;
}
- (NSTimeInterval)keyboardAnimationDurationForNotification:(NSNotification*)notification
{
    NSDictionary* info = [notification userInfo];
    NSValue* value = [info objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval duration = 0;
    [value getValue:&duration];
    return duration;
}
@end