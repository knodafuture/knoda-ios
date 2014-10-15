//
//  WebApi.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/4/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebApi.h"
#import "MultipartRequest.h"
#import "NSData+Utils.h"
#import "FileCache.h"
#import "AppDelegate.h"
#import "UserManager.h"

NSString *PredictionChangedNotificationName = @"P_CHANGED";
NSString *PredictionChangedNotificationKey = @"P_CHANGED_KEY";


static WebApi *sharedSingleton;

NSString *const HttpForbiddenNotification = @"HttpForbiddenNotification";
NSString *const DeprecatedAPI = @"DeprecatedAPI";
NSString *const NoConnection = @"NoConnection";
NSInteger PageLimit = 50;
#ifdef TESTFLIGHT
NSString const *baseURL = @"http://captaincold.knoda.com/api/";  // Old server=54.213.86.248
#else
NSString const *baseURL = @"http://api.knoda.com/api/";
#endif

@interface WebApi (Internal)


- (void)executeRequest:(NSURLRequest *)request completion:(void(^)(NSData *responseData, NSError *error))completionHandler;
- (void)handleResponse:(NSURLResponse *)response withData:(NSData *)data error:(NSError *)error completion:(void(^)(NSData *data, NSError *error))completionHandler;

- (NSString *)savedAuthToken;
- (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)method payload:(WebObject *)payload;
- (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)method data:(NSData *)data;
- (NSString *)buildUrl:(NSString *)path parameters:(NSDictionary *)parameters;
- (NSDictionary *)parametersDictionary:(NSDictionary *)dictionary withLastId:(NSInteger)lastId;
- (NSDictionary *)parametersDictionary:(NSDictionary *)dictionary withGreaterThanLastId:(NSInteger)lastId;

- (void)getCachedObjectForKey:(NSString *)key timeout:(NSTimeInterval)timeout inCache:(id<Cache>)cache requestForMiss:(NSURLRequest *(^)(void))miss completion:(void(^)(NSData *data, NSError *error))completionHandler;
@end

@interface WebApi ()

@property (strong, nonatomic) FileCache *fileCache;
@property (readonly, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSDictionary *headers;
@end

@implementation WebApi

+ (WebApi *)sharedInstance {
    static dispatch_once_t once;

    dispatch_once(&once, ^{
        sharedSingleton = [[self alloc] init];
    });

    return sharedSingleton;
}

- (id)init {
    self = [super init];
    self.fileCache = [[FileCache alloc] init];
    self.headers = @{@"Accept": @"application/json; api_version=7;", @"Content-Type" : @"application/json; charset=utf-8;"};
    return self;
}

- (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)authenticateUser:(LoginRequest *)loginRequest completion:(void (^)(LoginResponse *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"session.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:loginRequest];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([LoginResponse instanceFromData:responseData], error);
    }];
}

- (void)getSettingsCompletion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"settings.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Settings arrayFromData:responseData], error);
    }];
}
-(void)updateNotificationStatus:(NotificationSettings *)setting completion:(void (^)(NotificationSettings *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"settings/%ld.json", (long)setting.Id];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"PUT" payload:setting];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([NotificationSettings instanceFromData:responseData], error);
    }];

}



- (void)getCurrentUser:(void (^)(User *, NSError *))completionHandler {

    NSString *url = [self buildUrl:@"profile.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User instanceFromData:responseData], error);
    }];
}

- (void)requestPasswordReset:(PasswordResetRequest *)resetRequest completion:(void (^)(NSError *))completionHandler {
    NSString *url = [self buildUrl:@"password.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:resetRequest];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)sendSignUpWithRequest:(SignupRequest *)signupRequest completion:(void (^)(LoginResponse *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"registration.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:signupRequest];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([LoginResponse instanceFromData:responseData], error);
    }];
}

- (void)socialSignIn:(SocialAccount *)request completion:(void (^)(LoginResponse *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"session.json" parameters:nil];
    NSURLRequest *req = [self requestWithUrl:url method:@"POST" payload:request];

    [self executeRequest:req completion:^(NSData *responseData, NSError *error) {
        completionHandler([LoginResponse instanceFromData:responseData], error);
    }];
}

