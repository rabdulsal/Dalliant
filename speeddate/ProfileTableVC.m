//
//  ProfileTableVC.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/13/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "ProfileTableVC.h"
#import "UserParseHelper.h"

@interface ProfileTableVC ()
{
    BOOL *buttonsDisabled;
    NSMutableArray *preferenceStrings;
    NSDictionary *userSnapshotInfo;
}
@property UserParseHelper *mainUser;
@property (nonatomic) UISegmentedControl *bodyTypeControl;
@property (nonatomic) UISegmentedControl *relationshipStatusControl;
@property (nonatomic) UISegmentedControl *relationshipTypeControl;
@end

@implementation ProfileTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [User singleObj];
    
    _allPrefs = [[NSMutableArray alloc] initWithObjects:_animalLabel,
                 _artsLabel,
                 _beerLabel,
                 _bookClubLabel,
                 _cookingLabel,
                 _dancingLabel,
                 _diningOutLabel,
                 _hikingOutdoorsLabel,
                 _lecturesTalksLabel,
                 _musicConcertLabel,
                 _operaTheatreLabel,
                 _spiritualLabel,
                 _sportsLabel,
                 _techGadgetsLabel,
                 _travelLabel,
                 _volunteeringLabel,
                 _moviesLabel,
                 _workoutLabel,
                 nil];
    _userPrefs = [[NSMutableArray alloc] init];
    
    //[self assignTagNumbers:_allPrefs];
    
    _animalLabel.tag            = 1;
    _artsLabel.tag              = 2;
    _beerLabel.tag              = 3;
    _bookClubLabel.tag          = 4;
    _cookingLabel.tag           = 5;
    _dancingLabel.tag           = 6;
    _diningOutLabel.tag         = 7;
    _lecturesTalksLabel.tag     = 8;
    _hikingOutdoorsLabel.tag    = 9;
    _musicConcertLabel.tag      = 10;
    _operaTheatreLabel.tag      = 11;
    _spiritualLabel.tag         = 12;
    _sportsLabel.tag            = 13;
    _techGadgetsLabel.tag       = 14;
    _travelLabel.tag            = 15;
    _volunteeringLabel.tag      = 16;
    _moviesLabel.tag            = 17;
    _workoutLabel.tag           = 18;
    
    preferenceStrings = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self buildSegmentControls];
    
    PFQuery *query = [UserParseHelper query];
    [query getObjectInBackgroundWithId:[UserParseHelper currentUser].objectId
                                 block:^(PFObject *object, NSError *error)
     {
         self.mainUser = (UserParseHelper *)object;
         
         [self checkAndSetPreferenceValues];
         NSLog(@"HasKids Class %@", [_mainUser.hasKids class]);
     }];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)buildSegmentControls
{
    // Body Type
    NSArray *bodyArray = [NSArray arrayWithObjects: @"Skinny", @"Average", @"Fit", @"XL", nil];
    _bodyTypeControl = [[UISegmentedControl alloc] initWithItems:bodyArray];
    _bodyTypeControl.frame = CGRectMake(15, 60, 291, 29);
    //_bodyTypeControl.segmentedControlStyle = UISegmentedControlStylePlain;
    [_bodyTypeControl addTarget:self action:@selector(BodyTypeButtonPressed:) forControlEvents: UIControlEventValueChanged];
    
    // Relationship Status
    NSArray *statusArray = [NSArray arrayWithObjects: @"Single", @"Dating", @"Divorced", nil];
    _relationshipStatusControl = [[UISegmentedControl alloc] initWithItems:statusArray];
    _relationshipStatusControl.frame = CGRectMake(15, 218, 291, 29);
    //_relationshipStatusControl.segmentedControlStyle = UISegmentedControlStylePlain;
    [_relationshipStatusControl addTarget:self action:@selector(RelationshipStatusPressed:) forControlEvents: UIControlEventValueChanged];
    
    // Relationship Type
    NSArray *typeArray = [NSArray arrayWithObjects: @"Company", @"Friend", @"Relationship", nil];
    _relationshipTypeControl = [[UISegmentedControl alloc] initWithItems:typeArray];
    _relationshipTypeControl.frame = CGRectMake(15, 290, 291, 29);
    //_relationshipTypeControl.segmentedControlStyle = UISegmentedControlStylePlain;
    [_relationshipTypeControl addTarget:self action:@selector(RelationshipTypePressed:) forControlEvents: UIControlEventValueChanged];
    
    [self.view addSubview:_bodyTypeControl];
    [self.view addSubview:_relationshipStatusControl];
    [self.view addSubview:_relationshipTypeControl];
}

