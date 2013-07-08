//
//  BaseWebRequest.m
//  OncArticles
//
//  Created by Elena Timofeeva on 2/6/13.
//  Copyright (c) 2013 M3, Inc. All rights reserved.
//

#import "BaseWebRequest.h"


@interface BaseWebRequest ()

@property (atomic, assign) RequestState state;

@property (nonatomic, assign) NSInteger errorCode;
@property (nonatomic, strong) NSString* errorDescription;

@property (nonatomic, strong) id <NSObject> resultObject;
@property (nonatomic, strong) NSDictionary* parameters;

@end


#define PRODUCTION_ENVIRENMENT


#ifdef PRODUCTION_ENVIRENMENT

static NSString* const kBaseURL = @"m1.mdlinx.com/oncology/_query.cfc?method=";

#else

static NSString* const kBaseURL = @"dev.mdlinx.com/lillymobile/_query.cfc?method=";

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
            [urlParameters appendFormat: @"&%@=%@", key, value];
        }
        else if ([value isKindOfClass: [NSNumber class]])
        {
            if (strcmp([value objCType], @encode(BOOL)) == 0)
            {
                [urlParameters appendFormat: @"&%@=%@", key, ([value boolValue] == YES) ? @"true" : @"false"];
            }
            else if (strcmp([value objCType], @encode(int)) == 0)
            {
                [urlParameters appendFormat: @"&%@=%i", key, [value intValue]];
            }
            else if (strcmp([value objCType], @encode(float)) == 0 || strcmp([value objCType], @encode(double)) == 0 )
            {
                [urlParameters appendFormat: @"&%@=%f", key, [value floatValue]];
            }
        }
    }
    
    [urlParameters appendString: @"&returnformat=json"];
    
    return [urlParameters stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}


+ (NSString*) serverErrorDescriptionByCode: (NSInteger) code
{
    NSString* description = @"";
    
    switch (code)
    {
        case kServerErrorCodeInvalidUIC:
            description = NSLocalizedString(@"Invalid UIC", @"");
            break;
        case kServerErrorCodeWrongHTTPMethod:
            description = NSLocalizedString(@"Wrong HTTP method: used GET instead of POST", @"");
            break;
        case kServerErrorCodeAuthenticationInvalidCredentials:
            description = NSLocalizedString(@"Authentication failed: invalid username or password", @"");
            break;
        case kServerErrorCodeForgotPasswordUserNotFound:
            description = NSLocalizedString(@"Forgot password failed: user or password was not found", @"");
            break;
        case kServerErrorCodeMethodRequiresHTTPS:
            description = NSLocalizedString(@"Method requires HTTPS", @"");
            break;
        case kServerErrorCodeNewUserEmailExists:
            description = NSLocalizedString(@"New user creation failed: email already exists", @"");
            break;
        case kServerErrorCodeNewUserPasswordTooShort:
            description = NSLocalizedString(@"New user creation failed: password is too short (must be at least 4 chars)", @"");
            break;
        case kServerErrorCodeNewUserCreationFailed:
            description = NSLocalizedString(@"New user creation failed", @"");
            break;
        case kServerErrorCodeSearchArticleFailed:
            description = NSLocalizedString(@"Search articles failed", @"");
            break;
        case kServerErrorCodeGetArticleFailed:
            description = NSLocalizedString(@"Get article failed", @"");
            break;
        case kServerErrorCodeTrackingFailed:
            description = NSLocalizedString(@"Tracking failed", @"");
            break;
        case kServerErrorCodeRegisterUserInvalidCountry:
            description = NSLocalizedString(@"New user: invalid country code", @"");
            break;
        case kServerErrorCodeGetAdsInvalidAdsPosition:
            description = NSLocalizedString(@"Get ads: invalid position", @"");
            break;
        case kServerErrorCodeNewUserInvalidEmail:
            description = NSLocalizedString(@"New user: invalid email", @"");
            break;
        case kServerErrorCodeNewUserInvalidFirstNameLength:
            description = NSLocalizedString(@"New user: first name length should be 60 chars or less", @"");
            break;
        case kServerErrorCodeNewUserInvalidLastNameLength:
            description = NSLocalizedString(@"New user: last name length should be 60 chars or less", @"");
            break;
        case kServerErrorCodeNewUserInvalidEmailLength:
            description = NSLocalizedString(@"New user: email length should be 120 chars or less", @"");
            break;
        case kServerErrorCodeNewUserInvalidPasswordLength:
            description = NSLocalizedString(@"New user: password length should be 20 chars or less", @"");
            break;
        case kServerErrorCodeNewUserInvalidZipLength:
            description = NSLocalizedString(@"New user: zip length should be 20 chars or less", @"");
            break;
        case kServerErrorCodeNewUserInvalidNLValue:
            description = NSLocalizedString(@"New user: invalid 'nl' value (should be 0 or 1)", @"");
            break;
        case kServerErrorCodeNewUserInvalidProfessionID:
            description = NSLocalizedString(@"New user: invalid prof_id (must be an integer)", @"");
            break;
        case kServerErrorCodeNewUserInvalidSpecialityID:
            description = NSLocalizedString(@"New user: invalid specialty_id (must be an integer)", @"");
            break;
        case kServerErrorCodeGetJournalsInvalidPageID:
            description = NSLocalizedString(@"Get journals: invalid page_id", @"");
            break;
        case kServerErrorCodeShareInvalidToEmail:
            description = NSLocalizedString(@"Share: invalid to_email passed to shareApp/shareArticle", @"");
            break;
        case kServerErrorCodeShareArticleInvalidAID:
            description = NSLocalizedString(@"Get Article: invalid AID", @"");
            break;
        case kServerErrorCodeSearchArticlesSearchStringTooLong:
            description = NSLocalizedString(@"Search Articles: search string is too long", @"");
            break;
            
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
        else if (response.statusCode != 200)
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
            
            if (resultString != nil)
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
