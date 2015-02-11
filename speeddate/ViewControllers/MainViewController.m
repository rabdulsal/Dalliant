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
#import "UserTableViewCell.h"
#import "MatchViewController.h"
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
#define SECONDS_DAY 24*60*60

@interface MainViewController () <UIGestureRecognizerDelegate, CLLocationManagerDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>{
    
    BOOL inAnimation;
    CALayer *waveLayer;
    NSTimer *animateTimer;
    User *userSingleton;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
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
@property (nonatomic) UserParseHelper* curUser;
@property (nonatomic) UserParseHelper *matchUser;
@property UIImage *userPhoto;
@property UIImage *matchPhoto;
@property (weak, nonatomic) IBOutlet UITextView *activityLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property UILabel* imageCountLabel;
@property NSArray *filteredAllUsersArray;
@property NSMutableArray *messages;
@property NSMutableArray *usersArray;
@property NSArray *matchedUsers;
@property NSMutableArray *matchRelationships;
@property PossibleMatchHelper *otherUser;
@property PossibleMatchHelper *possibleMatch;
@property double prefCounter;
@property double totalPrefs; //<-- should be attribute on UserParseHelper
@property (weak, nonatomic) IBOutlet UILabel *matchedLabel;

@property (weak, nonatomic) IBOutlet UIButton *baedarLabel;
- (IBAction)toggleBaedar:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *matchButtonLabel;
- (IBAction)pressedMatchButton:(id)sender;

@property (nonatomic,retain) UIView *bannerView;

@property (strong) NSDictionary *match;
@property (strong) NSMutableArray *sharedPrefs;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *filtersButton;
@property NSArray *blockedUsers;

- (IBAction)pushToBaedar:(id)sender;

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
    _curUser.installation = [PFInstallation currentInstallation];
    [_curUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
    }];

#endif
    userSingleton = [User singleObj];
    
    _matched = false;
    
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.view.frame];
    iv.image = [UIImage imageNamed:@"match"];
    
    [self.activityIndicator startAnimating];
    PFQuery* curQuery = [UserParseHelper query];
    [curQuery whereKey:@"username" equalTo:[UserParseHelper currentUser].username];
    [curQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.curUser = objects.firstObject;
        NSLog(@"Blocked Users MainVC: %lu", (unsigned long) [_curUser.blockedUsers count]);
        [self.curUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            self.userPhoto = [UIImage imageWithData:data];
        }];
        /*
        if (!self.curUser.geoPoint) {
            NSLog(@"No User Geolocation");
            [self currentLocationIdentifier];
        }
        */
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
    
    [self configureButton:_matchButtonLabel];
    [_matchButtonLabel setHidden:YES];
    [_activityLabel setHidden:YES];
    [_likeButton setHidden:YES];
    [_dislikeButton setHidden:YES];
    [_matchedLabel setHidden:YES];
    
    self.navigationController.navigationBar.barTintColor = RED_LIGHT;
    inAnimation = NO;
    
    // Circle Animation <-- wrap in Toggle Button
    waveLayer=[CALayer layer];
    if (IS_IPHONE_5) {
        waveLayer.frame = CGRectMake(155, 105, 10, 10);
    }else{
        waveLayer.frame = CGRectMake(155, 105, 10, 10);
    }
    waveLayer.borderWidth =0.2;
    waveLayer.cornerRadius =5.0;
    [self.view.layer addSublayer:waveLayer];
   
    [waveLayer setHidden:YES];
    
    self.usersArray = [NSMutableArray new];
    self.matchRelationships = [NSMutableArray new];
    
    [self customizeApp];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:receivedMessage object:nil];

    
    //[self currentLocationIdentifier];
    //[self performSegueWithIdentifier:@"test_match" sender:nil];

}