#pragma mark - Segmented Controls - Actions

- (void)BodyTypeButtonPressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            self.mainUser.bodyType = @"Skinny";
            [self.mainUser saveInBackground];
            break;
        case 1:
            self.mainUser.bodyType = @"Average";
            [self.mainUser saveInBackground];
            break;
        case 2:
            self.mainUser.bodyType = @"Fit";
            [self.mainUser saveInBackground];
            break;
        case 3:
            self.mainUser.bodyType = @"XL";
            [self.mainUser saveInBackground];
            break;
    }
}

- (void)RelationshipStatusPressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            _mainUser.relationshipStatus = @"Single";
            [_mainUser saveInBackground];
            break;
        case 1:
            _mainUser.relationshipStatus = @"Dating";
            [_mainUser saveInBackground];
            break;
        case 2:
            _mainUser.relationshipStatus = @"Divorced";
            [_mainUser saveInBackground];
            break;
    }
}

- (void)RelationshipTypePressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            _mainUser.relationshipType = @"Company";
            [_mainUser saveInBackground];
            break;
        case 1:
            _mainUser.relationshipType = @"Friend";
            [_mainUser saveInBackground];
            break;
        case 2:
            _mainUser.relationshipType = @"Relationship";
            [_mainUser saveInBackground];
            break;
    }
}

