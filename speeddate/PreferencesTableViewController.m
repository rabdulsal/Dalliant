//
//  PreferencesTableViewController.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 11/24/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "PreferencesTableViewController.h"
#import "User.h"

@interface PreferencesTableViewController ()
{
    BOOL *buttonsDisabled;
    User *user;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@end

@implementation PreferencesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    //[self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];

    user = [User singleObj];
    
    // Will have to do a check on the User to pre-load Preferences into appropriate Arrays
    
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self checkAndSetPreferenceValues];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (user.genderPref) {
        if ([user.genderPref isEqualToString:@"Male"]) {
            [_genderControl setSelectedSegmentIndex:0];
        } else if ([user.genderPref isEqualToString:@"Female"]) {
            [_genderControl setSelectedSegmentIndex:1];
        } else if ([user.genderPref isEqualToString:@"Both"]){
            [_genderControl setSelectedSegmentIndex:2];
        }
    }
    
    if (user.minAgePref) {
        _minAgeField.text = user.minAgePref;
    }
    
    if (user.maxAgePref) {
        _maxAgeField.text = user.maxAgePref;
    }
    
    if (user.bodyTypePref) {
        if ([user.bodyTypePref isEqualToString:@"Skinny"]) {
            [_bodyTypeControl setSelectedSegmentIndex:0];
        } else if ([user.bodyTypePref isEqualToString:@"Average"]) {
            [_bodyTypeControl setSelectedSegmentIndex:1];
        } else if ([user.bodyTypePref isEqualToString:@"Fit"]) {
            [_bodyTypeControl setSelectedSegmentIndex:2];
        } else if ([user.bodyTypePref isEqualToString:@"XL"]) {
            [_bodyTypeControl setSelectedSegmentIndex:3];
        }
    }
    
    if (user.relationshipStatusPref) {
        if ([user.relationshipStatusPref isEqualToString:@"Single"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:0];
        } else if ([user.relationshipStatusPref isEqualToString:@"Dating"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:1];
        } else if ([user.relationshipStatusPref isEqualToString:@"Married"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:2];
        } else if ([user.relationshipStatusPref isEqualToString:@"Divorced"]){
            [_relationshipStatusControl setSelectedSegmentIndex:3];
        }
    }
    
    if (user.romanticPreference) {
        if ([user.romanticPreference isEqualToString:@"Fun"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:0];
        } else if ([user.romanticPreference isEqualToString:@"Friend"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:1];
        } else if ([user.romanticPreference isEqualToString:@"Relationship"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:2];
        }
    }
    
    if (user.kidsOkay) {
        [_hasKidsFilter setOn:YES];
    } else {
        [_hasKidsFilter setOn:NO];
    }
    
    if (user.drinkingOkay) {
        [_drinksFilter setOn:YES];
    } else {
        [_drinksFilter setOn:NO];
    }
    
    if (user.smokingOkay) {
        [_smokesCigsFilter setOn:YES];
    } else {
        [_smokesCigsFilter setOn:NO];
    }
    
    if (user.drugsOkay) {
        [_takesDrugsFilter setOn:YES];
    } else {
        [_takesDrugsFilter setOn:NO];
    }
    
    if (user.bodyArtOkay) {
        [_hasBodyArtFilter setOn:YES];
    } else {
        [_hasBodyArtFilter setOn:NO];
    }
    
    // Pref Buttons
    
    if (user.animalsPref) {
        [self buttonSelected:_animalLabel];
    }
    
    if (user.artsPref) {
        [self buttonSelected:_artsLabel];
    }
    
    if (user.beerPref) {
        [self buttonSelected:_beerLabel];
    }
    
    if (user.bookClubPref) {
        [self buttonSelected:_bookClubLabel];
    }
    
    if (user.cookingPref) {
        [self buttonSelected:_cookingLabel];
    }
    
    if (user.dancingPref) {
        [self buttonSelected:_dancingLabel];
    }
    
    if (user.diningOutPref) {
        [self buttonSelected:_diningOutLabel];
    }
    
    if (user.hikingPref) {
        [self buttonSelected:_hikingOutdoorsLabel];
    }
    
    if (user.lecturesPref) {
        [self buttonSelected:_lecturesTalksLabel];
    }
    
    if (user.moviesPref) {
        [self buttonSelected:_moviesLabel];
    }
    
    if (user.musicConcertsPref) {
        [self buttonSelected:_musicConcertLabel];
    }
    
    if (user.operaPref) {
        [self buttonSelected:_operaTheatreLabel];
    }
    
    if (user.religiousPref) {
        [self buttonSelected:_spiritualLabel];
    }
    
    if (user.sportsPref) {
        [self buttonSelected:_sportsLabel];
    }
    
    if (user.techPref) {
        [self buttonSelected:_techGadgetsLabel];
    }
    
    if (user.travelPref) {
        [self buttonSelected:_travelLabel];
    }
    
    if (user.volunteerPref) {
        [self buttonSelected:_volunteeringLabel];
    }
    
    if (user.workoutPref) {
        [self buttonSelected:_workoutLabel];
    }
}

