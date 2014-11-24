//
//  User.h
//  Firechat
//
//  Created by Rashad Abdul-Salaam on 9/6/14.
//  Copyright (c) 2014 Firebase. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface User : NSObject <CLLocationManagerDelegate>

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *userRef;
@property (strong, nonatomic) NSString *userImage;
@property (strong, nonatomic) CLLocation *location;

// Profile -------------------------------------------------

//Old
@property (strong, nonatomic) NSString *blurb;
@property (strong, nonatomic) NSString *age;
@property (strong, nonatomic) NSString *height;
@property (strong, nonatomic) NSString *favActivity;
@property (strong, nonatomic) NSString *likeToDrink;
@property (strong, nonatomic) NSString *haveKids;
@property (strong, nonatomic) NSString *hasTatoos;
@property (strong, nonatomic) NSString *smokesCigs;
@property (strong, nonatomic) NSString *usesDrugs;

//New
@property (assign, nonatomic) BOOL *hasKids;
@property (assign, nonatomic) BOOL *drinks;
@property (assign, nonatomic) BOOL *smokes;
@property (assign, nonatomic) BOOL *drugs;
@property (assign, nonatomic) BOOL *bodyArt;
@property (strong, nonatomic) NSString *bodyType;
@property (strong, nonatomic) NSString *relationshipType;
@property (strong, nonatomic) NSString *relationshipStatus;

// ----------------------------------------------------------

// Filters -------------------------------------------------

// Old
@property (strong, nonatomic) NSString *fireBaseRef;
@property (strong, nonatomic) NSString *kidsPref;
@property (strong, nonatomic) NSString *tatooPref;
@property (strong, nonatomic) NSString *drinkingPref;
@property (strong, nonatomic) NSString *minAgePref;
@property (strong, nonatomic) NSString *maxAgePref;
@property (assign, nonatomic) NSString *bodyTypePref;
@property (strong, nonatomic) NSString *minHeightPref;
@property (strong, nonatomic) NSString *maxHeightPref;

// New
@property (strong, nonatomic) NSString *genderPref;
@property (strong, nonatomic) NSString *romanticPreference;
@property (strong, nonatomic) NSString *relationshipStatusPref;
@property (assign, nonatomic) BOOL *kidsOkay;
@property (assign, nonatomic) BOOL *bodyArtOkay;
@property (assign, nonatomic) BOOL *drinkingOkay;
@property (assign, nonatomic) BOOL *drugsOkay;
@property (assign, nonatomic) BOOL *smokingOkay;

// Preferences -------------------------------------------------

@property (assign, nonatomic) BOOL *animalsPref;
@property (assign, nonatomic) BOOL *artsPref;
@property (assign, nonatomic) BOOL *beerPref;
@property (assign, nonatomic) BOOL *bookClubPref;
@property (assign, nonatomic) BOOL *cookingPref;
@property (assign, nonatomic) BOOL *dancingPref;
@property (assign, nonatomic) BOOL *diningOutPref;
@property (assign, nonatomic) BOOL *hikingPref;
@property (assign, nonatomic) BOOL *lecturesPref;
@property (assign, nonatomic) BOOL *musicConcertsPref;
@property (assign, nonatomic) BOOL *operaPref;
@property (assign, nonatomic) BOOL *religiousPref;
@property (assign, nonatomic) BOOL *sportsPref;
@property (assign, nonatomic) BOOL *techPref;
@property (assign, nonatomic) BOOL *travelPref;
@property (assign, nonatomic) BOOL *volunteerPref;
@property (assign, nonatomic) BOOL *moviesPref;
@property (assign, nonatomic) BOOL *workoutPref;

+(User *)singleObj;

-(id)initWithName:(NSString *)aName lastName:(NSString *)aLastName gender:(NSString *)aGender;

@end
