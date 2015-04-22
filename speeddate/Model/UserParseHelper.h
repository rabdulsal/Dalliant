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
@property NSString *userHeightFeet;
@property NSString *userHeightInches;
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
@property NSMutableArray *work;
@property NSMutableArray *school;
@property NSNumber *credits;
@property NSNumber *goodRating;
@property NSNumber *badRating;
@property NSMutableArray *blockedUsers;
@property NSMutableArray *blockedBy;
@property NSNumber *reportCount;

////thumb_photo
@property PFFile* photo_thumb;
@property PFFile* photo1_thumb;
@property PFFile* photo2_thumb;
@property PFFile* photo3_thumb;
@property PFFile* photo4_thumb;

/// online
@property NSString *online;

// New Dalliant Attributes -----------------------------------

// Profile
@property NSNumber *hasKids;
@property NSNumber *drinks;
@property NSNumber *smokes;
@property NSNumber *drugs;
@property NSNumber *bodyArt;
@property NSString *bodyType;
@property NSString *relationshipType;
@property NSString *relationshipStatus;
@property NSArray *interests;

// Filter
@property NSString *genderPref;
@property NSNumber *minAgePref;
@property NSNumber *maxAgePref;
@property NSString *bodyTypePref;
@property NSString *romanticPreference;
@property NSString *relationshipStatusPref;
@property NSNumber *kidsOkay;
@property NSNumber *bodyArtOkay;
@property NSNumber *drinkingOkay;
@property NSNumber *drugsOkay;
@property NSNumber *smokingOkay;

// Preferences
@property NSNumber *animalsPref;
@property NSNumber *artsPref;
@property NSNumber *beerPref;
@property NSNumber *bookClubPref;
@property NSNumber *cookingPref;
@property NSNumber *dancingPref;
@property NSNumber *diningOutPref;
@property NSNumber *hikingPref;
@property NSNumber *lecturesPref;
@property NSNumber *musicConcertsPref;
@property NSNumber *operaPref;
@property NSNumber *religiousPref;
@property NSNumber *sportsPref;
@property NSNumber *techPref;
@property NSNumber *travelPref;
@property NSNumber *volunteerPref;
@property NSNumber *moviesPref;
@property NSNumber *workoutPref;

@property int *totalPreferences;

- (NSString *)userWork;
- (NSString *)userSchool;
- (void)configureImage:(UIImage *)image picNumber:(int)photoNum;
- (void)increaseCreditsBy:(int)points;
- (void)decreaseCreditsBy:(int)points;
- (void)blockUser:(NSString *)matchUser;
- (void)userGeolocationOutput:(UILabel *)locationLabel;

@end
