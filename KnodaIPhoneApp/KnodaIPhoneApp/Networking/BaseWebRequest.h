//
//  BaseWebRequest.h
//  OncArticles
//
//  Created by Elena Timofeeva on 2/6/13.
//  Copyright (c) 2013 M3, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"


extern const NSInteger kRequestTimeoutError;
extern const NSInteger kInternetOfflineError;


typedef enum _InternalErrorCodes
{
    kInternalErrorCodeUnknownServerError = -1,
    kInetrnalErrorCodeJSONParsingError = -2,
    kInternalErrorCodeUnexpectedJSONParsingResult = -3
} InternalErrorCodes;


typedef enum _ServerErrorCodes
{
    kServerErrorCodeInvalidUIC = 10001,
    kServerErrorCodeWrongHTTPMethod = 10002,
    kServerErrorCodeAuthenticationInvalidCredentials = 10003,
    kServerErrorCodeForgotPasswordUserNotFound = 10004,
    kServerErrorCodeMethodRequiresHTTPS = 10005,
    kServerErrorCodeNewUserEmailExists = 10006,
    kServerErrorCodeNewUserPasswordTooShort = 10007,
    kServerErrorCodeNewUserCreationFailed = 10008,
    kServerErrorCodeSearchArticleFailed = 10009,
    kServerErrorCodeGetArticleFailed = 10010,
    kServerErrorCodeTrackingFailed = 10011,
    kServerErrorCodeRegisterUserInvalidCountry = 10012,
    kServerErrorCodeGetAdsInvalidAdsPosition = 10013,
    kServerErrorCodeNewUserInvalidEmail = 10014,
    kServerErrorCodeNewUserInvalidFirstNameLength = 10015,
    kServerErrorCodeNewUserInvalidLastNameLength = 10016,
    kServerErrorCodeNewUserInvalidEmailLength = 10017,
    kServerErrorCodeNewUserInvalidPasswordLength = 10018,
    kServerErrorCodeNewUserInvalidZipLength = 10019,
    kServerErrorCodeNewUserInvalidNLValue = 10020,
    kServerErrorCodeNewUserInvalidProfessionID = 10021,
    kServerErrorCodeNewUserInvalidSpecialityID = 10022,
    kServerErrorCodeGetJournalsInvalidPageID = 10023,
    kServerErrorCodeShareInvalidToEmail = 10024,
    kServerErrorCodeShareArticleInvalidAID = 10025,
    kServerErrorCodeSearchArticlesSearchStringTooLong = 10026,
} ServerErrorCodes;


typedef enum _RequestState
{
    kRequestStateNotStarted,
    kRequestStateStarted,
    kRequestStateSucceed,
    kRequestStateFailed,
    kRequestStateCancelled
} RequestState;


@interface BaseWebRequest : NSObject {
@protected
    id <NSObject> resultObject;
    NSDictionary* parameters;
}

@property (nonatomic, readonly, assign) NSInteger errorCode;
@property (nonatomic, readonly, strong) NSString* errorDescription;
@property (atomic, readonly, assign) RequestState state;
@property (atomic, readonly) BOOL isSucceeded;
@property (atomic, readonly) BOOL isCancelled;

- (id) initWithParameters: (NSDictionary*) parameters;

- (void) executeWithCompletionBlock: (void (^)(void)) completion;
- (void) cancel;

@end
