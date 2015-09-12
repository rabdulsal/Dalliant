//
//  ProfileTableVC.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/13/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "ProfileTableVC.h"
#import "UserParseHelper.h"
#import <ActionSheetDistancePicker.h>

@interface ProfileTableVC () <UIAlertViewDelegate>
{
    BOOL *buttonsDisabled;
    NSMutableArray *preferenceStrings;
    NSDictionary *userSnapshotInfo;
}
@property UserParseHelper *mainUser;
@property (nonatomic) UISegmentedControl *bodyTypeControl;
@property (nonatomic) UISegmentedControl *relationshipStatusControl;
@property (nonatomic) UISegmentedControl *relationshipTypeControl;
@property (nonatomic) UIButton *saveProfileButton;
@property (weak, nonatomic) IBOutlet UILabel *userAbout;
@property (weak, nonatomic) IBOutlet UILabel *userEmployment;
@property (weak, nonatomic) IBOutlet UILabel *userEducation;
@property (weak, nonatomic) IBOutlet UILabel *minHeightFeet;
@property (weak, nonatomic) IBOutlet UILabel *minHeightInches;
@property (weak, nonatomic) IBOutlet UILabel *maxHeightFeet;
@property (weak, nonatomic) IBOutlet UILabel *maxHeightInches;

- (IBAction)minHeightSelect:(id)sender;
- (IBAction)maxHeightSelect:(id)sender;


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
         
     }];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)minHeightSelect:(id)sender {
    
    int footHeight;
    int inchHeight;
    [ActionSheetDistancePicker showPickerWithTitle:@"Your Height"
                                     bigUnitString:@"ft"
                                        bigUnitMax:6
                                   selectedBigUnit:footHeight
                                   smallUnitString:@"in"
                                      smallUnitMax:10
                                 selectedSmallUnit:inchHeight
                                            target:self
                                            action:@selector(setMinHeightFeet:andInches:) origin:sender];
}

- (IBAction)maxHeightSelect:(id)sender {
    
    int footHeight;
    int inchHeight;
    [ActionSheetDistancePicker showPickerWithTitle:@"Select Length"
                                     bigUnitString:@"ft"
                                        bigUnitMax:6
                                   selectedBigUnit:footHeight
                                   smallUnitString:@"in"
                                      smallUnitMax:12
                                 selectedSmallUnit:inchHeight
                                            target:self
                                            action:@selector(setMaxHeightFeet:andInches:) origin:sender];
}