- (void)addSocialAccount:(SocialAccount *)account completion:(void (^)(SocialAccount *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"social_accounts.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:account];
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([SocialAccount instanceFromData:responseData], error);
    }];
}

- (void)deleteSocialAccount:(SocialAccount *)account completion:(void (^)(NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"social_accounts/%@.json", account.socialAccountId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"DELETE" payload:nil];
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)updateSocialAccount:(SocialAccount *)socialAccount completion:(void (^)(SocialAccount *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"social_accounts/%@.json", socialAccount.socialAccountId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"PUT" payload:socialAccount];
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([SocialAccount instanceFromData:responseData], error);
    }];
}

- (void)postPredictionToFacebook:(Prediction *)prediction brag:(BOOL)brag completion:(void (^)(NSError *))completionHandler {
    NSDictionary *params = @{@"prediction_id": @(prediction.predictionId), @"type" : brag ? @"brag" : @""};
    NSString *url = [self buildUrl:@"facebook.json" parameters:params];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)postPredictionToTwitter:(Prediction *)prediction brag:(BOOL)brag completion:(void (^)(NSError *))completionHandler  {
    NSDictionary *params = @{@"prediction_id": @(prediction.predictionId), @"type" : brag ? @"brag" : @""};
    NSString *url = [self buildUrl:@"twitter.json" parameters:params];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:nil];
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)getRivals:(NSInteger)userId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"users/%ld/rivals.json",(long)userId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User arrayFromData:responseData], error);
    }];
}

- (void)uploadProfileImage:(UIImage *)profileImage completion:(void (^)(NSError *))completionHandler {

    NSData *profileData = UIImagePNGRepresentation(profileImage);

    if (!profileData) {
        completionHandler([NSError errorWithDomain:@"" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Bad image!"}]);
        return;
    }

    NSDictionary *parameters = @{@"Images" : @{@"user[avatar]" : UIImagePNGRepresentation(profileImage)}};

    NSString *url = [self buildUrl:@"profile.json" parameters:nil];
    MultipartRequest *request = [[MultipartRequest alloc] initWithHTTPMethod:@"PATCH" url:url parameters:parameters];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)updateUser:(User *)user completion:(void (^)(User *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"profile.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"PUT" payload:user];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User instanceFromData:responseData], error);
    }];
}

- (void)changePassword:(PasswordChangeRequest *)changeRequest completion:(void (^)(User *, NSError *))completionHandler {

    NSString *url = [self buildUrl:@"password.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"PUT" payload:changeRequest];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User instanceFromData:responseData], error);
    }];


}

- (void)signoutCompletion:(void (^)(NSError *))completionHandler {
    NSString *url = [self buildUrl:@"session.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"DELETE" payload:nil];


    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}
- (void)sendToken:(DeviceToken *)deviceToken completion:(void (^)(NSString *, NSError *))completionHandler {

    NSString *url = [self buildUrl:@"apple_device_tokens.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:deviceToken];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        NSString *tokenId = nil;

        if (!error)
            tokenId = [[responseData jsonObject] objectForKey:@"id"];
        completionHandler(tokenId, error);
    }];
}

- (void)deleteToken:(NSString *)tokenId completion:(void (^)(NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat: @"apple_device_tokens/%@.json", tokenId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"DELETE" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)getUser:(NSInteger)userId completion:(void (^)(User *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"users/%ld.json", (long)userId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User instanceFromData:responseData], error);
    }];

}

- (void)autoCompleteUsers:(NSString *)query completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *params = @{@"query": query};

    NSString *url = [self buildUrl:@"users/autocomplete.json" parameters:params];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User arrayFromData:responseData], error);
    }];
}

- (void)getUserFromUsername:(NSString *)username completion:(void (^)(User *, NSError *))completionHandler {
    username = [username stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *path = [NSString stringWithFormat:@"users/%@.json", username];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User instanceFromData:responseData], error);
    }];
    
}

- (void)getPredictionsAfter:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    [self getPredictionsAfter:lastId tag:nil completion:completionHandler];
}

