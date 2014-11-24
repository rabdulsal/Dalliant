//
//  UserParseHelper.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "UserParseHelper.h"

@implementation UserParseHelper

@dynamic age;
@dynamic photo;
@dynamic photo1;
@dynamic photo2;
@dynamic photo3;
@dynamic photo4;
@dynamic isMale;
@dynamic desc;
@dynamic sexuality;
@dynamic matches;
@dynamic distance;
@dynamic address;
@dynamic geoPoint;
@dynamic report;
@dynamic useAddress;
@dynamic installation;
@dynamic nickname;
@dynamic membervip;

////thumb photo
@dynamic photo_thumb;
@dynamic photo1_thumb;
@dynamic photo2_thumb;
@dynamic photo3_thumb;
@dynamic photo4_thumb;

//// online

@dynamic online;

+ (void)load {
    [self registerSubclass];
    
}

- (NSUInteger)hash
{
    return self.objectId.intValue;
}

- (BOOL)isEqual:(UserParseHelper *)user
{
    return [self.objectId isEqualToString:user.objectId];
}

@end
