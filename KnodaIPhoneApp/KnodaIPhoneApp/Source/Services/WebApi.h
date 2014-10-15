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
#import "Tag.h"
#import "Comment.h"
#import "ActivityItem.h"
#import "PasswordResetRequest.h"
#import "PasswordChangeRequest.h"
#import "DeviceToken.h"
#import "Group.h"
#import "Member.h"
#import "Invitation.h"
#import "InvitationCodeDetails.h"
#import "SocialAccount.h" 
#import "NotificationSettings.h"
#import "Settings.h"
#import "Contest.h"
#import "ContactMatch.h"

typedef NS_ENUM(NSInteger, HttpStatus) {
	HttpStatusOk				= 200,
	HttpStatusCreated           = 201,
	HttpStatusBadRequest		= 400,
	HttpStatusUnauthorized      = 401,
	HttpStatusForbidden         = 403,
	HttpStatusNotFound          = 404,
	HttpStatusConflict          = 409,
    HttpStatusGone              = 410,
	HttpStatusOutdated          = 412,
	HttpStatusServerError		= 500
};

extern NSString *const HttpForbiddenNotification;
extern NSString *const DeprecatedAPI;
extern NSString *const NoConnection;
extern NSInteger PageLimit;
UIKIT_EXTERN NSString *PredictionChangedNotificationName;
UIKIT_EXTERN NSString *PredictionChangedNotificationKey;
@interface WebApi : NSObject

+ (WebApi *)sharedInstance;



// -- Login/Signup/Profile -- //

- (void)authenticateUser:(LoginRequest *)loginRequest completion:(void(^)(LoginResponse *response, NSError *error))completionHandler;
- (void)getCurrentUser:(void(^)(User *user, NSError *error))completionHandler;
- (void)requestPasswordReset:(PasswordResetRequest *)resetRequest completion:(void(^)(NSError *error))completionHandler;
- (void)sendSignUpWithRequest:(SignupRequest *)signupRequest completion:(void(^)(LoginResponse *response, NSError *error))completionHandler;
- (void)uploadProfileImage:(UIImage *)profileImage completion:(void(^)(NSError *error))completionHandler;
- (void)updateUser:(User *)user completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)changePassword:(PasswordChangeRequest *)changeRequest completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)signoutCompletion:(void(^)(NSError *error))completionHandler;
- (void)sendToken:(DeviceToken *)deviceToken completion:(void(^)(NSString *tokenId, NSError *error))completionHandler;
- (void)deleteToken:(NSString *)tokenId completion:(void(^)(NSError *error))completionHandler;
- (void)getUser:(NSInteger)userId completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)autoCompleteUsers:(NSString *)query completion:(void(^)(NSArray *users, NSError *error))completionHandler;
- (void)getUserFromUsername:(NSString *)username completion:(void(^)(User *user, NSError *error))completionHandler;
- (void)socialSignIn:(SocialAccount *)request completion:(void(^)(LoginResponse *response, NSError *error))completionHandler;
- (void)addSocialAccount:(SocialAccount *)account completion:(void(^)(SocialAccount *account, NSError *error))completionHandler;
- (void)deleteSocialAccount:(SocialAccount *)account completion:(void(^)(NSError *error))completionHandler;
- (void)updateSocialAccount:(SocialAccount *)socialAccount completion:(void(^)(SocialAccount *account, NSError *error))completionHandler;
- (void)postPredictionToFacebook:(Prediction *)prediction brag:(BOOL)brag completion:(void(^)(NSError *error))completionHandler;
- (void)postPredictionToTwitter:(Prediction *)prediction brag:(BOOL)brag completion:(void(^)(NSError *error))completionHandler;
- (void)getRivals:(NSInteger)userId completion:(void(^)(NSArray *rivals, NSError *error))completionHandler;
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

- (void)getHistoryAfter:(NSInteger)lastId challenged:(BOOL)challenged completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;
- (void)getChallengeForPrediction:(NSInteger)predictionId completion:(void(^)(Challenge *challenge, NSError *error))completionHandler;
- (void)getCategoriesCompletion:(void(^)(NSArray *categories, NSError *error))completionHandler;
- (void)updatePrediction:(Prediction *)prediction completion:(void(^)(Prediction *prediction, NSError *error))completionHandler;
- (void)sendBS:(NSInteger)predictionId completion:(void(^)(NSError *error))completionHandler;

- (void)getCommentsForPrediction:(NSInteger)predictionId last:(NSInteger)lastId completion:(void(^)(NSArray *comments, NSError *error))completionHandler;
- (void)createComment:(Comment *)comment completion:(void(^)(Comment *createdComment, NSError *error))completionHandler;

