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

@property (nonatomic, strong) IBOutlet UILabel* usernameLabel;
@property (nonatomic, strong) IBOutlet UILabel* bodyLabel;
@property (nonatomic, strong) IBOutlet UILabel* metadataLabel;
@property (nonatomic, strong) IBOutlet UIImageView* imageView;

- (void) addPanGestureRecognizer: (UIPanGestureRecognizer*) recognizer;

@end