- (void)customizeApp
{
    self.tableView.backgroundColor = WHITE_COLOR;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    //self.searchTextField.backgroundColor = RED_DEEP;
    
}

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView {
    NSLog(@"Banner adapter class name: %@", bannerView.adNetworkClassName);
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial {
    NSLog(@"Interstitial adapter class name: %@", interstitial.adNetworkClassName);
}

#pragma mark - Baedar Toggle

// Turn on Baedar
- (IBAction)toggleBaedar:(id)sender {
    if (_baedarLabel.isSelected) {
        [self baedarOff];
    } else {
        [self baedarOn];
    }
}

- (void)baedarOn
{
    //[self.locationManager startUpdatingLocation];
    _filtersButton.enabled = false;
    _filtersButton.title = @"";
    [self currentLocationIdentifier];
    _curUser.online = @"yes";
    [_curUser saveInBackground];
    [self.view.layer addSublayer:waveLayer];
    [waveLayer setHidden:NO];
    [self startAnimation];
    //_baedarLabel.transform = CGAffineTransformMakeScale(1.1,1.1); // <-- Increase button size on press
    [_baedarLabel setSelected:YES];
    userSingleton.baedarIsRunning = true;
    NSLog(@"Block User count2: %lu", (unsigned long)[_curUser.blockedUsers count]);
    [self getMatches];
}

- (void)baedarOff
{
    //_baedarLabel.transform = CGAffineTransformMakeScale(1.1,1.1); // <-- Increase button size on press
    _curUser.online = @"no";
    [_curUser saveInBackground];
    _filtersButton.enabled = true;
    _filtersButton.title = @"Filters";
    [_baedarLabel setSelected:NO];
    inAnimation = NO;
    [waveLayer removeFromSuperlayer];
    [waveLayer setHidden:YES];
    userSingleton.baedarIsRunning = false;
}

- (IBAction)pressedMatchButton:(id)sender {
    
    //[self performSegueWithIdentifier:@"viewMatches" sender:nil];
    [self performSegueWithIdentifier:@"newViewMatches" sender:nil];
    
}

- (void)configureButton:(UIButton *)button
{
    button.layer.cornerRadius = 3;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
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
    // Listen for TableView changes
    //[self checkIncomingViewController];
    //[self currentLocationIdentifier];
    //[self loadingChat];
    if (userSingleton.baedarIsRunning) {
        [self baedarOn];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkFirstTime];
    [self performSelector:@selector(startAnimation) withObject:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:@"TableUpdated" object:nil];
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

// Get User Geo
-(void)currentLocationIdentifier
{
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    
    /* 
     Simulated locations:
     
     San Fran: 
     
     Chicago on Armitage: Lat 41.9179682946223, Long -87.6730694343221
     */
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [locations objectAtIndex:0];
    // Timestamp location capture?
    [self.locationManager stopUpdatingLocation];
    CLGeocoder* geocoder = [CLGeocoder new];
    [geocoder reverseGeocodeLocation:locations.firstObject completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark* placemark = placemarks.firstObject;
        /* Shows City and State once radar is activitated
        self.activityLabel.text = [NSString stringWithFormat:@"Locating :\n %@, %@", placemark.locality, placemark.administrativeArea];
         */
    }];
    _curUser.geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    self.curUser.geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    [_curUser save];
    NSLog(@"%@ location: %@", _curUser.nickname, _curUser.geoPoint);
    //[self performSegueWithIdentifier:@"viewMatches" sender:nil];
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    // Handle error
    NSLog(@"Location error - %@\n Description: %@", [error userInfo], error.description);
}

#pragma mark - GET MATCHES

- (void)getMatches
{
        NSLog(@"Block User count3: %lu", (unsigned long)[_curUser.blockedUsers count]);
    /* ---------------- START BLOCK COMMENT
     
    // Fetch PossibleMatch ------------------------------------------------------------------
    
    PFQuery *query = [PossibleMatchHelper query];
    [query whereKey:@"toUser" equalTo:self.curUser];
    [query whereKey:@"match" equalTo:@"YES"];
    [query whereKey:@"toUserApproved" equalTo:@"notDone"]; // May not need this, based on swipe
    
    //
    PFQuery *queryInside = [PossibleMatchHelper query];
    [queryInside whereKey:@"toUser" equalTo:_curUser];
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
        [query whereKey:@"fromUser" equalTo:_curUser];
        
        // Query for current User was liked (may not need)
        PFQuery *queryTwo = [PossibleMatchHelper query];
        [queryTwo whereKey:@"toUser" equalTo:_curUser];
        [queryTwo whereKey:@"toUserApproved" equalTo:@"YES"];
        
        // Make sure users returned in queries are not the Current User
        PFQuery* userQuery = [UserParseHelper query];
        PFQuery* checkQuery = [UserParseHelper query];
        [userQuery whereKey:@"objectId" notEqualTo:_curUser.objectId];
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
        self.curUser.distance = [NSNumber numberWithDouble:1.6];
    }
    NSLog(@"Block User count4: %lu", (unsigned long)[_curUser.blockedUsers count]);
    // Fetch Nearby Users based on distance; while require a time-based While-loop
    PFQuery *userQuery = [UserParseHelper query];
    [userQuery whereKey:@"geoPoint" nearGeoPoint:self.curUser.geoPoint withinKilometers:self.curUser.distance.doubleValue];
    [userQuery whereKey:@"objectId" notEqualTo:_curUser.objectId];
    [userQuery whereKey:@"objectId" notContainedIn:_curUser.blockedUsers];
    [userQuery whereKey:@"online" equalTo:@"yes"];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!objects) {
            NSLog(@"No Matches found");
        } else {
            //[waveLayer setHidden:YES];
            [_posibleMatchesArray addObjectsFromArray:objects];
            NSLog(@"Potential matches found, total: %ld", objects.count);
            
            /*
            for (UserParseHelper *possMatch in _posibleMatchesArray) {
                _matchUser = possMatch;
                [self matchGender];
            }
             */
            
            [self loopThroughMatches];
            
        }
    }];
}

