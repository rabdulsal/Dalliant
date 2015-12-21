//
//  RevealRequest.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/17/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "RevealRequest.h"
#import <Parse/PFObject+Subclass.h>

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
    self.requestReply    = @"";
    
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFQuery *query = [PFInstallation query];
            [query whereKey:@"objectId" equalTo:matchUser.installation.objectId];
                
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Request to Share Identities", @"alert",
                                    [NSString stringWithFormat:@"%@", matchUser.nickname], @"match",
                                    [NSString stringWithFormat:@"%@", self.objectId], @"requestId", // RequestId for notification userInfo
                                    @"Increment", @"badge",
                                    @"Ache.caf", @"sound",
                                    nil];
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            [push setData:data];
            [push sendPushInBackground];
            
            [identityDelegate shareRequestSentFromUser:user toMatch:matchUser];
            callback(succeeded);
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

- (void)acceptShareRequestWithCompletion:(void (^)(BOOL shared))callback
{
    //Do stuff
    self.requestReply = @"Yes";
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            UserParseHelper *matchUser = self.requestFromUser;
            PFQuery *query = [PFInstallation query];
            [query whereKey:@"objectId" equalTo:matchUser.installation.objectId];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"Identity Share Reply"], @"alert",
                                  [NSString stringWithFormat:@"%@", self.objectId], @"requestId", // RequestId for notification userInfo
                                  @"Increment", @"badge",
                                  @"Ache.caf", @"sound",nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [identityDelegate shareRequestFromMatch:matchUser acceptedByUser:self.requestToUser];
                    callback(succeeded);
                }
            }];
            
        }
    }];
    
}

- (void)rejectShareRequestWithCompletion:(void (^)(BOOL))callback
{
    // Do stuff
    self.requestReply = @"No";
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (succeeded) {
            UserParseHelper *matchUser = self.requestFromUser;
            PFQuery *query = [PFInstallation query];
            [query whereKey:@"objectId" equalTo:matchUser.installation.objectId];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"Identity Share Reply"], @"alert",
                                  [NSString stringWithFormat:@"%@", self.objectId], @"requestId",
                                  @"Increment", @"badge",
                                  @"Ache.caf", @"sound",nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [identityDelegate shareRequestFromMatch:matchUser rejectedByUser:self.requestToUser];
                    callback(succeeded);
                }
            }];
            
        }
    }];
    
}

@end