- (void)getPredictionsAfter:(NSInteger)lastId tag:(NSString *)tag completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSMutableDictionary *params = [@{@"recent" : @"true", @"limit"  : @(PageLimit)} mutableCopy];
    if (tag)
        [params setObject:tag forKey:@"tag"];

    NSDictionary *parameters = [self parametersDictionary:params withLastId:lastId];

    NSString *url = [self buildUrl:@"predictions.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)addPrediction:(Prediction *)prediction completion:(void (^)(Prediction *, NSError *))completionHandler {

    NSString *url = [self buildUrl:@"predictions.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:prediction];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction instanceFromData:responseData], error);
    }];
}

- (void)getPrediction:(NSInteger)predictionId completion:(void (^)(Prediction *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%ld.json", (long)predictionId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction instanceFromData:responseData],error);
    }];
}

- (void)getPredictionsForUser:(NSInteger)userId after:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit" : @(PageLimit), @"count" : @(1)};
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    NSString *path = [NSString stringWithFormat:@"users/%ld/predictions.json", (long)userId];
    NSString *url = [self buildUrl:path parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)getCategoriesCompletion:(void (^)(NSArray *, NSError *))completionHandler {

    [self getCachedObjectForKey:@"categories" timeout:FileCacheTimeOneDay inCache:self.fileCache requestForMiss:^NSURLRequest *{
        NSString *url = [self buildUrl:@"topics.json" parameters:nil];
        NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];
        return request;
    } completion:^(NSData *data, NSError *error) {
        completionHandler([Tag arrayFromData:data], error);
    }];
}

- (void)agreeWithPrediction:(NSInteger)predictionId completion:(void (^)(Challenge *challenge, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat: @"predictions/%ld/agree.json", (long)predictionId];

    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        if (!error)
            [self getChallengeForPrediction:predictionId completion:completionHandler];
        else
            completionHandler(nil, error);
    }];
}

- (void)disagreeWithPrediction:(NSInteger)predictionId completion:(void (^)(Challenge *challenge, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat: @"predictions/%ld/disagree.json", (long)predictionId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        if (!error)
            [self getChallengeForPrediction:predictionId completion:completionHandler];
        else
            completionHandler(nil, error);
    }];
}

- (void)getChallengeForPrediction:(NSInteger)predictionId completion:(void (^)(Challenge *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat: @"predictions/%ld/challenge.json", (long)predictionId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Challenge instanceFromData:responseData], error);
    }];
}

- (void)getHistoryAfter:(NSInteger)lastId challenged:(BOOL)challenged completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters;
    if (challenged)
        parameters = @{@"challenged": @"true", @"limit" : @(PageLimit)};
    else
        parameters = @{@"limit": @(PageLimit)};
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    NSString *url = [self buildUrl:@"predictions" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)getAgreedUsers:(NSInteger)predictionId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%ld/history_agreed.json", (long)predictionId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User arrayFromData:responseData], error);
    }];
}

- (void)getDisagreedUsers:(NSInteger)predictionId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%ld/history_disagreed.json", (long)predictionId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User arrayFromData:responseData], error);
    }];
}

- (void)sendBS:(NSInteger)predictionId completion:(void (^)(NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%ld/bs.json", (long)predictionId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)setPredictionOutcome:(NSInteger)predictionId correct:(BOOL)correct completion:(void (^)(NSError *))completionHandler {
    NSString *path;

    if (correct)
        path = [NSString stringWithFormat:@"predictions/%ld/realize.json", (long)predictionId];
    else
        path = [NSString stringWithFormat:@"predictions/%ld/unrealize.json", (long)predictionId];

    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
        
        if (!error) {
            [self getPrediction:predictionId completion:^(Prediction *prediction, NSError *error) {
                if (!error)
                    [[NSNotificationCenter defaultCenter] postNotificationName:PredictionChangedNotificationName object:nil userInfo:@{PredictionChangedNotificationKey: prediction}];
            }];
        }
    }];
}

- (void)updatePrediction:(Prediction *)prediction completion:(void (^)(Prediction *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%ld.json", (long)prediction.predictionId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"PUT" payload:prediction];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction instanceFromData:responseData], error);
        if (!error)
            [[NSNotificationCenter defaultCenter] postNotificationName:PredictionChangedNotificationName object:nil userInfo:@{PredictionChangedNotificationKey: [Prediction instanceFromData:responseData]}];
    }];
}

