//
//  WhoSeeViewController.m
//  speeddate
//
//  Created by studio76 on 21.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "WhoSeeViewController.h"
#import "UserNearMeViewController.h"
#import "UserParseHelper.h"
#import "SWRevealViewController.h"
#import "MBProgressHUD.h"
#import "UserProfileViewController.h"
#import "UIImageView+WebCache.h"

#import <MapKit/MapKit.h>
#import "WhoSeeMeHelper.h"

@interface WhoSeeViewController (){
    
}
@property UserParseHelper* mainUser;
@property UserParseHelper* cellUser;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property (nonatomic,weak) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic,retain) NSMutableArray *photoArray;
@property CLLocationManager* locationManager;
@property CLLocation* currentLocation;
@property NSNumber* milesAway;

@end

@implementation WhoSeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    self.navigationController.navigationBar.barTintColor = RED_LIGHT;
    self.navigationItem.title = @"My Guests";
    
    [self queryParseMethod];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void)queryParseMethod {
   
    PFQuery *query = [PFUser query];
    PFQuery *seeQuery = [PFQuery queryWithClassName:@"WhoSee"];
    [seeQuery whereKey:@"seeUser" equalTo:[PFUser currentUser].objectId];
    [query whereKey:@"objectId" matchesKey:@"userSee" inQuery:seeQuery];
    

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            userFilesArray = [[NSArray alloc] initWithArray:objects];
            
          
            
            [_whoCollectionView reloadData];
            [_whoCollectionView performBatchUpdates:nil completion:nil];
        }
    }];
    
   
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [userFilesArray count];
}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    static NSString *cellIdentifier = @"Cell";

    UserNearCollectionViewCell *cell = (UserNearCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    

    
    UserParseHelper *watUser = [userFilesArray objectAtIndex:indexPath.row];
    
    _cellUser = [userFilesArray objectAtIndex:indexPath.row];
    
    PFFile *imageFile = watUser.photo_thumb;
   
    
    NSURL *imgUrl = [NSURL URLWithString:imageFile.url];
    
   
    
    [cell.profileImage sd_setImageWithURL:imgUrl placeholderImage:[UIImage imageNamed:@"1024_gm.png"]];
    
    double distance = [_cellUser.geoPoint distanceInKilometersTo:[UserParseHelper currentUser].geoPoint];
    if ([_cellUser.geoPoint distanceInKilometersTo:[UserParseHelper currentUser].geoPoint] < 1) {
        distance = 1;
    }
    
    cell.distance.text = [NSString stringWithFormat:@"%.0fkm", distance];
    cell.agez.text = [NSString stringWithFormat:@"%@",watUser.age];
    
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
    
        if ([[segue identifier] isEqualToString:@"userprofileSee"]) {
            NSIndexPath *indexPath = [[self.whoCollectionView indexPathsForSelectedItems] lastObject];
            self.photoArray =[[NSMutableArray alloc]init];
            NSLog(@"%@",indexPath );
            
            UserProfileViewController *prVC = [[UserProfileViewController alloc]initWithNibName:@"UserVC" bundle:nil];
            prVC = segue.destinationViewController;
            _cellUser = [userFilesArray objectAtIndex:indexPath.row];
            
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







@end
