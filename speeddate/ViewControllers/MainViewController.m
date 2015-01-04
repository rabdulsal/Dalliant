//
//  MainViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

/* ----------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 
 *** TINDER-LIKE SWIPING GAME
 
 *** INCLUDES BAEDAR WAVE ANIMATION AND PUSH TO MATCH_VIEW_CONTROLLER
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */

#import "MainViewController.h"
#import "SWRevealViewController.h"
#import "UserParseHelper.h"
#import "PossibleMatchHelper.h"
#import "MessageParse.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MessagesViewController.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "GADInterstitial.h"
#import "config.h"
#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "RageIAPHelper.h"
#import "User.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define labelHeight 20
#define labelCushion 20
#define MARGIN 50
#define imageMargin 10
#define imageMarginOld 40
#define buttonWidth 40
#define buttonHeight 50
#define cardBorder 1.0f
#define boundaryBackground 8
#define secondBackground 7
#define firstBackground 6
#define currentProfileView 5
#define currentProfileImage 4
#define profileViewTag 3
#define likeViewTag 2
#define dislikeViewTag 1
#define topMarginView 60
#define cornRadius 0

@interface MainViewController () <UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate>{
    
    BOOL inAnimation;
    CALayer *waveLayer;
    NSTimer *animateTimer;
    User *user;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (strong, nonatomic) UIView *profileView;
@property (strong, nonatomic) UIView* backgroundView;
@property (strong, nonatomic) UIView* firstBox;
@property (strong, nonatomic) UIView* secondBox;
@property UserParseHelper* currShowingProfile;
@property UserParseHelper* backgroundUserProfile;

// Matches Arrays -----------------------------------------

@property NSMutableArray *posibleMatchesArray;
@property NSMutableArray* willBeMatches;

// --------------------------------------------------------
@property (strong, nonatomic) UIImageView* profileImage;
@property (strong, nonatomic) UIImageView* profileImageAge;
@property (strong, nonatomic) UIImageView* profileImageLocation;
@property (strong, nonatomic) UIImageView* backgroundImage;
@property (strong, nonatomic) UIImageView* backgroundImageAge;
@property (strong, nonatomic) UIImageView* backgroundImageLocation;
@property NSMutableArray* arrayOfPhotoDataForeground;
@property NSMutableArray* arrayOfPhotoDataBackground;
@property (strong, nonatomic) UILabel* foregroundLabel;
@property (strong, nonatomic) UILabel* backgroundLabel;
@property (strong, nonatomic) UILabel* foregroundLabelAge;
@property (strong, nonatomic) UILabel* backgroundLabelAge;
@property (strong, nonatomic) UILabel* foregroundLabelLocation;
@property (strong, nonatomic) UILabel* backgroundLabelLocation;
@property (strong, nonatomic) UILabel* foregroundDescriptionLabel;
@property (strong, nonatomic) UILabel* backgroundDescriptionLabel;
@property BOOL firstTime;
@property BOOL isRotating;
@property int photoArrayIndex;
@property CLLocationManager* locationManager;
@property CLLocation* currentLocation;
@property NSNumber* milesAway;
@property UIImageView* background;
@property (weak, nonatomic) IBOutlet UIButton *dislikeButton;
@property (weak, nonatomic) IBOutlet UIButton *cyclePhotosButton;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property UserParseHelper* curUser;
@property UIImage *userPhoto;
@property UIImage *matchPhoto;
@property (weak, nonatomic) IBOutlet UITextView *activityLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property UILabel* imageCountLabel;
@property PossibleMatchHelper *otherUser;
@property double prefCounter;
@property double totalPrefs; //<-- should be attribute on UserParseHelper

@property (weak, nonatomic) IBOutlet UIButton *baedarLabel;
- (IBAction)toggleBaedar:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *matchButtonLabel;
- (IBAction)pressedMatchButton:(id)sender;

@property (nonatomic,retain) UIView *bannerView;

@property (strong) NSDictionary *match;
@property (strong) NSMutableArray *sharedPrefs;

@end

@implementation MainViewController

-(void)dealloc{
    
    _adBanner.delegate = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#if (TARGET_IPHONE_SIMULATOR)

#else
    [UserParseHelper currentUser].installation = [PFInstallation currentInstallation];
    [[UserParseHelper currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
    }];

#endif
    user = [User singleObj];
    
    _matched = false;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.view.frame];
    iv.image = [UIImage imageNamed:@"match"];
    
    [self.activityIndicator startAnimating];
    PFQuery* curQuery = [UserParseHelper query];
    [curQuery whereKey:@"username" equalTo:[UserParseHelper currentUser].username];
    [curQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.curUser = objects.firstObject;
        [self.curUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.userPhoto = [UIImage imageWithData:data];
        }];
        if (self.curUser.geoPoint != nil) { // <-- Change to '== nil', and only run 'else'
            //[self getMatches];
            //[self performSegueWithIdentifier:@"viewMatches" sender:nil];
        } else {
            [self currentLocationIdentifier];
        }
    }];


    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    self.posibleMatchesArray = [NSMutableArray new];
    self.willBeMatches = [NSMutableArray new];
    self.photoArrayIndex = 1;
    self.firstTime = YES;
    self.isRotating = YES;
    //self.view.backgroundColor = RED_LIGHT;
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"match"]];
    
    [_matchButtonLabel setHidden:YES];
    
    self.navigationController.navigationBar.barTintColor = RED_LIGHT;
    self.navigationItem.title = @"Speed Dating";
    inAnimation = NO;
    
    // Circle Animation <-- wrap in Toggle Button
    waveLayer=[CALayer layer];
    if (IS_IPHONE_5) {
        waveLayer.frame = CGRectMake(155, 220, 10, 10);
    }else{
        waveLayer.frame = CGRectMake(155, 180, 10, 10);
    }
    waveLayer.borderWidth =0.2;
    waveLayer.cornerRadius =5.0;
    [self.view.layer addSublayer:waveLayer];
   
    [waveLayer setHidden:YES];
    
    //[self performSegueWithIdentifier:@"test_match" sender:nil];

}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"Banner adapter class name: %@", bannerView.adNetworkClassName);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"Interstitial adapter class name: %@", interstitial.adNetworkClassName);
}

#pragma mark - Baedar Toggle

- (IBAction)toggleBaedar:(id)sender {
    if (_baedarLabel.isSelected) {
        [self baedarOff];
    } else {
        [self baedarOn];
    }
}

- (void)baedarOn
{
    [self.view.layer addSublayer:waveLayer];
    [waveLayer setHidden:NO];
    [self startAnimation];
    [_baedarLabel setSelected:YES];
    user.baedarIsRunning = true;
    [self getMatches];
    //[self findMatches]; // This must eventually be called later after Matches are made
}

- (void)baedarOff
{
    [_baedarLabel setSelected:NO];
    inAnimation = NO;
    [waveLayer removeFromSuperlayer];
    [waveLayer setHidden:YES];
    user.baedarIsRunning = false;
}

- (IBAction)pressedMatchButton:(id)sender {
    [self performSegueWithIdentifier:@"viewMatches" sender:nil];
}