- (void)getCommentsForPrediction:(NSInteger)predictionId last:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"list": @"prediction", @"limit" : @(PageLimit),
                                 @"prediction_id": @(predictionId)};
    parameters = [self parametersDictionary:parameters withGreaterThanLastId:lastId];
    NSString *url = [self buildUrl:@"comments.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Comment arrayFromData:responseData], error);
    }];
}

- (void)createComment:(Comment *)comment completion:(void (^)(Comment *newComment, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"comments.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:comment];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Comment instanceFromData:responseData], error);
    }];
}
- (void)getImage:(NSString *)imageUrl completion:(void (^)(UIImage *, NSError *))completionHandler {

    [self getCachedObjectForKey:imageUrl timeout:FileCacheTimeInfinite inCache:self.fileCache requestForMiss:^NSURLRequest *{
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        return request;

    } completion:^(NSData *data, NSError *error) {
        UIImage *image;
        if (!error)
            image = [UIImage imageWithData:data];
        completionHandler(image, error);
    }];
}

- (void)getUnseenActivity:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"list": @"unseen"};
    NSString *url = [self buildUrl:@"activityfeed.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([ActivityItem arrayFromData:responseData], error);
    }];
}

- (void)getActivityAfter:(NSInteger)lastId filter:(NSString *)filter completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSMutableDictionary *parameters = [@{@"limit": @(PageLimit)} mutableCopy];
    
    if (filter)
        parameters[@"filter"] = filter;
    
    parameters = [[self parametersDictionary:[NSDictionary dictionaryWithDictionary:parameters] withLastId:lastId] mutableCopy];
    NSString *url = [self buildUrl:@"activityfeed.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([ActivityItem arrayFromData:responseData], error);
    }];
}

- (void)searchForPredictions:(NSString *)searchText completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit": @(PageLimit), @"q" : searchText};

    NSString *url = [self buildUrl:@"search/predictions.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)searchForUsers:(NSString *)searchText completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit": @(5), @"q" : searchText};

    NSString *url = [self buildUrl:@"search/users.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User arrayFromData:responseData], error);
    }];
}

- (void)getGroups:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"groups.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Group arrayFromData:responseData], error);
    }];
}

- (void)getGroup:(NSInteger)groupId completion:(void (^)(Group *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"groups/%ld.json", (long)groupId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Group instanceFromData:responseData], error);
    }];
}

- (void)getPredictionsForGroup:(NSInteger)groupId after:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"groups/%ld/predictions.json", (long)groupId];
    NSDictionary *parameters = [self parametersDictionary:@{@"limit": @(PageLimit)} withLastId:lastId];
    NSString *url = [self buildUrl:path parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)getMembersForGroup:(NSInteger)groupId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"groups/%ld/memberships.json", (long)groupId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Member arrayFromData:responseData], error);
    }];
}

- (void)sendInvites:(NSArray *)invitations completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"invitations.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" data:[WebObject dataFromArrayOfWebObjects:invitations]];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Invitation arrayFromData:responseData], error);
    }];
}

- (void)createGroup:(Group *)group completion:(void (^)(Group *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"groups.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" payload:group];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Group instanceFromData:responseData], error);
    }];
}

- (void)updateGroup:(Group *)group completion:(void (^)(Group *, NSError *))completionHandler {

    NSString *path = [NSString stringWithFormat:@"groups/%ld.json", (long)group.groupId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"PUT" payload:group];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Group instanceFromData:responseData], error);
    }];
}

- (void)getLeaderBoardForGroup:(NSInteger)groupId location:(NSString *)location completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters;

    if (location)
        parameters = @{@"board": location};
    NSString *path = [NSString stringWithFormat:@"groups/%ld/leaderboard.json", (long)groupId];
    NSString *url = [self buildUrl:path parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Leader arrayFromData:responseData], error);
    }];
}

