//
//  PreditionCell.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/25/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PreditionCell : UITableViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL agreed;
@property (nonatomic, assign) BOOL disagreed;

- (void) addPanGestureRecognizer: (UIPanGestureRecognizer*) recognizer;

@end
