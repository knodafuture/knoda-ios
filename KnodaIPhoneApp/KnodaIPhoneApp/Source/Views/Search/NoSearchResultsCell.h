//
//  NoSearchResultsCell.h
//  KnodaIPhoneApp
//
//  Created by nick on 1/2/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN CGFloat NoSearchResultsCellHeight;

@interface NoSearchResultsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

+ (NoSearchResultsCell *)noSearchResultsCellWithTitle:(NSString *)title forTableView:(UITableView *)tableView;

@end
