//
//  PossibleMatchHelper.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <Parse/Parse.h>
#import "UserParseHelper.h"
#import <MDRadialProgressLabel.h>
#import <MDRadialProgressTheme.h>
#import <MDRadialProgressView.h>
#import "MessageParse.h"
#import "IdentityRevealDelegate.h"

typedef enum {UnRevealed, Requested, Sharing, Declined} ShareState; //
#define RevealStateString(enum) [@[@"UnRevealed",@"Requested",@"Revealed",@"Declined"] objectAtIndex:enum] // NSString *state = RevealStateString(UnRevealed);

typedef enum {RequestWaiting, ReplyWaiting} RequestState; // For MessageVC to determine indicator display
#define RequestStateString(enum) [@[@"RequestWaiting",@"ReplyWaiting"] objectAtIndex:enum] // NSString *state = RequestStateString(RequestWaiting);

@interface PossibleMatchHelper : PFObject <PFSubclassing, IdentityRevealDelegate>
@property (nonatomic, strong) UserParseHelper* fromUser;
@property (nonatomic, strong) UserParseHelper* toUser;
@property NSString* fromUserEmail;
@property NSString* toUserEmail;
@property NSString* toUserApproved;
@property NSString* match;
@property NSArray *matches;
@property NSArray *chatMessages;
@property NSNumber *prefCounter;
@property NSNumber *totalPrefs;
@property NSNumber *compatibilityIndex;
@property NSNumber *usersRevealed;
@property NSNumber *messagesCount;
@property NSString *toUserRating;
@property NSString *fromUserRating;
@property NSNumber *toUserRedeem;
@property NSNumber *fromUserRedeem;
@property ShareState *toUserShareState;
@property RequestState *toUserRequestState;
@property ShareState *fromUserShareState;
@property RequestState *fromUserRequestState;
@property NSString *rvStString;
@property NSString *rqStString;

- (void)calculateCompatibility:(double)prefCounter with:(double)totalPreferences;
- (void)configureRadialViewForView:(UIView *)view withFrame:(CGRect)frame;
- (void)addChatMessageToConveration:(MessageParse *)message;
- (NSString *)calculateUserDistance;
- (void)compareUser:(NSArray *)userInterests andMatchInterests:(NSArray *)matchInterests forImages:(UIImageView *)image1 and:(UIImageView *)image2 and:(UIImageView *)image3 and:(UIImageView *)image4 andFinally:(UIImageView *)image5;
- (void)storeShareState:(int)state;
- (void)storeRequestState:(int)state;

@end