// Loop Through Matches
- (void)loopThroughMatches
{
    /*
    int possMatchArrSize = (int)_posibleMatchesArray.count;
    for (int i = 0; i < possMatchArrSize; i++) {
        // Push into Array
        _matchUser = [_posibleMatchesArray objectAtIndex:i];
        [self matchGender];
        if (i == possMatchArrSize - 1) {
            NSLog(@"Last match reached");
            //[self generateMatchMessage];
            //[self findMatches:_willBeMatches];
            
            // Reload TableView
            
            /*[self. tableView beginUpdates];
                for (PossibleMatchHelper *relationship in _matchRelationships) {
                    NSLog(@"TableView Reload run");
                    NSLog(@"Match Relationships Count before table animation: %lu", (unsigned long)[_matchRelationships count]);
                    NSInteger position = [_matchRelationships indexOfObject:relationship];
                    NSLog(@"Position: %ld", (long)position);
                    //NSIndexPath *indexPath = [NSIndexPath indexPathForItem:position inSection:0];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:position inSection:0];
                    NSLog(@"IndexPath: %@", indexPath);
                    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    NSLog(@"TableView insertRow run");
                    //[self generateMatchMessage]; //<-- Don't need this?
                }
            [self.tableView endUpdates];
             
        }
    }*/
    
    for (UserParseHelper *match in _posibleMatchesArray) {
        _matchUser = match;
        [self matchGender];
    }
    
    [self fetchAllUserMatchRelationships];
    [self.tableView reloadData];
}

- (void)findMatches:(NSMutableArray *)matches
{
    [_matchButtonLabel setHidden:NO];
    [_matchedLabel setHidden:NO];
    
    NSString *matchNum = [[NSString alloc] init];
    if ([matches count] == 1) {
        matchNum = @"Match";
    } else matchNum = @"Matches";
    
    NSString *matchTitle = [[NSString alloc] initWithFormat:@"You have %lu %@!", (unsigned long)[matches count], matchNum];
    _matchedLabel.text = matchTitle;
    _matchedLabel.textColor = [UIColor whiteColor];
    
    NSString *buttonTitle = @"Click to View";
    [_matchButtonLabel setTitle:buttonTitle forState:UIControlStateNormal];
}

