//
//  SocialFollowTableViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 8/23/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "SocialFollowTableViewController.h"
#import "UserManager.h"
#import "FacebookManager.h" 
#import "TwitterManager.h"
#import "UIActionSheet+Blocks.h"
#import "LoadingView.h"
#import "WebApi.h"
#import "SocialFollowTableViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
@interface SocialFollowTableViewController () <SocialFollowTableViewCellDelegate>
@property (strong, nonatomic) NSString *provider;
@property (strong, nonatomic) UITableViewCell *connectCell;
@property (assign, nonatomic) BOOL shouldShowHeader;
@property (assign, nonatomic) BOOL selectAll;
@property (weak, nonatomic) IBOutlet UIButton *selectAllButton;
@property (assign, nonatomic) NSInteger prefilteredCount;
@end

@implementation SocialFollowTableViewController

- (id)initForProvider:(NSString *)provider delegate:(id<SocialFollowTableViewControllerDelegate>)delegate {
    self = [super initWithStyle:UITableViewStylePlain];
    self.provider = provider;
    self.shouldShowHeader = YES;
    self.delegate = delegate;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![[UserManager sharedInstance] userHasAccountForProvider:self.provider])
        [self showConnectCell];
    else {
        [self hideConnectCell];

        }
    
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    [self.refreshControl removeFromSuperview];
    self.refreshControl = nil;

    
}

- (void)viewDidAppear:(BOOL)animated {
    if (![[UserManager sharedInstance] userHasAccountForProvider:self.provider])
        self.hasAppeared = YES;
    [super viewDidAppear:animated];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!self.connectCell && self.shouldShowHeader)
        return 36.0;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.connectCell || !self.shouldShowHeader)
        return nil;
    
    if ([self.provider isEqualToString:@"twitter"])
        return [[[UINib nibWithNibName:@"FollowTwitterHeaderView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    else
        return [[[UINib nibWithNibName:@"FollowFacebookHeaderView" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.connectCell)
        return 1;
    
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.connectCell)
        return self.connectCell.frame.size.height;
    
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.connectCell)
        return self.connectCell;
    
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    SocialFollowTableViewCell *cell = [SocialFollowTableViewCell cellForTableView:tableView delegate:self indexPath:indexPath];
    
    ContactMatch *match = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    
    cell.contactIdLabel.text = match.contactId;
    cell.usernameLabel.text = match.info.username;
    cell.avatarImageView.image = [_imageLoader lazyLoadImage:match.info.avatar.small onIndexPath:indexPath];
    cell.checked = match.selected;
    return cell;
}

- (void)showConnectCell {
    
    if ([self.provider isEqualToString:@"twitter"])
        self.connectCell = [[[UINib nibWithNibName:@"FollowTwitterConnectCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    else if ([self.provider isEqualToString:@"facebook"])
        self.connectCell = [[[UINib nibWithNibName:@"FollowFacebookConnectCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil] lastObject];
    
    [self.tableView reloadData];
    
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    if (![[UserManager sharedInstance] userHasAccountForProvider:self.provider]) {
        [self showConnectCell];
        return;
    } else
        [self hideConnectCell];
    
    self.shouldShowHeader = NO;
    
    UITableViewCell *cell = nil;
    
    if ([self.provider isEqualToString:@"twitter"]) {
            cell = [[[ UINib nibWithNibName:@"NoTwitterFriendsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    } else {
            cell = [[[UINib nibWithNibName:@"NoFacebookFriendsCell" bundle:[NSBundle mainBundle]] instantiateWithOwner:nil options:nil] lastObject];
    }
    
    [self showNoContent:cell];
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    SocialFollowTableViewCell *cell = (SocialFollowTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:SocialFollowTableViewCell.class])
        return;
    cell.avatarImageView.image = image;
}

- (void)hideConnectCell {
    
    self.connectCell = nil;
    
    [self beginRefreshing];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, self.view.frame.size.width, 60);
    button.backgroundColor = [UIColor clearColor];
    
    if ([self.provider isEqualToString:@"twitter"])
        [button setImage:[UIImage imageNamed:@"InviteTwitterShareBtn"] forState:UIControlStateNormal];
    else
        [button setImage:[UIImage imageNamed:@"InviteFacebookShareBtn"] forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchUpInside];
    
    self.tableView.tableFooterView = button;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell respondsToSelector:@selector(toggleChecked:)]) {
        [cell toggleChecked:nil];
    }
}


- (IBAction)connectFacebook:(id)sender {
    [self addFacebookAccount];
}

- (IBAction)connectTwitter:(id)sender {
    [self addTwitterAccount];
}

- (void)addTwitterAccount {
    [[LoadingView sharedInstance] show];
    [[TwitterManager sharedInstance] performReverseAuth:^(SocialAccount *request, NSError *error) {
        if (error) {
            [[LoadingView sharedInstance] hide];
            return;
        }
        
        [[UserManager sharedInstance] addSocialAccount:request completion:^(User *user, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (error)
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:error.localizedDescription
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                  otherButtonTitles:nil] show];
            else
                [self hideConnectCell];
        }];
    }];
}
- (void)addFacebookAccount {
    [[LoadingView sharedInstance] show];
    [[FacebookManager sharedInstance] openSession:^(NSDictionary *data, NSError *error) {
        if (error) {
            [[LoadingView sharedInstance] hide];
            [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            return;
        }
        SocialAccount *request = [[SocialAccount alloc] init];
        request.providerName = @"facebook";
        request.providerId = data[@"id"];
        request.accessToken = [[FacebookManager sharedInstance] accessTokenForCurrentSession];
        
        
        [[UserManager sharedInstance] addSocialAccount:request completion:^(User *user, NSError *error) {
            [[LoadingView sharedInstance] hide];
            if (error)
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:error.localizedDescription
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"OK", @"")
                                  otherButtonTitles:nil] show];
            else
                [self hideConnectCell];
        }];
    }];
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    
    void(^handler)(NSArray *, NSError*) = ^(NSArray *array, NSError *error) {
        
        NSArray *unfiltered = array;
        NSArray *filtered = [unfiltered filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(ContactMatch *evaluatedObject, NSDictionary *bindings) {
            return !evaluatedObject.info.following;
        }]];
        self.prefilteredCount = array.count;
        completionHandler(filtered, error);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            if (!self.selectAll)
                [self selectAll:nil];
        });
    };
    
    if ([self.provider isEqualToString:@"twitter"])
        [[WebApi sharedInstance] matchTwitterFriends:handler];
    else if ([self.provider isEqualToString:@"facebook"])
        [[WebApi sharedInstance] matchFacebookFriends:handler];
}