#pragma mark - Segmented Controls - Actions

- (IBAction)genderOptions:(id)sender {
    if (_genderControl.selectedSegmentIndex == 0) {
        user.genderPref = @"Male";
    } else if (_genderControl.selectedSegmentIndex == 1) {
        user.genderPref = @"Female";
    } else {
        user.genderPref = @"Both";
    }
}

- (IBAction)bodyType:(id)sender {
    switch (_bodyTypeControl.selectedSegmentIndex) {
        case 0:
            user.bodyTypePref = @"Skinny";
            break;
        case 1:
            user.bodyTypePref = @"Average";
            break;
        case 2:
            user.bodyTypePref = @"Fit";
            break;
        case 3:
            user.bodyTypePref = @"XL";
            break;
    }
}

- (IBAction)relationshipStatus:(id)sender {
    switch (_relationshipStatusControl.selectedSegmentIndex) {
        case 0:
            user.relationshipStatusPref = @"Single";
            break;
        case 1:
            user.relationshipStatusPref= @"Dating";
            break;
        case 2:
            user.relationshipStatusPref = @"Married";
            break;
        case 3:
            user.relationshipStatusPref = @"Divorced";
            break;
    }
}

- (IBAction)relationshipType:(id)sender {
    switch (_relationshipTypeControl.selectedSegmentIndex) {
        case 0:
            user.romanticPreference = @"Fun";
            break;
        case 1:
            user.romanticPreference = @"Friend";
            break;
        case 2:
            user.romanticPreference = @"Relationship";
            break;
    }
}

#pragma mark - UI Switches

- (IBAction)kidStatusToggle:(id)sender {
    if (_hasKidsFilter.on) {
        user.kidsOkay = true;
    } else user.kidsOkay = false;
}

- (IBAction)drinkPreferenceToggle:(id)sender {
    if (_drinksFilter.on) {
        user.drinkingOkay = true;
    } else  user.drinkingOkay = false;
}

- (IBAction)smokesPreferenceToggle:(id)sender {
    if (_smokesCigsFilter.on) {
        user.smokingOkay = true;
    } else  user.smokingOkay = false;
}

- (IBAction)drugPreferenceToggle:(id)sender {
    if (_takesDrugsFilter.on) {
        user.drugsOkay = true;
    } else  user.drugsOkay = false;
}

- (IBAction)tatooPreferenceToggle:(id)sender {
    if (_hasBodyArtFilter.on) {
        user.bodyArtOkay = true;
    } else  user.bodyArtOkay = false;
}

#pragma mark - Interests & Hobbies

- (IBAction)animalsToggle:(id)sender {
    if (_animalLabel.isSelected) {
        user.animalsPref = false;
        [self buttonDeSelected:_animalLabel];
    } else {
        user.animalsPref = true;
        [self buttonSelected:_animalLabel];
    }
}

- (IBAction)artsToggle:(id)sender {
    if (_artsLabel.isSelected) {
        [self buttonDeSelected:_artsLabel];
        user.artsPref = false;
    } else {
        [self buttonSelected:_artsLabel];
        user.artsPref = true;
    }
}

- (IBAction)beerToggle:(id)sender {
    if (_beerLabel.isSelected) {
        user.beerPref = false;
        [self buttonDeSelected:_beerLabel];
    } else {
        user.beerPref = true;
        [self buttonSelected:_beerLabel];
    }
}

- (IBAction)bookClubToggle:(id)sender {
    if (_bookClubLabel.isSelected) {
        user.bookClubPref = false;
        [self buttonDeSelected:_bookClubLabel];
    } else {
        user.bookClubPref = true;
        [self buttonSelected:_bookClubLabel];
    }
}

- (IBAction)cookingToggle:(id)sender {
    if (_cookingLabel.isSelected) {
        user.cookingPref = false;
        [self buttonDeSelected:_cookingLabel];
    } else {
        user.cookingPref = true;
        [self buttonSelected:_cookingLabel];
    }
}

