//
//  EmptyDatasource.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/7/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmptyDatasource : NSObject <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) UITableViewCell *cell;
@end
