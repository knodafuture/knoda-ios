//
//  SearchBar.h
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SearchBar;
@protocol SearchBarDelegate <NSObject>

- (void)searchBar:(SearchBar *)searchBar didSearchForText:(NSString *)searchText;
- (void)searchBarDidClearText:(SearchBar *)searchBar;
@end

@interface SearchBar : UIView

@property (readonly, nonatomic) UITextField *textField;

@property (weak, nonatomic) id<SearchBarDelegate> delegate;

@end
