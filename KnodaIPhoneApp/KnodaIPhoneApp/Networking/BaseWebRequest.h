//
//  BaseWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

extern NSString* const kBaseURL;

extern const NSInteger kRequestTimeoutError;
extern const NSInteger kInternetOfflineError;

extern NSString* const kImages;

typedef enum _InternalErrorCodes
{
    kInternalErrorCodeUnknownServerError = -1,
    kInetrnalErrorCodeJSONParsingError = -2,
    kInternalErrorCodeUnexpectedJSONParsingResult = -3
} InternalErrorCodes;


typedef enum _ServerErrorCodes
{
    kSomeServerError
} ServerErrorCodes;


typedef enum _RequestState
{
    kRequestStateNotStarted,
    kRequestStateStarted,
    kRequestStateSucceed,
    kRequestStateFailed,
    kRequestStateCancelled
} RequestState;

typedef void (^RequestCompletionBlock)(void);

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
@property (atomic, readonly) BOOL isMultipartData;

@property (nonatomic, readonly) NSString *userFriendlyErrorDescription;

- (id) initWithParameters: (NSDictionary*) parameters;

- (void) executeWithCompletionBlock: (RequestCompletionBlock) completion;
- (void) cancel;

@end
