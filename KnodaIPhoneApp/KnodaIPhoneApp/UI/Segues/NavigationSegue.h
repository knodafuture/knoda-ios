//
//  NavegationSegue.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/24/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)();

@interface NavigationSegue : UIStoryboardSegue

@property (nonatomic, weak) UIView* detailsView;
@property (nonatomic, copy) CompletionBlock completion;

@end
