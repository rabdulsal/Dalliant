//
//  UserNearMeViewController.m
//  speeddate
//
//  Created by studio76 on 19.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

/* ----------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 
 *** BAEDAR VC - VIEW WILL SET PREFERENCES BEFORE PUSHING TO BAEDAR
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */

#import "UserNearMeViewController.h"
#import "UserParseHelper.h"
#import "SWRevealViewController.h"
#import "MBProgressHUD.h"
#import "UserProfileViewController.h"
#import "UIImageView+WebCache.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "config.h"

@interface UserNearMeViewController ()<CLLocationManagerDelegate>{
    
}
@property UserParseHelper* mainUser;
@property UserParseHelper* cellUser;
@property UserParseHelper* userStart;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic,retain)  NSMutableArray *photoArray;
@property (nonatomic,retain) IBOutlet UIButton *upgradeVip;

//location

@property CLLocationManager* locationManager;
@property CLLocation* currentLocation;
@property NSNumber* milesAway;

@end

@implementation UserNearMeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"UserNearMeVC run");
    
#if (TARGET_IPHONE_SIMULATOR)
    
#else
    [UserParseHelper currentUser].installation = [PFInstallation currentInstallation];
    [[UserParseHelper currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
    }];
    
#endif
    
    //[self checkFirstTime];
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.navigationController.navigationBar.barTintColor = RED_LIGHT;
    self.navigationItem.title = @"Speed Dating";
    
    self.photoArray =[[NSMutableArray alloc]init];
    
    PFQuery* curQuery = [UserParseHelper query];
    
    [curQuery whereKey:@"username" equalTo:[UserParseHelper currentUser].username];
    [curQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        self.mainUser = objects.firstObject;
        
        if (self.mainUser.geoPoint != nil) {
            [self queryParseMethod];
        } else {
            [self currentLocationIdentifier];
        }
    }];
   
    if ([PFUser currentUser]) {
        PFQuery *usr = [UserParseHelper query];
        [usr whereKey:@"objectId" equalTo:[UserParseHelper currentUser].objectId];
        [usr findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.userStart = [UserParseHelper alloc];
            self.userStart = objects.firstObject;
            self.userStart.online = @"yes";
            [self.userStart saveEventually];
            
        }];
    }

    
    self.segmentedControl.selectedSegmentIndex = 2;
    
}

#pragma mark - LOCATION MANAGER SERVICES

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
       // CLPlacemark* placemark = placemarks.firstObject;
       // self.activityLabel.text = [NSString stringWithFormat:@"Locating :\n %@, %@", placemark.locality, placemark.administrativeArea];
       // self.activityLabel.textColor = [UIColor whiteColor];
    }];
    [UserParseHelper currentUser].geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    self.mainUser.geoPoint = [PFGeoPoint geoPointWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude];
    [[UserParseHelper currentUser] saveEventually];
    [self queryParseMethod];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)queryParseMethod {
    NSLog(@"start query");
    
  
    PFQuery *query = [UserParseHelper query];
    [query whereKey:@"username" notEqualTo:self.mainUser.username];
    PFGeoPoint *userGeoPoint = self.mainUser.geoPoint;
    
    [query whereKey:@"geoPoint" nearGeoPoint:userGeoPoint];
    
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        [query whereKey:@"isMale" equalTo:@"true"];
        
    }
    if (self.segmentedControl.selectedSegmentIndex== 1) {
       [query whereKey:@"isMale" equalTo:@"false"];
       
    }

    
    PFUser *chekUser = [PFUser currentUser];
    NSString *vip = chekUser[@"membervip"];
    if ([vip isEqualToString:@"vip"]) {
        
        NSLog(@"Unlim - vip member");
        self.upgradeVip.hidden = YES;
        
    } else{
        
        NSLog(@"No Unlim - no vip member");
     //   query.limit = limitQueruNoVipUser;
        self.upgradeVip.hidden = NO;
        
    }
    
    [query whereKey:@"geoPoint" nearGeoPoint:self.mainUser.geoPoint withinKilometers:self.mainUser.distance.doubleValue];
    
   
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            imageFilesArray = [[NSArray alloc] initWithArray:objects];
            
            
           [_imagesCollection reloadData];
            [_imagesCollection performBatchUpdates:nil completion:nil];
        }
    }];
    
    
}

#pragma mark - COLLECTIONVIEW LAYOUT

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [imageFilesArray count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"Cell";
   
    UserNearCollectionViewCell *cell = (UserNearCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    _cellUser = [imageFilesArray objectAtIndex:indexPath.row];
    
    PFObject *imageObject = [imageFilesArray objectAtIndex:indexPath.row];
    PFFile *imageFile = [imageObject objectForKey:@"photo_thumb"];
    
    cell.loading.hidden = YES;
    
   
    NSURL *imgUrl = [NSURL URLWithString:imageFile.url];
    
    [cell.profileImage sd_setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"1024_gm.png"]];
    
    
    double distance = [_cellUser.geoPoint distanceInKilometersTo:self.mainUser.geoPoint];
    if ([_cellUser.geoPoint distanceInKilometersTo:self.mainUser.geoPoint] < 1) {
        distance = 1;
    }
    
    
    
    cell.distance.text = [NSString stringWithFormat:@"%.0fkm", distance];
    cell.agez.text = [NSString stringWithFormat:@"%@",[imageObject objectForKey:@"age"]];
    
    NSString *online = _cellUser.online;
    if ([online isEqualToString:@"yes"]) {
        cell.online.backgroundColor = [UIColor greenColor];
    }
    if ([online isEqualToString:@"no"]) {
        cell.online.backgroundColor = [UIColor redColor];
    }
    
    cell.online.layer.masksToBounds = YES;
    cell.online.layer.cornerRadius = 5;
    
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"userprofile"]) {
        NSIndexPath *indexPath = [[self.imagesCollection indexPathsForSelectedItems] lastObject];
        self.photoArray =[[NSMutableArray alloc]init];
       
       
        UserProfileViewController *prVC = [[UserProfileViewController alloc]initWithNibName:@"UserVC" bundle:nil];
         prVC = segue.destinationViewController;
        _cellUser = [imageFilesArray objectAtIndex:indexPath.row];
        
        
        if (_cellUser.photo) {
            
            PFFile *mainphoto = _cellUser.photo;
            [_photoArray addObject:mainphoto.url];
        }
        if (_cellUser.photo1) {
            
            PFFile *mainphoto1 = _cellUser.photo1;
            [_photoArray addObject:mainphoto1.url];
        }
        if (_cellUser.photo2) {
            
            PFFile *mainphoto2 = _cellUser.photo2;
            [_photoArray addObject:mainphoto2.url];
        }
        if (_cellUser.photo3) {
            
            PFFile *mainphoto3 = _cellUser.photo3;
            [_photoArray addObject:mainphoto3.url];
        }
        
       
        [[segue destinationViewController]setGetPhotoArray:self.photoArray];
        [[segue destinationViewController] setUserId:_cellUser.objectId];
        [[segue destinationViewController]setStatus:_cellUser.online];
    }
}




-(IBAction)changeSex:(id)sender{
    
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            NSLog(@"1");
            break;
        case 1:
             NSLog(@"2");
            break;
        case 2:
             NSLog(@"3");
            break;
        default: 
            break; 
    }
    
    [self queryParseMethod];
    
    
}


@end
