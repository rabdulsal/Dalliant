//
//  MatchProfileTVC.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/24/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "MatchProfileTVC.h"
#import <KIImagePager.h>
#import <MDRadialProgressLabel.h>
#import <MDRadialProgressTheme.h>
#import <MDRadialProgressView.h>

@interface MatchProfileTVC ()

@property (nonatomic) NSData *imageData;

@end

@implementation MatchProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set profileImage - Fbook photo blurry
    [_matchUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *userImage = [[UIImage alloc] initWithData:data];
        _imageData = data;
        _userFBPic.image = userImage;
    }];
    
    if ([_matchUser.isMale isEqualToString:@"false"]) {
        _userGender.text = @"F";
    } else _userGender.text = @"M";
    _userName.text               = _matchUser.nickname;
    _userDescription.text        = _matchUser.desc;
    _userAge.text                = [[NSString alloc] initWithFormat:@"%@", _matchUser.age];
    _matchBodyType.text          = _matchUser.bodyType;
    _matchDatingStatus.text      = _matchUser.relationshipStatus;
    _matchRelationshipType.text  = _matchUser.relationshipType;
    _matchWork.text              = [_matchUser userWork];
    _matchSchool.text            = [_matchUser userSchool];
    
    if ([_matchUser.drinks isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        _matchDrinksPref.text = @"Y";
        _matchDrinksPref.textColor = RED_LIGHT;
    } else _matchDrinksPref.text = @"N";
    if ([_matchUser.smokes isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        _matchSmokesPref.text = @"Y";
        _matchSmokesPref.textColor = RED_LIGHT;
    } else _matchSmokesPref.text = @"N";
    if ([_matchUser.drugs isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        _matchDrugsPref.text = @"Y";
        _matchDrugsPref.textColor = RED_LIGHT;
    }else _matchDrugsPref.text = @"N";
    if ([_matchUser.bodyArt isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        _matchBodyArPref.text = @"Y";
        _matchBodyArPref.textColor = RED_LIGHT;
    }else _matchBodyArPref.text = @"N";
    
    
    [self listInterests:_matchUser.interests];
    
    [self tapUserImage];
    
    [self configureRadialView];
    
    NSLog(@"%@'s compatiblility Index: %@", _matchUser.nickname, _matchCompatibility.compatibilityIndex);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setHighCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor     = RED_DEEP;
    newTheme.incompletedColor   = RED_LIGHT;
    newTheme.centerColor        = RED_OMNY;
}

- (void)setMedCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor     = SEA_DEEP_COLOR;
    newTheme.incompletedColor   = SEA_COLOR;
    newTheme.centerColor        = MENU_BLUE;
}

- (void)setLowCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor     = [UIColor darkGrayColor];
    newTheme.incompletedColor   = [UIColor lightGrayColor];
    newTheme.centerColor        = GRAY_COLOR;
}

- (void)configureRadialView
{
    MDRadialProgressTheme *newTheme = [[MDRadialProgressTheme alloc] init];
    //newTheme.completedColor = [UIColor colorWithRed:90/255.0 green:212/255.0 blue:39/255.0 alpha:1.0];
    
    //newTheme.incompletedColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
    newTheme.centerColor = [UIColor clearColor];
    //[self setHighCompatibilityColor:newTheme];
    
    // Compatibility conditional
    if (_matchCompatibility.compatibilityIndex > [NSNumber numberWithInt:66]) {
        [self setHighCompatibilityColor:newTheme];
    } else if (_matchCompatibility.compatibilityIndex < [NSNumber numberWithInt:66] && _matchCompatibility.compatibilityIndex > [NSNumber numberWithInt:33]) {
        [self setMedCompatibilityColor:newTheme];
    } else [self setLowCompatibilityColor:newTheme];
    
    newTheme.sliceDividerHidden = YES;
    newTheme.labelColor = [UIColor blackColor];
    newTheme.labelShadowColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(self.view.center.x - 30, 65, 60, 60);
    MDRadialProgressView *radialView7 = [[MDRadialProgressView alloc] initWithFrame:frame andTheme:newTheme];
    radialView7.progressTotal = (int)_matchCompatibility.totalPrefs;;
    radialView7.progressCounter = (int)_matchCompatibility.prefCounter;
    //[self.view addSubview:radialView7];
    [self.view addSubview:radialView7];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    _imagePager.pageControl.center = CGPointMake(CGRectGetWidth(_imagePager.frame)/2, CGRectGetHeight(_imagePager.frame)/2);
}

- (void)listInterests:(NSArray *)interests
{
    NSString *string = @"";
    for (int i = 0; i < interests.count; i++) {
        //_matchInterest1.numberOfLines = 1;
        string = [string stringByAppendingFormat:@"%@ \n", interests[i]];
        
        NSLog(@"%@", _matchUser.interests[i]);
    }
    
    _matchInterest1.text = string;
}

- (NSArray *) arrayWithImages:(KIImagePager*)pager
{
    
    return @[
             [[UIImage alloc] initWithData:_imageData],
             [[UIImage alloc] initWithData:_imageData],
             [[UIImage alloc] initWithData:_imageData],
             [[UIImage alloc] initWithData:_imageData]
             /*@"https://raw.github.com/kimar/tapebooth/master/Screenshots/Screen1.png",
             @"https://raw.github.com/kimar/tapebooth/master/Screenshots/Screen2.png",
             @"https://raw.github.com/kimar/tapebooth/master/Screenshots/Screen3.png"*/
             ];
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image inPager:(KIImagePager*)pager
{
    return UIViewContentModeScaleAspectFill;
}

- (NSString *) captionForImageAtIndex:(NSUInteger)index inPager:(KIImagePager*)pager
{
    return @[
             @"First screenshot",
             @"Another screenshot",
             @"Yet another one",
             @"Last one! ;-)"
             ][index];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - set up and handle pan gesture
- (void) tapUserImage
{
    [self.userFBPic setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [_userFBPic addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    //_userFBPic.userInteractionEnabled = NO;
    [self performSegueWithIdentifier:@"view_image" sender:nil];
}

- (IBAction)closeProfileView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)reportUser:(id)sender {
    
}

#pragma mark - Table view data source
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
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