- (void)findMatches:(NSMutableArray *)matches
{
    [_matchButtonLabel setHidden:NO];
    
    NSString *matchNum = [[NSString alloc] init];
    if ([matches count] == 1) {
        matchNum = @"Match";
    } else matchNum = @"Matches";
    
    NSString *buttonTitle = [[NSString alloc] initWithFormat:@"You have %lu %@! \nClick to view", (unsigned long)[matches count], matchNum];
    [_matchButtonLabel setTitle:buttonTitle forState:UIControlStateNormal];
}

- (void)checkFirstTime
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"first"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"first"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Edit profile" message:@"Please edit your profile before matching" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Edit", nil];
        [av show];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    //[self checkIncomingViewController];
    
    if (user.baedarIsRunning) {
        [self baedarOn];
        NSLog(@"Baedar running");
    } else NSLog(@"Baedar NOT running");
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkFirstTime];
    [self performSelector:@selector(startAnimation) withObject:nil];
    
}

- (void)checkIncomingViewController
{
    NSLog(@"Matched checked");
    
    if (_matched) {
        NSLog(@"Matched run");
        [self performSegueWithIdentifier:@"viewMatches" sender:nil];
    }
}

#pragma mark - LOCATION IDENTIFIER

-(void)currentLocationIdentifier
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    [self.locationManager stopUpdatingLocation];
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:locations.firstObject completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark* placemark = placemarks.firstObject;
        self.activityLabel.text = [NSString stringWithFormat:@"Locating :\n %@, %@", placemark.locality, placemark.administrativeArea];
        self.activityLabel.textColor = [UIColor whiteColor];
    }];
    [UserParseHelper currentUser].geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    self.curUser.geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    [[UserParseHelper currentUser] saveEventually];
    
    [self getMatches];
    //[self performSegueWithIdentifier:@"viewMatches" sender:nil];
}

#pragma mark - GET MATCHES

- (void)getMatches
{
    /* ---------------- START BLOCK COMMENT
     
    // Fetch PossibleMatch ------------------------------------------------------------------
    
    PFQuery *query = [PossibleMatchHelper query];
    [query whereKey:@"toUser" equalTo:self.curUser];
    [query whereKey:@"match" equalTo:@"YES"];
    [query whereKey:@"toUserApproved" equalTo:@"notDone"]; // May not need this, based on swipe
    
    //
    PFQuery *queryInside = [PossibleMatchHelper query];
    [queryInside whereKey:@"toUser" equalTo:[UserParseHelper currentUser]];
    [queryInside whereKey:@"toUserApproved" equalTo:@"YES"]; // May not need this, based on swipe
    
    // Make sure users returned in queries are not the Current User
    PFQuery* checkQuery = [UserParseHelper query];
    [checkQuery whereKey:@"email" matchesKey:@"fromUserEmail" inQuery:queryInside];
    PFQuery* userQuery = [UserParseHelper query];
    [userQuery whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:checkQuery];
   
    // --------------------------------------------------------------------------------------
    
    // Setting a query distance?
    if (self.curUser.distance.doubleValue == 0.0) {
        self.curUser.distance = [NSNumber numberWithInt:100];
    }
    
    // Query Nearby Users based on distance
    [userQuery whereKey:@"geoPoint" nearGeoPoint:self.curUser.geoPoint withinKilometers:self.curUser.distance.doubleValue];
    [userQuery whereKey:@"email" matchesKey:@"fromUserEmail" inQuery:query];
    
    // If User is Female, look for Female
    if (self.curUser.sexuality.integerValue == 0) {
        [userQuery whereKey:@"isMale" equalTo:@"true"];
    }
    
    /* If User is Male, look for Female
    if (self.curUser.sexuality.integerValue == 1) {
        [userQuery whereKey:@"isMale" equalTo:@"false"];
    }// end comment here
    NSUserDefaults *mainUser = [NSUserDefaults standardUserDefaults];
    [mainUser setInteger:self.curUser.sexuality.integerValue forKey:@"sex"];
    [mainUser synchronize];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [self.posibleMatchesArray addObjectsFromArray:objects];
        [self.willBeMatches addObjectsFromArray:objects];
        
        // Query for current User
        PFQuery *query = [PossibleMatchHelper query];
        [query whereKey:@"fromUser" equalTo:[UserParseHelper currentUser]];
        
        // Query for current User was liked (may not need)
        PFQuery *queryTwo = [PossibleMatchHelper query];
        [queryTwo whereKey:@"toUser" equalTo:[UserParseHelper currentUser]];
        [queryTwo whereKey:@"toUserApproved" equalTo:@"YES"];
        
        // Make sure users returned in queries are not the Current User
        PFQuery* userQuery = [UserParseHelper query];
        PFQuery* checkQuery = [UserParseHelper query];
        [userQuery whereKey:@"objectId" notEqualTo:[UserParseHelper currentUser].objectId];
        [userQuery whereKey:@"email" doesNotMatchKey:@"toUserEmail" inQuery:query];
        [checkQuery whereKey:@"email" matchesKey:@"fromUserEmail" inQuery:queryTwo];
        
        // Querying on sexuality - If Female show Female
        if (self.curUser.sexuality.integerValue == 0) {
            [userQuery whereKey:@"isMale" equalTo:@"true"];
        }
        
        // If Male show Female
        /*if (self.curUser.sexuality.integerValue == 1) {
            [userQuery whereKey:@"isMale" equalTo:@"false"];
        }// end comment here
        
        // Increasing query distance?
        if (self.curUser.distance.doubleValue == 0.0) {
            self.curUser.distance = [NSNumber numberWithInt:10000];
        }
        [userQuery whereKey:@"objectId" doesNotMatchKey:@"objectId" inQuery:checkQuery];
        [userQuery whereKey:@"geoPoint" nearGeoPoint:self.curUser.geoPoint withinKilometers:self.curUser.distance.doubleValue];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!objects) {
                NSLog(@"No Matches found");
            } else NSLog(@"Matches found: %@ Total: %ld", objects, objects.count);
            /*
            [self.posibleMatchesArray addObjectsFromArray:objects];
       
            self.activityLabel.text = @"No results found";
            
            if (objects == 0) {
                 [waveLayer setHidden:NO];
            }
             [waveLayer setHidden:YES];
            self.activityLabel.textColor = [UIColor whiteColor];
            self.activityLabel.textAlignment = NSTextAlignmentCenter;
           [[self activityLabel] setFont:[UIFont systemFontOfSize:24]];
            self.activityIndicator.hidden = YES;
            
         
            if (self.firstTime) {
                [self firstPlacement];
            }
             // end comment here
        }];
    }]; */
    
    // My Queries
    // Setting a query distance?
    if (self.curUser.distance.doubleValue == 0.0) {
        self.curUser.distance = [NSNumber numberWithInt:100];
    }
    
    // Query Nearby Users based on distance; while require a time-based While-loop
    PFQuery *userQuery = [UserParseHelper query];
    [userQuery whereKey:@"geoPoint" nearGeoPoint:self.curUser.geoPoint withinKilometers:self.curUser.distance.doubleValue];
    [userQuery whereKey:@"objectId" notEqualTo:_curUser.objectId];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [_posibleMatchesArray addObjectsFromArray:objects];
        
        if (!objects) {
            NSLog(@"No Matches found");
        } else {
            
            NSLog(@"Potential matches found, total: %ld", objects.count);
            for (UserParseHelper *possMatch in _posibleMatchesArray) {
                [self matchGender:possMatch];
            }
        }
    }];
}

