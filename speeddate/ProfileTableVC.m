//
//  ProfileTableVC.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/13/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "ProfileTableVC.h"

@interface ProfileTableVC ()
{
    BOOL *buttonsDisabled;
    NSMutableArray *preferenceStrings;
    NSDictionary *userSnapshotInfo;
}

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
    
    if (user.bodyType) {
        NSLog(@"Body Type: %@", user.bodyType);
    } else {
        NSLog(@"Body Type Control: %ld", _bodyTypeControl.selectedSegmentIndex);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self buildSegmentControls];
    
    [self checkAndSetPreferenceValues];
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

- (void)BodyTypeButtonPressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            user.bodyType = @"Skinny";
            NSLog(@"Body type index: %ld", segment.selectedSegmentIndex);
            break;
        case 1:
            user.bodyType = @"Average";
            NSLog(@"Body type index: %ld", segment.selectedSegmentIndex);
            break;
        case 2:
            user.bodyType = @"Fit";
            NSLog(@"Body type index: %ld", segment.selectedSegmentIndex);
            break;
        case 3:
            user.bodyType = @"XL";
            NSLog(@"Body type index: %ld", segment.selectedSegmentIndex);
            break;
    }
}

- (void)RelationshipStatusPressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            user.relationshipStatus = @"Single";
            break;
        case 1:
            user.relationshipStatus = @"Dating";
            break;
        case 2:
            user.relationshipStatus = @"Divorced";
            break;
    }
}

- (void)RelationshipTypePressed:(UISegmentedControl *)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            user.relationshipType = @"Company";
            break;
        case 1:
            user.relationshipType = @"Friend";
            break;
        case 2:
            user.relationshipType = @"Relationship";
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
    
    // Check settings based on Toggle and Control State and change conditionals as such MUST REFACTOR
    if (user.bodyType) {
        if ([user.bodyType isEqualToString:@"Skinny"]) {
            [_bodyTypeControl setSelectedSegmentIndex:0];
        } else if ([user.bodyType isEqualToString:@"Average"]) {
            [_bodyTypeControl setSelectedSegmentIndex:1];
        } else if ([user.bodyType isEqualToString:@"Fit"]) {
            [_bodyTypeControl setSelectedSegmentIndex:2];
        } else if ([user.bodyType isEqualToString:@"XL"]) {
            [_bodyTypeControl setSelectedSegmentIndex:3];
        }
        
        NSLog(@"Body Type Index: %ld", _bodyTypeControl.selectedSegmentIndex);
    }
    
    if (user.relationshipStatus) {
        if ([user.relationshipStatus isEqualToString:@"Single"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:0];
        } else if ([user.relationshipStatus isEqualToString:@"Dating"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:1];
        } else if ([user.relationshipStatus isEqualToString:@"Divorced"]) {
            [_relationshipStatusControl setSelectedSegmentIndex:2];
        }
    }
    
    if (user.relationshipType) {
        if ([user.relationshipType isEqualToString:@"Company"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:0];
        } else if ([user.relationshipType isEqualToString:@"Friend"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:1];
        } else if ([user.relationshipType isEqualToString:@"Relationship"]) {
            [_relationshipTypeControl setSelectedSegmentIndex:2];
        }
    }
    
    if (user.hasKids) {
        [_hasKidsFilter setOn:YES];
        user.haveKids = @"Yes";
    } else {
        [_hasKidsFilter setOn:NO];
        user.haveKids = @"No";
    }
    
    if (user.drinks) {
        [_drinksFilter setOn:YES];
        user.likeToDrink = @"Yes";
    } else {
        [_drinksFilter setOn:NO];
        user.likeToDrink = @"No";
    }
    
    if (user.smokes) {
        [_smokesCigsFilter setOn:YES];
        user.smokesCigs = @"Yes";
    } else {
        [_smokesCigsFilter setOn:NO];
        user.smokesCigs = @"No";
    }
    
    if (user.drugs) {
        [_takesDrugsFilter setOn:YES];
        user.usesDrugs = @"Yes";
    } else {
        [_takesDrugsFilter setOn:NO];
        user.usesDrugs = @"No";
    }
    
    if (user.bodyArt) {
        [_hasBodyArtFilter setOn:YES];
        user.hasTatoos = @"Yes";
    } else {
        [_hasBodyArtFilter setOn:NO];
        user.hasTatoos = @"No";
    }
    
    // Pref Buttons
    //if (_userPrefs.count <= 5) {
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
     
   // } // End buttonDisabled conditional*/
}

