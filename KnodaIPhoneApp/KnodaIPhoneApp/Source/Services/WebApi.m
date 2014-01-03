//
//  WebApi.m
//  KnodaIPhoneApp
//
//  Created by nick on 12/4/13.
//  Copyright (c) 2013 Knoda. All rights reserved.
//

#import "WebApi.h"
#import "WebRequest.h"
#import "NSData+Utils.h"
#import "FileCache.h"
#import "AppDelegate.h" 

static WebApi *sharedSingleton;

NSString *const HttpForbiddenNotification = @"HttpForbiddenNotification";
NSInteger PageLimit = 50;

@interface WebApi (Internal)

- (void)executeRequest:(WebRequest *)request completion:(void(^)(NSData *responseData, NSError *error))completionHandler;
- (void)executeUpdateUserRequest:(WebRequest *)request completion:(void(^)(NSData *responseData, NSError *error))completionHandler;
- (void)handleResponse:(NSURLResponse *)response withData:(NSData *)data error:(NSError *)error completion:(void(^)(NSData *data, NSError *error))completionHandler;

- (NSDictionary *)parametersDictionary:(NSDictionary *)dictionary withLastId:(NSInteger)lastId;
- (void)getCachedObjectForKey:(NSString *)key timeout:(NSTimeInterval)timeout inCache:(id<Cache>)cache requestForMiss:(WebRequest *(^)(void))miss completion:(void(^)(NSData *data, NSError *error))completionHandler;
@end

@interface WebApi ()

@property (strong, nonatomic) FileCache *fileCache;
@property (readonly, nonatomic) AppDelegate *appDelegate;
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
    return self;
}

- (AppDelegate *)appDelegate {
    return [[UIApplication sharedApplication] delegate];
}

- (void)authenticateUser:(LoginRequest *)loginRequest completion:(void (^)(LoginResponse *, NSError *))completionHandler {
    NSDictionary *parameters = [loginRequest parametersDictionary];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:@"session.json" parameters:parameters requiresAuthToken:NO isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([LoginResponse instanceFromData:responseData], error);
    }];
}

- (void)getCurrentUser:(void (^)(User *, NSError *))completionHandler {

    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"profile.json" parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        User *user = [User instanceFromData:responseData];
        if (!error)
            [self.appDelegate setValue:user forKey:@"currentUser"];
        completionHandler(user, error);
    }];
}

- (void)requestPasswordResetForEmail:(NSString *)email completion:(void (^)(NSError *))completionHandler {
    NSDictionary *parameters = @{@"login": email};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:@"password.json" parameters:parameters requiresAuthToken:NO isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)sendSignUpWithRequest:(SignupRequest *)signupRequest completion:(void (^)(LoginResponse *, NSError *))completionHandler {
    NSDictionary *parameters = [signupRequest parametersDictionary];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:@"registration.json" parameters:parameters requiresAuthToken:NO isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([LoginResponse instanceFromData:responseData], error);
    }];
}

- (void)uploadProfileImage:(UIImage *)profileImage completion:(void (^)(NSError *))completionHandler {
    NSDictionary *parameters = @{@"Images" : @{@"user[avatar]" : UIImagePNGRepresentation(profileImage)}};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"PATCH" path:@"profile.json" parameters:parameters requiresAuthToken:YES isMultiPartData:YES];
    
    [self executeUpdateUserRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)changeUsername:(NSString *)newUsername completion:(void (^)(NSError *))completionHandler {
    NSDictionary *parameters = @{@"user[username]" : newUsername};

    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"PATCH" path:@"profile.json" parameters:parameters requiresAuthToken:YES isMultiPartData:YES];
    
    [self executeUpdateUserRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)changeEmail:(NSString *)newEmail completion:(void (^)(NSError *))completionHandler {
    NSDictionary *parameters = @{@"user[email]" : newEmail};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"PATCH" path:@"profile.json" parameters:parameters requiresAuthToken:YES isMultiPartData:YES];
    
    [self executeUpdateUserRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)changePassword:(NSString *)currentPassword newPassword:(NSString *)newPassword completion:(void (^)(NSError *))completionHandler {
    NSDictionary *parameters = @{@"current_password" : currentPassword, @"new_password" : newPassword};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"PUT" path:@"password.json" parameters:parameters requiresAuthToken:YES isMultiPartData:YES];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        NSLog(@"%@", [responseData jsonObject]);
        completionHandler(error);
    }];

}

- (void)signoutCompletion:(void (^)(NSError *))completionHandler {
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"DELETE" path:@"session.json" parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)sendToken:(NSString *)token completion:(void (^)(NSString *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"apple_device_token[token]": token, @"apple_device_token[sandbox]" : @"false"};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:@"apple_device_tokens.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        NSString *tokenId = nil;
        
        if (!error)
            tokenId = [[responseData jsonObject] objectForKey:@"id"];
        completionHandler(tokenId, error);
    }];
}