// Add (NSDictionary *)userInfo
- (void)checkAndSetPreferenceValues
{
    /* ----------------------------------------------
     
     REFACTOR TO USE INDEX NUMBERS FOR USER FILTER/PREFERENCE VALUES
     AND TAG NUMERICAL TAGS FOR BUTTONS & LABELS TO UTILIZE LOOPS
     
     ------------------------------------------------*/
    // Access with userInfo[@"personal_info"]
    NSLog(@"Check and Set run");
    // Check settings based on Toggle and Control State and change conditionals as such MUST REFACTOR
    if (self.mainUser.bodyType) {
        NSLog(@"Body Type Set");
        if ([_mainUser.bodyType isEqualToString:@"Skinny"]) {
            [_bodyTypeControl setSelectedSegmentIndex:0];
        } else if ([_mainUser.bodyType isEqualToString:@"Average"]) {
            [_bodyTypeControl setSelectedSegmentIndex:1];
        } else if ([_mainUser.bodyType isEqualToString:@"Fit"]) {
            [_bodyTypeControl setSelectedSegmentIndex:2];
        } else if ([_mainUser.bodyType isEqualToString:@"XL"]) {
            [_bodyTypeControl setSelectedSegmentIndex:3];
        }
        
    }
    
    if (self.mainUser.relationshipStatus) {
        NSLog(@"Relationship Status Set");
        if ([_mainUser.relationshipStatus isEqualToString:@"Single"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:0];
        } else if ([_mainUser.relationshipStatus isEqualToString:@"Dating"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:1];
        } else if ([_mainUser.relationshipStatus isEqualToString:@"Divorced"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:2];
        }
    }
    
    if (self.mainUser.relationshipType) {
        NSLog(@"Relationship Type Set");
        if ([_mainUser.relationshipType isEqualToString:@"Company"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:0];
        } else if ([_mainUser.relationshipType isEqualToString:@"Friend"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:1];
        } else if ([_mainUser.relationshipType isEqualToString:@"Relationship"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:2];
        }
    }
    
    NSNumber *yep = [[NSNumber alloc] initWithBool:true];
    
    if ([self.mainUser.hasKids isEqualToNumber:yep]) {
        NSLog(@"HasKids: Equal");
        [_hasKidsFilter setOn:YES];
    } else {
        NSLog(@"HasKids NOT Equal");
        [self.hasKidsFilter setOn:NO];
    }
    
    if ([_mainUser.drinks isEqualToNumber:yep]) {
        [_drinksFilter setOn:YES];
       // _mainUser.likeToDrink = @"Yes";
    } else {
        [_drinksFilter setOn:NO];
        //_mainUser.likeToDrink = @"No";
    }
    
    if ([_mainUser.smokes isEqualToNumber:yep]) {
        [_smokesCigsFilter setOn:YES];
        //_mainUser.smokesCigs = @"Yes";
    } else {
        [_smokesCigsFilter setOn:NO];
        //_mainUser.smokesCigs = @"No";
    }
    
    if ([_mainUser.drugs isEqualToNumber:yep]) {
        [_takesDrugsFilter setOn:YES];
        //_mainUser.usesDrugs = @"Yes";
    } else {
        [_takesDrugsFilter setOn:NO];
        //_mainUser.usesDrugs = @"No";
    }
    
    if ([_mainUser.bodyArt isEqualToNumber:yep]) {
        [_hasBodyArtFilter setOn:YES];
        //_mainUser.hasTatoos = @"Yes";
    } else {
        [_hasBodyArtFilter setOn:NO];
       // _mainUser.hasTatoos = @"No";
    }
    
    // Pref Buttons
    //if (_userPrefs.count <= 5) {
    if (_mainUser.animalsPref) {
        [self buttonSelected:_animalLabel];
    }
    
    if (_mainUser.artsPref) {
        [self buttonSelected:_artsLabel];
    }
    
    if (_mainUser.beerPref) {
        [self buttonSelected:_beerLabel];
    }
    
    if (_mainUser.bookClubPref) {
        [self buttonSelected:_bookClubLabel];
    }
    
    if (_mainUser.cookingPref) {
        [self buttonSelected:_cookingLabel];
    }
    
    if (_mainUser.dancingPref) {
        [self buttonSelected:_dancingLabel];
    }
    
    if (_mainUser.diningOutPref) {
        [self buttonSelected:_diningOutLabel];
    }
    
    if (_mainUser.hikingPref) {
        [self buttonSelected:_hikingOutdoorsLabel];
    }
    
    if (_mainUser.lecturesPref) {
        [self buttonSelected:_lecturesTalksLabel];
    }
    
    if (_mainUser.moviesPref) {
        [self buttonSelected:_moviesLabel];
    }
    
    if (_mainUser.musicConcertsPref) {
        [self buttonSelected:_musicConcertLabel];
    }
    
    if (_mainUser.operaPref) {
        [self buttonSelected:_operaTheatreLabel];
    }
    
    if (_mainUser.religiousPref) {
        [self buttonSelected:_spiritualLabel];
    }
    
    if (_mainUser.sportsPref) {
        [self buttonSelected:_sportsLabel];
    }
    
    if (_mainUser.techPref) {
        [self buttonSelected:_techGadgetsLabel];
    }
    
    if (_mainUser.travelPref) {
        [self buttonSelected:_travelLabel];
    }
    
    if (_mainUser.volunteerPref) {
        [self buttonSelected:_volunteeringLabel];
    }
    
    if (_mainUser.workoutPref) {
        [self buttonSelected:_workoutLabel];
    }
    
    [_mainUser saveInBackground];
   // } // End buttonDisabled conditional*/
}

#pragma mark - UI Switches

- (IBAction)kidStatusToggle:(id)sender {
    if (_hasKidsFilter.on) {
        _mainUser.hasKids = [NSNumber numberWithBool:YES];
    } else {
        _mainUser.hasKids = [NSNumber numberWithBool:NO];
    }
    [_mainUser saveInBackground];
}

