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

- (void)sendShareRequestFromUser:(UserParseHelper *)user toMatch:(UserParseHelper *)matchUser completion:(void(^)(BOOL *success))callback
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
            callback(&succeeded);
        }
    }];
    
}

- (void)acceptShareRequest:(NSString *)shareRequestId
{
    //Do stuff
    
    [identityDelegate revealRequestAccepted];
}

- (void)rejectRevealRequest
{
    // Do stuff
    
    [identityDelegate revealRequestRejected];
}

@end