// Save Match Relationship to Database
- (void) setPossMatchHelper
{
    _otherUser                  = [PossibleMatchHelper object];
    _otherUser.fromUser         = _curUser;
    _otherUser.toUser           = _matchUser;
    _otherUser.toUserEmail      = _matchUser.email;
    _otherUser.fromUserEmail    = _curUser.email;
    _otherUser.matches          = [[NSArray alloc] initWithObjects:_curUser, _matchUser, nil];
    NSLog(@"Possible Matches count: %lu", (unsigned long)[_otherUser.matches count]);
    NSLog(@"Other User: %@", _otherUser.toUserEmail);
    _otherUser.prefCounter = [NSNumber numberWithDouble:_prefCounter];
    _otherUser.totalPrefs = [NSNumber numberWithDouble:_totalPrefs];
    double compatibility = (_prefCounter / _totalPrefs) * 100;
    _otherUser.compatibilityIndex = [NSNumber numberWithDouble:compatibility];
    NSLog(@"%@ compatibility: %@", _otherUser.toUserEmail, _otherUser.compatibilityIndex);
    /*[_otherUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Before Succeeded Other User: %@", _otherUser.toUserEmail);
        if (succeeded) {
            NSLog(@"Before GenMess for %@", _otherUser.toUserEmail);
            [self generateMatchMessage];
        }
    }];*/
    [_otherUser save];
    //[_matchRelationships addObject:_otherUser];
    
}

#pragma mark - MATCH FILTER

- (void)matchGender
{
    _prefCounter = 0;
    _totalPrefs = 0;
    NSString *matchGender = [[NSString alloc] init];
    
    if ([_matchUser.isMale isEqualToString:@"true"]) {
        matchGender = @"Male";
    } else matchGender = @"Female";
    
   
    if ([_curUser.genderPref isEqualToString:@"Both"]) {
        
        [_willBeMatches addObject:_matchUser];
        NSLog(@"User gender: %@", _curUser.genderPref);
        NSLog(@"Match gender: %@", matchGender);
        _prefCounter++;
        _totalPrefs++;
        /*[possMatch saveInBackground];
        possMatch.prefMatchCounter++;
        possMatch.totalPrefs++;*/
        
        //NSLog(@"Poss Match: %@", _otherUser);
        //[self matchBodyType:match];
        //[_otherUser calculateCompatibility:_prefCounter with:_totalPrefs];
        //NSLog(@"Compatibility: %@%%", _otherUser.compatibilityIndex);
        //[self setPossMatchHelper];
        //[self performSegueWithIdentifier:@"viewMatch" sender:nil];
        
        [self matchBodyType];
        //[self matchKids];
        
    } else if ([_curUser.genderPref isEqualToString:matchGender]) {
        [_willBeMatches addObject:_matchUser];
        _prefCounter++;
        _totalPrefs++;
        
        NSLog(@"Just before Save run");
        //[self setPossMatchHelper];
        
        [self matchBodyType];
        //[self matchKids];
        //[self performSegueWithIdentifier:@"viewMatch" sender:nil];
    } else NSLog(@"No match with %@", _matchUser.nickname);
    
    //_totalPrefs++;
    
    //NSLog(@"Pref Counter: %ld Total Prefs: %ld", (long)_prefMatchCounter, (long)_totalPrefs);
}

/* ---------------------------------------------------------------------------
 
            MUST SET UP CHECK TO ENSURE BOOLEAN VALUES AREN'T NIL
 
 -------------------------------------------------------------------------- */

- (void)matchBodyType
{
    NSLog(@"Start MatchBodyType");
    _totalPrefs++;
    
    if([_curUser.bodyTypePref isEqualToString:_matchUser.bodyType]) {
        _prefCounter++;
        //[self matchRelationshipStatus];
        NSLog(@"Equal BodyType Run");
        [self matchAgePreference];
    } else {
        //[self matchRelationshipStatus];
        NSLog(@"NOT Equal BodyType Run");
        [self matchAgePreference];
    }
    
}

- (void)matchAgePreference
{
    NSLog(@"MatchAge Run");
    _totalPrefs++;
    int minAgeDiff = 0;
    int maxAgeDiff = 0;
    
    minAgeDiff += (int)_matchUser.age - (int)_curUser.minAgePref;
    maxAgeDiff += (int)_curUser.maxAgePref - (int)_matchUser.age;
    
    if (minAgeDiff < 0 || maxAgeDiff < 0) {
        NSLog(@"MatchAge equal");
        _prefCounter++;
        [self matchRelationshipStatus];
    } else {
        NSLog(@"MatchAge NOT equal");
        [self matchRelationshipStatus];
    }
    
    NSLog(@" %@ minAgePref: %@ | maxAgePref: %@ ; %@'s age: %@", _curUser.nickname, _curUser.minAgePref, _curUser.maxAgePref, _matchUser.nickname, _matchUser.age);
    NSLog(@"MinAgeDiff: %@, MaxAgeDiff: %@", [NSNumber numberWithInt:minAgeDiff], [NSNumber numberWithInt:maxAgeDiff]);
}

