//
//  AutocompleteTableViewViewController.h
//  KnodaIPhoneApp
//
//  Created by nick on 10/11/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "BaseTableViewController.h"

typedef NS_ENUM(NSInteger, AutoCompleteItemType) {
    AutoCompleteItemTypeUnknown,
    AutoCompleteItemTypeMention,
    AutoCompleteItemTypeHashtag,
};

@class AutoCompleteTableViewController;

@protocol AutoCompleteTableViewControllerDelegate <NSObject>

- (void)termSelected:(NSString *)term completionString:(NSString *)completionString withType:(AutoCompleteItemType)type inViewController:(AutoCompleteTableViewController *)viewController;

@end


@interface AutoCompleteTableViewController : BaseTableViewController

@property (weak, nonatomic) id<AutoCompleteTableViewControllerDelegate> delegate;

- (id)initWithDelegate:(id<AutoCompleteTableViewControllerDelegate>)delegate;

- (void)loadSuggestionsForTerm:(NSString *)term type:(AutoCompleteItemType)type completion:(void(^)(NSArray *results))completionHandler;

@end
