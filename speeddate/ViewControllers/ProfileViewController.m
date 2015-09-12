//
//  ProfileViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "ProfileViewController.h"
#import "SWRevealViewController.h"
#import "UserParseHelper.h"
#import "V8HorizontalPickerView.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "config.h"
#import "RageIAPHelper.h"
#import "User.h"
#import "UserRatingViewController.h"
#import "UserRating2ViewController.h"
#import "PossibleMatchHelper.h"
#import <StoreKit/StoreKit.h>

#define DEFAULT_DESCRIPTION  @"Please fill information about you"
#define MAXLENGTH 125
#define MAX_PHOTOS 10

#pragma mark - CHANGES 1
@interface ProfileViewController () <V8HorizontalPickerViewDataSource, V8HorizontalPickerViewDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, /*UINavigationControllerDelegate,*/ UIActionSheetDelegate>{
    
    NSArray *allproduct;
    int count;
    SKProduct *findProduct;
    User *mainUser;
}
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *genderLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UILabel *charactersLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;

@property NSMutableArray *ages;
@property (weak, nonatomic) IBOutlet V8HorizontalPickerView *agePickerView;
@property (weak, nonatomic) IBOutlet UIView *genderSelect;
@property (weak, nonatomic) IBOutlet UIView *genderLikeSelect;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property NSUInteger selectedPhoto;

@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIView *profileBackground;
@property (weak, nonatomic) IBOutlet UIImageView *femaleImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bothImageView;
@property (weak, nonatomic) IBOutlet UIImageView *maleImageView;

@property (nonatomic,retain) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@property (nonatomic,retain) SKProduct *vipMember;
@property (nonatomic,retain) IBOutlet UILabel *distanceChange;


@property (weak, nonatomic) IBOutlet UILabel *cityLable;
@property (nonatomic,retain)  IBOutlet UISwitch *switchTouchId;

@property UserParseHelper *user;
@property PossibleMatchHelper *connection;

////who?

@property (nonatomic,retain) IBOutlet UIButton *whosee;
@property (nonatomic,retain) IBOutlet UIButton *whoseeVip;

@end

@implementation ProfileViewController
@synthesize vipLocation,location;


-(void)dealloc{
    
    _adBanner.delegate = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self checkPurchase];
    
    //[_scroller setContentSize:CGSizeMake(320, 1555)];
    [_scroller setContentSize:CGSizeMake(self.view.frame.size.width, 1466)];
    [_scroller setScrollEnabled:YES];
    
    mainUser = [User singleObj];
    mainUser.isRevealed = false;
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    [self populateProfile];
    [self customize];
    [self createAgePickerView];
    self.navigationController.navigationBar.barTintColor = RED_LIGHT;
    self.navigationItem.title = [UserParseHelper currentUser].nickname;
#pragma mark - CHANGES 2
    /*UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setShadowImage:[UIImage new]];*/
    
        GADBannerView *bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        bannerView_.adUnitID = kSampleAdUnitID;
        bannerView_.rootViewController = self;
        bannerView_.delegate = self;
        [bannerView_ loadRequest:[GADRequest request]];
        [self.bannerView addSubview:bannerView_];
        
    
    if (![UserParseHelper currentUser].geoPoint) {
        self.cityLable.text = @"No Location";
    } else {
        [[UserParseHelper currentUser] userGeolocationOutput:self.cityLable];
        /*
        CLGeocoder* geocoder = [CLGeocoder new];
        CLLocation* locationz = [[CLLocation alloc]initWithLatitude:[UserParseHelper currentUser].geoPoint.latitude longitude:[UserParseHelper currentUser].geoPoint.longitude];
        [geocoder reverseGeocodeLocation:locationz completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = placemarks.firstObject;
        
            self.cityLable.text = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];

        }];
         */
    }
   
    NSUserDefaults *touchFbP = [NSUserDefaults standardUserDefaults];
   NSString *touch = [touchFbP objectForKey:@"touchId"];
    
    if ([touch isEqualToString:@"yes"]) {
        self.switchTouchId.on = YES;
    }
    
    if ([touch isEqualToString:@"no"]) {
        self.switchTouchId.on = NO;
    }

    [UserParseHelper currentUser].credits = @5;
    
    
    //[self findUnratedMatches];
    
    self.restorationIdentifier = @"ProfileViewController";
    
}