- (void)matchRelationshipStatus
{
    _totalPrefs++;
    
    if ([_curUser.relationshipStatusPref isEqualToString:_matchUser.relationshipStatus]) {
        _prefCounter++;
        NSLog(@"MatchRelatStat equal");
        [self matchRomanticPreference];
    } else {
        NSLog(@"MatchRelatStat NOT equal");
        [self matchRomanticPreference];
    }
}

- (void)matchRomanticPreference
{
    _totalPrefs++;
    
    if ([_curUser.romanticPreference isEqualToString:_matchUser.relationshipType]) {
        _prefCounter++;
        NSLog(@"MatchRomPref equal");
        [self matchKids];
    } else {
        NSLog(@"MatchRomPref NOT equal");
        [self matchKids];
    }
}

- (void)matchKids
{
    _totalPrefs++;
    
    NSLog(@"User KidsPref: %@", _curUser.kidsOkay);
    NSLog(@"Match HasKids: %@", _matchUser.hasKids);
    
    if ([_curUser.kidsOkay isEqualToNumber:_matchUser.hasKids]) {
        _prefCounter++;
        NSLog(@"MatchRomPref equal");
        [self matchDrinking];
    } else {
        NSLog(@"MatchRomPref NOT equal");
        [self matchDrinking];
    }
}

- (void)matchDrinking
{
    _totalPrefs++;
    
    if([_curUser.drinkingOkay isEqualToNumber:_matchUser.drinks]) {
        _prefCounter++;
        NSLog(@"Drink Okay equal");
        [self matchSmoking];
    } else {
        NSLog(@"Drink Okay NOT equal");
        [self matchSmoking];
    }
}

- (void)matchSmoking
{
    _totalPrefs++;
    
    if ([_curUser.smokingOkay isEqualToNumber:_matchUser.smokes]) {
        _prefCounter++;
        NSLog(@"SMoke Okay equal");
        [self matchDrugUse];
    } else {
        NSLog(@"Smoke Okay NOT equal");
        [self matchDrugUse];
    }
}

- (void)matchDrugUse
{
    _totalPrefs++;
    
    if ([_curUser.drugsOkay isEqualToNumber:_matchUser.drugs]) {
        _prefCounter++;
        NSLog(@"Drugs Okay equal");
        [self matchBodyArt];
    } else {
        NSLog(@"Drugs Okay NOT equal");
        [self matchBodyArt];
    }
}

- (void)matchBodyArt
{
    _totalPrefs++;
    
    if ([_curUser.bodyArtOkay isEqualToNumber:_matchUser.bodyArt]) {
        _prefCounter++;
        NSLog(@"BodyArt equal");
        [self compare:_curUser.interests with:_matchUser.interests];
    } else {
        NSLog(@"BodyArt NOT equal");
        [self compare:_curUser.interests with:_matchUser.interests];
    }
    
    NSLog(@"PrefMatchCounter before compare: %ld", (long)_prefCounter);
   
}

- (void)compare:(NSArray *)userPreferences with:(NSArray *)matchPreferences
{
    _totalPrefs += [userPreferences count];
    
    NSLog(@"Total Preferences: %ld", (long)_totalPrefs);
    
    for (NSString *preference in userPreferences) {
        if (userPreferences.count && matchPreferences.count) {
            if ([matchPreferences containsObject:preference]) {
                _prefCounter++;
                NSLog(@"PrefMatchCounter after compare: %ld", (long)_prefCounter);
                [_sharedPrefs addObject:preference];
                NSLog(@"Shared Prefs: %ld", [_sharedPrefs count]);
            }
        }
    }
    
    [self setPossMatchHelper];
}

#pragma mark - MATCH SEGUE

