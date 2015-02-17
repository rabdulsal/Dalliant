//
//  PreferencesTableViewController.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 11/24/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "PreferencesTableViewController.h"
#import "User.h"
#import "UserParseHelper.h"
#import "NMRangeSlider.h"

@interface PreferencesTableViewController ()
{
    BOOL *buttonsDisabled;
    User *user;
    NSNumber *yup;
    NSNumber *nope;
}
@property UserParseHelper *mainUser;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet NMRangeSlider *labelSlider;
@property (weak, nonatomic) IBOutlet UILabel *lowerLabel;
@property (weak, nonatomic) IBOutlet UILabel *upperLabel;

@end

@implementation PreferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    user = [User singleObj];
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    _maxAgeField.delegate = self;
    _minAgeField.delegate = self;
    
    // Will have to do a check on the User to pre-load Preferences into appropriate Arrays
    
    yup = [NSNumber numberWithBool:YES];
    nope = [NSNumber numberWithBool:NO];
    
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
    
    [self configureLabelSlider];
    
    self.restorationIdentifier = @"PreferencesTableViewController";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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

- (void) configureLabelSlider
{
    self.labelSlider.maximumValue = 100;
    self.labelSlider.minimumValue = 18;
    
    // Store these values to database, then CheckAndSet based on database values
    if (_mainUser.maxAgePref) {
        self.labelSlider.upperValue = [_mainUser.maxAgePref floatValue];
    } else self.labelSlider.upperValue = 100;
    
    if (_mainUser.minAgePref) {
        self.labelSlider.lowerValue = [_mainUser.minAgePref floatValue];
    } self.labelSlider.lowerValue = 18;
    
    self.labelSlider.minimumRange = 10;
}

- (void) updateSliderLabels
{
    // You get get the center point of the slider handles and use this to arrange other subviews
    
    /*CGPoint lowerCenter;
    lowerCenter.x = (self.labelSlider.lowerCenter.x + self.labelSlider.frame.origin.x);
    lowerCenter.y = (self.labelSlider.center.y - 30.0f);
    self.lowerLabel.center = lowerCenter;*/
    self.lowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.lowerValue];
    _mainUser.minAgePref = [NSNumber numberWithFloat:_labelSlider.lowerValue ];
    
    /*CGPoint upperCenter;
    upperCenter.x = (self.labelSlider.upperCenter.x + self.labelSlider.frame.origin.x);
    upperCenter.y = (self.labelSlider.center.y - 30.0f);
    self.upperLabel.center = upperCenter;*/
    self.upperLabel.text = [NSString stringWithFormat:@"%d", (int)self.labelSlider.upperValue];
    _mainUser.maxAgePref = [NSNumber numberWithFloat:_labelSlider.upperValue ];
}

