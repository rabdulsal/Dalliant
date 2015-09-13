//
//  UserRating.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 4/19/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "UserRating.h"

@implementation UserRating

@dynamic toUser;
@dynamic fromUser;
@dynamic ratingType;
@dynamic badRatingDescription;

+ (void)load {
    [self registerSubclass];
    
}

+ (NSString *)parseClassName {
    return @"UserRating";
}

- (void)giveMatch:(UserParseHelper *)match ratingOf:(NSString *)rating byUser:(UserParseHelper *)user inView:(UIViewController *)view forConnection:(PossibleMatchHelper *)connection because:(NSString *)description
{
    self.toUser               = match;
    self.fromUser             = user;
    self.ratingType           = rating;
    self.badRatingDescription = description;
    
    if ([connection.fromUser isEqual:user]) {
        // User made the Connection
        connection.toUserRating = rating;
    } else connection.fromUserRating = rating;
    
    
    [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [connection saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    [view dismissViewControllerAnimated:NO completion:nil];
                }
            }];
        }
    }];
    
}

- (void)addRating:(NSString *)rating toConnection:(NSArray *)matchPair
{
    // Get the Connection using
}

@end