#pragma mark - MATCH FILTER

- (void)matchGender:(UserParseHelper *)match
{
    _prefCounter = 0;
    _totalPrefs = 0;
    NSString *matchGender = [[NSString alloc] init];
    
    if ([match.isMale isEqualToString:@"true"]) {
        matchGender = @"Male";
    } else matchGender = @"Female";
    
   
    if ([_curUser.genderPref isEqualToString:matchGender]) {
        
        [_willBeMatches addObject:match];
        NSLog(@"Matched with %@", match.nickname);
        NSLog(@"Will be matches: %ld", _willBeMatches.count);
        _prefCounter++;
        _totalPrefs++;
        
        _otherUser = [PossibleMatchHelper object];
        _otherUser.fromUser = [UserParseHelper currentUser];
        _otherUser.toUser = match;
        _otherUser.toUserEmail = match.email;
        _otherUser.fromUserEmail = [UserParseHelper currentUser].email;
        _otherUser.prefCounter = [NSNumber numberWithDouble:_prefCounter];
        _otherUser.totalPrefs = [NSNumber numberWithDouble:_totalPrefs];
        _otherUser.matches = [[NSArray alloc] initWithObjects:[UserParseHelper currentUser], match, nil];
        /*[possMatch saveInBackground];
        possMatch.prefMatchCounter++;
        possMatch.totalPrefs++;*/
        
        //NSLog(@"Poss Match: %@", _otherUser);
        //[self matchBodyType:match];
        //[_otherUser calculateCompatibility:_prefCounter with:_totalPrefs];
        //NSLog(@"Compatibility: %@%%", _otherUser.compatibilityIndex);
        NSLog(@"PossMatch count: %lu", (unsigned long)[_otherUser.matches count]);
        [_otherUser saveInBackground];
            
        NSLog(@"Save run");
        [self generateMatchMessageWith:match];
            

        
        
        //[self performSegueWithIdentifier:@"viewMatch" sender:nil];
        
    } else if ([_curUser.genderPref isEqualToString:@"Both"]) {
        [_willBeMatches addObject:match];
        
        NSLog(@"Gender Pref = Both, Matched with %@", match.nickname);
        [_otherUser calculateCompatibility:_prefCounter with:_totalPrefs];
        NSLog(@"Just before Save run");
        [_otherUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"Save run");
                [self generateMatchMessageWith:match];
            }
        }];
        
        //[self performSegueWithIdentifier:@"viewMatch" sender:nil];
    } else NSLog(@"No match with %@", match.nickname);
    
    //_totalPrefs++;
    
    //NSLog(@"Pref Counter: %ld Total Prefs: %ld", (long)_prefMatchCounter, (long)_totalPrefs);
}
/*
- (void)matchBodyType:(UserParseHelper *)match
{
    if([_curUser.bodyTypePref isEqualToString:match.bodyType]) {
        _prefMatchCounter++;
    } else {
        //
    }
    _totalPrefs++;
}

- (void)matchRelationshipStatus
{
    if ([_curUser.relationshipStatusPref isEqualToString:match.relationshipStatus]) {
        
        _prefMatchCounter++;
    } else {
        
    }
    _totalPrefs++;
}

- (void)matchRomanticPreference
{
    if ([_curUser.romanticPreference isEqualToString:match.relationshipType]) {
        
        _prefMatchCounter++;
    } else {
        
    }
    _totalPrefs++;
}

- (void)matchKids
{
    if ([_curUser.kidsOkay isEqualToNumber:match.hasKids]) {
        _prefMatchCounter++;
    } else {
        
    }
    _totalPrefs++;
}

- (void)matchDrinking
{
    if([_curUser.drinkingOkay isEqualToNumber:match.drinks]) {
        _prefMatchCounter++;
    } else {
        
    }
    _totalPrefs++;
}

- (void)matchSmoking
{
    if ([_curUser.smokingOkay isEqualToNumber:match.smokes]) {
        _prefMatchCounter++;
    } else {
        
    }
    _totalPrefs++;
}

- (void)matchDrugUse
{
    if ([_curUser.drugsOkay isEqualToNumber:match.drugs]) {
        _prefMatchCounter++;
    } else {
        
    }
    _totalPrefs++;
}

- (void)matchBodyArt
{
    if ([_curUser.bodyArtOkay isEqualToNumber:match.bodyArt]) {
        _prefMatchCounter++;
    } else {
        
    }
    _totalPrefs++;
    
    NSLog(@"PrefMatchCounter before compare: %ld", (long)_prefMatchCounter);
    
}

- (void)compare:(NSArray *)userPreferences with:(NSArray *)matchPreferences
{
    _totalPrefs += [userPreferences count];
    
    NSLog(@"Total Preferences: %ld", (long)_totalPrefs);
    
    for (NSString *preference in userPreferences) {
        if ([matchPreferences containsObject:preference]) {
            _prefMatchCounter++;
            NSLog(@"PrefMatchCounter after compare: %ld", (long)_prefMatchCounter);
            [_sharedPrefs addObject:preference];
            NSLog(@"Shared Prefs: %ld", [_sharedPrefs count]);
        }
    }
    
    [self performSegueWithIdentifier:@"viewMatches" sender:nil];
}*/

#pragma mark - MATCH SEGUE

// ----------------------- MATCHING SEGUE PUSHES TO MATCH_VIEW_CONTROLLER --------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewMatches"]) {
        
        //_matched = true;
        /*
        MessagesViewController *vc  = segue.destinationViewController;
            vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                    vc.totalPrefs   = _otherUser.totalPrefs;
                    vc.prefCounter  = _otherUser.prefCounter;
         */
    }
}

- (void)generateMatchMessageWith:(UserParseHelper *)match
{
    // Check if a Message already exists
    PFQuery* query = [MessageParse query];
    [query whereKey:@"fromUserParse" equalTo:match];
    [query whereKey:@"toUserParse" equalTo:[UserParseHelper currentUser]];
    
    if ([query findObjects].firstObject) {
        NSLog(@"Message with Match exists");
    } else {
        //NSLog(@"Compatibility with %@ is: %@%%", match.nickname, [NSNumber numberWithDouble:*(_otherUser.compatibilityIndex)]);
        
        MessageParse* message = [MessageParse object];
        message.fromUserParse = match;
        message.fromUserParseEmail = match.email;
        message.toUserParse = [UserParseHelper currentUser];
        message.toUserParseEmail = [UserParseHelper currentUser].email;
        message.text = @"";
        [message saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self findMatches:_willBeMatches]; //<-- Test before matchBodyType
                /*
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                } else {
                    [self removeBackgroundMatchCards];
                    self.activityLabel.hidden = NO;
                    [self.activityIndicator startAnimating];
                    [self.view bringSubviewToFront:self.profileView];
                }*/
         
            }
        }];
    }

}

