//
//  BaseWebRequest.m
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "BaseWebRequest.h"
#import "AppDelegate.h"


@interface BaseWebRequest ()

@property (atomic, assign) RequestState state;

@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSString* errorDescription;

@property (nonatomic, strong) id <NSObject> resultObject;
@property (nonatomic, strong) NSDictionary* parameters;

@property (nonatomic, readonly) AppDelegate* appDelegate;

@end


//#define PRODUCTION_ENVIRENMENT


#ifdef PRODUCTION_ENVIRENMENT

static NSString* const kBaseURL = @"example.com";

#else

//static NSString* const kBaseURL = @"89.22.50.128/api/";
static NSString* const kBaseURL = @"54.213.86.248/api/";

#endif


const NSInteger kRequestTimeoutError = -1001;
const NSInteger kInternetOfflineError = -1009;


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

#pragma mark Private methods


- (NSURL*) url
{
    NSMutableString* urlString = [NSMutableString stringWithFormat: @"%@%@%@", ([self requiresHTTPS]) ? @"https://" : @"http://", kBaseURL, [self methodName]];
    
    if ([self requiresAuthToken])
    {
        [urlString appendFormat: @"?auth_token=%@&", self.appDelegate.user.token];
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
    
    for (NSString* key in keys)
    {
        id value = [self.parameters objectForKey: key];
        
        if ([value isKindOfClass: [NSString class]])
        {
            [urlParameters appendFormat: @"%@=%@", key, value];
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
    
    return [urlParameters stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


+ (NSString*) serverErrorDescriptionByCode: (NSInteger) code
{
    NSString* description = @"";
    
    switch (code)
    {
        default:
            description = [NSString stringWithFormat: NSLocalizedString(@"Uncnown error code came from the server: %i", @""), code];
            break;
    }
    
    return description;
}


#pragma mark Public methods


- (void) executeWithCompletionBlock: (void (^)(void)) completion
{
    self.state = kRequestStateStarted;
    
    self.errorCode = 0;
    self.errorDescription = @"";
    
    self.resultObject = nil;
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL: [self url]];
    
    [request setHTTPMethod: [self httpMethod]];
    [request setTimeoutInterval: 20];
    
    NSLog(@"%@ Start request %@", NSStringFromClass([self class]), request.URL);
    
    if ([request.HTTPMethod isEqualToString: @"POST"])
    {
        NSString* body = [self formParametersString];
        [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
        
        NSLog(@"%@ %@\nRequest body:\n%@",  NSStringFromClass([self class]), request.URL, body);
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
        else if (response.statusCode < 200 && response.statusCode > 299)
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
        else
        {
            NSString* resultString = [[NSString alloc] initWithData: result encoding: NSUTF8StringEncoding];
            
             NSLog(@"%@ %@\nRequest result:\n%@",  NSStringFromClass([self class]), request.URL, resultString);
            
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
                        NSString* serverError = [parsedResult objectForKey: @"error"];
                        
                        // Handle our server errors
                        if (serverError != nil)
                        {
                            NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
                            
                            [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
                            [formatter setPositivePrefix: @"#"];
                            
                            NSInteger serverErrorCode = [[formatter numberFromString: serverError] integerValue];
                            
                            self.errorCode = serverErrorCode;
                            self.errorDescription = [[self class] serverErrorDescriptionByCode: serverErrorCode];
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
        if (completion != nil)
        {
            dispatch_async(dispatch_get_main_queue(), completion);
        }
    });
}


- (void) cancel
{
    self.state = kRequestStateCancelled;
}


@end
