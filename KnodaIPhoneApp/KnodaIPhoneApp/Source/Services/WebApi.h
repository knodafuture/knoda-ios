//
//  WebApi.h
//  KnodaIPhoneApp
//
//  Created by nick on 12/4/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoginResponse.h"
#import "LoginRequest.h"
#import "User+Utils.h"
#import "SignupRequest.h"
#import "Prediction+Utils.h"
#import "Challenge.h"
#import "Topic.h"
#import "WebObject+Utils.h"
#import "UpdatePredictionRequest.h"
#import "Badge.h"
#import "Comment.h"
#import "Alert.h"

typedef NS_ENUM(NSInteger, HttpStatus) {
	HttpStatusOk				= 200,
	HttpStatusCreated           = 201,
	HttpStatusBadRequest		= 400,
	HttpStatusUnauthorized      = 401,
	HttpStatusForbidden         = 403,
	HttpStatusNotFound          = 404,
	HttpStatusConflict          = 409,
	HttpStatusOutdated          = 412,
	HttpStatusServerError		= 500
};

extern NSString *const HttpForbiddenNotification;
extern NSInteger PageLimit;

@interface WebApi : NSObject

+ (WebApi *)sharedInstance;

// -- Login/Signup/Profile -- //

- (void)authenticateUser:(LoginRequest *)loginRequest completion:(void(^)(LoginResponse *response, NSError *error))completionHandler;
- (void)getCurrentUser:(void(^)(User *user, NSError *error))completionHandler;
- (void)requestPasswordResetForEmail:(NSString *)email completion:(void(^)(NSError *error))completionHandler;
- (void)sendSignUpWithRequest:(SignupRequest *)signupRequest completion:(void(^)(LoginResponse *response, NSError *error))completionHandler;
- (void)uploadProfileImage:(UIImage *)profileImage completion:(void(^)(NSError *error))completionHandler;
- (void)changeUsername:(NSString *)newUsername completion:(void(^)(NSError *error))completionHandler;
- (void)changeEmail:(NSString *)newEmail completion:(void(^)(NSError *error))completionHandler;
- (void)changePassword:(NSString *)currentPassword newPassword:(NSString *)newPassword completion:(void(^)(NSError *error))completionHandler;
- (void)signoutCompletion:(void(^)(NSError *error))completionHandler;
- (void)sendToken:(NSString *)token completion:(void(^)(NSString *tokenId, NSError *error))completionHandler;
- (void)deleteToken:(NSString *)tokenId completion:(void(^)(NSError *error))completionHandler;
- (void)getUser:(NSInteger)userId completion:(void(^)(User *user, NSError *error))completionHandler;

// -- Predictions -- //

- (void)getPredictionsAfter:(NSInteger)lastId completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;

- (void)getPredictionsAfter:(NSInteger)lastId tag:(NSString *)tag completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;
- (void)addPrediction:(Prediction *)prediction completion:(void(^)(Prediction *prediction, NSError *error))completionHandler;

- (void)getPrediction:(NSInteger)predictionId completion:(void(^)(Prediction *prediction, NSError *error))completionHandler;
- (void)getPredictionsForUser:(NSInteger)userId after:(NSInteger)lastId completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;
- (void)agreeWithPrediction:(NSInteger)predictionId completion:(void(^)(Challenge *challenge, NSError *error))completionHandler;
- (void)disagreeWithPrediction:(NSInteger)predictionId completion:(void(^)(Challenge *challenge, NSError *error))completionHandler;

- (void)getAgreedUsers:(NSInteger)predictionId completion:(void(^)(NSArray *users, NSError *error))completionHandler;
- (void)getDisagreedUsers:(NSInteger)predictionId completion:(void(^)(NSArray *users, NSError *error))completionHandler;

- (void)setPredictionOutcome:(NSInteger)predictionId correct:(BOOL)correct completion:(void(^)(NSError *error))completionHandler;

- (void)getHistoryAfter:(NSInteger)lastId completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;
- (void)getChallengeForPrediction:(NSInteger)predictionId completion:(void(^)(Challenge *challenge, NSError *error))completionHandler;
- (void)getCategoriesCompletion:(void(^)(NSArray *categories, NSError *error))completionHandler;
- (void)updatePrediction:(UpdatePredictionRequest *)updateRequest completion:(void(^)(Prediction *prediction, NSError *error))completionHandler;
- (void)sendBS:(NSInteger)predictionId completion:(void(^)(NSError *error))completionHandler;

- (void)getCommentsForPrediction:(NSInteger)predictionId last:(NSInteger)lastId completion:(void(^)(NSArray *comments, NSError *error))completionHandler;
- (void)createComment:(Comment *)comment completion:(void(^)(NSError *error))completionHandler;

- (void)getImage:(NSString *)imageUrl completion:(void(^)(UIImage *image, NSError *error))completionHandler;

// -- Badges -- //

- (void)checkNewBadges;
- (void)getNewBadgesCompletion:(void(^)(NSArray *badges, NSError *error))completionHandler;
- (void)getAllBadgesCompletion:(void(^)(NSArray *badges, NSError *error))completionHandler;


// -- Alerts -- //
- (void)getAlertsAfter:(NSInteger)lastId completion:(void(^)(NSArray *alerts, NSError *error))completionHandler;
- (void)getUnseenAlertsCompletion:(void(^)(NSArray *alerts, NSError *error))completionHandler;
- (void)setSeenAlerts:(NSArray *)seenAlertIds completion:(void(^)(NSError *error))completionHandler;
@end
