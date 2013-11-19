//
//  BaseWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"
#import "AppDelegate.h"
#import "SignOutWebRequest.h"

@interface BaseWebRequest ()

@property (atomic, assign) RequestState state;

@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSString* errorDescription;

@property (nonatomic, strong) id <NSObject> resultObject;
@property (nonatomic, strong) NSDictionary* parameters;

@property (nonatomic, readonly) AppDelegate* appDelegate;

@property (nonatomic) ServerError *serverError;

@end


//#define PRODUCTION_ENVIRENMENT


#ifdef PRODUCTION_ENVIRENMENT

NSString* const kBaseURL = @"api.knoda.com";

#else

//Uncomment the following line for local environment
//NSString* const kBaseURL = @"127.0.0.1:3000";

//Uncomment the following line for the development environment
NSString* const kBaseURL = @"api-dev.knoda.com";

//Uncomment the following line for the test environment
//NSString* const kBaseURL = @"api-test.knoda.com";  // Old server=54.213.86.248


//NSString* const kBaseURL = @"knoda-dev.herokuapp.com";
//NSString *const kBaseURL = @"localhost:1234";
#endif


const NSInteger kRequestTimeoutError = -1001;
const NSInteger kInternetOfflineError = -1009;

NSString* const kImages = @"Images";
static const char *MULTIPART_CHARS = "1234567890_-qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM";

@implementation BaseWebRequest

@synthesize parameters = parameters;
@synthesize resultObject = resultObject;

#pragma mark - Properties

- (BOOL)isSucceeded
{
    return self.state == kRequestStateSucceed;
}


- (BOOL)isCancelled
{
    return self.state == kRequestStateCancelled;
}


- (AppDelegate*) appDelegate
{
    return [UIApplication sharedApplication].delegate;
}


#pragma mark - Init

- (id) initWithParameters: (NSDictionary*) theParameters
{
    self = [super init];
    
    if (self != nil)
    {
        self.parameters = theParameters;
    }
    
    return self;
}


#pragma mark Protected methods (to be overridden in subclasses)


- (NSString*) methodName
{
    return @"";
}


- (NSString*) httpMethod
{
    return @"GET";
}


- (BOOL) requiresHTTPS
{
    return NO;
}


- (BOOL) requiresAuthToken
{
    return NO;
}


- (void) fillResultObject: (id) parsedResult
{
}


- (BOOL) isMultipartData
{
    return NO;
}


#pragma mark Private methods


- (void) checkStateAfterFinished
{
    if (self.errorCode == 0)
    {
        self.state = kRequestStateSucceed;
    } else
    {
        self.state = kRequestStateFailed;
    }
}

- (NSString *)userFriendlyErrorDescription {
    return NSLocalizedString(@"Unknown error. Please try again later.", @"");
}

- (NSString *)localizedErrorDescription {
    return self.serverError.shouldNotifyUser ? self.serverError.localizedDescription : [self userFriendlyErrorDescription];
}

- (NSURL*) url
{
    NSMutableString* urlString = [NSMutableString stringWithFormat: @"%@%@/api/%@", ([self requiresHTTPS]) ? @"https://" : @"http://", kBaseURL, [self methodName]];
    
    if ([self requiresAuthToken])
    {
        [urlString appendFormat: @"?auth_token=%@", self.appDelegate.user.token];
    }
    
    if ([[self httpMethod] isEqualToString: @"GET"])
    {
        [urlString appendString: [self formParametersString]];
    }
    
    NSURL* url = [NSURL URLWithString: urlString];
    
    return url;
}


- (NSString*) formParametersString
{
    NSMutableString* urlParameters = [NSMutableString stringWithString: @""];
    
    NSArray* keys = [self.parameters allKeys];
    
    if (keys.count != 0 && [[self httpMethod] isEqualToString: @"GET"])
    {
        [urlParameters appendString: @"&"];
    }
    
    for (NSString* key in keys)
    {
        id value = [self.parameters objectForKey: key];
        
        if ([value isKindOfClass: [NSString class]])
        {
            NSLog(@"value before = %@", value);
            NSLog(@"value after = %@", [self encodeString:value]);
            [urlParameters appendFormat: @"%@=%@", key, [self encodeString:value]];
        }
        else if ([value isKindOfClass: [NSDate class]])
        {
            NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat: @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
            [dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation: @"GMT"]];
            NSString* dateString = [dateFormatter stringFromDate: value];
            
            if (dateString != nil)
            {
                [urlParameters appendFormat: @"%@=%@", key, dateString];
            }
        }
        else if ([value isKindOfClass: [NSNumber class]])
        {
            if (strcmp([value objCType], @encode(BOOL)) == 0)
            {
                [urlParameters appendFormat: @"%@=%@", key, ([value boolValue] == YES) ? @"true" : @"false"];
            }
            else if (strcmp([value objCType], @encode(int)) == 0)
            {
                [urlParameters appendFormat: @"%@=%i", key, [value intValue]];
            }
            else if (strcmp([value objCType], @encode(float)) == 0 || strcmp([value objCType], @encode(double)) == 0 )
            {
                [urlParameters appendFormat: @"%@=%f", key, [value floatValue]];
            }
        }
        
        if ([keys lastObject] != key)
        {
            [urlParameters appendString: @"&"];
        }
    }
    
    NSLog(@"URL parameters: %@", urlParameters);
    
    return urlParameters;
}

+ (NSString *)generateBoundary {
    NSMutableString *boundary = [NSMutableString string];

    static NSUInteger multCharsLen = 0;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        multCharsLen = strlen(MULTIPART_CHARS);
    });
    
    for (int i = 0; i < multCharsLen; i++) {
        [boundary appendFormat:@"%c", MULTIPART_CHARS[arc4random() % multCharsLen]];
    }
    return boundary;
}

