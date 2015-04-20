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

@end