- (void)deleteToken:(NSString *)tokenId completion:(void (^)(NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat: @"apple_device_tokens/%@.json", tokenId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"DELETE" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)getUser:(NSInteger)userId completion:(void (^)(User *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"users/%d.json", userId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
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
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"predictions.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)addPrediction:(Prediction *)prediction completion:(void (^)(Prediction *, NSError *))completionHandler {
    NSDictionary *parameters = [prediction parametersDictionary];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:@"predictions.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        if (error) {
            completionHandler(nil, error);
            return;
        } else {
            NSString *createdId = [self getCreatedObjectId:responseData];
            if (!createdId)
                completionHandler(nil, [NSError errorWithDomain:@"http" code:HttpStatusNotFound userInfo:nil]);
            else
                [self getPrediction:[createdId integerValue] completion:completionHandler];
            
            
        }
    }];
}

- (void)getPrediction:(NSInteger)predictionId completion:(void (^)(Prediction *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%d.json", predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:path parameters:Nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction instanceFromData:responseData],error);
    }];
}

- (void)getPredictionsForUser:(NSInteger)userId after:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit" : @(PageLimit), @"count" : @(1)};
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    NSString *path = [NSString stringWithFormat:@"users/%d/predictions.json", userId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:path parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)getCategoriesCompletion:(void (^)(NSArray *, NSError *))completionHandler {
    
    
    [self getCachedObjectForKey:@"categories" timeout:FileCacheTimeOneDay inCache:self.fileCache requestForMiss:^WebRequest *{
        WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"topics.json" parameters:nil requiresAuthToken:YES isMultiPartData:NO];
        return request;
    } completion:^(NSData *data, NSError *error) {
        completionHandler([Topic arrayFromData:data], error);
    }];
}

- (void)agreeWithPrediction:(NSInteger)predictionId completion:(void (^)(Challenge *challenge, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat: @"predictions/%d/agree.json", predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        if (!error)
            [self getChallengeForPrediction:predictionId completion:completionHandler];
        else
            completionHandler(nil, error);
    }];
}

- (void)disagreeWithPrediction:(NSInteger)predictionId completion:(void (^)(Challenge *challenge, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat: @"predictions/%d/disagree.json", predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        if (!error)
            [self getChallengeForPrediction:predictionId completion:completionHandler];
        else
            completionHandler(nil, error);
    }];
}

- (void)getChallengeForPrediction:(NSInteger)predictionId completion:(void (^)(Challenge *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat: @"predictions/%d/challenge.json", predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Challenge instanceFromData:responseData], error);
    }];
}

- (void)getHistoryAfter:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"list": @"ownedAndPicked", @"limit" : @(PageLimit)};
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"challenges.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromHistoryData:responseData], error);
    }];
}

- (void)getAgreedUsers:(NSInteger)predictionId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%d/history_agreed.json", predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([TallyUser arrayFromData:responseData], error);
    }];
}

- (void)getDisagreedUsers:(NSInteger)predictionId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%d/history_disagreed.json", predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([TallyUser arrayFromData:responseData], error);
    }];
}

- (void)sendBS:(NSInteger)predictionId completion:(void (^)(NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%d/bs.json", predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)setPredictionOutcome:(NSInteger)predictionId correct:(BOOL)correct completion:(void (^)(NSError *))completionHandler {
    NSString *path;
    
    if (correct)
        path = [NSString stringWithFormat:@"predictions/%d/realize.json", predictionId];
    else
        path = [NSString stringWithFormat:@"predictions/%d/unrealize.json", predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:path parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)updatePrediction:(UpdatePredictionRequest *)updateRequest completion:(void (^)(Prediction *, NSError *))completionHandler {
    NSString *path = [NSString stringWithFormat:@"predictions/%d.json", updateRequest.predictionId];
    NSDictionary *parameters = [updateRequest parametersDictionary];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"PATCH" path:path parameters:parameters requiresAuthToken:YES isMultiPartData:YES];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction instanceFromData:responseData], error);
    }];
}

- (void)getCommentsForPrediction:(NSInteger)predictionId last:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"list": @"prediction", @"limit" : @(PageLimit),
                                 @"prediction_id": @(predictionId)};
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"comments.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Comment arrayFromData:responseData], error);
    }];
}

- (void)createComment:(Comment *)comment completion:(void (^)(NSError *))completionHandler {
    NSDictionary *params = @{@"comment[text]": comment.body};
    NSString *path = [NSString stringWithFormat: @"predictions/%d/comment.json", comment.predictionId];
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:path parameters:params requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)checkNewBadges {
    [self getNewBadgesCompletion:^(NSArray *badges, NSError *error) {
        if (badges.count > 0 && !error)
            [[NSNotificationCenter defaultCenter] postNotificationName:BadgeNotification object:nil userInfo:@{BadgeNotificationKey: badges}];
    }];
}

- (void)getNewBadgesCompletion:(void (^)(NSArray *, NSError *))completionHandler {
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"badges/recent.json" parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Badge arrayFromData:responseData], error);
    }];
}

- (void)getAllBadgesCompletion:(void (^)(NSArray *, NSError *))completionHandler {
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"badges.json" parameters:nil requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Badge arrayFromData:responseData], error);
    }];
}

