//
//  PossibleMatch.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "PossibleMatchHelper.h"

@implementation PossibleMatchHelper
@dynamic fromUser;
@dynamic toUser;
@dynamic fromUserEmail;
@dynamic toUserEmail;
@dynamic toUserApproved;
@dynamic match;
@dynamic prefCounter;
@dynamic totalPrefs;
@dynamic compatibilityIndex;
@dynamic usersRevealed;
@dynamic matches;
@dynamic chatMessages;
@dynamic messagesCount;
@dynamic toUserRating;
@dynamic fromUserRating;
@dynamic toUserRedeem;
@dynamic fromUserRedeem;
@synthesize toUserShareState;
@synthesize toUserRequestState;
@synthesize fromUserRequestState;
@synthesize fromUserShareState;
@dynamic rvStString;
@dynamic rqStString;

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"PossibleMatch";
}

- (void)calculateCompatibility:(double)prefCounter with:(double)totalPreferences
{
    //NSNumber *indexCalculation = @20.1;
    
    double indexCalculation = (prefCounter / totalPreferences)*100;
    self.compatibilityIndex = [NSNumber numberWithDouble:(indexCalculation)];
    //return *(self.compatibilityIndex);
}

- (void)setHighCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor   = RED_DEEP;
    newTheme.incompletedColor = RED_LIGHT;
    newTheme.centerColor      = RED_OMNY;
}

- (void)setMedCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor   = [UIColor colorWithRed:0.8 green:0.8 blue:0 alpha:1.0];
    newTheme.incompletedColor = [UIColor colorWithRed:0.9 green:0.9 blue:0 alpha:1.0];
    //newTheme.centerColor        = YELLOW_COLOR;
    newTheme.centerColor      = [UIColor colorWithRed:1 green:1 blue:0.6 alpha:1];
}

- (void)setLowCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor   = [UIColor darkGrayColor];
    newTheme.incompletedColor = [UIColor lightGrayColor];
    newTheme.centerColor      = GRAY_COLOR;
}

- (void)configureRadialViewForView:(UIView *)view withFrame:(CGRect)frame
{
    MDRadialProgressTheme *newTheme = [[MDRadialProgressTheme alloc] init];
    //newTheme.completedColor = [UIColor colorWithRed:90/255.0 green:212/255.0 blue:39/255.0 alpha:1.0];
    
    //newTheme.incompletedColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
    newTheme.centerColor = [UIColor clearColor];
    //[self setHighCompatibilityColor:newTheme];
    NSInteger compatibility = [self.compatibilityIndex integerValue];
    // Compatibility conditional
    if (compatibility > 66) {
        [self setHighCompatibilityColor:newTheme];
    } else if (compatibility < 66 && compatibility > 33) {
        [self setMedCompatibilityColor:newTheme];
    } else [self setLowCompatibilityColor:newTheme];
    
    newTheme.sliceDividerHidden = YES;
    newTheme.labelColor = [UIColor blackColor];
    newTheme.labelShadowColor = [UIColor whiteColor];
    
    
    MDRadialProgressView *radialView7 = [[MDRadialProgressView alloc] initWithFrame:frame andTheme:newTheme];
    radialView7.progressTotal   = [self.totalPrefs integerValue];
    radialView7.progressCounter = [self.prefCounter integerValue];
    //[self.view addSubview:radialView7];
    [view addSubview:radialView7];
}

- (void)addChatMessageToConveration:(MessageParse *)message
{
    /* --- Method not working, breaks messaging logic -- */
    PFRelation *conversations = [self relationForKey:@"chatMessages"];
    [conversations addObject:message];
    [self saveInBackground];
}

- (NSString *)calculateUserDistance
{
    UserParseHelper *toUser     = (UserParseHelper *)[self.toUser fetchIfNeeded];
    UserParseHelper *fromUser   = (UserParseHelper *)[self.fromUser fetchIfNeeded];
    NSString *distanceOutput;
    
    double distanceDouble   = [fromUser.geoPoint distanceInMilesTo:toUser.geoPoint];
    //_userDistance.text      = [[NSString alloc]initWithFormat:@"%@", [NSNumber numberWithDouble:distanceDouble]];
    if (distanceDouble < 0.3) {
        distanceOutput = @"5 min walk";
    } else if (distanceDouble > 0.6) {
        distanceOutput = @"15 min walk";
    } else distanceOutput = @"10 min walk";
    
    return distanceOutput;
    
    NSLog(@"%@ GeoPoint: %@ | %@ GeoPoint: %@",self.toUser.nickname, self.toUser.geoPoint, self.fromUser.nickname, self.fromUser.geoPoint); //
}

- (void)compareUser:(NSArray *)userInterests andMatchInterests:(NSArray *)matchInterests forImages:(UIImageView *)image1 and:(UIImageView *)image2 and:(UIImageView *)image3 and:(UIImageView *)image4 andFinally:(UIImageView *)image5
{
    NSMutableArray *mutualInterests = [NSMutableArray new];
    
    for (NSString *userInterest in userInterests) {
        if ([matchInterests containsObject:userInterest]) {
            [mutualInterests addObject:userInterest];
        }
    }
    
    NSString *interest;
    for (int i = 0; i < [mutualInterests count]; i++) {
        interest = [mutualInterests objectAtIndex:i];
        NSLog(@"Interest count: %lu", (unsigned long)[userInterests count]);
        switch (i) {
            case 0:
                image1.image = [UIImage imageNamed:interest];
                break;
            case 1:
                image2.image = [UIImage imageNamed:interest];
                break;
            case 2:
                image3.image = [UIImage imageNamed:interest];
                break;
            case 3:
                image4.image = [UIImage imageNamed:interest];
                break;
            case 4:
                image5.image = [UIImage imageNamed:interest];
                break;
        }
        
    }
}

- (void)storeShareState:(int)state // Must initialize .UnRevealed
{
    // Set up ShareState conditional for to- or from- User
    self.rvStString = RevealStateString(state);
    [self saveInBackground];
}

- (void)storeRequestState:(int)state // Must initialize
{
    // Set up ShareState conditional for to- or from- User
    self.rqStString = RequestStateString(state);
    [self saveInBackground];
}

#pragma mark - IdentityRevealDelegate

- (void)shareRequestSent {
    [self storeShareState:Requested];
}

- (void)shareRequestAccepted { // Set from Reply Notification, Match Accept User Request
    [self storeShareState:Sharing];
}

- (void)shareRequestRejected { // Set from Reply Notification, Match Rejected User Request
    [self storeShareState:Declined];
}

- (void)acceptedShareRequest { // Accepted incoming Request from Match
    [self storeShareState:Sharing];
}

@end
