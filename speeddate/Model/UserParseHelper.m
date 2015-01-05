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
@dynamic maxAgePref;
@dynamic minAgePref;

////thumb photo
@dynamic photo_thumb;
@dynamic photo1_thumb;
@dynamic photo2_thumb;
@dynamic photo3_thumb;
@dynamic photo4_thumb;

//// online

@dynamic online;

@dynamic hasKids;
@dynamic drinks;
@dynamic smokes;
@dynamic drugs;
@dynamic bodyArt;
@dynamic bodyType;
@dynamic relationshipType;
@dynamic relationshipStatus;
@dynamic interests;
@dynamic work;
@dynamic school;

// Filters
@dynamic genderPref;
@dynamic romanticPreference;
@dynamic relationshipStatusPref;
@dynamic kidsOkay;
@dynamic bodyArtOkay;
@dynamic drinkingOkay;
@dynamic drugsOkay;
@dynamic smokingOkay;

// Preferences
@dynamic animalsPref;
@dynamic artsPref;
@dynamic bodyTypePref;
@dynamic beerPref;
@dynamic bookClubPref;
@dynamic cookingPref;
@dynamic dancingPref;
@dynamic diningOutPref;
@dynamic hikingPref;
@dynamic lecturesPref;
@dynamic musicConcertsPref;
@dynamic operaPref;
@dynamic religiousPref;
@dynamic sportsPref;
@dynamic techPref;
@dynamic travelPref;
@dynamic volunteerPref;
@dynamic moviesPref;
@dynamic workoutPref;

@dynamic totalPreferences;

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

- (NSString *)userWork
{
    return [self.work objectAtIndex:0][@"employer"][@"name"];
    
}

- (NSString *)userSchool
{
    return [self.school objectAtIndex:0][@"school"][@"name"];
}

@end