- (void)uploadImageForGroup:(Group *)group image:(UIImage *)image completion:(void(^)(Group *newGroup, NSError *error))completionHandler {

    NSData *profileData = UIImagePNGRepresentation(image);

    if (!profileData) {
        completionHandler(nil, [NSError errorWithDomain:@"" code:400 userInfo:@{NSLocalizedDescriptionKey: @"Bad image!"}]);
        return;
    }

    NSDictionary *parameters = @{@"Images" : @{@"avatar" : UIImagePNGRepresentation(image)}};

    NSString *path = [NSString stringWithFormat:@"groups/%ld.json", (long)group.groupId];
    NSString *url = [self buildUrl:path parameters:nil];
    MultipartRequest *request = [[MultipartRequest alloc] initWithHTTPMethod:@"PUT" url:url parameters:parameters];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Group instanceFromData:responseData], error);
    }];
}

- (void)deleteMembership:(Member *)member completion:(void (^)(NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"memberships/%ld.json", (long)member.memberId];
    NSString *url = [self buildUrl:path parameters:nil];

    NSURLRequest *request = [self requestWithUrl:url method:@"DELETE" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)deleteGroupAvatar:(Group *)group completion:(void (^)(NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"groups/%ld/avatar.json", (long)group.groupId];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"DELETE" payload:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)getInvitationDetails:(NSString *)code completion:(void (^)(InvitationCodeDetails *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"invitations/%@.json", code];
    NSString *url = [self buildUrl:path parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([InvitationCodeDetails instanceFromData:responseData], error);
    }];
}

- (void)consumeInviteCode:(NSString *)code forGroup:(Group *)group completion:(void (^)(Member *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"memberships.json" parameters:nil];
    NSDictionary *dict = @{@"code": code, @"group_id" : @(group.groupId)};
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" data:[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil]];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Member instanceFromData:responseData], error);
    }];
}

- (void)getContest:(NSInteger)contestId completion:(void (^)(Contest *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"contests/%ld.json", (long)contestId];
    NSString *url = [self buildUrl:path parameters:nil];
    
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Contest instanceFromData:responseData], error);
    }];
}

- (void)getContestsAfter:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit" : @(PageLimit)};
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    
    NSString *url = [self buildUrl:@"contests.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Contest arrayFromData:responseData], error);
    }];
}

- (void)getMyContestsAfter:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit" : @(PageLimit), @"list" : @"entered"};
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    
    NSString *url = [self buildUrl:@"contests.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Contest arrayFromData:responseData], error);
    }];
}

- (void)getExploreContestsAfter:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit" : @(PageLimit), @"list" : @"explore"};
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    
    NSString *url = [self buildUrl:@"contests.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Contest arrayFromData:responseData], error);
    }];
}

- (void)getPredictionsForContest:(NSInteger)contestId after:(NSInteger)lastId expired:(BOOL)expired completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"contests/%ld/predictions.json", (long)contestId];
    NSDictionary *parameters = [self parametersDictionary:@{@"limit": @(PageLimit)} withLastId:lastId];
    
    if (expired) {
        NSMutableDictionary *mutable = [parameters mutableCopy];
        mutable[@"list"] = @"expired";
        parameters = mutable;
    }
    
    NSString *url = [self buildUrl:path parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)getLeaderBoardForContest:(NSInteger)contestId stage:(NSInteger)stageId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"contests/%ld/leaderboard.json", (long)contestId];
    NSDictionary *parameters = @{@"stage": @(stageId)};
    
    if (stageId == 0)
        parameters = nil;
    
    NSString *url = [self buildUrl:path parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Leader arrayFromData:responseData], error);
    }];
}

- (void)matchFacebookFriends:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"facebook": @"true"};
    
    NSString *url = [self buildUrl:@"contact_matches.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([ContactMatch arrayFromData:responseData], error);
    }];
}

- (void)matchTwitterFriends:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"twitter": @"true"};
    NSString *url = [self buildUrl:@"contact_matches.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {

        completionHandler([ContactMatch arrayFromData:responseData], error);
    }];
}

- (void)matchContacts:(NSArray *)contacts completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"contact_matches.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" data:[WebObject dataFromArrayOfWebObjects:contacts]];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        
        NSArray *matches = [ContactMatch arrayFromData:responseData];
        
        NSMutableArray *actualMatches = [NSMutableArray arrayWithCapacity:matches.count];
        
        for (ContactMatch *match in matches) {
            if (match.info && !match.info.following)
                [actualMatches addObject:match];
        }
        
        completionHandler([NSArray arrayWithArray:actualMatches], error);
    }];
}

