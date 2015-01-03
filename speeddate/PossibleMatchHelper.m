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
@dynamic prefMatchCounter;
@dynamic totalPrefs;
@dynamic compatibilityIndex;

+ (void)load {
    [self registerSubclass];
}



+ (NSString *)parseClassName {
    return @"PossibleMatch";
}

- (void)calculateCompatibility:(double)prefCounter with:(double)totalPreferences
{
    //NSNumber *indexCalculation = @20.1;
    /*
    double indexCalculation = (prefCounter / totalPreferences)*100;
    self.compatibilityIndex = &(indexCalculation);*/
    NSLog(@"Calculate compatibility run");
}

@end