- (void)getImage:(NSString *)imageUrl completion:(void(^)(UIImage *image, NSError *error))completionHandler;

// -- Activity -- //
- (void)getActivityAfter:(NSInteger)lastId filter:(NSString *)filter completion:(void(^)(NSArray *activityItems, NSError *error))completionHandler;
- (void)getUnseenActivity:(void(^)(NSArray *activityItems, NSError *error))completionHandler;


// -- Search -- //

- (void)searchForUsers:(NSString *)searchText completion:(void(^)(NSArray *users, NSError *error))completionHandler;
- (void)searchForPredictions:(NSString *)searchText completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;


// -- Groups -- //

- (void)getGroups:(void(^)(NSArray *groups, NSError *error))completionHandler;
- (void)getGroup:(NSInteger)groupId completion:(void(^)(Group *group, NSError *error))completionHandler;
- (void)getPredictionsForGroup:(NSInteger)groupId after:(NSInteger)lastId completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;
- (void)getMembersForGroup:(NSInteger)groupId completion:(void(^)(NSArray *members, NSError *error))completionHandler;
- (void)sendInvites:(NSArray *)invitations completion:(void(^)(NSArray *invitations, NSError *error))completionHandler;
- (void)createGroup:(Group *)group completion:(void(^)(Group *group, NSError *error))completionHandler;
- (void)updateGroup:(Group *)group completion:(void(^)(Group *group, NSError *error))completionHandler;
- (void)getLeaderBoardForGroup:(NSInteger)groupId location:(NSString *)location completion:(void(^)(NSArray *leaders, NSError *error))completionHandler;
- (void)uploadImageForGroup:(Group *)group image:(UIImage *)image completion:(void(^)(Group *newGroup, NSError *error))completionHandler;
- (void)deleteMembership:(Member *)member completion:(void(^)(NSError *error))completionHandler;
- (void)deleteGroupAvatar:(Group *)group completion:(void(^)(NSError *error))completionHandler;
- (void)getInvitationDetails:(NSString *)code completion:(void(^)(InvitationCodeDetails *details, NSError *error))completionHandler;
- (void)consumeInviteCode:(NSString *)code forGroup:(Group *)group completion:(void(^)(Member *membership, NSError *error))completionHandler;

// -- Settings -- //

- (void)getSettingsCompletion:(void (^)(NSArray *settings, NSError *error))completionHandler;
- (void)updateNotificationStatus:(NotificationSettings *)settings completion:(void (^)(NotificationSettings *, NSError *))completionHandler;

- (void)getContest:(NSInteger)contestId completion:(void(^)(Contest *contest, NSError *error))completionHandler;
- (void)getContestsAfter:(NSInteger)lastId completion:(void(^)(NSArray *contests, NSError *error))completionHandler;
- (void)getMyContestsAfter:(NSInteger)lastId completion:(void(^)(NSArray *contests, NSError *error))completionHandler;
- (void)getExploreContestsAfter:(NSInteger)lastId completion:(void(^)(NSArray *contests, NSError *error))completionHandler;
- (void)getPredictionsForContest:(NSInteger)contestId after:(NSInteger)lastId expired:(BOOL)expired completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;
- (void)getLeaderBoardForContest:(NSInteger)contestId stage:(NSInteger)stageId completion:(void(^)(NSArray *leaders, NSError *error))completionHandler;


//Followers

- (void)matchFacebookFriends:(void(^)(NSArray *matches, NSError *error))completionHandler;
- (void)matchTwitterFriends:(void(^)(NSArray *matches, NSError *error))completionHandler;
- (void)matchContacts:(NSArray *)contacts completion:(void(^)(NSArray *matches, NSError *error))completionHandler;
- (void)followUsers:(NSArray *)followers completion:(void(^)(NSArray *results, NSError *error))completionHandler;
- (void)unfollowUser:(NSInteger)userId completion:(void(^)(NSError *error))completionHandler;
- (void)getFollowers:(NSInteger)userId completion:(void(^)(NSArray *followers, NSError *error))completionHandler;
- (void)getFollowing:(NSInteger)userId completion:(void(^)(NSArray *followers, NSError *error))completionHandler;
- (void)getSocialFeedAfter:(NSInteger)lastId completion:(void(^)(NSArray *predictions, NSError *error))completionHandler;
- (void)getShortLeaders:(void(^)(NSArray *leaders, NSError *error))completionHandler;

//Hashtags

- (void)searchForHashtags:(NSString *)term completion:(void(^)(NSArray *results, NSError *error))completionHandler;
@end