- (void)followUsers:(NSArray *)followers completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *url = [self buildUrl:@"followings.json" parameters:nil];
    NSURLRequest *request = [self requestWithUrl:url method:@"POST" data:[WebObject dataFromArrayOfWebObjects:followers]];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        NSArray *result;
        if (responseData != nil)
            result = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        completionHandler(result, error);
        [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {
            
        }];
    }];
}

- (void)unfollowUser:(NSInteger)userId completion:(void (^)(NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"followings/%ld.json", (long)userId];
    NSString *url = [self buildUrl:path parameters:nil];
    
    NSURLRequest *request = [self requestWithUrl:url method:@"DELETE" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
        [[UserManager sharedInstance] refreshUser:^(User *user, NSError *error) {
            
        }];
    }];
}

- (void)getFollowers:(NSInteger)userId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"users/%ld/followers.json", (long)userId];
    NSString *url = [self buildUrl:path parameters:nil];
    
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User arrayFromData:responseData], error);
    }];
}

- (void)getFollowing:(NSInteger)userId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"users/%ld/leaders.json", (long)userId];
    NSString *url = [self buildUrl:path parameters:nil];
    
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User arrayFromData:responseData], error);
    }];
}

- (void)getSocialFeedAfter:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSMutableDictionary *params = [@{@"social" : @"true", @"limit"  : @(PageLimit)} mutableCopy];
    NSDictionary *parameters = [self parametersDictionary:params withLastId:lastId];
    
    NSString *url = [self buildUrl:@"predictions.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" payload:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)getShortLeaders:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"mode": @"as_follower"};
    
    NSString *url = [self buildUrl:@"followings.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        NSArray *array = nil;
        if (responseData)
            array = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        completionHandler(array, nil);
    }];
}

- (void)searchForHashtags:(NSString *)term completion:(void (^)(NSArray *, NSError *))completionHandler {
    
    NSDictionary *parameters = nil;
    
    if (term)
        parameters = @{@"q":term};
    
    NSString *url = [self buildUrl:@"hashtags/autocomplete.json" parameters:parameters];
    NSURLRequest *request = [self requestWithUrl:url method:@"GET" data:nil];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        NSArray *results = nil;
        
        if (responseData)
            results = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
        
        completionHandler(results, error);
    }];
    
}

- (NSString *)getCreatedObjectId:(NSData *)data {
    if (!data)
        return nil;

    id jsonObject = [data jsonObject];

    if (!jsonObject || ![jsonObject isKindOfClass:NSDictionary.class])
        return nil;

    return jsonObject[@"id"];
}

@end

@implementation WebApi (Internal)

- (NSString *)savedAuthToken {
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:LoginResponseKey];

    if ([token isKindOfClass:NSString.class])
        return token;

    return nil;
}

- (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)method data:(NSData *)data {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];

    for (NSString *key in self.headers) {
        [request setValue:self.headers[key] forHTTPHeaderField:key];
    }

    [request setHTTPMethod:method];

    if (data) {

        [request setHTTPBody:data];
    }

    return request;
}

- (NSMutableURLRequest *)requestWithUrl:(NSString *)url method:(NSString *)method payload:(WebObject *)payload {
    NSData *data;
    if (payload) {
        NSDictionary *dictionary = [MTLJSONAdapter JSONDictionaryFromModel:payload];
        NSLog(@"%@", dictionary);
        data = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    }

    return [self requestWithUrl:url method:method data:data];
}

- (NSString *)buildUrl:(NSString *)path parameters:(NSDictionary *)parameters {

    if (!parameters)
        parameters = @{};

    NSString *authToken = [self savedAuthToken];

    if (authToken) {
        NSMutableDictionary *tmp = [parameters mutableCopy];
        [tmp setObject:authToken forKey:@"auth_token"];
        parameters = tmp;
    }

    NSMutableString *url = [[NSString stringWithFormat:@"%@%@", baseURL, path] mutableCopy];

    BOOL first = YES;

    for (NSString *key in parameters) {
        if (first) {
            [url appendFormat:@"?%@=%@", key, parameters[key]];
            first = NO;
        } else
            [url appendFormat:@"&%@=%@", key, parameters[key]];
    }

    return url;


}