- (void) firstPlacement
{
    UserParseHelper* aUser = self.posibleMatchesArray.firstObject;
  
    self.arrayOfPhotoDataForeground = [NSMutableArray new];
    [self.posibleMatchesArray removeObject:aUser];
    self.currShowingProfile = aUser;
    self.profileView.tag = profileViewTag;
    if (self.posibleMatchesArray.firstObject != nil) {
        [self placeBackgroundProfile];
        self.cyclePhotosButton.userInteractionEnabled = YES;
    } else {
        [self removeBackgroundMatchCards];
        self.activityLabel.hidden = NO;
        [self.activityIndicator startAnimating];
        [self.view bringSubviewToFront:self.profileView];
        self.cyclePhotosButton.userInteractionEnabled = NO;
    }
    PFFile* file = aUser.photo;
    NSString* nickname = aUser.nickname;
    NSNumber* age = aUser.age;
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [self.arrayOfPhotoDataForeground addObject:data];
        self.imageCountLabel.text = [NSString stringWithFormat:@"1 of %lu", (unsigned long)self.arrayOfPhotoDataForeground.count];
        
        self.profileView = [[UIView alloc] initWithFrame:[self createMatchRect]];
        self.profileView.clipsToBounds = NO;
        self.profileView.backgroundColor = WHITE_COLOR;
        self.profileView.layer.cornerRadius = 5.0;
        self.profileView.layer.shadowOffset  = CGSizeMake(0, 0);
        self.profileView.layer.shadowColor = [UIColor grayColor].CGColor;
        self.profileView.layer.shadowRadius = 5;
        self.profileView.layer.shadowOpacity = 0.5;
        self.profileImage.tag = currentProfileView;
        [self.view addSubview:self.profileView];
        self.profileImage = [[UIImageView alloc] initWithFrame:[self createPhotoRect]];
        self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
        self.profileImage.tag = currentProfileImage;
        self.profileImage.image = [UIImage imageWithData:data];
        self.profileImage.clipsToBounds = YES;
        self.profileImage.backgroundColor =[UIColor blackColor];
        self.profileImage.layer.cornerRadius = cornRadius;
        [self.profileView addSubview:self.profileImage];
        self.imageCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(220, 255, 70, 30)];
        self.imageCountLabel.textColor = WHITE_COLOR;
        self.imageCountLabel.textAlignment = NSTextAlignmentCenter;
        [self.imageCountLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Nue",self.imageCountLabel.font.fontName] size:self.imageCountLabel.font.pointSize];
        [self.imageCountLabel setFont:newFont];
        [self.profileImage addSubview:self.imageCountLabel];
        [self.profileImage bringSubviewToFront:self.imageCountLabel];
        self.foregroundLabel = [[UILabel alloc] initWithFrame:[self createLabelRect]];
        self.matchPhoto = self.profileImage.image;
        double distance = [aUser.geoPoint distanceInKilometersTo:self.curUser.geoPoint];
        if ([aUser.geoPoint distanceInKilometersTo:self.curUser.geoPoint] < 1) {
            distance = 1;
        }
        self.foregroundLabel.text = [NSString stringWithFormat:@"%@", nickname];
        self.foregroundLabel.textColor = RED_LIGHT;
        self.foregroundLabel.clipsToBounds = YES;
       [self.foregroundLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        UIFont *descFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",self.foregroundLabel.font.fontName] size: 12];
        [self.foregroundLabel setFont:newFont];
        [self.profileView addSubview:self.foregroundLabel];
        [self.profileView bringSubviewToFront:self.foregroundLabel];
        self.profileImageAge = [[UIImageView alloc] initWithFrame:[self createImageViewAge]];
        self.profileImageAge.image = [UIImage imageNamed:@"birthday2@2x.png"];
        [self.profileView addSubview:self.profileImageAge];
        [self.profileView bringSubviewToFront:self.profileImageAge];
        self.foregroundLabelAge = [[UILabel alloc] initWithFrame:[self createLabelAge]];
        self.foregroundLabelAge.text = [NSString stringWithFormat:@"%@", age];
        self.foregroundLabelAge.textColor = MENU_GRAY_LIGHT;
        [self.foregroundLabelAge setFont:newFont];
        [self.profileView addSubview:self.foregroundLabelAge];
        [self.profileView bringSubviewToFront:self.foregroundLabelAge];
        self.profileImageLocation = [[UIImageView alloc] initWithFrame:[self createImageLocation]];
        self.profileImageLocation.image = [UIImage imageNamed:@"location2@2x.png"];
        self.profileImageLocation.contentMode = UIViewContentModeScaleAspectFit;
        [self.profileView addSubview:self.profileImageLocation];
        self.foregroundLabelLocation = [[UILabel alloc] initWithFrame:[self createLabelLocation]];
        self.foregroundLabelLocation.text = [NSString stringWithFormat:@"%.0fkm", distance];
        self.foregroundLabelLocation.textColor = MENU_GRAY_LIGHT;
        [self.foregroundLabelLocation setFont:newFont];
        [self.profileView addSubview:self.foregroundLabelLocation];
        [self.profileView bringSubviewToFront:self.imageCountLabel];
        [self.profileView bringSubviewToFront:self.foregroundLabelLocation];
        [self.profileView bringSubviewToFront:self.profileImageLocation];
        UILabel* boundaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.profileImage.frame.size.height+self.foregroundLabel.frame.size.height+23, self.profileView.frame.size.width, 1)];
        boundaryLabel.backgroundColor = RED_DEEP;
        boundaryLabel.alpha = 0.6;
        [self.profileView addSubview:boundaryLabel];
        [self.profileView bringSubviewToFront:boundaryLabel];
        self.foregroundDescriptionLabel = [[UILabel alloc] initWithFrame:[self createLabelDescription]];
        self.foregroundDescriptionLabel.numberOfLines = 0;
        self.foregroundDescriptionLabel.textAlignment = NSTextAlignmentJustified;
        self.foregroundDescriptionLabel.text = aUser.desc;
        self.foregroundDescriptionLabel.textColor = MENU_GRAY_LIGHT;
        [self.foregroundDescriptionLabel setFont:descFont];
        [self.profileView addSubview:self.foregroundDescriptionLabel];
        [self setPanGestureRecognizer];
        self.firstTime = NO;

        if ([aUser.photo1 isKindOfClass:[PFFile class]]) {
            PFFile* photo1 = aUser.photo1;
            [photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
                self.matchPhoto = [UIImage imageWithData:data];
                self.imageCountLabel.text = [NSString stringWithFormat:@"1 of %lu", (unsigned long)self.arrayOfPhotoDataForeground.count];
        }];
        }
        if ([aUser.photo2 isKindOfClass:[PFFile class]]) {
            PFFile* photo2 = aUser.photo2;
            [photo2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
                self.imageCountLabel.text = [NSString stringWithFormat:@"1 of %lu", (unsigned long)self.arrayOfPhotoDataForeground.count];
            }];
        }
        if ([aUser.photo3 isKindOfClass:[PFFile class]]) {
            PFFile* photo3 = aUser.photo3;
            [photo3 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
                self.imageCountLabel.text = [NSString stringWithFormat:@"1 of %lu", (unsigned long)self.arrayOfPhotoDataForeground.count];
            }];
        }
        if ([aUser.photo4 isKindOfClass:[PFFile class]]) {
            PFFile* photo4 = aUser.photo4;
            [photo4 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                [self.arrayOfPhotoDataForeground addObject:data];
                self.imageCountLabel.text = [NSString stringWithFormat:@"1 of %lu", (unsigned long)self.arrayOfPhotoDataForeground.count];
            }];
        }
        [self.profileImage bringSubviewToFront:self.imageCountLabel];
        [self.activityIndicator stopAnimating];
        self.activityLabel.hidden = YES;
        [self placeBackgroundMatchCards];
    }];
    
    
}

