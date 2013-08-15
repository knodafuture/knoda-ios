//
//  LoadableCell.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 15.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseTableViewCell.h"

@interface LoadableCell : BaseTableViewCell

@property (nonatomic, weak) IBOutlet UIView *loadingView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, assign) BOOL loading;

@end
