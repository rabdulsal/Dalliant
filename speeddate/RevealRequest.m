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

- (void)sendShareRequestFromUser:(UserParseHelper *)user toMatch:(UserParseHelper *)matchUser completion:(void(^)(BOOL success))callback
{
    //Do stuff
    RevealRequest *revealRequest  = [RevealRequest object];
    revealRequest.requestFromUser = user;
    revealRequest.requestToUser   = matchUser;
    revealRequest.requestReply    = @"";
    
    [revealRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            PFQuery *query = [PFInstallation query];
            [query whereKey:@"objectId" equalTo:matchUser.installation.objectId];
                
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                    @"Request to Share Identities", @"alert",
                                    [NSString stringWithFormat:@"%@", matchUser.nickname], @"match",
                                    /*[NSString stringWithFormat:@"%@", _matchedUsers], @"relationship",*/
                                    @"Increment", @"badge",
                                    @"Ache.caf", @"sound",
                                    nil];
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            [push setData:data];
            [push sendPushInBackground];
            
            [identityDelegate revealRequestSent];
            callback(succeeded);
        }
    }];
    
}

- (void)fetchShareRequestWithId:(NSString *)shareRequestId completion:(void(^)(RevealRequest *incomingRequest, BOOL fetched))callback
{
    PFQuery *request = [RevealRequest query];
    [request getObjectInBackgroundWithId:shareRequestId block:^(PFObject *object, NSError *error) {
        
        if (!error) {
            callback((RevealRequest *)object, (BOOL *)true);
        }
    }];
}

- (void)fetchShareReplyWithId:(NSString *)shareRequestId completion:(void(^)(RevealRequest *incomingReply, BOOL fetched))callback
{
    PFQuery *request = [RevealRequest query];
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
                                  @"Increment", @"badge",
                                  @"Ache.caf", @"sound",nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [identityDelegate revealRequestAccepted];
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
                                  @"Increment", @"badge",
                                  @"Ache.caf", @"sound",nil];
            
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            [push setData:data];
            [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [identityDelegate revealRequestRejected];;
                    callback(succeeded);
                }
            }];
            
        }
    }];
    
}

@end