-(void) placeBackgroundProfile
{
    UserParseHelper* aUser = self.posibleMatchesArray.firstObject;
    [self.posibleMatchesArray removeObject:aUser];
    self.backgroundUserProfile = aUser;
    self.arrayOfPhotoDataBackground = [NSMutableArray new];
    PFFile* file = aUser[@"photo"];
    NSString* nickname = aUser[@"nickname"];
    NSNumber* age = aUser[@"age"];
   
    
    self.backgroundView = [[UIView alloc] initWithFrame:[self createBackgroundMatchRect]];
    self.backgroundView.clipsToBounds = NO;
    self.backgroundView.backgroundColor = WHITE_COLOR;
    self.backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
    self.backgroundView.layer.cornerRadius = 5.0;
    self.backgroundView.layer.shadowOffset  = CGSizeMake(0, 0);
    self.backgroundView.layer.shadowColor = [UIColor grayColor].CGColor;
    self.backgroundView.layer.shadowRadius = 5;
    self.backgroundView.layer.shadowOpacity = 0.5;
    
    [self.view addSubview:self.backgroundView];
    [self.view sendSubviewToBack:self.backgroundView];
    [self.view sendSubviewToBack:self.background];
   
    [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        [self.arrayOfPhotoDataBackground addObject:data];
        self.backgroundImage = [[UIImageView alloc] initWithFrame:[self createBackgroundPhotoRect]];
        self.backgroundImage.image = [UIImage imageWithData:data];
        self.backgroundImage.clipsToBounds = YES;
        [self.backgroundImage setContentMode:UIViewContentModeScaleAspectFit];
        [self.backgroundView addSubview:self.backgroundImage];
        self.backgroundLabel = [[UILabel alloc] initWithFrame:[self createBackgroundLabelRect]];
        double distance = [aUser.geoPoint distanceInKilometersTo:self.curUser.geoPoint];
        if ([aUser.geoPoint distanceInKilometersTo:self.curUser.geoPoint] < 1) {
            distance = 1;
        }
        self.backgroundLabel.text = [NSString stringWithFormat:@"%@", nickname];
        self.backgroundLabel.textColor = RED_LIGHT;
        self.backgroundLabel.clipsToBounds = YES;
        self.backgroundLabel.layer.cornerRadius = cornRadius;
        [self.backgroundLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        UIFont *newFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Nue",self.backgroundLabel.font.fontName] size:self.backgroundLabel.font.pointSize];
        UIFont *descFont = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold",self.backgroundLabel.font.fontName] size: 12];
        [self.backgroundLabel setFont:newFont];
        [self.backgroundView addSubview:self.backgroundLabel];
        self.backgroundDescriptionLabel = [[UILabel alloc] initWithFrame:[self createBackgroundLabelDescription]];
        [self.profileView bringSubviewToFront:self.foregroundLabel];
        self.backgroundImageAge = [[UIImageView alloc] initWithFrame:[self createBackgroundImageViewAge]];
        self.backgroundImageAge.image = [UIImage imageNamed:@"birthday2@2x.png"];
        [self.backgroundView addSubview:self.backgroundImageAge];
        [self.backgroundView bringSubviewToFront:self.backgroundImageAge];
        self.backgroundLabelAge = [[UILabel alloc] initWithFrame:[self createBackgroundLabelAge]];
        self.backgroundLabelAge.text = [NSString stringWithFormat:@"%@", age];
        self.backgroundLabelAge.textColor = MENU_GRAY_LIGHT;
        [self.backgroundLabelAge setFont:newFont];
        [self.backgroundView addSubview:self.backgroundLabelAge];
        [self.backgroundView bringSubviewToFront:self.backgroundLabelAge];
        self.backgroundImageLocation = [[UIImageView alloc] initWithFrame:[self createBackgroundImageLocation]];
        self.backgroundImageLocation.image = [UIImage imageNamed:@"location2@2x.png"];
        self.backgroundImageLocation.contentMode = UIViewContentModeScaleAspectFit;
        [self.backgroundView addSubview:self.backgroundImageLocation];
        self.backgroundLabelLocation = [[UILabel alloc] initWithFrame:[self createBackgroundLabelLocation]];
        self.backgroundLabelLocation.text = [NSString stringWithFormat:@"%.0fkm", distance];
        self.backgroundLabelLocation.textColor = MENU_GRAY_LIGHT;
        [self.backgroundLabelLocation setFont:newFont];
        [self.backgroundView addSubview:self.backgroundLabelLocation];
        [self.backgroundView bringSubviewToFront:self.backgroundLabelLocation];
        [self.backgroundView bringSubviewToFront:self.backgroundLabelLocation];
        UILabel* boundaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.backgroundImage.frame.size.height+self.backgroundLabel.frame.size.height+23, self.backgroundView.frame.size.width, 1)];
        boundaryLabel.backgroundColor = [UIColor grayColor];
        boundaryLabel.alpha = 0.6;
        [self.backgroundView addSubview:boundaryLabel];
        [self.backgroundView bringSubviewToFront:boundaryLabel];
        self.backgroundDescriptionLabel = [[UILabel alloc] initWithFrame:[self createBackgroundLabelDescription]];
        self.backgroundDescriptionLabel.numberOfLines = 0;
        self.backgroundDescriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.backgroundDescriptionLabel.text = aUser.desc;
        self.backgroundDescriptionLabel.textColor = MENU_GRAY_LIGHT;
        [self.backgroundDescriptionLabel setFont:descFont];
        [self.backgroundView addSubview:self.backgroundDescriptionLabel];
        [self.view sendSubviewToBack:self.firstBox];
        [self.view sendSubviewToBack:self.secondBox];
    }];
    if ([aUser[@"photo1"] isKindOfClass:[PFFile class]]) {
        PFFile* photo1 = aUser[@"photo1"];
        [photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.arrayOfPhotoDataBackground addObject:data];
        }];
    }
    if ([aUser[@"photo2"] isKindOfClass:[PFFile class]]) {
        PFFile* photo2 = aUser[@"photo2"];
        [photo2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.arrayOfPhotoDataBackground addObject:data];
        }];
    }
    if ([aUser[@"photo3"] isKindOfClass:[PFFile class]]) {
        PFFile* photo3 = aUser[@"photo3"];
        [photo3 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.arrayOfPhotoDataBackground addObject:data];
        }];
    }
    if ([aUser[@"photo4"] isKindOfClass:[PFFile class]]) {
        PFFile* photo4 = aUser[@"photo4"];
        [photo4 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            [self.arrayOfPhotoDataBackground addObject:data];
        }];
    }
}

