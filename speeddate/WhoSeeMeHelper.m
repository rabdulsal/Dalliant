//
//  WhoSeeMeHelper.m
//  speeddate
//
//  Created by studio76 on 21.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "WhoSeeMeHelper.h"

@implementation WhoSeeMeHelper
@dynamic WhoSeeUser;
@dynamic WhomSeeUser;
@dynamic userSee;
@dynamic seeUser;

+ (void)load {
    [self registerSubclass];
    
}

+ (NSString *)parseClassName {
    return @"WhoSee";
}

@end