// Handle control value changed events just like a normal slider
- (IBAction)labelSliderChanged:(NMRangeSlider*)sender
{
    [self updateSliderLabels];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (void)checkAndSetPreferenceValues
{
    
    /* ----------------------------------------------
     
     REFACTOR TO USE INDEX NUMBERS FOR USER FILTER/PREFERENCE VALUES
     AND TAG NUMERICAL TAGS FOR BUTTONS & LABELS TO UTILIZE LOOPS
     
     ------------------------------------------------*/
    if (_mainUser.genderPref) {
        if ([_mainUser.genderPref isEqualToString:@"Male"]) {
            [_genderControl setSelectedSegmentIndex:0];
        } else if ([_mainUser.genderPref isEqualToString:@"Female"]) {
            [_genderControl setSelectedSegmentIndex:1];
        } else if ([_mainUser.genderPref isEqualToString:@"Both"]){
            [_genderControl setSelectedSegmentIndex:2];
        }
    }
    /*
    if (_mainUser.minAgePref) {
        _minAgeField.text = [[NSString alloc] initWithFormat:@"%@", _mainUser.minAgePref];
    }
    
    if (_mainUser.maxAgePref) {
        _maxAgeField.text = [[NSString alloc] initWithFormat:@"%@", _mainUser.maxAgePref];
    }
    */
    self.labelSlider.upperValue = [_mainUser.maxAgePref floatValue];
    self.labelSlider.lowerValue = [_mainUser.minAgePref floatValue];
    [self updateSliderLabels];
    
    if([self.view respondsToSelector:@selector(setTintColor:)])
    {
        self.view.tintColor = RED_DEEP;
    }
    
    if (_mainUser.bodyTypePref) {
        if ([_mainUser.bodyTypePref isEqualToString:@"Skinny"]) {
            [_bodyTypeControl setSelectedSegmentIndex:0];
        } else if ([_mainUser.bodyTypePref isEqualToString:@"Average"]) {
            [_bodyTypeControl setSelectedSegmentIndex:1];
        } else if ([_mainUser.bodyTypePref isEqualToString:@"Fit"]) {
            [_bodyTypeControl setSelectedSegmentIndex:2];
        } else if ([_mainUser.bodyTypePref isEqualToString:@"XL"]) {
            [_bodyTypeControl setSelectedSegmentIndex:3];
        }
    }
    
    if (_mainUser.relationshipStatusPref) {
        if ([_mainUser.relationshipStatusPref isEqualToString:@"Single"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:0];
        } else if ([_mainUser.relationshipStatusPref isEqualToString:@"Dating"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:1];
        } else if ([_mainUser.relationshipStatusPref isEqualToString:@"Divorced"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:2];
        }
    }
    
    if (_mainUser.romanticPreference) {
        if ([_mainUser.romanticPreference isEqualToString:@"Company"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:0];
        } else if ([_mainUser.romanticPreference isEqualToString:@"Friend"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:1];
        } else if ([_mainUser.romanticPreference isEqualToString:@"Relationship"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:2];
        }
    }
    
    NSNumber *yeah = [[NSNumber alloc] initWithBool:true];
    
    if ([_mainUser.kidsOkay isEqualToNumber:yeah]) {
        [_hasKidsFilter setOn:YES];
    } else {
        [_hasKidsFilter setOn:NO];
    }
    
    if ([_mainUser.drinkingOkay isEqualToNumber:yeah]) {
        [_drinksFilter setOn:YES];
    } else {
        [_drinksFilter setOn:NO];
    }
    
    if ([_mainUser.smokingOkay isEqualToNumber:yeah]) {
        [_smokesCigsFilter setOn:YES];
    } else {
        [_smokesCigsFilter setOn:NO];
    }
    
    if ([_mainUser.drugsOkay isEqualToNumber:yeah]) {
        [_takesDrugsFilter setOn:YES];
    } else {
        [_takesDrugsFilter setOn:NO];
    }
    
    if ([_mainUser.bodyArtOkay isEqualToNumber:yeah]) {
        [_hasBodyArtFilter setOn:YES];
    } else {
        [_hasBodyArtFilter setOn:NO];
    }
    
    // Pref Buttons <-- May Not Need
    /*
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
    }*/
}

#pragma mark - Segmented Controls - Actions

- (IBAction)genderOptions:(id)sender {
    if (_genderControl.selectedSegmentIndex == 0) {
        _mainUser.genderPref = @"Male";
    } else if (_genderControl.selectedSegmentIndex == 1) {
        _mainUser.genderPref = @"Female";
    } else {
        _mainUser.genderPref = @"Both";
    }
    [_mainUser saveInBackground];
}

- (IBAction)bodyType:(id)sender {
    NSLog(@"Button index: %lu", _bodyTypeControl.selectedSegmentIndex);
    switch (_bodyTypeControl.selectedSegmentIndex) {
        case 0:
            _mainUser.bodyTypePref = @"Skinny";
            [_mainUser saveInBackground];
            break;
        case 1:
            _mainUser.bodyTypePref = @"Average";
            [_mainUser saveInBackground];
            break;
        case 2:
            _mainUser.bodyTypePref = @"Fit";
            [_mainUser saveInBackground];
            break;
        case 3:
            _mainUser.bodyTypePref = @"XL";
            [_mainUser saveInBackground];
            break;
    }
}

- (IBAction)relationshipStatus:(id)sender {
    switch (_relationshipStatusControl.selectedSegmentIndex) {
        case 0:
            _mainUser.relationshipStatusPref = @"Single";
            [_mainUser saveInBackground];
            break;
        case 1:
            _mainUser.relationshipStatusPref= @"Dating";
            [_mainUser saveInBackground];
            break;
        case 2:
            _mainUser.relationshipStatusPref = @"Divorced";
            [_mainUser saveInBackground];
            break;
    }
}

- (IBAction)relationshipType:(id)sender {
    switch (_relationshipTypeControl.selectedSegmentIndex) {
        case 0:
            _mainUser.romanticPreference = @"Company";
            [_mainUser saveInBackground];
            break;
        case 1:
            _mainUser.romanticPreference = @"Friend";
            [_mainUser saveInBackground];
            break;
        case 2:
            _mainUser.romanticPreference = @"Relationship";
            [_mainUser saveInBackground];
            break;
    }
}

#pragma mark - UI Switches

- (IBAction)kidStatusToggle:(id)sender {
    if (_hasKidsFilter.on) {
        _mainUser.kidsOkay = yup;
    } else _mainUser.kidsOkay = nope;
    [_mainUser saveInBackground];

}

- (IBAction)drinkPreferenceToggle:(id)sender {
    if (_drinksFilter.on) {
        _mainUser.drinkingOkay = yup;
    } else  _mainUser.drinkingOkay = nope;
    [_mainUser saveInBackground];
}

- (IBAction)smokesPreferenceToggle:(id)sender {
    if (_smokesCigsFilter.on) {
        _mainUser.smokingOkay = yup;
    } else  _mainUser.smokingOkay = nope;
    [_mainUser saveInBackground];
}

- (IBAction)drugPreferenceToggle:(id)sender {
    if (_takesDrugsFilter.on) {
        _mainUser.drugsOkay = yup;
    } else  _mainUser.drugsOkay = nope;
    [_mainUser saveInBackground];
}

- (IBAction)tatooPreferenceToggle:(id)sender {
    if (_hasBodyArtFilter.on) {
        _mainUser.bodyArtOkay = yup;
    } else  _mainUser.bodyArtOkay = nope;
    [_mainUser saveInBackground];
}

/*
#pragma mark - Interests & Hobbies

- (IBAction)animalsToggle:(id)sender {
    if (_animalLabel.isSelected) {
        _mainUser.animalsPref = false;
        [self buttonDeSelected:_animalLabel];
    } else {
        _mainUser.animalsPref = true;
        [self buttonSelected:_animalLabel];
    }
}

- (IBAction)artsToggle:(id)sender {
    if (_artsLabel.isSelected) {
        [self buttonDeSelected:_artsLabel];
        _mainUser.artsPref = false;
    } else {
        [self buttonSelected:_artsLabel];
        _mainUser.artsPref = true;
    }
}

- (IBAction)beerToggle:(id)sender {
    if (_beerLabel.isSelected) {
        _mainUser.beerPref = false;
        [self buttonDeSelected:_beerLabel];
    } else {
        _mainUser.beerPref = true;
        [self buttonSelected:_beerLabel];
    }
}

- (IBAction)bookClubToggle:(id)sender {
    if (_bookClubLabel.isSelected) {
        _mainUser.bookClubPref = false;
        [self buttonDeSelected:_bookClubLabel];
    } else {
        _mainUser.bookClubPref = true;
        [self buttonSelected:_bookClubLabel];
    }
}

- (IBAction)cookingToggle:(id)sender {
    if (_cookingLabel.isSelected) {
        _mainUser.cookingPref = false;
        [self buttonDeSelected:_cookingLabel];
    } else {
        _mainUser.cookingPref = true;
        [self buttonSelected:_cookingLabel];
    }
}

- (IBAction)dancingToggle:(id)sender {
    if (_dancingLabel.isSelected) {
        _mainUser.dancingPref = false;
        [self buttonDeSelected:_dancingLabel];
    } else {
        _mainUser.dancingPref = true;
        [self buttonSelected:_dancingLabel];
    }
}

- (IBAction)diningClubToggle:(id)sender {
    if (_diningOutLabel.isSelected) {
        _mainUser.diningOutPref = false;
        [self buttonDeSelected:_diningOutLabel];
    } else {
        _mainUser.diningOutPref = true;
        [self buttonSelected:_diningOutLabel];
    }
}

- (IBAction)hikingToggle:(id)sender {
    if (_hikingOutdoorsLabel.isSelected) {
        _mainUser.hikingPref = false;
        [self buttonDeSelected:_hikingOutdoorsLabel];
    } else {
        _mainUser.hikingPref = true;
        [self buttonSelected:_hikingOutdoorsLabel];
    }
}

- (IBAction)lecturesToggle:(id)sender {
    if (_lecturesTalksLabel.isSelected) {
        _mainUser.lecturesPref = false;
        [self buttonDeSelected:_lecturesTalksLabel];
    } else {
        _mainUser.lecturesPref = true;
        [self buttonSelected:_lecturesTalksLabel];
    }
}

- (IBAction)musicToggle:(id)sender {
    if (_musicConcertLabel.isSelected) {
        _mainUser.musicConcertsPref = false;
        [self buttonDeSelected:_musicConcertLabel];
    } else {
        _mainUser.musicConcertsPref = true;
        [self buttonSelected:_musicConcertLabel];
    }
}

- (IBAction)operaToggle:(id)sender {
    if (_operaTheatreLabel.isSelected) {
        _mainUser.operaPref = false;
        [self buttonDeSelected:_operaTheatreLabel];
    } else {
        _mainUser.operaPref = true;
        [self buttonSelected:_operaTheatreLabel];
    }
}

- (IBAction)religiousToggle:(id)sender {
    if (_spiritualLabel.isSelected) {
        _mainUser.religiousPref = false;
        [self buttonDeSelected:_spiritualLabel];
    } else {
        _mainUser.religiousPref = true;
        [self buttonSelected:_spiritualLabel];
    }
}

- (IBAction)sportsToggle:(id)sender {
    if (_sportsLabel.isSelected) {
        _mainUser.sportsPref = false;
        [self buttonDeSelected:_sportsLabel];
    } else {
        _mainUser.sportsPref = true;
        [self buttonSelected:_sportsLabel];
    }
}

- (IBAction)techToggle:(id)sender {
    if (_techGadgetsLabel.isSelected) {
        _mainUser.techPref = false;
        [self buttonDeSelected:_techGadgetsLabel];
    } else {
        _mainUser.techPref = true;
        [self buttonSelected:_techGadgetsLabel];
    }
}

- (IBAction)travelToggle:(id)sender {
    if (_travelLabel.isSelected) {
        _mainUser.travelPref = false;
        [self buttonDeSelected:_travelLabel];
    } else {
        _mainUser.travelPref = true;
        [self buttonSelected:_travelLabel];
    }
}

- (IBAction)volunteeringToggle:(id)sender {
    if (_volunteeringLabel.isSelected) {
        _mainUser.volunteerPref = false;
        [self buttonDeSelected:_volunteeringLabel];
    } else {
        _mainUser.volunteerPref = true;
        [self buttonSelected:_volunteeringLabel];
    }
}

- (IBAction)moviesToggle:(id)sender {
    if (_moviesLabel.isSelected) {
        _mainUser.moviesPref = false;
        [self buttonDeSelected:_moviesLabel];
    } else {
        _mainUser.moviesPref = true;
        [self buttonSelected:_moviesLabel];
    }
}

- (IBAction)workoutToggle:(id)sender {
    if (_workoutLabel.isSelected) {
        _mainUser.workoutPref = false;
        [self buttonDeSelected:_workoutLabel];
    } else {
        _mainUser.workoutPref = true;
        [self buttonSelected:_workoutLabel];
    }
}
*/
#pragma mark - Check and Set Switches

- (void)checkAndSetSwitchToggle:(UISwitch *)switchToggle andUserPreference:(BOOL *)preference
{
    
}

/* Not really needed anymore

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
*/

#pragma mark - Save and Close

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
/*
    if (_minAgeField.text) {
        _mainUser.minAgePref = [[NSNumberFormatter new] numberFromString:_minAgeField.text];
    }
    
    if (_maxAgeField.text) {
        _mainUser.maxAgePref = [[NSNumberFormatter new] numberFromString:_maxAgeField.text];
    }
   */ 
    // Set Segment Controls when left un-pressed
    
    if (_genderControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        _mainUser.genderPref = @"Male";
        NSLog(@"No gender set");
    }
    if (_bodyTypeControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        _mainUser.bodyTypePref = @"Skinny";
        NSLog(@"No Body Type set");
    }
    
    if (_relationshipStatusControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        _mainUser.relationshipStatusPref = @"Single";
        NSLog(@"No RelatStat set");
    }
    
    if (_relationshipTypeControl.selectedSegmentIndex == UISegmentedControlNoSegment) {
        _mainUser.romanticPreference = @"Company";
        NSLog(@"No RomPref set");
    }
    
    // Set Switches when left un-pressed
    
    if (!_hasKidsFilter.on && _mainUser.kidsOkay == nil) {
        _mainUser.kidsOkay = nope;
    }
    if (!_drinksFilter.on && _mainUser.drinkingOkay == nil) {
        _mainUser.drinkingOkay = nope;
    } 
    if (!_smokesCigsFilter.on && _mainUser.smokingOkay == nil) {
        _mainUser.smokingOkay = nope;
    } 
    if (!_takesDrugsFilter.on && _mainUser.drugsOkay == nil) {
        _mainUser.drugsOkay = nope;
    } 
    if (!_hasBodyArtFilter.on && _mainUser.bodyArtOkay == nil) {
        _mainUser.bodyArtOkay = nope;
    }
    
    [_mainUser saveInBackground];
}
/* If using a TextField
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [_minAgeField resignFirstResponder];
    [_maxAgeField resignFirstResponder];
    return YES;
}
*/
@end