- (IBAction)drinkPreferenceToggle:(id)sender {
    if (_drinksFilter.on) {
        _mainUser.drinks = [NSNumber numberWithBool:YES];
    } else  _mainUser.drinks = [NSNumber numberWithBool:NO];
    [_mainUser saveInBackground];
}

- (IBAction)smokesPreferenceToggle:(id)sender {
    if (_smokesCigsFilter.on) {
        _mainUser.smokes = [NSNumber numberWithBool:YES];
    } else  _mainUser.smokes = [NSNumber numberWithBool:NO];
    [_mainUser saveInBackground];
}

- (IBAction)drugPreferenceToggle:(id)sender {
    if (_takesDrugsFilter.on) {
        _mainUser.drugs = [NSNumber numberWithBool:YES];
    } else  _mainUser.drugs = [NSNumber numberWithBool:NO];
    [_mainUser saveInBackground];
}

- (IBAction)tatooPreferenceToggle:(id)sender {
    if (_hasBodyArtFilter.on) {
        _mainUser.bodyArt = [NSNumber numberWithBool:YES];
    } else  _mainUser.bodyArt = [NSNumber numberWithBool:NO];
    [_mainUser saveInBackground];
}

#pragma mark - Interests & Hobbies

- (IBAction)animalsToggle:(id)sender {
    if (_animalLabel.isSelected) {
        _mainUser.animalsPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_animalLabel];
    } else {
        _mainUser.animalsPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_animalLabel];
    }
}

- (IBAction)artsToggle:(id)sender {
    if (_artsLabel.isSelected) {
        [self buttonDeSelected:_artsLabel];
        _mainUser.artsPref = [NSNumber numberWithBool:NO];;
    } else {
        [self buttonSelected:_artsLabel];
        _mainUser.artsPref = [NSNumber numberWithBool:YES];
    }
}

- (IBAction)beerToggle:(id)sender {
    if (_beerLabel.isSelected) {
        _mainUser.beerPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_beerLabel];
    } else {
        _mainUser.beerPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_beerLabel];
    }
}

- (IBAction)bookClubToggle:(id)sender {
    if (_bookClubLabel.isSelected) {
        _mainUser.bookClubPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_bookClubLabel];
    } else {
        _mainUser.bookClubPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_bookClubLabel];
    }
}

- (IBAction)cookingToggle:(id)sender {
    if (_cookingLabel.isSelected) {
        _mainUser.cookingPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_cookingLabel];
    } else {
        _mainUser.cookingPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_cookingLabel];
    }
}

- (IBAction)dancingToggle:(id)sender {
    if (_dancingLabel.isSelected) {
        _mainUser.dancingPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_dancingLabel];
    } else {
        _mainUser.dancingPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_dancingLabel];
    }
}

- (IBAction)diningClubToggle:(id)sender {
    if (_diningOutLabel.isSelected) {
        _mainUser.diningOutPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_diningOutLabel];
    } else {
        _mainUser.diningOutPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_diningOutLabel];
    }
}

- (IBAction)hikingToggle:(id)sender {
    if (_hikingOutdoorsLabel.isSelected) {
        _mainUser.hikingPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_hikingOutdoorsLabel];
    } else {
        _mainUser.hikingPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_hikingOutdoorsLabel];
    }
}

- (IBAction)lecturesToggle:(id)sender {
    if (_lecturesTalksLabel.isSelected) {
        _mainUser.lecturesPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_lecturesTalksLabel];
    } else {
        _mainUser.lecturesPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_lecturesTalksLabel];
    }
}

- (IBAction)musicToggle:(id)sender {
    if (_musicConcertLabel.isSelected) {
        _mainUser.musicConcertsPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_musicConcertLabel];
    } else {
        _mainUser.musicConcertsPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_musicConcertLabel];
    }
}

