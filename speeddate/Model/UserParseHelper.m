//
//  UserParseHelper.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "UserParseHelper.h"
#import "ProgressHUD.h"
#import "MessageParse.h"
#import "PossibleMatchHelper.h"
#import "RevealRequest.h"

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
@dynamic allConnections;
@dynamic allMessages;
@dynamic allRevealRequests;
@dynamic revealState;
@dynamic requestState;

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

- (void)storeRevealState:(RevealState *)state
{
    self.revealState = state;
    self.rvStString = RevealStateString((unsigned long)self.revealState);
    [self saveInBackground];
}

- (void)storeRequestState:(RequestState *)state
{
    self.requestState = state;
    self.rqStString = RequestStateString((unsigned long)self.requestState);
    [self saveInBackground];
}

- (void)increaseCreditsBy:(int)points
{
    self.credits = [NSNumber numberWithInteger:self.credits.intValue + points];
}

- (void)decreaseCreditsBy:(int)points
{
    self.credits = [NSNumber numberWithInt:self.credits.intValue - points];
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
    CLLocation* locationz = [[CLLocation alloc]initWithLatitude:[UserParseHelper currentUser].geoPoint.latitude
                                                      longitude:[UserParseHelper currentUser].geoPoint.longitude];
    [geocoder reverseGeocodeLocation:locationz completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark* placemark = placemarks.firstObject;
        
        locationLabel.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
    }];
}

- (void)getAllConnections
{
    PFQuery *unRatedConnectionsFromMe = [PossibleMatchHelper query];
    [unRatedConnectionsFromMe whereKey:@"fromUser" equalTo:self];
    PFQuery *unRatedConnectionsToMe = [PossibleMatchHelper query];
    [unRatedConnectionsToMe whereKey:@"toUser" equalTo:self];
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[unRatedConnectionsFromMe, unRatedConnectionsToMe]];
    [both orderByDescending:@"createdAt"];
    [both findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        self.allConnections = objects;
    }];
}

- (void)getAllMessages
{
    PFQuery *messageQueryFrom = [MessageParse query];
    [messageQueryFrom whereKey:@"fromUserParse" equalTo:self];
    PFQuery *messageQueryTo = [MessageParse query];
    [messageQueryTo whereKey:@"toUserParse" equalTo:self];
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[messageQueryFrom, messageQueryTo]];
    [both orderByDescending:@"createdAt"];
    [both findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
       
        self.allMessages = objects;
    }];
}

- (void)getAllRevealRequests
{
    PFQuery *requestFromQuery = [RevealRequest query];
    [requestFromQuery whereKey:@"requestFromUser" equalTo:self];
    PFQuery *requestToQuery = [RevealRequest query];
    [requestToQuery whereKey:@"requestToUser" equalTo:self];
    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:@[requestFromQuery, requestToQuery]];
    [orQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.allRevealRequests = objects;
    }];
    
}

- (void)deleteAllUserData
{
    /*
    self.allRevealRequests  = [NSArray new];
    self.allConnections     = [NSArray new];
    self.allMessages        = [NSArray new];
    */
    [self getAllConnections];
    [self getAllMessages];
    [self getAllRevealRequests];
    
    // Get all Relationships & Delete
    for (PossibleMatchHelper *connection in self.allConnections) {
        [connection deleteInBackground];
    }
    // Get all Messages & Delete
    for (PossibleMatchHelper *message in self.allMessages) {
        [message deleteInBackground];
    }
    
    // Get all RevealRequests & Delete
    for (PossibleMatchHelper *request in self.allRevealRequests) {
        [request deleteInBackground];
    }
    
    // Delete User
    [self deleteInBackground];
    
}
/*
- (void)calculateDistanceBetweenUser:(UserParseHelper *)currentUser andMatch:(UserParseHelper *)match
{
     double distanceDouble   = [match.geoPoint distanceInMilesTo:currentUser.geoPoint];
     //_userDistance.text      = [[NSString alloc]initWithFormat:@"%@", [NSNumber numberWithDouble:distanceDouble]];
     _userDistance.text    = [[NSString alloc] initWithFormat:@"%f", distanceDouble];
     NSLog(@"%@ GeoPoint: %@ | %@ GeoPoint: %@",_matchUser.nickname, _matchUser.geoPoint, _curUser.nickname, _curUser.geoPoint);
     
}
*/
@end