- (void)getImage:(NSString *)imageUrl completion:(void (^)(UIImage *, NSError *))completionHandler {
    
    
    [self getCachedObjectForKey:imageUrl timeout:FileCacheTimeInfinite inCache:self.fileCache requestForMiss:^WebRequest *{
        WebRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
        return request;

    } completion:^(NSData *data, NSError *error) {
        UIImage *image;
        if (!error)
            image = [UIImage imageWithData:data];
        completionHandler(image, error);
    }];
}

- (void)getUnseenAlertsCompletion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"list": @"unseen"};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"activityfeed.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Alert arrayFromData:responseData], error);
    }];
}

- (void)getAlertsAfter:(NSInteger)lastId completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit": @(PageLimit)};
    
    parameters = [self parametersDictionary:parameters withLastId:lastId];
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"activityfeed.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Alert arrayFromData:responseData], error);
    }];
    
}

- (void)setSeenAlerts:(NSArray *)seenAlertIds completion:(void (^)(NSError *))completionHandler {
    NSMutableString  *idString = [NSMutableString stringWithFormat: @"%d", [[seenAlertIds firstObject] integerValue]];
    
    for (int i = 1; i < seenAlertIds.count; i++)
        [idString appendFormat: @",%d", [[seenAlertIds objectAtIndex: i] integerValue]];
    
    NSDictionary *parameters = @{@"ids[]" : idString};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"POST" path:@"activityfeed/seen.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];

    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler(error);
    }];
}

- (void)searchForPredictions:(NSString *)searchText completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit": @(PageLimit), @"q" : searchText};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"search/predictions.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([Prediction arrayFromData:responseData], error);
    }];
}

- (void)searchForUsers:(NSString *)searchText completion:(void (^)(NSArray *, NSError *))completionHandler {
    NSDictionary *parameters = @{@"limit": @(5), @"q" : searchText};
    
    WebRequest *request = [[WebRequest alloc] initWithHTTPMethod:@"GET" path:@"search/users.json" parameters:parameters requiresAuthToken:YES isMultiPartData:NO];
    
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        completionHandler([User arrayFromData:responseData], error);
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

- (void)executeRequest:(WebRequest *)request completion:(void (^)(NSData *, NSError *))completionHandler {
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        [self handleResponse:response withData:data error:connectionError completion:completionHandler];
    }];
}

- (void)executeUpdateUserRequest:(WebRequest *)request completion:(void (^)(NSData *, NSError *))completionHandler {
    [self executeRequest:request completion:^(NSData *responseData, NSError *error) {
        if (error)
            completionHandler(nil, error);
        else
            [self getCurrentUser:^(User *user, NSError *error) {
                if (!error)
                    [self.appDelegate setValue:user forKey:@"currentUser"];
                completionHandler(responseData, nil);
            }];
    }];
}

- (void)getCachedObjectForKey:(NSString *)key timeout:(NSTimeInterval)timeout inCache:(id<Cache>)cache requestForMiss:(WebRequest *(^)(void))miss completion:(void (^)(NSData *, NSError *))completionHandler {
    [cache dataForKey:key complete:^(NSData *data, BOOL stale) {
        if (data && !stale)
            completionHandler(data, nil);
        else
            [self executeRequest:miss() completion:^(NSData *responseData, NSError *error) {
                NSLog(@"%d", responseData.length);
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

- (void)handleResponse:(NSURLResponse *)response withData:(NSData *)data error:(NSError *)error completion:(void(^)(NSData *data, NSError *error))completionHandler {
	NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if (error != nil && [error code] == NSURLErrorUserCancelledAuthentication) {
		[[NSNotificationCenter defaultCenter] postNotificationName:HttpForbiddenNotification object:nil];
	}
	else if (httpResponse.statusCode >= 300) {
		NSLog(@"Error for request: %@", response.URL.absoluteString);
		NSLog(@"Error code: %d, message: %@", [httpResponse statusCode], [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
		
        NSDictionary *errors = [data jsonObject];
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [self buildLocalizedErrorDescriptionFromErrorDictionary:errors]};
        
        completionHandler(nil, [NSError errorWithDomain:@"" code:[httpResponse statusCode] userInfo:userInfo]);
	}
	else
		completionHandler(data, error);
}

- (NSString *)buildLocalizedErrorDescriptionFromErrorDictionary:(NSDictionary *)dictionary {
    
    if (![dictionary isKindOfClass:NSDictionary.class])
        return @"";
    
    NSDictionary *errors = dictionary[@"errors"];
    
    if (![errors isKindOfClass:NSDictionary.class])
        return @"";
    
    NSString *errorKey = [errors.allKeys firstObject];
    
    id errorDescription = errors[errorKey];
    
    NSString *errorString = [errorDescription isKindOfClass:[NSArray class]] ? [errorDescription lastObject] : errorDescription;

    return [NSString stringWithFormat:@"%@ %@", errorKey.capitalizedString, errorString];
}

@end
