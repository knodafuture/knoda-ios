//
//  WebRequest.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/5/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebRequest.h"
#import "LoginResponse.h"

#ifdef TESTFLIGHT
NSString const *baseURL = @"http://api-test.knoda.com/api/";  // Old server=54.213.86.248
#else
NSString const *baseURL = @"http://api.knoda.com/api/";
#endif

static const char *MULTIPART_CHARS = "1234567890_-qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";


@interface WebRequest (Internal)
@property (readonly, nonatomic) NSDateFormatter *dateFormatter;
@property (readonly, nonatomic) NSString *boundaryString;

- (NSString *)savedAuthToken;
- (NSString *)boundaryString;
- (NSURL *)UrlForMethod:(NSString *)HTTPMethod path:(NSString *)path parameters:(NSDictionary *)parameters requiresAuthToken:(BOOL)requiresAuthToken;
- (NSString *)formParametersStringForMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters;
- (NSData *)formParametersMultipartDataWithParameters:(NSDictionary *)parameters;
- (NSString *)encodeString:(NSString *)string;

@end


@implementation WebRequest

- (id)initWithHTTPMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters requiresAuthToken:(BOOL)requiresAuthToken isMultiPartData:(BOOL)isMutliPartData {
    
    NSURL *url = [self UrlForMethod:method path:path parameters:parameters requiresAuthToken:requiresAuthToken];
    
    self = [super initWithURL:url];
    
    [self setHTTPMethod:method];
    [self setTimeoutInterval:20];
    [self setHTTPShouldHandleCookies:NO];
    
    if ([method isEqualToString: @"POST"] || [method isEqualToString:@"PATCH"] || [method isEqualToString:@"PUT"]) {
        if (isMutliPartData) {
            [self setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", self.boundaryString] forHTTPHeaderField:@"Content-Type"];
            [self setHTTPBody:[self formParametersMultipartDataWithParameters:parameters]];
        } else {
            NSString *bodySting = [self formParametersStringForMethod:method parameters:parameters];
            [self setHTTPBody:[bodySting dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
    }
    
    return self;
    
}
@end


@implementation WebRequest (Internal)

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

- (NSString *)savedAuthToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:LoginResponseKey];
    
    if ([token isKindOfClass:NSString.class])
        return token;
    
    return nil;
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

- (NSURL *)UrlForMethod:(NSString *)HTTPMethod path:(NSString *)path parameters:(NSDictionary *)parameters requiresAuthToken:(BOOL)requiresAuthToken {
    
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@", baseURL, path];
    
    if (requiresAuthToken)
        [urlString appendFormat:@"?auth_token=%@", [self savedAuthToken]];
    
    if ([HTTPMethod isEqualToString:@"GET"])
        [urlString appendString:[self formParametersStringForMethod:HTTPMethod parameters:parameters]];
    
    return [NSURL URLWithString:urlString];
    
}


- (NSString *)formParametersStringForMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters {
    NSMutableString *urlParameters = [[NSMutableString alloc] init];
    
    NSArray *keys = [parameters allKeys];
    
    if (keys.count != 0 && [HTTPMethod isEqualToString: @"GET"])
        [urlParameters appendString: @"&"];
    
    for (NSString *key in keys) {
        id value = [parameters objectForKey:key];
        
        if ([value isKindOfClass: [NSString class]])
            [urlParameters appendFormat: @"%@=%@", key, [self encodeString:value]];
        
        else if ([value isKindOfClass: [NSDate class]]) {
            NSString *dateString = [self.dateFormatter stringFromDate:value];
            if (dateString)
                [urlParameters appendFormat: @"%@=%@", key, dateString];
        }
        else if ([value isKindOfClass: [NSNumber class]]) {
            if (strcmp([value objCType], @encode(BOOL)) == 0)
                [urlParameters appendFormat: @"%@=%@", key, ([value boolValue] == YES) ? @"true" : @"false"];
            else if (strcmp([value objCType], @encode(int)) == 0)
                [urlParameters appendFormat: @"%@=%i", key, [value intValue]];
            else if (strcmp([value objCType], @encode(float)) == 0 || strcmp([value objCType], @encode(double)) == 0 )
                [urlParameters appendFormat: @"%@=%f", key, [value floatValue]];
        }
        
        if ([keys lastObject] != key)
            [urlParameters appendString: @"&"];
    }
    
    return urlParameters;
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