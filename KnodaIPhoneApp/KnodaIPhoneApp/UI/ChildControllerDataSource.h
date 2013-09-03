//
//  ChildControllerDataSource.h
//  KnodaIPhoneApp
//
//  Created by Viktor Levschanov on 02.09.13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChildControllerDataSource <NSObject>

- (NSArray *)cachedDataForController:(UIViewController *)vc;
- (void)cacheData:(NSArray *)data forController:(UIViewController *)vc;

@end