// ----------------------- MATCHING SEGUE PUSHES TO MATCH_VIEW_CONTROLLER --------------------------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"viewMatch"]){
        //if ([[segue identifier] isEqualToString:@"userprofileSee"]) {
        // Move to ViewDidLoad
        NSLog(@"View Profile Pressed");
        MatchViewController *matchVC = [[MatchViewController alloc]init];
        matchVC = segue.destinationViewController;
        PossibleMatchHelper *matchRelationship  = [self.matchRelationships objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        UserParseHelper *match                  = matchRelationship.toUser;
        //matchVC.userFBPic.image             = _toUserParse.photo;
        matchVC.matchUser                       = match;
        matchVC.possibleMatch                   = matchRelationship;
        matchVC.getPhotoArray                   = [NSMutableArray new];
        matchVC.user                            = _curUser;
        
        [matchVC setUserPhotosArray:matchVC.matchUser];
    }
}

- (void)generateMatchMessage // Don't Need?
{
    // Check if a Message already exists
    PFQuery* query = [MessageParse query];
    [query whereKey:@"fromUserParse" equalTo:_matchUser];
    [query whereKey:@"toUserParse" equalTo:_curUser];
    
    PFQuery* query2 = [MessageParse query];
    [query2 whereKey:@"toUserParse" equalTo:_matchUser];
    [query2 whereKey:@"fromUserParse" equalTo:_curUser];
    
    if ([query findObjects].firstObject || [query2 findObjects].firstObject) {
        NSLog(@"Message with %@ exists", _matchUser.nickname);
    } else {
        //NSLog(@"Compatibility with %@ is: %@%%", match.nickname, [NSNumber numberWithDouble:*(_otherUser.compatibilityIndex)]);
        
        MessageParse* message       = [MessageParse object];
        message.fromUserParse       = _curUser;
        message.fromUserParseEmail  = _curUser.email;
        message.toUserParse         = _matchUser;
        message.toUserParseEmail    = _matchUser.email;
        message.text                = @"";
        [message saveInBackground];
        NSLog(@"Created message for %@", _matchUser.nickname);
        /*
        [message saveEventually:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [self findMatches:_willBeMatches]; //<-- Test before matchBodyType
                
                /* // All old Speeddate code below
                self.currShowingProfile = self.backgroundUserProfile;
                [self setPanGestureRecognizer];
                if (self.posibleMatchesArray.firstObject != nil) {
                    [self placeBackgroundProfile];
                } else {
                    [self removeBackgroundMatchCards];
                    self.activityLabel.hidden = NO;
                    [self.activityIndicator startAnimating];
                    [self.view bringSubviewToFront:self.profileView];
                } // <-- End Comment bracket here
         
            }
        }];*/
    }

}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self baedarOff];
}

#pragma mark - TableView Configurations

/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self loadingChat];
    [self reloadView];
}
*/
- (void)receivedNotification:(NSNotification *)notification
{
    [self.usersArray removeAllObjects];
    [self.messages removeAllObjects];
    [self loadingChat];
}

- (void)loadingChat
{
    self.messages = [NSMutableArray new];
    self.filteredAllUsersArray = [NSArray new];
    
    // Query for
    PFQuery *matchQueryFrom = [PossibleMatchHelper query];
    [matchQueryFrom whereKey:@"fromUser" equalTo:_curUser];
    PFQuery *matchQueryTo = [PossibleMatchHelper query];
    [matchQueryTo whereKey:@"toUser" equalTo:_curUser];
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[matchQueryFrom, matchQueryTo]];
    [both orderByDescending:@"createdAt"];
    //[both orderByDescending:@"compatibilityIndex"]; // <-- Won't work for now, need a compatibility attribute on messages somehow
    
    [both findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableSet *users = [NSMutableSet new];
        for (MessageParse *message in objects) {
            if(![message.fromUserParse.objectId isEqualToString:_curUser.objectId]) {
                NSUInteger count = users.count;
                [users addObject:message.fromUserParse];
                if (users.count > count) {
                    [message.fromUserParse fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        [self.messages addObject:message];
                        
                        // Move usersArray up and populate with _otherUser info
                        [self.usersArray addObject:message.fromUserParse];
                        NSInteger position = [self.usersArray indexOfObject:message.fromUserParse];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:position inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }];
                }
            }
            if(![message.toUserParse.objectId isEqualToString:_curUser.objectId]) {
                NSUInteger count = users.count;
                [users addObject:message.toUserParse];
                if (users.count > count) {
                    [message.toUserParse fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        [self.messages addObject:message];
                        [self.usersArray addObject:message.toUserParse];
                        
                        NSInteger position = [self.usersArray indexOfObject:message.toUserParse];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:position inSection:0];
                        
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }];
                }
            }
        }
        [self.tableView reloadData];
    }];
}

