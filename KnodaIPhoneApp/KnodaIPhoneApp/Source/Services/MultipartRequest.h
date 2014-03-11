//
//  WebRequest.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MultipartRequest : NSMutableURLRequest

- (id)initWithHTTPMethod:(NSString *)method url:(NSString *)url parameters:(NSDictionary *)parameters;
@end
