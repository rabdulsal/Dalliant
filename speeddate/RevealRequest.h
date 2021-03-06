//
//  RevealRequest.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/17/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <Parse/Parse.h>
#import "UserParseHelper.h"
#import "IdentityRevealDelegate.h"

@interface RevealRequest : PFObject <PFSubclassing>

+ (NSString *)parseClassName;

@property (nonatomic) UserParseHelper *requestFromUser;
@property (nonatomic) UserParseHelper *requestToUser;
@property (nonatomic) NSNumber *requestReply;
@property (nonatomic) NSNumber *requestClosed;
@property (nonatomic) id <IdentityRevealDelegate> identityDelegate;

// Methods
+ (void)getRequestsBetween:(UserParseHelper *)currentUser
                  andMatch:(UserParseHelper *)matchUser
                completion:(void(^)(RevealRequest *outgoingRequest,
                                    RevealRequest *incomingRequest))callback;
- (void)sendShareRequestFromUser:(UserParseHelper *)user toMatch:(UserParseHelper *)matchUser completion:(void(^)(BOOL success))callback;
+ (void)fetchShareRequestWithId:(NSString *)shareRequestId completion:(void(^)(RevealRequest *incomingRequest, BOOL fetched))callback;
+ (void)fetchShareReplyWithId:(NSString *)shareRequestId completion:(void(^)(RevealRequest *incomingReply, BOOL fetched))callback;
- (void)acceptShareRequestWithCompletion:(void(^)(BOOL shared))callback;
- (void)rejectShareRequestWithCompletion:(void(^)(BOOL rejected))callback;
- (void)notifyCurrentUser:(UserParseHelper *)currentUser ofReplyToShareRequestFromMatch:(UserParseHelper *)match;

@end