- (void)fetchAllUserMatchRelationships
{
    PFQuery *matchQueryFrom = [PossibleMatchHelper query];
    [matchQueryFrom whereKey:@"fromUser" equalTo:_curUser];
    
    PFQuery *matchQueryTo = [PossibleMatchHelper query];
    [matchQueryTo whereKey:@"toUser" equalTo:_curUser];
    
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[matchQueryFrom, matchQueryTo]];
    // Exclude duplicate matches and Blockeds
    
    [both orderByDescending:@"compatibilityIndex"];
    
    
        NSArray *fetchedMatches = [[NSArray alloc] initWithArray:[both findObjects]];
        
        // Add all returned Matches to MatchRelationships
        for (PossibleMatchHelper *match in fetchedMatches) {
            [_matchRelationships addObject:match];
        }
    
    NSLog(@"Total MatchRelationships: %lu", (unsigned long)[_matchRelationships count]);
}

- (void)updateTableView
{
    [_matchRelationships removeAllObjects];
    NSLog(@"UpdateTableView MatchRelationships: %lu", (unsigned long)[_matchRelationships count]);
    [self fetchAllUserMatchRelationships];
    [self.tableView reloadData];
}

#pragma mark TableView Delegate - Includes Blurring

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UserParseHelper *user;
    PossibleMatchHelper *matchedConnection;
    /*
    if (self.filteredAllUsersArray.count) {
        user = [self.filteredAllUsersArray objectAtIndex:indexPath.row];
    } else {
        user = [self.usersArray objectAtIndex:indexPath.row];
    }
    */
    // Get Possible Matches
    matchedConnection = [_matchRelationships objectAtIndex:indexPath.row];
    
    if ([matchedConnection.toUser.objectId isEqualToString:_curUser.objectId]) {
        user = (UserParseHelper *)matchedConnection.fromUser;
    } else user = (UserParseHelper *)matchedConnection.toUser;
    
    user = (UserParseHelper *)user.fetchIfNeeded;
    NSLog(@"Cell User: %@", user.nickname);
    
    NSNumber *yep = [NSNumber numberWithBool:YES];
    [user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        if (!error) {
            
            cell.userImageView.image = [UIImage imageWithData:data];
            cell.userImageView.hidden = YES;
            //[self configureRadialView:cell forConnection:matchedConnection];
            //CGRect frame = CGRectMake(190, 8, 45, 45);
            CGRect frame = CGRectMake(20, 8, 50, 50);
            [matchedConnection configureRadialViewForView:cell.contentView withFrame:frame];
            if (![matchedConnection.usersRevealed isEqualToNumber:yep]) { // <-- Test purposes - change to check isRevealed on Matched User - NOT WORKING
                [self blurImages:cell.userImageView];
        
                if ([user.isMale isEqualToString:@"true"]) {
                    NSString *matchGender = @"M";
                    cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@ - %@", matchGender, user.age, user.bodyType];
                } else {
                    NSString *matchGender = @"F";
                    cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@ - %@ - %@", matchGender, user.age, user.bodyType];
                }
        
            } else{
                NSLog(@"User revealed");
                cell.nameTextLabel.text = user.nickname;
            }
        }
    }];
    // All old code
    /*_matchedUsers = [[NSArray alloc] initWithObjects:_curUser, user, nil];
    PFQuery *possMatch1 = [PossibleMatchHelper query];
    [possMatch1 whereKey:@"matches" containsAllObjectsInArray:_matchedUsers];
    //[possMatch1 findObjects];
    [possMatch1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //for (PossibleMatchHelper *match in objects) {
        _possibleMatch = [objects objectAtIndex:0];
        [self configureRadialView:cell forConnection:_possibleMatch];
        //}
        NSNumber *yep = [NSNumber numberWithBool:YES];
        if (![_possibleMatch.usersRevealed isEqualToNumber:yep]) { // <-- Test purposes - change to check isRevealed on Matched User - NOT WORKING
            [self blurImages:cell.userImageView];
            
            if ([user.isMale isEqualToString:@"true"]) {
                NSString *matchGender = @"Male";
                cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, user.age];
            } else {
                NSString *matchGender = @"Female";
                cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, user.age];
            }
            
        } else{
            NSLog(@"User revealed");
            cell.nameTextLabel.text = user.nickname;
        }
        
        
        [user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            
            cell.userImageView.image = [UIImage imageWithData:data];
            
        }];
    }];
    */
    //[self setPossibleMatchesFromMessages:_matchedUsers for:cell];
    
    
    // Revealed conditional -----------------------------------------------------
    
    
    
    // ----------------------------------------------------------------------------
    
    //cell.nameTextLabel.textColor = WHITE_COLOR;
    cell.nameTextLabel.textColor = RED_LIGHT;
    cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width / 2;
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.layer.borderWidth = 1.0,
    cell.userImageView.layer.borderColor = WHITE_COLOR.CGColor;
    
    /*
    UIImageView *accesory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accesory"]];
    accesory.frame = CGRectMake(15, 0, 15, 15);
    accesory.contentMode = UIViewContentModeScaleAspectFit;
    cell.accessoryView = accesory;
    
    MessageParse *message = [self.messages objectAtIndex:indexPath.row];
    cell.lastMessageLabel.text = message.text;
    if (!message.text && message.image) {
        cell.lastMessageLabel.text = @"Image";
    }
    if (!message.read && [message.toUserParse.objectId isEqualToString:_curUser.objectId]) {
        //cell.lastMessageLabel.textColor = WHITE_COLOR;
        cell.dateLabel.textColor = [UIColor lightGrayColor];
    } else {
        //cell.lastMessageLabel.textColor = WHITE_COLOR;
        cell.dateLabel.textColor = [UIColor lightGrayColor];
    }
    //cell.dateLabel.textColor = WHITE_COLOR;
    cell.dateLabel.textColor = RED_LIGHT;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    if ([[message createdAt] timeIntervalSinceNow] * -1 < SECONDS_DAY) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    
    cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
    */
    
    UIView *bgColorView = [[UIView alloc] init];
    //bgColorView.backgroundColor = RED_COLOR;
    bgColorView.backgroundColor = WHITE_COLOR;
    [cell setSelectedBackgroundView:bgColorView];
    
    cell.lastMessageLabel.text = @"";
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    dateFormatter.dateStyle = NSDateFormatterShortStyle;
    cell.dateLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    
    return cell;
}