- (void)checkPurchase {
    
    PFUser *chekUser = [PFUser currentUser];
    NSString *vip = chekUser[@"membervip"];
    if ([vip isEqualToString:@"vip"]) {
        
        self.bannerView.hidden = YES;
        self.location.hidden = NO;
        self.vipLocation.hidden = YES;
        self.whosee.hidden = NO;
        self.whoseeVip.hidden = YES;
        
    }else{
        
        self.location.hidden = YES;
        self.vipLocation.hidden = NO;
        self.whosee.hidden = YES;
        self.whoseeVip.hidden = NO;
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //self.navigationItem.title = [UserParseHelper currentUser].nickname;
    
    // My Edits -------------------------------------
    self.bannerView.hidden = YES;
    self.location.hidden = NO;
    self.vipLocation.hidden = YES;
    self.whosee.hidden = NO;
    self.whoseeVip.hidden = YES;
    
    //[self checkPurchase];
    //------------------------------------------------
}

- (void)findUnratedMatches
{
    NSLog(@"Connection query started");
    PFQuery *unRatedConnectionsFromMe = [PossibleMatchHelper query];
    [unRatedConnectionsFromMe whereKey:@"fromUser" equalTo:[UserParseHelper currentUser]];
    PFQuery *unRatedConnectionsToMe = [PossibleMatchHelper query];
    [unRatedConnectionsToMe whereKey:@"toUser" equalTo:[UserParseHelper currentUser]];
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[unRatedConnectionsFromMe, unRatedConnectionsToMe]];
    [both findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Connections found: %lu", (unsigned long)[objects count]);

        if ([objects count] > 0) {
            
            for (int i=0; i < [objects count]; i++) {
                
                _connection = (PossibleMatchHelper *)[objects objectAtIndex:i];
                if ([_connection.toUser isEqual:[UserParseHelper currentUser]]) {
                    _connection.fromUser = (UserParseHelper *)[_connection.fromUser fetchIfNeeded];
                    
                    [self performSegueWithIdentifier:@"userRating2" sender:_connection.fromUser];
                    
                } else {
                    _connection.toUser = (UserParseHelper *)[_connection.toUser fetchIfNeeded];
                    
                    [self performSegueWithIdentifier:@"userRating" sender:_connection.toUser];
                    
                }
            }
            
            /*
                        for (PossibleMatchHelper *connection in objects) {
                            
                            if ([connection.toUser isEqual:[UserParseHelper currentUser]]) {
                                connection.fromUser = (UserParseHelper *)[connection.fromUser fetchIfNeeded];
                                //[self performSegueWithIdentifier:@"userRating" sender:connection.fromUser];
                                NSLog(@"Connection: %@", connection.fromUser.nickname);
                            } else {
                                connection.toUser = (UserParseHelper *)[connection.toUser fetchIfNeeded];
                                //[self performSegueWithIdentifier:@"userRating" sender:connection.toUser];
                                NSLog(@"Connection: %@", connection.toUser.nickname);
                            }
            }
             */
        }
    }];
}

- (void)createAgePickerView
{
    self.ages = [NSMutableArray new];
    for (int i = MIN_AGE; i <= MAX_AGE; i++) {
        [self.ages addObject:[NSNumber numberWithInt:i]];
    }
	self.agePickerView.backgroundColor   = [UIColor clearColor];
	self.agePickerView.selectedTextColor =  WHITE_COLOR;
	self.agePickerView.textColor   = RED_LIGHT;
	self.agePickerView.delegate    = self;
	self.agePickerView.dataSource  = self;
	self.agePickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	self.agePickerView.selectionPoint = CGPointMake(self.view.frame.size.width/3, 0);
}

- (void)customize
{
    self.profileBackground.backgroundColor =  RED_DEEP;
    self.view.backgroundColor = RED_DEEP;
    self.genderSelect.backgroundColor = [UIColor clearColor];
    [self.genderSelect.layer setBorderWidth:1];
    [self.genderSelect.layer setBorderColor:WHITE_COLOR.CGColor];
    self.genderLikeSelect.backgroundColor = RED_LIGHT;
    [self.genderLikeSelect.layer setBorderWidth:1];
    [self.genderLikeSelect.layer setBorderColor:WHITE_COLOR.CGColor];
    self.charactersLabel.textColor = WHITE_COLOR;
    self.editView.frame = CGRectMake(0, self.view.frame.size.height, self.editView.frame.size.width, self.editView.frame.size.height);
    self.descriptionTextView.textColor = WHITE_COLOR;
    self.descriptionTextView.textAlignment = NSTextAlignmentJustified;

}