- (void)placeBackgroundMatchCards
{
    self.firstBox = [[UIView alloc] initWithFrame:[self createFirstBox]];
    self.firstBox.tag = firstBackground;
    self.firstBox.backgroundColor = [UIColor whiteColor];
    self.firstBox.layer.borderColor = [UIColor grayColor].CGColor;
    self.firstBox.layer.masksToBounds = NO;
    self.firstBox.layer.cornerRadius = 5.0;
    self.firstBox.layer.shadowOffset  = CGSizeMake(0, 0);
    self.firstBox.layer.shadowColor = [UIColor grayColor].CGColor;
    self.firstBox.layer.shadowRadius = 5;
    self.firstBox.layer.shadowOpacity = 0.5;
    
    
    self.secondBox = [[UIView alloc] initWithFrame:[self createSecondBox]];
    self.secondBox.tag = secondBackground;
    self.secondBox.backgroundColor = [UIColor whiteColor];
    self.secondBox.layer.borderColor = [UIColor grayColor].CGColor;
    self.secondBox.layer.masksToBounds = NO;
    self.secondBox.layer.cornerRadius = 5.0;
    self.secondBox.layer.shadowOffset  = CGSizeMake(0, 0);
    self.secondBox.layer.shadowColor = [UIColor grayColor].CGColor;
    self.secondBox.layer.shadowRadius = 5;
    self.secondBox.layer.shadowOpacity = 0.5;
    [self.view addSubview:self.firstBox];
    [self.view sendSubviewToBack:self.firstBox];
    [self.view addSubview:self.secondBox];
    [self.view sendSubviewToBack:self.secondBox];
    
   
    
    [self checkPurchase];
}

- (void)removeBackgroundMatchCards
{
    for (UIView* view in self.view.subviews) {
        if (view.tag == firstBackground || view.tag == secondBackground) {
            [view removeFromSuperview];
        }
    }
}

