//
//  WebRequest.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "MultipartRequest.h"
#import "LoginResponse.h"

static const char *MULTIPART_CHARS = "1234567890_-qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";


@interface MultipartRequest (Internal)
@property (readonly, nonatomic) NSDateFormatter *dateFormatter;
@property (readonly, nonatomic) NSString *boundaryString;

- (NSString *)boundaryString;
- (NSData *)formParametersMultipartDataWithParameters:(NSDictionary *)parameters;
- (NSString *)encodeString:(NSString *)string;

@end


@implementation MultipartRequest


- (id)initWithHTTPMethod:(NSString *)method url:(NSString *)url parameters:(NSDictionary *)parameters {
    
    NSURL *URL = [NSURL URLWithString:url];;
    
    self = [super initWithURL:URL];
    
    [self setHTTPMethod:method];
    [self setTimeoutInterval:20];
    [self setHTTPShouldHandleCookies:NO];
    
    if ([method isEqualToString: @"POST"] || [method isEqualToString:@"PATCH"] || [method isEqualToString:@"PUT"]) {
            [self setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundaryString] forHTTPHeaderField:@"Content-Type"];
            [self setHTTPBody:[self formParametersMultipartDataWithParameters:parameters]];
    }
    
    return self;
    
}
@end


@implementation MultipartRequest (Internal)

- (NSDateFormatter *)dateFormatter {
    static dispatch_once_t once;
    
    static NSDateFormatter *sharedFormatter;
    
    dispatch_once(&once, ^{
        sharedFormatter = [[NSDateFormatter alloc] init];
        [sharedFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [sharedFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    });
    
    return sharedFormatter;
}

- (NSString *)boundaryString {
    static NSString *sharedBoundary;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        NSInteger multCharsLen = strlen(MULTIPART_CHARS);
        NSMutableString *boundary = [[NSMutableString alloc] init];
        for (int i = 0; i < multCharsLen; i++) {
            [boundary appendFormat:@"%c", MULTIPART_CHARS[arc4random() % multCharsLen]];
        }
    });
    
    return sharedBoundary;
}

- (NSData *)formParametersMultipartDataWithParameters:(NSDictionary *)parameters {
    
    NSMutableData *body = [NSMutableData data];
    
    for(NSString *key in [parameters allKeys]) {
        if([key isEqualToString:@"Images"])
            continue;
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [self encodeString:parameters[key]]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    NSDictionary *imgDict = parameters[@"Images"];
    for(NSString *key in imgDict) {
        NSData *data = imgDict[key];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", self.boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.png\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];

    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", self.boundaryString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    return body;
}

- (NSString *)encodeString:(NSString *)string {
    if (![string isKindOfClass:NSString.class])
        return string;
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@"&=+;:", kCFStringEncodingUTF8));
}


@end