- (IBAction)operaToggle:(id)sender {
    if (_operaTheatreLabel.isSelected) {
        _mainUser.operaPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_operaTheatreLabel];
    } else {
        _mainUser.operaPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_operaTheatreLabel];
    }
}

- (IBAction)religiousToggle:(id)sender {
    if (_spiritualLabel.isSelected) {
        _mainUser.religiousPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_spiritualLabel];
    } else {
        _mainUser.religiousPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_spiritualLabel];
    }
}

- (IBAction)sportsToggle:(id)sender {
    if (_sportsLabel.isSelected) {
        _mainUser.sportsPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_sportsLabel];
    } else {
        _mainUser.sportsPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_sportsLabel];
    }
}

- (IBAction)techToggle:(id)sender {
    if (_techGadgetsLabel.isSelected) {
        _mainUser.techPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_techGadgetsLabel];
    } else {
        _mainUser.techPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_techGadgetsLabel];
    }
}

- (IBAction)travelToggle:(id)sender {
    if (_travelLabel.isSelected) {
        _mainUser.travelPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_travelLabel];
    } else {
        _mainUser.travelPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_travelLabel];
    }
}

- (IBAction)volunteeringToggle:(id)sender {
    if (_volunteeringLabel.isSelected) {
        _mainUser.volunteerPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_volunteeringLabel];
    } else {
        _mainUser.volunteerPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_volunteeringLabel];
    }
}

- (IBAction)moviesToggle:(id)sender {
    if (_moviesLabel.isSelected) {
        _mainUser.moviesPref = [NSNumber numberWithBool:NO];;
        [self buttonDeSelected:_moviesLabel];
    } else {
        _mainUser.moviesPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_moviesLabel];
    }
}

- (IBAction)workoutToggle:(id)sender {
    if (_workoutLabel.isSelected) {
        _mainUser.workoutPref = [NSNumber numberWithBool:NO];
        [self buttonDeSelected:_workoutLabel];
    } else {
        _mainUser.workoutPref = [NSNumber numberWithBool:YES];
        [self buttonSelected:_workoutLabel];
    }
}

#pragma mark - Enable and Disable Preference Buttons

- (void)buttonDeSelected:(UIButton *)userPreference
{
    if (!userPreference.isEnabled) {
        NSLog(@"This button is Disabled");
    } else {
        [userPreference setSelected:NO];
        userPreference.backgroundColor = nil;
        [_userPrefs removeObject:userPreference];
        [_allPrefs addObject:userPreference];
        NSLog(@"User Prefs count: %lu", [_userPrefs count]);
    }
    
    [self checkAllPreferencesAndEnableOrDisableButtons];
}

- (void)buttonSelected:(UIButton *)userPreference
{
    if (!userPreference.isEnabled) {
        NSLog(@"This button is Disabled");
    } else {
        [userPreference setSelected:YES];
        userPreference.backgroundColor = [UIColor blueColor];
        [_allPrefs removeObject:userPreference];
        [_userPrefs addObject:userPreference];
        NSLog(@"User Prefs count: %lu", [_userPrefs count]);
    }
    
    [self checkAllPreferencesAndEnableOrDisableButtons];
}

- (void)checkAllPreferencesAndEnableOrDisableButtons
{
    if ([_userPrefs count] == 5 && !buttonsDisabled) {
        // Disable AllPrefs
        [self disableAllPreferences:_allPrefs];
        NSLog(@"All buttons disabled.");
    } else if ([_userPrefs count] == 4 && buttonsDisabled) {
        [self enableAllPreferences:_allPrefs];
        NSLog(@"All buttons re-enabled.");
    }
    
}

- (void)disableAllPreferences:(NSMutableArray *)preferences
{
    for (UIButton *preference in preferences) {
        preference.enabled = NO;
    }
    buttonsDisabled = true;
}

- (void)enableAllPreferences:(NSMutableArray *)preferences
{
    for (UIButton *preference in preferences) {
        preference.enabled = YES;
    }
    buttonsDisabled = false;
}