- (CGRect)createFirstBox
{
    int x = self.profileView.frame.origin.x-3;
    int y = self.profileView.frame.origin.y+3;
    int width = self.profileView.frame.size.width;
    int height = self.profileView.frame.size.height;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createSecondBox
{
    int x = self.profileView.frame.origin.x-6;
    int y = self.profileView.frame.origin.y+6;
    int width = self.profileView.frame.size.width;
    int height = self.profileView.frame.size.height;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createLabelDescription
{
    int x = imageMargin;
    int y = self.profileImage.frame.size.height+self.foregroundLabel.frame.size.height+25;
    int width = self.profileView.frame.size.width-imageMargin-imageMargin;
    int height = 50;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createLabelLocation
{
    int x = self.foregroundLabel.frame.size.width+77;
    int y = self.profileImage.frame.size.height+19;
    int width = 59-imageMargin;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createImageLocation
{
    int x = self.foregroundLabel.frame.size.width+55;
    int y = self.profileImage.frame.size.height+19;
    int width = 16;
    int height = 16;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createLabelAge
{
    int x = self.foregroundLabel.frame.size.width+24;
    int y = self.profileImage.frame.size.height+19;
    int width = 30;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}
- (CGRect)createImageViewAge
{
    int x = self.foregroundLabel.frame.size.width;
    int y = self.profileImage.frame.size.height+19;
    int width = 16;
    int height = 16;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createLabelRect
{
    int x = imageMargin;
    int y = self.profileImage.frame.size.height+19;
    int width = (self.profileImage.frame.size.width/2)+30;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createPhotoRect
{
    if (IS_IPHONE_5) {
        
    
    int x = imageMargin;
    int width = self.profileView.frame.size.width - (x*2);
    int y = imageMargin;
    int height = 280;
    return CGRectMake(x, y, width, height);
        
    }else{
        
    int x = imageMargin;
    int width = self.profileView.frame.size.width - (x*2);
    int y = imageMargin;
    int height = 210;
    return CGRectMake(x, y, width, height);
          }
}

- (CGRect)createMatchRect
{
    if( IS_IPHONE_5 )
    {
        
        int x = imageMargin;
        int width = 320 - (x*2);
        int y = imageMargin;
        int height = 380;
        return CGRectMake(x, y+topMarginView, width, height);
    
    }else{
    
        int x = imageMargin;
        int width = 320 - (x*2);
        int y = imageMargin;
        int height = 310;
        return CGRectMake(x, y+topMarginView, width, height);
    
    }
    
}

- (CGRect)createBackgroundLabelDescription
{
    int x = imageMargin;
    int y = self.backgroundImage.frame.size.height+self.backgroundLabel.frame.size.height+25;
    int width = self.backgroundView.frame.size.width-imageMargin-imageMargin;
    int height = 50;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundLabelLocation
{
    int x = self.backgroundLabel.frame.size.width+77;
    int y = self.backgroundImage.frame.size.height+19;
    int width = 59-imageMargin;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundImageLocation
{
    int x = self.backgroundLabel.frame.size.width+55;
    int y = self.backgroundImage.frame.size.height+19;
    int width = 20;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundLabelAge
{
    int x = self.backgroundLabel.frame.size.width+24;
    int y = self.backgroundImage.frame.size.height+19;
    int width = 30;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}
- (CGRect)createBackgroundImageViewAge
{
    int x = self.backgroundLabel.frame.size.width;
    int y = self.backgroundImage.frame.size.height+19;
    int width = 20;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundLabelRect
{
    int x = imageMargin;
    int y = self.backgroundImage.frame.size.height+19;
    int width = (self.backgroundImage.frame.size.width/2)+30;
    int height = labelHeight;
    return CGRectMake(x, y, width, height);
}

- (CGRect)createBackgroundPhotoRect
{
    
    if (IS_IPHONE_5) {
        
        
        int x = imageMargin;
        int width = self.backgroundView.frame.size.width - (x*2);
        int y = imageMargin;
        int height = 280;
        return CGRectMake(x, y, width, height);

        
    }else{
        
        int x = imageMargin;
        int width = self.backgroundView.frame.size.width - (x*2);
        int y = imageMargin;
        int height = 210;
        return CGRectMake(x, y, width, height);

    }

    
}

- (CGRect)createBackgroundMatchRect
{
   
    
    if( IS_IPHONE_5 )
    {
        
        int x = imageMargin;
        int width = 320 - (x*2);
        int y = imageMargin;
        int height = 380;
        return CGRectMake(x, y+topMarginView, width, height);
        
    }else{
        
        int x = imageMargin;
        int width = 320 - (x*2);
        int y = imageMargin;
        int height = 310;
        return CGRectMake(x, y+topMarginView, width, height);
        
    }

}

- (void)rotateImageView:(UIView*) view withDouble:(double) dub
{
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        [view setTransform:CGAffineTransformRotate(view.transform, dub)];
    }completion:^(BOOL finished){
        if (finished) {
            self.isRotating = NO;
        }
    }];
}

#pragma mark - set up and handle pan gesture
- (void) setPanGestureRecognizer
{
    [self.profileView setUserInteractionEnabled:YES];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.profileView addGestureRecognizer:pan];
    [self.profileView addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    self.profileView.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveLinear
                     animations:^(void) {
                         self.profileImage.alpha = 0.8;
                     }
                     completion:^(BOOL b) {
                         [self removeOldProfileImage];
                         [self addNewProfileImage];
                         self.profileView.userInteractionEnabled = YES;
                     }];
}

- (void)addNewProfileImage
{
    NSData* data;
    if (self.photoArrayIndex >= self.arrayOfPhotoDataForeground.count) {
        data = [self.arrayOfPhotoDataForeground objectAtIndex:self.photoArrayIndex-1];
        self.photoArrayIndex = 0;
    }
    if (self.photoArrayIndex < self.arrayOfPhotoDataForeground.count) {
        data = [self.arrayOfPhotoDataForeground objectAtIndex:self.photoArrayIndex];
        self.photoArrayIndex++;
    }
    self.imageCountLabel.text = [NSString stringWithFormat:@"%d of %lu", self.photoArrayIndex, (unsigned long)self.arrayOfPhotoDataForeground.count];
    self.profileImage = [[UIImageView alloc] initWithFrame:[self createPhotoRect]];
    self.profileImage.tag = currentProfileImage;
    self.profileImage.image = [UIImage imageWithData:data];
    self.profileImage.clipsToBounds = YES;
    self.profileImage.contentMode = UIViewContentModeScaleAspectFill;
    [self.profileView addSubview:self.profileImage];
    [self.profileImage addSubview:self.imageCountLabel];
    [self.profileImage bringSubviewToFront:self.imageCountLabel];
}

- (void)removeOldProfileImage
{
    for (UIView* view in self.profileView.subviews) {
        if (view.tag == currentProfileImage) {
            [view removeFromSuperview];
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pan
{
    CGPoint vel = [pan velocityInView:self.view];
    CGPoint point = [pan translationInView:self.view];
    BOOL allowRotation = YES;
    if (vel.x > 0)
    {
        
        if (allowRotation) {
            allowRotation = NO;
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                [self.profileView setTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(point.x, point.y), CGAffineTransformMakeRotation(-0.15))];
            }completion:^(BOOL finished){
                if (finished) {
                }
            }];
            [self removeDislikeView];
            [self addLikeView];
        }
    }
    else
    {
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            [self.profileView setTransform:CGAffineTransformConcat(CGAffineTransformMakeTranslation(point.x, point.y), CGAffineTransformMakeRotation(0.15))];
        }completion:^(BOOL finished){
            if (finished) {
            }
        }];
        [self removeLikeView];
        [self addDislikeView];
    }

    point.x += self.profileView.center.x;
    point.y += self.profileView.center.y;

    
    [self checkPointsForLike:point];
    if (pan.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.4 animations:^{
            self.profileView.transform = CGAffineTransformMakeTranslation(0, -5);
        } completion:^(BOOL finished) {
            self.profileView.transform = CGAffineTransformMakeTranslation(0, 0);
            self.profileView.alpha = 1;
        }];
        [self removeLikeAndDislikeView];
    }
}

#pragma mark - pan gesture helper methods
- (void) checkPointsForLike:(CGPoint)point
{
    if (point.x > self.view.frame.size.width - MARGIN) {
        [self likeAProfile];
    }
    if (point.x < MARGIN) {
        [self dislikeAProfile];
    }
}

- (void)dislikeAProfile
{
   
    self.profileView.gestureRecognizers = [NSArray new];
    [self.profileView removeFromSuperview];
    self.profileView = self.backgroundView;
    self.profileImage = self.backgroundImage;

    [self.profileImage bringSubviewToFront:self.imageCountLabel];
    self.foregroundLabel = self.backgroundLabel;
    self.foregroundDescriptionLabel = self.backgroundDescriptionLabel;
    self.profileImage.tag = currentProfileImage;
    self.photoArrayIndex = 1;
    self.arrayOfPhotoDataForeground = self.arrayOfPhotoDataBackground;
    self.imageCountLabel.text = [NSString stringWithFormat:@"1 of %lu", (unsigned long)self.arrayOfPhotoDataForeground.count];
    [self.profileImage addSubview:self.imageCountLabel];
    if ([self.willBeMatches containsObject:self.currShowingProfile]) {
        PFQuery* query = [PossibleMatchHelper query];
        [query whereKey:@"fromUser" equalTo:self.currShowingProfile];
        [query whereKey:@"toUser" equalTo:[UserParseHelper currentUser]];
        PossibleMatchHelper* posMatch = [query findObjects].firstObject;
        posMatch.toUserApproved = @"NO";
        [posMatch saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                } else {
                    [self removeBackgroundMatchCards];
                    self.activityLabel.hidden = NO;
                    [self.activityIndicator startAnimating];
                    [self.view bringSubviewToFront:self.profileView];
                }
            }
        }];
    } else {
        PossibleMatchHelper* possibleMatch = [PossibleMatchHelper object];
        possibleMatch.fromUser = [UserParseHelper currentUser];
        possibleMatch.fromUserEmail = [UserParseHelper currentUser].email;
        possibleMatch.toUserEmail = self.currShowingProfile.email;
        possibleMatch.toUser = self.currShowingProfile;
        possibleMatch.match = @"NO";
        [possibleMatch saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                } else {
                    [self removeBackgroundMatchCards];
                    self.activityLabel.hidden = NO;
                    [self.activityIndicator startAnimating];
                    [self.view bringSubviewToFront:self.profileView];
                }
            }
        }];
    }
}

#pragma mark - LIKE A PROFILE

/* ---------------------------------------------------------------
 
                    SETS UP SEGUE IDENTIFIER
 
 --------------------------------------------------------------- */

