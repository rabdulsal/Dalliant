//
//  RevealRequest.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/17/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "RevealRequest.h"
#import <Parse/PFObject+Subclass.h>
#import "speeddate-Swift.h"

@implementation RevealRequest

@dynamic requestFromUser;
@dynamic requestToUser;
@dynamic requestReply;
@dynamic requestClosed;
@synthesize identityDelegate;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"RevealRequest";
}

#pragma mark - Class Fetch Methods
+ (void)getRequestsBetween:(UserParseHelper *)currentUser
                  andMatch:(UserParseHelper *)matchUser
                completion:(void(^)(RevealRequest * _Nullable outgoingRequest,
                                    RevealRequest * _Nullable incomingRequest))callback
{
    PFQuery *requestFromQuery = [[self class] query];
    [requestFromQuery whereKey:@"requestFromUser" equalTo:currentUser];
    [requestFromQuery whereKey:@"requestToUser" equalTo:matchUser];
    
    PFQuery *requestToQuery = [[self class] query];
    [requestToQuery whereKey:@"requestToUser" equalTo:currentUser];
    [requestToQuery whereKey:@"requestFromUser" equalTo:matchUser];
    
    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:@[requestFromQuery, requestToQuery]];
    [orQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
     
        if (!error) {
            if (objects.count > 0) {
                for (RevealRequest *request in objects) {
                    UserParseHelper *fromRequestUser = (UserParseHelper *)[request.requestFromUser fetchIfNeeded];
                    UserParseHelper *toRequestUser = (UserParseHelper *)[request.requestToUser fetchIfNeeded];
                    
                    if ([fromRequestUser isEqual:currentUser]) {
                        callback(request, nil);
                    } else if ([toRequestUser isEqual:currentUser]) {
                        callback(nil, request);
                    }
                }
            } else {
                callback(nil,nil);
            }
        } else {
            // Handle error
        }
    }];
}


+ (void)fetchShareRequestWithId:(NSString *)shareRequestId completion:(void(^)(RevealRequest *incomingRequest, BOOL fetched))callback
{
    PFQuery *request = [[self class] query];
    [request getObjectInBackgroundWithId:shareRequestId block:^(PFObject *object, NSError *error) {
        
        if (!error) {
            callback((RevealRequest *)object, (BOOL)true);
        }
    }];
}

+ (void)fetchShareReplyWithId:(NSString *)shareRequestId completion:(void(^)(RevealRequest *incomingReply, BOOL fetched))callback
{
    PFQuery *request = [[self class] query];
    [request getObjectInBackgroundWithId:shareRequestId block:^(PFObject *object, NSError *error) {
        
        if (!error) {
            callback((RevealRequest *)object, true);
        }
    }];
}

#pragma mark - Request Update Methods

- (void)notifyCurrentUser:(UserParseHelper *)currentUser ofReplyToShareRequestFromMatch:(UserParseHelper *)match
{
    if ([self.requestReply isEqualToNumber:[NSNumber numberWithBool:NO]] &&
        ![self.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        [identityDelegate currentUserShareRequest:currentUser rejectedByMatch:match];
    }
    else if ([self.requestReply isEqualToNumber:[NSNumber numberWithBool:YES]] &&
             ![self.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])
    {
        [identityDelegate currentUserShareRequest:currentUser acceptedByMatch:match];
    }
    
}

#pragma mark - Instance Action Methods

- (void)sendShareRequestFromUser:(UserParseHelper *)user toMatch:(UserParseHelper *)matchUser completion:(void(^)(BOOL success))callback
{
    //Do stuff
    /*
    RevealRequest *revealRequest  = [RevealRequest object];
    revealRequest.requestFromUser = user;
    revealRequest.requestToUser   = matchUser;
    revealRequest.requestReply    = @"";
    */
    self.requestFromUser = user;
    self.requestToUser   = matchUser;
    //self.requestReply    = @"";
    
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            [self sendPushNotificationTo:matchUser withRequestType:RequestTypeShareRequest andCompletionBlock:^(PushNotificationManager *pushNotification) {
                [pushNotification sendShareRequestPushNotificationToUser:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        [identityDelegate shareRequestSentFromUser:user toMatch:matchUser];
                        callback(succeeded);
                    } else {
                        // Handle Error
                    }
                }];
            }];
        }
    }];
}

- (void)acceptShareRequestWithCompletion:(void (^)(BOOL shared))callback
{
    //Do stuff
    self.requestReply = [NSNumber numberWithBool:YES];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            UserParseHelper *matchUser = self.requestFromUser;
            
            [self sendPushNotificationTo:matchUser
                         withRequestType:RequestTypeShareReply
                      andCompletionBlock:^(PushNotificationManager *pushNotification) {
                [pushNotification sendShareRequestPushNotificationToUser:^(BOOL success, NSError * _Nullable error) {
                    if (success) {
                        [identityDelegate shareRequestFromMatch:matchUser acceptedByUser:self.requestToUser];
                        callback(succeeded);
                    } else {
                        // Handle Error
                    }
                }];
            }];
        }
    }];
}

- (void)sendPushNotificationTo:(UserParseHelper *)match
               withRequestType:(RequestType)requestType
            andCompletionBlock:(void (^)(PushNotificationManager *pushNotification))completion
{
    PushNotificationManager *pushNotification = [[PushNotificationManager alloc] initWithMatchName:match.nickname
                                                                             matchId:match.objectId
                                                                      installationId:match.installation.objectId
                                                                           requestId:self.objectId
                                                                         requestType:requestType];
    
    completion(pushNotification);
}

- (void)rejectShareRequestWithCompletion:(void (^)(BOOL))callback
{
    // Do stuff
    self.requestReply = [NSNumber numberWithBool:NO];
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            UserParseHelper *matchUser = self.requestFromUser;
            [self sendPushNotificationTo:matchUser
                         withRequestType:RequestTypeShareReply
                      andCompletionBlock:^(PushNotificationManager *pushNotification) {
                [pushNotification sendShareRequestPushNotificationToUser:^(BOOL success, NSError * _Nullable error) {
                    if (success) callback(succeeded);
                    else callback(error); // TODO: Ensure works!!!
                }];
            }];
        }
    }];    
}

@end