- (void)setMinHeightFeet:(NSNumber *)feet andInches:(NSNumber *)inches
{
    if ([inches integerValue] > 11) {
        
        //Trigger AlertView error if inches > 11
        NSString *alertTitle = [[NSString alloc] initWithFormat:@"Height Error :("];
        NSString *alertMessage = [[NSString alloc] initWithFormat:@"Woah there Beanstalk.....we get you're tall, but please enter an Inch-Height less than 11 inches"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        alert.tag = 1;
        [alert show];
        
    } else if ([feet integerValue] < 4){
        //Trigger AlertView error if inches > 11
        NSString *alertTitle = [[NSString alloc] initWithFormat:@"Height Error :("];
        NSString *alertMessage = [[NSString alloc] initWithFormat:@"Sorry but you have to be at least 4 feet to go on this ride my friend."];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        alert.tag = 2;
        [alert show];
    } else {
        
    self.minHeightFeet.text         = [[NSString alloc] initWithFormat:@"%@",feet];
    self.minHeightInches.text       = [[NSString alloc] initWithFormat:@"%@",inches];
    self.mainUser.userHeightFeet    = self.minHeightFeet.text;
    self.mainUser.userHeightInches  = self.minHeightInches.text;
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Clicked 'Okay' AlertView Error");
    
    if _mainUser.userHeightFeet
    self.minHeightFeet.text     = @"0";
    self.minHeightInches.text   = @"0";
}

- (void)setMaxHeightFeet:(NSNumber *)feet andInches:(NSNumber *)inches
{
    self.maxHeightFeet.text = [[NSString alloc] initWithFormat:@"%@",feet];
    self.maxHeightInches.text = [[NSString alloc] initWithFormat:@"%@",inches];
    
    //Trigger AlertView error if inches > 11
}

- (void)buildSegmentControls
{
    // Body Type
    NSArray *bodyArray = [NSArray arrayWithObjects: @"Skinny", @"Average", @"Fit", @"XL", nil];
    _bodyTypeControl = [[UISegmentedControl alloc] initWithItems:bodyArray];
    _bodyTypeControl.frame = CGRectMake(15, 234, 291, 29);
    _bodyTypeControl.tintColor = RED_LIGHT;
    //_bodyTypeControl.segmentedControlStyle = UISegmentedControlStylePlain;
    [_bodyTypeControl addTarget:self action:@selector(BodyTypeButtonPressed:) forControlEvents: UIControlEventValueChanged];
    
    // Relationship Status
    NSArray *statusArray = [NSArray arrayWithObjects: @"Single", @"Dating", @"Divorced", nil];
    _relationshipStatusControl = [[UISegmentedControl alloc] initWithItems:statusArray];
    _relationshipStatusControl.frame = CGRectMake(15, 422, 291, 29);
    _relationshipStatusControl.tintColor = RED_LIGHT;
    //_relationshipStatusControl.segmentedControlStyle = UISegmentedControlStylePlain;
    [_relationshipStatusControl addTarget:self action:@selector(RelationshipStatusPressed:) forControlEvents: UIControlEventValueChanged];
    
    // Relationship Type
    NSArray *typeArray = [NSArray arrayWithObjects: @"Company", @"Friend", @"Relationship", nil];
    _relationshipTypeControl = [[UISegmentedControl alloc] initWithItems:typeArray];
    _relationshipTypeControl.frame = CGRectMake(15, 490, 291, 29);
    _relationshipTypeControl.tintColor = RED_LIGHT;
    //_relationshipTypeControl.segmentedControlStyle = UISegmentedControlStylePlain;
    [_relationshipTypeControl addTarget:self action:@selector(RelationshipTypePressed:) forControlEvents: UIControlEventValueChanged];
    
    // Save Button
    _saveProfileButton = [[UIButton alloc] initWithFrame:CGRectMake(15, 1268, 291, 50)];
    [_saveProfileButton setTitle:@"Save Profile" forState:UIControlStateNormal];
    [_saveProfileButton setTitle:@"Saved!" forState:UIControlStateSelected];
    _saveProfileButton.backgroundColor = [UIColor lightGrayColor];
    [_saveProfileButton addTarget:self action:@selector(SaveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_bodyTypeControl];
    [self.view addSubview:_relationshipStatusControl];
    [self.view addSubview:_relationshipTypeControl];
    [self.view addSubview:_saveProfileButton];
}

- (void)unSave
{
    [_saveProfileButton setSelected:NO];
    _saveProfileButton.backgroundColor = [UIColor lightGrayColor];
}

#pragma mark - Segmented Controls - Actions

- (void)BodyTypeButtonPressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            self.mainUser.bodyType = @"Skinny";
            [self unSave];
            break;
        case 1:
            self.mainUser.bodyType = @"Average";
            [self unSave];
            break;
        case 2:
            self.mainUser.bodyType = @"Fit";
            [self unSave];
            break;
        case 3:
            self.mainUser.bodyType = @"XL";
            [self unSave];
            break;
    }
}

- (void)RelationshipStatusPressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            _mainUser.relationshipStatus = @"Single";
            [self unSave];
            break;
        case 1:
            _mainUser.relationshipStatus = @"Dating";
            [self unSave];
            break;
        case 2:
            _mainUser.relationshipStatus = @"Divorced";
            [self unSave];
            break;
    }
}

- (void)RelationshipTypePressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            _mainUser.relationshipType = @"Company";
            [self unSave];
            break;
        case 1:
            _mainUser.relationshipType = @"Friend";
            [self unSave];
            break;
        case 2:
            _mainUser.relationshipType = @"Relationship";
            [self unSave];
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
    _userAbout.text         = _mainUser.desc;
    _userEmployment.text    = [_mainUser userWork];
    _userEducation.text     = [_mainUser userSchool];
    _minHeightFeet.text     = _mainUser.userHeightFeet;
    _minHeightInches.text   = _mainUser.userHeightInches;
    //_userEmployment.text    = _mainUser.school;
    //_userEducation.text     = _mainUser.work;
    
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
    if ([_mainUser.animalsPref isEqualToNumber:yep]) {
        [self buttonSelected:_animalLabel];
    }
    
    if ([_mainUser.artsPref isEqualToNumber:yep]) {
        [self buttonSelected:_artsLabel];
    }
    
    if ([_mainUser.beerPref isEqualToNumber:yep]) {
        [self buttonSelected:_beerLabel];
    }
    
    if ([_mainUser.bookClubPref isEqualToNumber:yep]) {
        [self buttonSelected:_bookClubLabel];
    }
    
    if ([_mainUser.cookingPref isEqualToNumber:yep]) {
        [self buttonSelected:_cookingLabel];
    }
    
    if ([_mainUser.dancingPref isEqualToNumber:yep]) {
        [self buttonSelected:_dancingLabel];
    }
    
    if ([_mainUser.diningOutPref isEqualToNumber:yep]) {
        [self buttonSelected:_diningOutLabel];
    }
    
    if ([_mainUser.hikingPref isEqualToNumber:yep]) {
        [self buttonSelected:_hikingOutdoorsLabel];
    }
    
    if ([_mainUser.lecturesPref isEqualToNumber:yep]) {
        [self buttonSelected:_lecturesTalksLabel];
    }
    
    if ([_mainUser.moviesPref isEqualToNumber:yep]) {
        [self buttonSelected:_moviesLabel];
    }
    
    if ([_mainUser.musicConcertsPref isEqualToNumber:yep]) {
        [self buttonSelected:_musicConcertLabel];
    }
    
    if ([_mainUser.operaPref isEqualToNumber:yep]) {
        [self buttonSelected:_operaTheatreLabel];
    }
    
    if ([_mainUser.religiousPref isEqualToNumber:yep]) {
        [self buttonSelected:_spiritualLabel];
    }
    
    if ([_mainUser.sportsPref isEqualToNumber:yep]) {
        [self buttonSelected:_sportsLabel];
    }
    
    if ([_mainUser.techPref isEqualToNumber:yep]) {
        [self buttonSelected:_techGadgetsLabel];
    }
    
    if ([_mainUser.travelPref isEqualToNumber:yep]) {
        [self buttonSelected:_travelLabel];
    }
    
    if ([_mainUser.volunteerPref isEqualToNumber:yep]) {
        [self buttonSelected:_volunteeringLabel];
    }
    
    if ([_mainUser.workoutPref isEqualToNumber:yep]) {
        [self buttonSelected:_workoutLabel];
    }
    
    [self unSave];
   // } // End buttonDisabled conditional*/
}