#pragma mark - Blur Images

- (void)blurImages:(UIImageView *)imageView
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = imageView.bounds;
    [imageView addSubview:visualEffectView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Search Textfield
    /*
    if (self.searchTextField.text.length) {
        return self.filteredAllUsersArray.count;
    }
    */
    if (_usersArray.count) {
        userSingleton.numberOfConvos = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)_usersArray.count];
    }
    
    //return [_posibleMatchesArray count];
    return [_matchRelationships count];
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
        [query whereKey:@"toUser" equalTo:_curUser];
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
        possibleMatch.fromUser = _curUser;
        possibleMatch.fromUserEmail = _curUser.email;
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
        message.toUserParse = _curUser;
        message.toUserParseEmail = _curUser.email;
        message.text = @"";
        PFQuery* query = [PossibleMatchHelper query];
        [query whereKey:@"fromUser" equalTo:self.currShowingProfile];
        [query whereKey:@"toUser" equalTo:_curUser];
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
        possibleMatch.fromUser = _curUser;
        possibleMatch.toUser = self.currShowingProfile;
        possibleMatch.toUserEmail = self.currShowingProfile.email;
        possibleMatch.fromUserEmail = _curUser.email;
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

- (IBAction)pushToBaedar:(id)sender {
    NSLog(@"BlockedUser Array count: %lu", (unsigned long)[_curUser.blockedUsers count]);
    [_curUser.blockedUsers removeAllObjects];
    [_curUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"Users unBlocked, BlockedUser Array count: %lu", (unsigned long)[_curUser.blockedUsers count]);
        }
    }];
}
@end