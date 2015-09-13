//
//  ProfileTableVC.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/13/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface ProfileTableVC : UITableViewController

{
    User * user;
}

// User Attributes
@property (strong, nonatomic) User *currentUser;
@property (weak, nonatomic) IBOutlet UIImageView *userFBPic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UITextView *userDescription;
@property (weak, nonatomic) IBOutlet UILabel *userAge;
@property (strong, nonatomic) NSMutableArray *allPrefs;
@property (strong, nonatomic) NSMutableArray *userPrefs;

// Actions - Segmented Controls
- (IBAction)bodyType:(id)sender;

- (IBAction)relationshipStatus:(id)sender;
- (IBAction)relationshipType:(id)sender;

// Actions - UISwitches
- (IBAction)kidStatusToggle:(id)sender;
- (IBAction)drinkPreferenceToggle:(id)sender;
- (IBAction)smokesPreferenceToggle:(id)sender;
- (IBAction)drugPreferenceToggle:(id)sender;
- (IBAction)tatooPreferenceToggle:(id)sender;

// Outlets - UISwitches
@property (weak, nonatomic) IBOutlet UISwitch *hasKidsFilter;
@property (weak, nonatomic) IBOutlet UISwitch *drinksFilter;
@property (weak, nonatomic) IBOutlet UISwitch *smokesCigsFilter;
@property (weak, nonatomic) IBOutlet UISwitch *takesDrugsFilter;
@property (weak, nonatomic) IBOutlet UISwitch *hasBodyArtFilter;

// Actions - Hobbies/Interests
- (IBAction)animalsToggle:(id)sender;
- (IBAction)artsToggle:(id)sender;
- (IBAction)beerToggle:(id)sender;
- (IBAction)bookClubToggle:(id)sender;
- (IBAction)cookingToggle:(id)sender;
- (IBAction)dancingToggle:(id)sender;
- (IBAction)diningClubToggle:(id)sender;
- (IBAction)hikingToggle:(id)sender;
- (IBAction)lecturesToggle:(id)sender;
- (IBAction)musicToggle:(id)sender;
- (IBAction)operaToggle:(id)sender;
- (IBAction)religiousToggle:(id)sender;
- (IBAction)sportsToggle:(id)sender;
- (IBAction)techToggle:(id)sender;
- (IBAction)travelToggle:(id)sender;
- (IBAction)volunteeringToggle:(id)sender;
- (IBAction)moviesToggle:(id)sender;
- (IBAction)workoutToggle:(id)sender;

// Outlets - Hobbies/Interests
@property (weak, nonatomic) IBOutlet UIButton *animalLabel;
@property (weak, nonatomic) IBOutlet UIButton *artsLabel;
@property (weak, nonatomic) IBOutlet UIButton *beerLabel;
@property (weak, nonatomic) IBOutlet UIButton *bookClubLabel;
@property (weak, nonatomic) IBOutlet UIButton *cookingLabel;
@property (weak, nonatomic) IBOutlet UIButton *dancingLabel;
@property (weak, nonatomic) IBOutlet UIButton *diningOutLabel;
@property (weak, nonatomic) IBOutlet UIButton *hikingOutdoorsLabel;
@property (weak, nonatomic) IBOutlet UIButton *lecturesTalksLabel;
@property (weak, nonatomic) IBOutlet UIButton *musicConcertLabel;
@property (weak, nonatomic) IBOutlet UIButton *spiritualLabel;
@property (weak, nonatomic) IBOutlet UIButton *sportsLabel;
@property (weak, nonatomic) IBOutlet UIButton *techGadgetsLabel;
@property (weak, nonatomic) IBOutlet UIButton *travelLabel;
@property (weak, nonatomic) IBOutlet UIButton *volunteeringLabel;
@property (weak, nonatomic) IBOutlet UIButton *moviesLabel;
@property (weak, nonatomic) IBOutlet UIButton *workoutLabel;
@property (weak, nonatomic) IBOutlet UIButton *operaTheatreLabel;

- (void)disableAllPreferences:(NSMutableArray *)preferences;
- (void)enableAllPreferences:(NSMutableArray *)preferences;

- (IBAction)logoutFacebook:(id)sender;
- (IBAction)userEducation:(id)sender;

- (void)checkAndSetUserEnteredData;
- (IBAction)saveProfilePressed:(id)sender;

@end
