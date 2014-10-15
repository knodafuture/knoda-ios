//
//  AutocompleteTableViewViewController.m
//  KnodaIPhoneApp
//
//  Created by nick on 10/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "AutoCompleteTableViewController.h"
#import "AutocompleteMentionTableViewCell.h"
#import "AutocompleteHashtagTableViewCell.h"
#import "WebApi.h"
#import "UserManager.h"
#import "NoContentCell.h"
#import <QuartzCore/QuartzCore.h>

@interface AutoCompleteTableViewController ()
@property (assign, nonatomic) AutoCompleteItemType currentType;
@property (strong, nonatomic) NSString *currentTerm;
@property (strong, nonatomic) void(^completion)(NSArray *);
@end

@implementation AutoCompleteTableViewController

- (id)initWithDelegate:(id<AutoCompleteTableViewControllerDelegate>)delegate {
    self = [super initWithStyle:UITableViewStylePlain];
    
    self.delegate = delegate;
    self.tableView.delegate = self;
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor colorFromHex:@"efefef" withAlpha:1];
    self.tableView.separatorColor = [UIColor colorFromHex:@"efefef" withAlpha:1];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
}

- (void)objectsAfterObject:(id)object completion:(void (^)(NSArray *, NSError *))completionHandler {
    
    if (self.currentType == AutoCompleteItemTypeMention) {
        if (self.currentTerm.length == 0) {
            [[WebApi sharedInstance] getFollowers:[UserManager sharedInstance].user.userId completion:completionHandler];
        } else {
            [[WebApi sharedInstance] autoCompleteUsers:self.currentTerm completion:completionHandler];
        }
    } else {
        [[WebApi sharedInstance] searchForHashtags:self.currentTerm completion:completionHandler];
    }
}

- (void)noObjectsRetrievedInPagingDatasource:(PagingDatasource *)pagingDatasource {
    NoContentCell *cell = [NoContentCell noContentWithMessage:@"No suggestions at this time." forTableView:self.tableView];
    
    [self showNoContent:cell];
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    if (self.currentType == AutoCompleteItemTypeMention) {
        
        AutocompleteMentionTableViewCell *cell = [AutocompleteMentionTableViewCell cellForTableView:tableView];
        
        User *user = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = user.name;
        
        UIImage *image = [_imageLoader lazyLoadImage:user.avatar.small onIndexPath:indexPath];
        if (image)
            cell.avatarImageView.image = image;
        else
            cell.avatarImageView.image = [UIImage imageNamed:@"NotificationAvatar"];
        return cell;
        
        
    } else if (self.currentType == AutoCompleteItemTypeHashtag) {
        
        AutocompleteHashtagTableViewCell *cell = [AutocompleteHashtagTableViewCell cellForTableView:tableView];
        
        NSString *result = [self.pagingDatasource.objects objectAtIndex:indexPath.row];
        
        cell.nameLabel.text = [NSString stringWithFormat:@"#%@",result];
        
        return cell;
        
    } else {
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    }
}

- (void)imageLoader:(ImageLoader *)loader finishedLoadingImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath {
    AutocompleteMentionTableViewCell *cell = (AutocompleteMentionTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if (![cell isKindOfClass:AutocompleteMentionTableViewCell.class])
        return;
    cell.avatarImageView.image = image;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.pagingDatasource.objects.count)
        return;
    
    id cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    [self.delegate termSelected:self.currentTerm completionString:[cell nameLabel].text withType:self.currentType inViewController:self];
}


- (void)loadSuggestionsForTerm:(NSString *)term type:(AutoCompleteItemType)type completion:(void (^)(NSArray *))completionHandler {
    
    self.currentTerm = term;
    self.currentType = type;
    self.completion = completionHandler;
    
    [self.pagingDatasource loadPage:0 completion:^{
        [self.tableView reloadData];
        self.completion(self.pagingDatasource.objects);
    }];
    
}

@end