- (IBAction)selectAll:(id)sender {
    if (self.selectAll) {
        [self.selectAllButton setImage:[UIImage imageNamed:@"InviteCheckbox"] forState:UIControlStateNormal];
        self.selectAll = NO;
    } else {
        [self.selectAllButton setImage:[UIImage imageNamed:@"InviteCheckboxActive"] forState:UIControlStateNormal];
        self.selectAll = YES;
    }
    
    for (SocialFollowTableViewCell *cell in self.tableView.visibleCells) {
        if ([cell respondsToSelector:@selector(setChecked:)])
        [cell setChecked:self.selectAll];
    }
    
    for (ContactMatch *match in self.pagingDatasource.objects) {
        [match setSelected:self.selectAll];
    }
    
    [self notifiyParent];
}

- (void)matchSelectedInSocialFollowTableViewCell:(SocialFollowTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"matched selected");
    ContactMatch *match = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    match.selected = YES;
    [self notifiyParent];
}

- (void)matchUnselectedInSocialFollowTableViewCell:(SocialFollowTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"match unselected");
    
    ContactMatch *match = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
    match.selected = NO;
    
    if (self.selectAll) {
        [self.selectAllButton setImage:[UIImage imageNamed:@"InviteCheckbox"] forState:UIControlStateNormal];
        self.selectAll = NO;
    }
    
    [self notifiyParent];
}

- (void)notifiyParent {
    [self.delegate selectionUpdatedInViewController:self];
}

- (NSArray *)selectedMatches {
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.pagingDatasource.objects.count];
    
    for (ContactMatch *match in self.pagingDatasource.objects) {
        if (match.selected)
            [array addObject:match];
    }
    
    return [NSArray arrayWithArray:array];
}

- (NSArray *)invitations {
    return nil;
}

- (void)share {
    if ([self.provider isEqualToString:@"twitter"])
        [self twitterShare];
    else
        [self facebookShare];
}

- (void)facebookShare {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"Knoda", @"name",
                                   @"Predict Anything. Literally.", @"caption",
                                   @"Join me on Knoda!", @"description",
                                   @"http://knoda.com/start", @"link",
                                   nil];
    
    // Show the feed dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:FBSession.activeSession
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  if (error) {
                                                      // An error occurred, we need to handle the error
                                                      // See: https://developers.facebook.com/docs/ios/errors
                                                      NSLog(@"Error publishing story: %@", error.description);
                                                  } else {
                                                      if (result == FBWebDialogResultDialogNotCompleted) {
                                                          // User cancelled.
                                                          NSLog(@"User cancelled.");
                                                      } else {
                                                          // Handle the publish feed callback
                                                          NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                                                          
                                                          if (![urlParams valueForKey:@"post_id"]) {
                                                              // User cancelled.
                                                              NSLog(@"User cancelled.");
                                                              
                                                          } else {
                                                              // User clicked the Share button
                                                              NSString *result = [NSString stringWithFormat: @"Posted story, id: %@", [urlParams valueForKey:@"post_id"]];
                                                              NSLog(@"result %@", result);
                                                          }
                                                      }
                                                  }
                                              }];
}
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
- (void)twitterShare {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        SLComposeViewControllerCompletionHandler myBlock = ^(SLComposeViewControllerResult result){
            [controller dismissViewControllerAnimated:YES completion:Nil];
        };
        controller.completionHandler =myBlock;
        
        [controller setInitialText:@"I'm on Knoda. Start following me to see all of my predictions."];
        
        [controller addURL:[NSURL URLWithString:@"http://www.knoda.com/start"]];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }
    else{
        NSLog(@"UnAvailable");
    }
}

@end
