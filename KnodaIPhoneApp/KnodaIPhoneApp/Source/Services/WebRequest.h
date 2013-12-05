//
//  WebRequest.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebRequest : NSMutableURLRequest

- (id)initWithHTTPMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters requiresAuthToken:(BOOL)requiresAuthToken isMultiPartData:(BOOL)isMutliPartData;
@end
