//
//  UserParseHelper.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "UserParseHelper.h"
#import "ProgressHUD.h"

@implementation UserParseHelper

@dynamic age;
@dynamic userHeightFeet;
@dynamic userHeightInches;
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
@dynamic credits;
@dynamic blockedUsers;
@dynamic blockedBy;

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

- (void)configureImage:(UIImage *)image picNumber:(int)photoNum
{
    //[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image,0.9)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [ProgressHUD showError:@"Network error."];
            return ;
        }
        switch (photoNum) {
            case 1:
                self.photo1 = file;
                break;
            case 2:
                self.photo2 = file;
                break;
            case 3:
                self.photo3 = file;
                break;
            case 4:
                self.photo4 = file;
                break;
            default:
                self.photo = file;
                break;
        }
    }];
}

- (void)calculateCredits
{
    self.credits = [NSNumber numberWithInteger:self.credits.intValue +1];
}

- (void)decreaseCredits
{
    self.credits = [NSNumber numberWithInt:self.credits.intValue -1];
}

- (void)blockUser:(NSString *)matchUserId
{
    if ([self.blockedUsers count] == 0 || !self.blockedUsers) {
        self.blockedUsers = [NSMutableArray new];
        [self.blockedUsers addObject:matchUserId];
    } else [self.blockedUsers addObject:matchUserId];
}

- (void)userGeolocationOutput:(UILabel *)locationLabel
{
    CLGeocoder* geocoder = [CLGeocoder new];
    CLLocation* locationz = [[CLLocation alloc]initWithLatitude:[UserParseHelper currentUser].geoPoint.latitude longitude:[UserParseHelper currentUser].geoPoint.longitude];
    [geocoder reverseGeocodeLocation:locationz completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark* placemark = placemarks.firstObject;
        
        locationLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
    }];
}

@end
