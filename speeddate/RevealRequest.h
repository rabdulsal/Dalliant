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
@property (nonatomic) NSString *requestReply;
@property (nonatomic) NSNumber *requestClosed;
@property (nonatomic) id <IdentityRevealDelegate> identityDelegate;

// Methods
- (void)sendShareRequestFromUser:(UserParseHelper *)user toMatch:(UserParseHelper *)matchUser completion:(void(^)(BOOL success))callback;
+ (void)fetchShareRequestWithId:(NSString *)shareRequestId completion:(void(^)(RevealRequest *incomingRequest, BOOL fetched))callback;
+ (void)fetchShareReplyWithId:(NSString *)shareRequestId completion:(void(^)(RevealRequest *incomingReply, BOOL fetched))callback;
- (void)acceptShareRequestWithCompletion:(void(^)(BOOL shared))callback;
- (void)rejectShareRequestWithCompletion:(void(^)(BOOL rejected))callback;

@end
