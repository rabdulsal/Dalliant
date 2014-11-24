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

+ (void)load {
    [self registerSubclass];
}



+ (NSString *)parseClassName {
    return @"PossibleMatch";
}

@end
