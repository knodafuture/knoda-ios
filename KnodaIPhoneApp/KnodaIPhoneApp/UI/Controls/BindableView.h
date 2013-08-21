//
//  BindableView.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 20.08.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BindableView.h"
#import "ImageBindable.h"

@interface BindableView : UIView <ImageBindable>

@property (nonatomic, assign) BOOL loading;

- (void)bindToURL:(NSString *)imgUrl creationDate:(NSDate *)date;

@end