#pragma mark - Segmented Controls - Actions

- (IBAction)bodyType:(id)sender {
    _bodyTypeControl = (UISegmentedControl*)sender;
    
    switch (_bodyTypeControl.selectedSegmentIndex) {
        case 0:
            user.bodyType = @"Skinny";
            NSLog(@"Body type index: %ld", _bodyTypeControl.selectedSegmentIndex);
            break;
        case 1:
            user.bodyType = @"Average";
            NSLog(@"Body type index: %ld", _bodyTypeControl.selectedSegmentIndex);
            break;
        case 2:
            user.bodyType = @"Fit";
            NSLog(@"Body type index: %ld", _bodyTypeControl.selectedSegmentIndex);
            break;
        case 3:
            user.bodyType = @"XL";
            NSLog(@"Body type index: %ld", _bodyTypeControl.selectedSegmentIndex);
            break;
    }
}

- (IBAction)relationshipStatus:(id)sender {
    _relationshipStatusControl = (UISegmentedControl*)sender;
    
    switch (_relationshipStatusControl.selectedSegmentIndex) {
        case 0:
            user.relationshipStatus = @"Single";
            break;
        case 1:
            user.relationshipStatus = @"Dating";
            break;
        case 2:
            user.relationshipStatus = @"Married";
            break;
        case 3:
            user.relationshipStatus = @"Divorced";
            break;
    }
}

- (IBAction)relationshipType:(id)sender {
    _relationshipTypeControl = (UISegmentedControl*)sender;
    
    switch (_relationshipTypeControl.selectedSegmentIndex) {
        case 0:
            user.relationshipType = @"Fun";
            break;
        case 1:
            user.relationshipType = @"Friend";
            break;
        case 2:
            user.relationshipType = @"Relationship";
            break;
    }
}

- (void)setBodyTypeControl:(UISegmentedControl *)bodyTypeControl
{
    
    /*
    
    }*/
}

- (void)setRelationshipStatusControl:(UISegmentedControl *)relationshipStatusControl
{
    
}

- (void)setRelationshipTypeControl:(UISegmentedControl *)relationshipTypeControl
{
    
}


#pragma mark - UI Switches

- (IBAction)kidStatusToggle:(id)sender {
    if (_hasKidsFilter.on) {
        user.hasKids = true;
    } else user.hasKids = false;
}

- (IBAction)drinkPreferenceToggle:(id)sender {
    if (_drinksFilter.on) {
        user.drinks = true;
    } else  user.drinks = false;
}

- (IBAction)smokesPreferenceToggle:(id)sender {
    if (_smokesCigsFilter.on) {
        user.smokes = true;
    } else  user.smokes = false;
}

- (IBAction)drugPreferenceToggle:(id)sender {
    if (_takesDrugsFilter.on) {
        user.drugs = true;
    } else  user.drugs = false;
}

- (IBAction)tatooPreferenceToggle:(id)sender {
    if (_hasBodyArtFilter.on) {
        user.bodyArt = true;
    } else  user.bodyArt = false;
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
    _userDescription.text   = user.blurb;
    _userAge.text           = user.age;
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
    
    NSLog(@"Body type: %lu, Relationship Status: %lu, Relationship Type: %lu", _bodyTypeControl.selectedSegmentIndex, _relationshipStatusControl.selectedSegmentIndex, _relationshipTypeControl.selectedSegmentIndex);
    
    // Check for an existing Parse database then set values and upload to database
    /*if (user.userRef) {
        
        //   [self checkAndSetPreferenceValues:user];
        // Store all values to Firebase
        Firebase *personalInfo = [userRef childByAppendingPath:@"personal_info"];
        
        // Convert Pref Buttons to Strings
        [self convertPreferenceButtons:_userPrefs];
        
        NSDictionary *personal = @{
                                   // About User
                                   @"body_type" : user.bodyType,
                                   @"have_kids" : user.haveKids,
                                   @"relationship_status" : user.relationshipStatus,
                                   @"desired_relationship" : user.relationshipType,
                                   // Vices
                                   @"drinks" : user.likeToDrink,
                                   @"smokes" : user.smokesCigs,
                                   @"drugs" : user.usesDrugs,
                                   @"body_art" : user.hasTatoos,
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