- (void)likeAProfile
{
  
    self.profileView.gestureRecognizers = [NSArray new];
    [self.profileView removeFromSuperview];
    self.profileView = self.backgroundView;
    self.matchPhoto = self.profileImage.image;
    self.profileImage = self.backgroundImage;
    self.foregroundLabel = self.backgroundLabel;
    self.foregroundDescriptionLabel = self.backgroundDescriptionLabel;
    self.arrayOfPhotoDataForeground = self.arrayOfPhotoDataBackground;
    self.profileImage.tag = currentProfileImage;
    self.photoArrayIndex = 1;
    self.arrayOfPhotoDataForeground = self.arrayOfPhotoDataBackground;
    self.imageCountLabel.text = [NSString stringWithFormat:@"1 of %lu", (unsigned long)self.arrayOfPhotoDataForeground.count];
    if ([self.willBeMatches containsObject:self.currShowingProfile]) {
        [self performSegueWithIdentifier:@"match" sender:nil];
        MessageParse* message = [MessageParse object];
        message.fromUserParse = self.currShowingProfile;
        message.fromUserParseEmail = self.currShowingProfile.email;
        message.toUserParse = [UserParseHelper currentUser];
        message.toUserParseEmail = [UserParseHelper currentUser].email;
        message.text = @"";
        PFQuery* query = [PossibleMatchHelper query];
        [query whereKey:@"fromUser" equalTo:self.currShowingProfile];
        [query whereKey:@"toUser" equalTo:[UserParseHelper currentUser]];
        PossibleMatchHelper* posMatch = [query findObjects].firstObject;
        posMatch.toUserApproved = @"YES";
        [posMatch saveEventually];
        [message saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                } else {
                    [self removeBackgroundMatchCards];
                    self.activityLabel.hidden = NO;
                    [self.activityIndicator startAnimating];
                    [self.view bringSubviewToFront:self.profileView];
                }
            }
        }];
    } else {
        PossibleMatchHelper* possibleMatch = [PossibleMatchHelper object];
        possibleMatch.fromUser = [UserParseHelper currentUser];
        possibleMatch.toUser = self.currShowingProfile;
        possibleMatch.toUserEmail = self.currShowingProfile.email;
        possibleMatch.fromUserEmail = [UserParseHelper currentUser].email;
        possibleMatch.match = @"YES";
        possibleMatch.toUserApproved = @"notDone";
        [possibleMatch saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
              
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                } else {
                    [self removeBackgroundMatchCards];
                    self.activityLabel.hidden = NO;
                    [self.activityIndicator startAnimating];
                    [self.view bringSubviewToFront:self.profileView];
                }
            }
        }];
    }
}

- (void) addLikeView
{
    UIImageView* likeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, buttonWidth, buttonHeight)];
    likeImageView.tag = likeViewTag;
    likeImageView.image = [UIImage imageNamed:@"up2@2x.png"];
    likeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.profileView addSubview:likeImageView];
}

- (void) addDislikeView
{
    UIImageView* dislikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.profileImage.frame.size.width - buttonWidth + (imageMargin*2), 0, buttonWidth, buttonHeight)];
    dislikeImageView.tag = dislikeViewTag;
    dislikeImageView.image = [UIImage imageNamed:@"down2@2x.png"];
    dislikeImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.profileView addSubview:dislikeImageView];
    [self.profileView bringSubviewToFront:dislikeImageView];
}

- (void) removeLikeAndDislikeView
{
    for (UIView* view in self.profileView.subviews) {
        if (view.tag == dislikeViewTag || view.tag == likeViewTag) {
            [view removeFromSuperview];
        }
    }
}

- (void) removeLikeView
{
    for (UIView* view in self.profileView.subviews) {
        if (view.tag == likeViewTag) {
            [view removeFromSuperview];
        }
    }
}

- (void) removeDislikeView
{
    for (UIView* view in self.profileView.subviews) {
        if (view.tag == dislikeViewTag) {
            [view removeFromSuperview];
        }
    }
}

-(void) removeProfileViewForGood
{
    for (UIView* view in self.view.subviews) {
        if (view.tag == currentProfileView) {
            [view removeFromSuperview];
        }
    }
}

- (IBAction)dislikeButtonHit:(UIButton *)sender
{
    if(self.profileView != nil) {
        sender.enabled = NO;
        self.likeButton.enabled = NO;
        self.cyclePhotosButton.enabled = NO;
        [UIView animateWithDuration:0.4 animations:^{
            self.profileView.transform = CGAffineTransformMakeTranslation(-300, 40);
            [self addDislikeView];
        } completion:^(BOOL finished) {
            [self dislikeAProfile];
            sender.enabled = YES;
            self.likeButton.enabled = YES;
            self.cyclePhotosButton.enabled = YES;
        }];
    }
}

- (IBAction)likeButtonHit:(UIButton *)sender
{
    if(self.profileView != nil) {
        sender.enabled = NO;
        self.dislikeButton.enabled = NO;
        self.cyclePhotosButton.enabled = NO;
        [UIView animateWithDuration:0.4 animations:^{
            self.profileView.transform = CGAffineTransformMakeTranslation(300, 40);
            [self addLikeView];
        } completion:^(BOOL finished) {
            [self likeAProfile];
            sender.enabled = YES;
            self.dislikeButton.enabled = YES;
            self.cyclePhotosButton.enabled = YES;
        }];
    }
}



#pragma mark - AV delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1) {
        [self performSegueWithIdentifier:@"config" sender:nil];
    }
}

- (void)checkPurchase {
    
    PFUser *chekUser = [PFUser currentUser];
    NSString *vip = chekUser[@"membervip"];
    if ([vip isEqualToString:@"vip"]) {
        
        self.bannerView.hidden = YES;
        
    }else{
        
        self.bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0+topMarginView, 320, 50)];
        GADBannerView *bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        bannerView_.adUnitID = kSampleAdUnitID;
        bannerView_.rootViewController = self;
        bannerView_.delegate = self;
        [bannerView_ loadRequest:[GADRequest request]];
        [self.bannerView addSubview:bannerView_];
        
        self.bannerView.backgroundColor = [UIColor clearColor];
        
        [self.view addSubview:self.bannerView];
        
    }
}

#pragma mark - FIND BAEDAR WAVE ANIMATION

-(void)startAnimation
{
    if ([waveLayer isHidden] || ![self.view window] || inAnimation == YES)
    {
        return;
    }
    inAnimation = YES;
    [self waveAnimation:waveLayer];
}

-(void)waveAnimation:(CALayer*)aLayer
{
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.duration = 3;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnimation.removedOnCompletion = YES;
    transformAnimation.fillMode = kCAFillModeRemoved;
    [aLayer setTransform:CATransform3DMakeScale( 10, 10, 1.0)];
    [transformAnimation setDelegate:self];
    
    CATransform3D xform = CATransform3DIdentity;
    xform = CATransform3DScale(xform, 40, 40, 1.0);
    transformAnimation.toValue = [NSValue valueWithCATransform3D:xform];
    [aLayer addAnimation:transformAnimation forKey:@"transformAnimation"];
    
    
    UIColor *fromColor = [UIColor colorWithRed:241 green:91 blue:78 alpha:0];
    UIColor *toColor = [UIColor colorWithRed:255 green:120 blue:0 alpha:0];
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.duration = 3;
    colorAnimation.fromValue = (id)fromColor.CGColor;
    colorAnimation.toValue = (id)toColor.CGColor;
    
    [aLayer addAnimation:colorAnimation forKey:@"colorAnimationBG"];
    
    
    UIColor *fromColor1 = [UIColor colorWithRed:255 green:255 blue:255 alpha:1];
    UIColor *toColor1 = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.1];
    CABasicAnimation *colorAnimation1 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    colorAnimation1.duration = 3;
    colorAnimation1.fromValue = (id)fromColor1.CGColor;
    colorAnimation1.toValue = (id)toColor1.CGColor;
    
    [aLayer addAnimation:colorAnimation1 forKey:@"colorAnimation"];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    inAnimation = NO;
    [self performSelectorInBackground:@selector(startAnimation) withObject:nil];
}


- (IBAction)backToPreferences:(id)sender {
    //[self.navigationController popViewControllerAnimated:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end