- (void)executeRequest:(NSURLRequest *)request completion:(void (^)(NSData *, NSError *))completionHandler {
    NSLog(@"Executing request url: %@", request.URL.absoluteString);
    //NSLog(@"Body: %@", [[NSString alloc] initWithData:request.HTTPBody encoding:NSUTF8StringEncoding]);
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self handleResponse:response withData:data error:connectionError completion:completionHandler];
    }];
}
- (void)getCachedObjectForKey:(NSString *)key timeout:(NSTimeInterval)timeout inCache:(id<Cache>)cache requestForMiss:(NSURLRequest *(^)(void))miss completion:(void (^)(NSData *, NSError *))completionHandler {
    [cache dataForKey:key complete:^(NSData *data, BOOL stale) {
        if (data && !stale)
            completionHandler(data, nil);
        else
            [self executeRequest:miss() completion:^(NSData *responseData, NSError *error) {
                NSLog(@"%lu", (unsigned long)responseData.length);
                if (!error) {
                    [cache setData:responseData key:key timeout:timeout];
                }

                completionHandler(responseData, error);
            }];
    }];

}

- (NSDictionary *)parametersDictionary:(NSDictionary *)dictionary withLastId:(NSInteger)lastId {
    if (lastId == 0)
        return dictionary;

    NSMutableDictionary *dict = [dictionary mutableCopy];
    [dict setObject:@(lastId) forKey:@"id_lt"];

    return dict;

}

- (NSDictionary *)parametersDictionary:(NSDictionary *)dictionary withGreaterThanLastId:(NSInteger)lastId {
    if (lastId == 0)
        return dictionary;

    NSMutableDictionary *dict = [dictionary mutableCopy];
    [dict setObject:@(lastId) forKey:@"id_gt"];

    return dict;
}

- (void)handleResponse:(NSURLResponse *)response withData:(NSData *)data error:(NSError *)error completion:(void(^)(NSData *data, NSError *error))completionHandler {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error != nil && [error code] == NSURLErrorUserCancelledAuthentication) {
		[[NSNotificationCenter defaultCenter] postNotificationName:HttpForbiddenNotification object:nil];
	}
    else if ((httpResponse.statusCode == HttpStatusGone)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DeprecatedAPI object:nil];
        return;
    }
	else if (httpResponse.statusCode >= 300) {
		NSLog(@"Error for request: %@", response.URL.absoluteString);
		NSLog(@"Error code: %ld, message: %@", (long)[httpResponse statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

        NSDictionary *errors = [data jsonObject];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [self buildLocalizedErrorDescriptionFromErrorDictionary:errors]};

        completionHandler(nil, [NSError errorWithDomain:@"" code:[httpResponse statusCode] userInfo:userInfo]);
	}
//    else if (httpResponse == nil) {
//        NSLog(@"no connection");
//        [[NSNotificationCenter defaultCenter] postNotificationName:NoConnection object:nil];
//        //return;
//        
//    }
	else
		completionHandler(data, error);
}

- (NSString *)buildLocalizedErrorDescriptionFromErrorDictionary:(NSDictionary *)dictionary {

    if (![dictionary isKindOfClass:NSDictionary.class])
        return @"";

    NSDictionary *errors = dictionary[@"errors"];

    if (![errors isKindOfClass:NSDictionary.class])
        return @"";

    NSString *errorKey;

    for (NSString *key in errors.allKeys) {
        if ([key isEqualToString:@"user_facing"])
            errorKey = key;
    }

    if (!errorKey)
        errorKey = [errors.allKeys firstObject];

    if ([errorKey isEqualToString:@"user_facing"]) {
        return [errors[errorKey] firstObject];
    }

    id errorDescription = errors[errorKey];

    NSString *errorString = [errorDescription isKindOfClass:[NSArray class]] ? [errorDescription lastObject] : errorDescription;

    return [NSString stringWithFormat:@"%@ %@", errorKey.capitalizedString, errorString];
}


@end
