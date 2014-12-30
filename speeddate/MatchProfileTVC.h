//
//  MatchProfileTVC.h
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/24/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserParseHelper.h"
#import <KIImagePager.h>

@interface MatchProfileTVC : UITableViewController

@property (weak, nonatomic) UserParseHelper *matchUser;
@property (weak, nonatomic) IBOutlet UIImageView *userFBPic;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *userGender;
@property (weak, nonatomic) IBOutlet UILabel *userDistance;
@property (weak, nonatomic) IBOutlet UILabel *userDescription;
@property (weak, nonatomic) IBOutlet UILabel *userAge;
@property (weak, nonatomic) IBOutlet UILabel *matchBodyType;
@property (weak, nonatomic) IBOutlet UILabel *matchDatingStatus;
@property (weak, nonatomic) IBOutlet UILabel *matchRelationshipType;
@property (weak, nonatomic) IBOutlet UILabel *matchInterest1;
@property (weak, nonatomic) IBOutlet UILabel *matchDrinksPref;
@property (weak, nonatomic) IBOutlet UILabel *matchSmokesPref;
@property (weak, nonatomic) IBOutlet UILabel *matchDrugsPref;
@property (weak, nonatomic) IBOutlet UILabel *matchBodyArPref;

@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;


- (IBAction)closeProfileView:(id)sender;
- (IBAction)reportUser:(id)sender;
@end
