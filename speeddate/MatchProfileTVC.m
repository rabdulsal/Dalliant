//
//  MatchProfileTVC.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 12/24/14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "MatchProfileTVC.h"

@interface MatchProfileTVC ()

@end

@implementation MatchProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set profileImage - Fbook photo blurry
    [_matchUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        UIImage *userImage = [[UIImage alloc] initWithData:data];
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
    
    [self tapUserImage];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