-(void) populateProfile
{
    PFQuery *query = [UserParseHelper query];
    [query getObjectInBackgroundWithId:[UserParseHelper currentUser].objectId
                                 block:^(PFObject *object, NSError *error)
     {
         self.user = (UserParseHelper *)object;
         self.user.installation = [PFInstallation currentInstallation];
         self.charactersLabel.text = [NSString stringWithFormat:@"%lu/%d",(unsigned long)self.user.desc.length,MAXLENGTH];
         
         

         if (![self.user.desc isEqualToString:@""]) {
             self.descriptionLabel.text = self.user.desc;
         } else {
             self.descriptionLabel.text = DEFAULT_DESCRIPTION;
         }
         if (![self.user.desc isEqualToString:@""]) {
             self.descriptionTextView.text = self.user.desc;
         } else {
             self.descriptionTextView.text = DEFAULT_DESCRIPTION;
         }

         if ([self.user.isMale isEqualToString:@"true"]) {
             
             self.genderLabel.text = @"Male";
             
         } else {
            
             
             self.genderLabel.text = @"Female";
        }

         if ([self.user.sexuality isEqualToNumber:[NSNumber numberWithInt:1]]) {
             [self femaleLikeSelect:nil];
         }
         if ([self.user.sexuality isEqualToNumber:[NSNumber numberWithInt:2]]) {
             [self bothLikeSelect:nil];
         }
         [self.agePickerView scrollToElement:[NSNumber numberWithInt:self.user.age.intValue-18].intValue animated:YES];
         
     }];
}

- (void)viewDidLayoutSubviews
{

}

- (IBAction)maleSelect:(id)sender
{
    self.user.isMale = @"true";
    [UIView animateWithDuration:1.5 animations:^{
        self.genderSelect.frame = CGRectMake(109, self.genderSelect.frame.origin.y, self.genderSelect.frame.size.width, self.genderSelect.frame.size.height);
        [self.maleButton setTitleColor:RED_LIGHT forState:UIControlStateNormal];
        [self.femaleButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        self.genderLabel.text = @"Male";
    } completion:^(BOOL finished) {

    }];
    [self.user saveInBackground];
}

- (IBAction)femaleSelect:(id)sender
{
    self.user.isMale = @"false";
    [UIView animateWithDuration:1.5 animations:^{
        self.genderSelect.frame = CGRectMake(202, self.genderSelect.frame.origin.y, self.genderSelect.frame.size.width, self.genderSelect.frame.size.height);
        [self.maleButton setTitleColor:WHITE_COLOR forState:UIControlStateNormal];
        [self.femaleButton setTitleColor:RED_LIGHT forState:UIControlStateNormal];
        self.genderLabel.text = @"Female";

    } completion:^(BOOL finished) {


    }];
    [self.user saveInBackground];
}

- (IBAction)maleLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:0];
    [UIView animateWithDuration:0.7 animations:^{
        self.genderLikeSelect.frame = CGRectMake(40, self.genderLikeSelect.frame.origin.y , self.genderLikeSelect.frame.size.width, 2);
            } completion:^(BOOL finished) {
      
            }];
    [self.user saveInBackground];
}

- (IBAction)femaleLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:1];
    [UIView animateWithDuration:0.7 animations:^{
        self.genderLikeSelect.frame = CGRectMake(127, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, 2);
     
    } completion:^(BOOL finished) {
      
    }];
    [self.user saveInBackground];
}

- (IBAction)bothLikeSelect:(id)sender
{
    self.user.sexuality = [NSNumber numberWithInt:2];
    [UIView animateWithDuration:0.7 animations:^{
        self.genderLikeSelect.frame = CGRectMake(219, self.genderLikeSelect.frame.origin.y, self.genderLikeSelect.frame.size.width, 2);
    
    } completion:^(BOOL finished) {
       
    }];
    [self.user saveInBackground];
}

#pragma mark - V8 picker

#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker
{
	return [self.ages count];
}


#pragma mark - HorizontalPickerView Delegate Methods

- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index
{
    NSNumber *num = [self.ages objectAtIndex:index];
	return num.description;
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index
{
    return 42;
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
    self.user.age = [NSNumber numberWithInteger:index+MIN_AGE];
    [self.user saveInBackground];
    self.ageLabel.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:index+MIN_AGE]];
}

- (IBAction)logOut:(id)sender {
    [UserParseHelper logOut];
    [self performSegueWithIdentifier:@"logOut" sender:nil];
}

#pragma mark UItextView Delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([self.descriptionTextView.text isEqualToString:DEFAULT_DESCRIPTION]) {
        self.descriptionTextView.text = @"";
    }
    [UIView animateWithDuration:1.2 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.editView.frame = CGRectMake(0, self.editView.frame.origin.y-150, self.editView.frame.size.width, self.editView.frame.size.height);
    } completion:^(BOOL finished) {

    }];

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.descriptionLabel.text = self.descriptionTextView.text;
    self.user.desc =self.descriptionTextView.text;
    [self.user saveInBackground];
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.editView.frame = CGRectMake(0, self.editView.frame.origin.y+150, self.editView.frame.size.width, self.editView.frame.size.height);
    } completion:^(BOOL finished) {

    }];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self.user saveInBackground];
        return NO;
    }
    self.descriptionLabel.text = textView.text;
    self.charactersLabel.text = [NSString stringWithFormat:@"%lu/%d",(unsigned long)textView.text.length,MAXLENGTH];
    return self.descriptionTextView.text.length + (text.length - range.length) <= MAXLENGTH;
}

