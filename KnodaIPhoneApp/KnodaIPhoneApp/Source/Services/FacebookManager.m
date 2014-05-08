//
//  FacebookManager.m
//  KnodaIPhoneApp
//
//  Created by nick on 4/28/14.
//  Copyright (c) 2014 Knoda. All rights reserved.
//

#import "FacebookManager.h"
#import <FacebookSDK/FacebookSDK.h>

static FacebookManager *sharedSingleton;

@interface FacebookManager ()
@property (strong, nonatomic) NSMutableSet *interestedBlocks;
@end

@implementation FacebookManager
+ (FacebookManager *)sharedInstance {
    static dispatch_once_t once;
    
    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
    });
    
    return sharedSingleton;
}

- (id)init {
    self = [super init];
    self.interestedBlocks = [[NSMutableSet alloc] init];
    return self;
}

- (void)handleAppLaunch {
    
}

- (void)openSession:(void(^)(NSDictionary *, NSError *))completionHandler {
    [self.interestedBlocks addObject:completionHandler];

    BOOL cachedToken = FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded;
    
    if (!cachedToken) {
        [FBSession openActiveSessionWithReadPermissions:@[@"basic_info", @"email", @"offline_access"] allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
        return;
    }
    
    [FBSession.activeSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [self sessionStateChanged:session state:status error:error];
    }];
}

- (void)reauthorizeWithPublishIfNecessary:(FBSession *)session {
    
    if ([session.permissions containsObject:@"publish_actions"]) {
        [self getUserProfile];
        return;
    }
        
    
    [session requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceEveryone completionHandler:^(FBSession *session, NSError *error) {
        if (error) {
            [self finish:nil error:error];
            return;
        }
        [self getUserProfile];
    }];
}

- (void)getUserProfile {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary *result, NSError *error) {
        [self finish:result error:error];
    }];

}

- (void)finish:(NSDictionary *)data error:(NSError *)error {
    
    for (void(^block)(NSDictionary *, NSError *) in self.interestedBlocks) {
        block(data, error);
    }
    
    [self.interestedBlocks removeAllObjects];
    
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
    if (!error && state == FBSessionStateOpen){
        [self reauthorizeWithPublishIfNecessary:session];
        return;
    }

    
    if (error){
        NSLog(@"Error");
        NSString *errorText;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error]){
            errorText = [FBErrorUtility userMessageForError:error];
        } else {
            
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                NSLog(@"User cancelled login");
                errorText = @"Facebook login cancelled";
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
                errorText = @"Your current session is no longer valid. Please log in again.";
                
            } else {
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                errorText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
            }
        }
        [FBSession.activeSession closeAndClearTokenInformation];
        [self finish:nil error:[NSError errorWithDomain:@"facebook" code:400 userInfo:@{NSLocalizedDescriptionKey: errorText}]];
    }
}

- (NSString *)accessTokenForCurrentSession {
    return FBSession.activeSession.accessTokenData.accessToken;
}

@end
