//
//  UserParseHelper.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <Parse/Parse.h>

@interface UserParseHelper : PFUser <PFSubclassing>
@property NSNumber* age;
@property NSString* isMale;
@property PFFile* photo;
@property PFFile* photo1;
@property PFFile* photo2;
@property PFFile* photo3;
@property PFFile* photo4;
@property NSString *desc;
@property NSNumber *distance;
@property NSNumber* sexuality;
@property NSMutableArray* matches;
@property NSString* address;
@property PFGeoPoint* geoPoint;
@property NSNumber *report;
@property NSString* useAddress;
@property PFInstallation *installation;
@property NSString *nickname;
@property NSString *membervip;

////thumb_photo
@property PFFile* photo_thumb;
@property PFFile* photo1_thumb;
@property PFFile* photo2_thumb;
@property PFFile* photo3_thumb;
@property PFFile* photo4_thumb;

/// online
@property NSString *online;

@end