- (NSData *)formParametersMultipartDataWithBoundary:(NSString *)boundary {
    
    NSMutableData *body = [NSMutableData data];
    
    for(NSString *key in [self.parameters allKeys]) {
        if([key isEqualToString:kImages]) {
            continue;
        }
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", [self encodeString:boundary]] dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"first part of post: %@", [NSString stringWithFormat:@"--%@\r\n", [self encodeString:boundary]]);
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [self encodeString:key]] dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"second part of post: %@", [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", [self encodeString:key]]);
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", [self encodeString:self.parameters[key]]] dataUsingEncoding:NSUTF8StringEncoding]];
        NSLog(@"third part of post: %@", [NSString stringWithFormat:@"%@\r\n", [self encodeString:self.parameters[key]]]);
    }
    
    DLog(@"%@", [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding]);
    
    NSDictionary *imgDict = self.parameters[kImages];
    for(NSString *key in imgDict) {
        NSData *data = imgDict[key];
        
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.png\"\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: image/png\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}

#pragma mark Public methods

- (NSString *) baseUrlString {
    return kBaseURL;
}


- (void) executeWithCompletionBlock: (RequestCompletionBlock) completion
{
    RequestCompletionBlock completionBlock = completion ? [completion copy] : nil;
    
    self.state = kRequestStateStarted;
    
    self.errorCode = 0;
    self.errorDescription = @"";
    
    self.resultObject = nil;
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: [self url]];
    
    [request setHTTPMethod: [self httpMethod]];
    [request setTimeoutInterval: 20];
    [request setHTTPShouldHandleCookies: NO];
    
    if ([request.HTTPMethod isEqualToString: @"POST"] || [request.HTTPMethod isEqualToString:@"PATCH"] || [request.HTTPMethod isEqualToString:@"PUT"])
    {
        if([self isMultipartData]) {
            NSString *boundary = [[self class] generateBoundary];
            [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:[self formParametersMultipartDataWithBoundary:boundary]];
        }
        else {
            NSString* body = [self formParametersString];
            [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
            NSLog(@"%@ %@\nRequest body:\n%@",  NSStringFromClass([self class]), request.URL, body);
        }
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        NSHTTPURLResponse* response = nil;
        NSError* error = nil;
        
        if (self.state == kRequestStateCancelled)
        {
            return;
        }
        
        NSData* result = [NSURLConnection sendSynchronousRequest: request returningResponse: &response error: &error];
        NSString* resultString = [[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding];
        
        //NSLog(@"Status code: %d", response.statusCode);
        //NSLog(@"%@ %@\nRequest result:\n%@",  NSStringFromClass([self class]), request.URL, resultString);
        
        if (self.state == kRequestStateCancelled)
        {
            return;
        }
        
        // Handle system errors (including timeout - kRequestTimeoutError)
        if (error != nil)
        {
            self.errorCode = error.code;
            self.errorDescription = error.localizedDescription;
        }
        // Handle HTTP errors
        else if (response.statusCode < 200 || response.statusCode > 299)
        {
            self.errorCode = response.statusCode;
            self.errorDescription = [NSHTTPURLResponse localizedStringForStatusCode: response.statusCode];
        }
        // Handle result absence
        else if (result == nil)
        {
            self.errorCode = kInternalErrorCodeUnknownServerError;
            self.errorDescription = NSLocalizedString(@"Unknown server error", @"");
        }
        
        if(self.errorCode == -1012 && [self requiresAuthToken] && self.class != SignOutWebRequest.class) { //perform logout if authorization is failed
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.appDelegate logout];
            });
            return;
        }
        
        if (resultString.length != 0)
        {
            id parsedResult = [resultString JSONValue];
            
            // Handle parser error
            if (parsedResult == nil)
            {
                self.errorCode = kInetrnalErrorCodeJSONParsingError;
                self.errorDescription = NSLocalizedString(@"Error JSON parsing", @"");
            }
            else
            {
                if ([parsedResult isKindOfClass: [NSDictionary class]])
                {
                    id errors = [parsedResult objectForKey: @"errors"];
                    if([errors isKindOfClass:[NSDictionary class]] && [errors count]) {
                        if(self.errorCode == 0) {
                            self.errorCode = kServerError;
                        }
                        self.serverError = [[ServerError alloc] initWithCode:self.errorCode andInfo:errors];
                    }
                    // SUCESS - no error here!
                    else
                    {
                        [self fillResultObject: parsedResult];
                        [self checkStateAfterFinished];
                    }
                }
                // SUCESS - no error here!
                else if ([parsedResult isKindOfClass: [NSArray class]])
                {
                    [self fillResultObject: parsedResult];
                    [self checkStateAfterFinished];
                }
                // Handle unexpected result from JSON parser - not NSArray of NSDictionary. Should never happen.
                else
                {
                    self.errorCode = kInternalErrorCodeUnexpectedJSONParsingResult;
                    self.errorDescription = NSLocalizedString(@"Unexpected result type returned by JSON parser", @"");
                }
            }
        }
        
        if (self.errorCode != 0)
        {
            NSLog(@"%@ %@\nFailed: %i - %@", NSStringFromClass([self class]), request.URL, self.errorCode, self.errorDescription);
        }
        
        if (self.state == kRequestStateCancelled)
        {
            return;
        } else if (self.state == kRequestStateStarted)
        {
            [self checkStateAfterFinished];
        }
        
        // Notify about completion
        if (completionBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), completionBlock);
        }
    });
}


- (void) cancel
{
    self.state = kRequestStateCancelled;
}

- (NSString *)encodeString:(NSString *)string {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, (CFStringRef)@"&=+", kCFStringEncodingUTF8));
}

@end