- (IBAction)dancingToggle:(id)sender {
    if (_dancingLabel.isSelected) {
        user.dancingPref = false;
        [self buttonDeSelected:_dancingLabel];
    } else {
        user.dancingPref = true;
        [self buttonSelected:_dancingLabel];
    }
}

- (IBAction)diningClubToggle:(id)sender {
    if (_diningOutLabel.isSelected) {
        user.diningOutPref = false;
        [self buttonDeSelected:_diningOutLabel];
    } else {
        user.diningOutPref = true;
        [self buttonSelected:_diningOutLabel];
    }
}

- (IBAction)hikingToggle:(id)sender {
    if (_hikingOutdoorsLabel.isSelected) {
        user.hikingPref = false;
        [self buttonDeSelected:_hikingOutdoorsLabel];
    } else {
        user.hikingPref = true;
        [self buttonSelected:_hikingOutdoorsLabel];
    }
}

- (IBAction)lecturesToggle:(id)sender {
    if (_lecturesTalksLabel.isSelected) {
        user.lecturesPref = false;
        [self buttonDeSelected:_lecturesTalksLabel];
    } else {
        user.lecturesPref = true;
        [self buttonSelected:_lecturesTalksLabel];
    }
}

- (IBAction)musicToggle:(id)sender {
    if (_musicConcertLabel.isSelected) {
        user.musicConcertsPref = false;
        [self buttonDeSelected:_musicConcertLabel];
    } else {
        user.musicConcertsPref = true;
        [self buttonSelected:_musicConcertLabel];
    }
}

- (IBAction)operaToggle:(id)sender {
    if (_operaTheatreLabel.isSelected) {
        user.operaPref = false;
        [self buttonDeSelected:_operaTheatreLabel];
    } else {
        user.operaPref = true;
        [self buttonSelected:_operaTheatreLabel];
    }
}

- (IBAction)religiousToggle:(id)sender {
    if (_spiritualLabel.isSelected) {
        user.religiousPref = false;
        [self buttonDeSelected:_spiritualLabel];
    } else {
        user.religiousPref = true;
        [self buttonSelected:_spiritualLabel];
    }
}

- (IBAction)sportsToggle:(id)sender {
    if (_sportsLabel.isSelected) {
        user.sportsPref = false;
        [self buttonDeSelected:_sportsLabel];
    } else {
        user.sportsPref = true;
        [self buttonSelected:_sportsLabel];
    }
}

- (IBAction)techToggle:(id)sender {
    if (_techGadgetsLabel.isSelected) {
        user.techPref = false;
        [self buttonDeSelected:_techGadgetsLabel];
    } else {
        user.techPref = true;
        [self buttonSelected:_techGadgetsLabel];
    }
}

- (IBAction)travelToggle:(id)sender {
    if (_travelLabel.isSelected) {
        user.travelPref = false;
        [self buttonDeSelected:_travelLabel];
    } else {
        user.travelPref = true;
        [self buttonSelected:_travelLabel];
    }
}

- (IBAction)volunteeringToggle:(id)sender {
    if (_volunteeringLabel.isSelected) {
        user.volunteerPref = false;
        [self buttonDeSelected:_volunteeringLabel];
    } else {
        user.volunteerPref = true;
        [self buttonSelected:_volunteeringLabel];
    }
}

- (IBAction)moviesToggle:(id)sender {
    if (_moviesLabel.isSelected) {
        user.moviesPref = false;
        [self buttonDeSelected:_moviesLabel];
    } else {
        user.moviesPref = true;
        [self buttonSelected:_moviesLabel];
    }
}

- (IBAction)workoutToggle:(id)sender {
    if (_workoutLabel.isSelected) {
        user.workoutPref = false;
        [self buttonDeSelected:_workoutLabel];
    } else {
        user.workoutPref = true;
        [self buttonSelected:_workoutLabel];
    }
}

#pragma mark - Check and Set Switches

- (void)checkAndSetSwitchToggle:(UISwitch *)switchToggle andUserPreference:(BOOL *)preference
{
    
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

#pragma mark - Save and Close

- (IBAction)saveAndClose:(id)sender {
    if (_minAgeField.text) {
        user.minAgePref = _minAgeField.text;
    }
    
    if (_maxAgeField.text) {
        user.maxAgePref = _maxAgeField.text;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
