//
//  PossibleMatchHelper.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <Parse/Parse.h>
#import "UserParseHelper.h"

@interface PossibleMatchHelper : PFObject <PFSubclassing>
@property (nonatomic, strong) UserParseHelper* fromUser;
@property (nonatomic, strong) UserParseHelper* toUser;
@property NSString* fromUserEmail;
@property NSString* toUserEmail;
@property NSString* toUserApproved;
@property NSString* match;
@property NSArray *matches;
@property NSNumber *prefCounter;
@property NSNumber *totalPrefs;
@property NSNumber *compatibilityIndex;
@property NSNumber *usersRevealed;
@property NSNumber *messagesCount;
@property NSString *toUserRating;
@property NSString *fromUserRating;

- (void)calculateCompatibility:(double)prefCounter with:(double)totalPreferences;
- (void)configureRadialViewForView:(UIView *)view withFrame:(CGRect)frame;
- (NSString *)calculateUserDistance;
- (void)compareUser:(NSArray *)userInterests andMatchInterests:(NSArray *)matchInterests forImages:(UIImageView *)image1 and:(UIImageView *)image2 and:(UIImageView *)image3 and:(UIImageView *)image4 andFinally:(UIImageView *)image5;

@end
