//
//  BaseWebRequest.h
//  KnodaIPhoneApp
//
//  Created by Elena Timofeeva on 7/8/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
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