#pragma mark - UI Switches

- (IBAction)kidStatusToggle:(id)sender {
    if (_hasKidsFilter.on) {
        _mainUser.hasKids = [NSNumber numberWithBool:YES];
    } else {
        _mainUser.hasKids = [NSNumber numberWithBool:NO];
    }
    [self unSave];
}

- (IBAction)drinkPreferenceToggle:(id)sender {
    if (_drinksFilter.on) {
        _mainUser.drinks = [NSNumber numberWithBool:YES];
    } else  _mainUser.drinks = [NSNumber numberWithBool:NO];
    [self unSave];
}

- (IBAction)smokesPreferenceToggle:(id)sender {
    if (_smokesCigsFilter.on) {
        _mainUser.smokes = [NSNumber numberWithBool:YES];
    } else  _mainUser.smokes = [NSNumber numberWithBool:NO];
    [self unSave];
}

- (IBAction)drugPreferenceToggle:(id)sender {
    if (_takesDrugsFilter.on) {
        _mainUser.drugs = [NSNumber numberWithBool:YES];
    } else  _mainUser.drugs = [NSNumber numberWithBool:NO];
    [self unSave];
}

- (IBAction)tatooPreferenceToggle:(id)sender {
    if (_hasBodyArtFilter.on) {
        _mainUser.bodyArt = [NSNumber numberWithBool:YES];
    } else  _mainUser.bodyArt = [NSNumber numberWithBool:NO];
    [self unSave];
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
        //userPreference.backgroundColor = RED_LIGHT;
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
    [self unSave];
    
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

- (void)storeUnpressedButtons
{
    // Set Segment Controls when left un-pressed
    
    if (_bodyTypeControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        _mainUser.bodyType = @"Skinny";
    }
    
    if (_relationshipStatusControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        _mainUser.relationshipStatus = @"Single";
    }
    
    if (_relationshipTypeControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        _mainUser.relationshipType = @"Company";
    }
    
    // Set Switches when left un-pressed
    
    if (!_hasKidsFilter.on && _mainUser.hasKids == nil) {
        _mainUser.hasKids = [NSNumber numberWithBool:NO];
    }
    if (!_drinksFilter.on && _mainUser.drinks == nil) {
        _mainUser.drinks = [NSNumber numberWithBool:NO];
    } 
    if (!_smokesCigsFilter.on && _mainUser.smokes == nil) {
        _mainUser.smokes = [NSNumber numberWithBool:NO];
    } 
    if (!_takesDrugsFilter.on && _mainUser.drugs == nil) {
        _mainUser.drugs = [NSNumber numberWithBool:NO];
    } 
    if (!_hasBodyArtFilter.on && _mainUser.bodyArt == nil) {
        _mainUser.bodyArt = [NSNumber numberWithBool:NO];
    }
}

- (void)SaveButtonPressed:(UIButton *)button
{
    [_saveProfileButton setSelected:YES];
    _saveProfileButton.backgroundColor = RED_LIGHT;
    [self convertPreferenceButtons:_userPrefs];
    //_mainUser.interests = preferenceStrings;
    _mainUser.interests = [[[NSSet alloc] initWithArray:preferenceStrings] allObjects];
    
    [self storeUnpressedButtons];
    
    [_mainUser saveInBackground];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self storeUnpressedButtons];
    
    [_mainUser saveInBackground];
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