- (void)checkAndSetUserEnteredData
{
    // Set Label Values
    //_userDescription.text   = _mainUser.blurb;
    //_userAge.text           = _mainUser.age;
    //_userHeight           = sobj.height
    /*_userFavActivity.text   = sobj.favActivity;
     _userLikesDrinks.text   = sobj.likeToDrink;
     _userHasKids.text       = sobj.haveKids;
     _userHasTatoos.text     = sobj.hasTatoos;*/
    
}

- (void)convertPreferenceButtons:(NSMutableArray *)preferences
{
    for (UIButton *preference in preferences) {
        switch (preference.tag) {
            case 1:
                [preferenceStrings addObject:@"Animals & Pets"];
                break;
            case 2:
                [preferenceStrings addObject:@"Art Galleries & Photography"];
                break;
            case 3:
                [preferenceStrings addObject:@"Beer & Wine-tasting"];
                break;
            case 4:
                [preferenceStrings addObject:@"Book Club & Reading"];
                break;
            case 5:
                [preferenceStrings addObject:@"Cooking"];
                break;
            case 6:
                [preferenceStrings addObject:@"Dancing"];
                break;
            case 7:
                [preferenceStrings addObject:@"Dining-out"];
                break;
            case 8:
                [preferenceStrings addObject:@"Lectures & Conferences"];
                break;
            case 9:
                [preferenceStrings addObject:@"Hiking, Camping, Nature-walks"];
                break;
            case 10:
                [preferenceStrings addObject:@"Music Concerts"];
                break;
            case 11:
                [preferenceStrings addObject:@"Opera & Theatre"];
                break;
            case 12:
                [preferenceStrings addObject:@"Religion & Spirituality"];
                break;
            case 13:
                [preferenceStrings addObject:@"Sports"];
                break;
            case 14:
                [preferenceStrings addObject:@"Tech, Gadgets, Science"];
                break;
            case 15:
                [preferenceStrings addObject:@"Travel"];
                break;
            case 16:
                [preferenceStrings addObject:@"Volunteering, Social-activism, Politics"];
                break;
            case 17:
                [preferenceStrings addObject:@"TV & Movies"];
                break;
            case 18:
                [preferenceStrings addObject:@"Working-out & Exercise"];
                break;
            default:
                [preferenceStrings addObject:@"N/A"];
                break;
        }
        
        NSLog(@"Total PreferenceStrings: %lu", preferenceStrings.count);
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    NSLog(@"Body Type: %@", _mainUser.bodyType);
    NSLog(@"Relationship Status: %@", _mainUser.relationshipStatus);
    NSLog(@"Relationship Type: %@", _mainUser.relationshipType);
    
    // User Preferences
    
    // Convert Pref Buttons to Strings
    /*
    [self convertPreferenceButtons:_userPrefs];
    _mainUser.interests = preferenceStrings;
     
     [self.mainUser saveInBackground];
    /*
    // Check for an existing Parse database then set values and upload to database
    if (_mainUser.userRef) {
        
        //   [self checkAndSetPreferenceValues:user];
        // Store all values to Firebase
        Firebase *personalInfo = [userRef childByAppendingPath:@"personal_info"];
        
        NSDictionary *personal = @{
                                   // About User
                                   @"body_type" : _mainUser.bodyType,
                                   @"have_kids" : _mainUser.haveKids,
                                   @"relationship_status" : _mainUser.relationshipStatus,
                                   @"desired_relationship" : _mainUser.relationshipType,
                                   // Vices
                                   @"drinks" : _mainUser.likeToDrink,
                                   @"smokes" : _mainUser.smokesCigs,
                                   @"drugs" : _mainUser.usesDrugs,
                                   @"body_art" : _mainUser.hasTatoos,
                                   // Interests & Hobbies
                                   @"interests" : preferenceStrings
                                   };
        
        [personalInfo setValue:personal];
        
        [self checkAndSetPreferenceValues];
        
    }*/
}

#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