- (IBAction)changePicture:(UIButton *)button
{
    self.selectedPhoto = button.tag;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

#pragma mark - DELETE ACTION

- (IBAction)deleteButtonPressed:(id)sender // Delete Profile via Parse
{
    [self performSegueWithIdentifier:@"userRating" sender:nil];
    /*
    UIAlertView *deleteAlert = [[UIAlertView alloc] initWithTitle:@"Delete Profile"
                                                          message:@"Are you sure you want to permanently Delete your Dalliant Profile? This cannot be un-done."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                                otherButtonTitles:@"Delete",nil];
    deleteAlert.tag = 1;
    [deleteAlert show];
     */
}

// Alertview handler
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1 && buttonIndex == 1) {
        /*
        [self.user deleteInBackground];
        if ([PFUser currentUser]) {
            [[PFUser currentUser] deleteInBackground];
        }
         */
        [self.user deleteAllUserData];
        [self performSegueWithIdentifier:@"backToLogin" sender:nil];
        
        //[self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"userRating"]) {
        
        UserRatingViewController *vc = segue.destinationViewController;
        vc.relationship = _connection;
        vc.matchUser = (UserParseHelper *)sender; // Will be Match returned in PossMatch Query
        vc.user = [UserParseHelper currentUser];
        vc.matchUserImage = [UIImage imageWithData:[vc.matchUser.photo getData]];
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        
    } else if ([segue.identifier isEqualToString:@"userRating2"]) {
        
        UserRating2ViewController *rateVC = segue.destinationViewController;
        rateVC.relationship = _connection;
        rateVC.matchUser = (UserParseHelper *)sender; // Will be Match returned in PossMatch Query
        rateVC.user = [UserParseHelper currentUser];
        rateVC.matchUserImage = [UIImage imageWithData:[rateVC.matchUser.photo getData]];
        /*
        [rateVC setModalPresentationStyle:UIModalPresentationOverCurrentContext];
         */
    } else self.navigationItem.title = @"Profile";
}

-(IBAction)buyMemberPro:(id)sender{
    
    NSLog(@"Buying %@...", _vipMember.productIdentifier);
    [[RageIAPHelper sharedInstance] buyProduct:_vipMember];
    
}

-(IBAction)onOffSwitch:(id)sender{
    
    if(self.switchTouchId.on) {
       
        NSLog(@"yes pass");
        
        NSUserDefaults *touchFb = [NSUserDefaults standardUserDefaults];
        [touchFb setObject:@"yes" forKey:@"touchId"];
        [touchFb synchronize];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Security"
                                                        message:@"Your application is protected Touch Id"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
       
    }
    
    else {
         NSLog(@"no pass");
        
        NSUserDefaults *touchFb = [NSUserDefaults standardUserDefaults];
        [touchFb setObject:@"yes" forKey:@"touchId"];
        [touchFb synchronize];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Security"
                                                        message:@"Your application is not protected Touch Id"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    }
    
}

- (void)editProfile // Will eventually delete
{
    if (!self.editing) {
        [self.editButton setTitle:@"Done"];
    } else {
        [self.editButton setTitle:@"Edit"];
    }
    self.editing = !self.editing;
    if (self.editing) {
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.editView.frame = CGRectMake(0, self.view.frame.size.height-self.editView.frame.size.height, self.editView.frame.size.width, self.editView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.editView.frame = CGRectMake(0, self.view.frame.size.height, self.editView.frame.size.width, self.editView.frame.size.height);
        } completion:^(BOOL finished) {
            
        }];
        
    }
}

-(IBAction)explorelocation:(id)sender{
    
    [self performSegueWithIdentifier:@"locationMap" sender:nil];
    
    /*
    PFUser *chekUser = [PFUser currentUser];
    NSString *vip = chekUser[@"membervip"];
    if ([vip isEqualToString:@"novip"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"This features available only vip users"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }*/
    
}

-(IBAction)whooseevips:(id)sender{
    
    
    PFUser *chekUser = [PFUser currentUser];
    NSString *vip = chekUser[@"membervip"];
    if ([vip isEqualToString:@"novip"]) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry"
                                                        message:@"This features available only vip users"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}
@end
