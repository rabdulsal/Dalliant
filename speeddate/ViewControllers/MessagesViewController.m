//
//  MessagesViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "MessagesViewController.h"
#import "UserParseHelper.h"
#import "PossibleMatchHelper.h"
#import "MessageParse.h"
#import "UserTableViewCell.h"
#import "UserMessagesViewController.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "GADInterstitial.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "IAPHelper.h"
#import <TDBadgedCell.h>
#import <MDRadialProgressLabel.h>
#import <MDRadialProgressTheme.h>
#import <MDRadialProgressView.h>

#define SECONDS_DAY 24*60*60

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;@property NSArray *filteredAllUsersArray;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property NSMutableArray *messages;
@property PossibleMatchHelper *matchUser;
@property int progressTotal;
@property int progressCounter;
@property NSArray *matchedUsers;

@end

@implementation MessagesViewController
@synthesize adBanner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
    mainUser = [User singleObj];
    
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 48, 20)];
    self.searchTextField.leftView = paddingView;
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:receivedMessage object:nil];
    
    
    [self customizeApp];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
  }

- (void)customizeApp
{
    self.tableView.backgroundColor = WHITE_COLOR;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    //self.searchTextField.backgroundColor = RED_DEEP;
  
}

- (void)setPossibleMatchesFromMessages:(NSArray *)matches for:(UserTableViewCell *)cell
{
    PFQuery *possMatch1 = [PossibleMatchHelper query];
    [possMatch1 whereKey:@"matches" containsAllObjectsInArray:matches];
    [possMatch1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        _matchUser = [objects objectAtIndex:0];
        [self configureRadialView:cell];
    }];
    //PFQuery *both = [PFQuery orQueryWithSubqueries:@[messageQueryFrom, messageQueryTo]];
}

- (void)setHighCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor = RED_DEEP;
    newTheme.incompletedColor = RED_LIGHT;
    newTheme.centerColor = RED_OMNY;
}

- (void)setLowCompatibilityColor:(MDRadialProgressTheme *)newTheme
{
    newTheme.completedColor = [UIColor darkGrayColor];
    newTheme.incompletedColor = [UIColor lightGrayColor];
    newTheme.centerColor = GRAY_COLOR;
}

- (void)configureRadialView:(UserTableViewCell *)matchCell
{
    MDRadialProgressTheme *newTheme = [[MDRadialProgressTheme alloc] init];
    //newTheme.completedColor = [UIColor colorWithRed:90/255.0 green:212/255.0 blue:39/255.0 alpha:1.0];
    
    //newTheme.incompletedColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
    newTheme.centerColor = [UIColor clearColor];
    //[self setHighCompatibilityColor:newTheme];
    [self setLowCompatibilityColor:newTheme];
    //newTheme.centerColor = [UIColor colorWithRed:224/255.0 green:248/255.0 blue:216/255.0 alpha:1.0];
    newTheme.sliceDividerHidden = YES;
    newTheme.labelColor = [UIColor blackColor];
    newTheme.labelShadowColor = [UIColor whiteColor];
    
    CGRect frame = CGRectMake(190, 8, 45, 45);
    MDRadialProgressView *radialView7 = [[MDRadialProgressView alloc] initWithFrame:frame andTheme:newTheme];
    radialView7.progressTotal = (int)_matchUser.totalPrefs;;
    radialView7.progressCounter = (int)_matchUser.prefCounter;
    //[self.view addSubview:radialView7];
    [matchCell.contentView addSubview:radialView7];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self loadingChat];
    [self reloadView];
}

- (void)receivedNotification:(NSNotification *)notification
{
    [self.usersArray removeAllObjects];
    [self.messages removeAllObjects];
    [self loadingChat];
}

- (void)loadingChat
{
    self.usersArray = [NSMutableArray new];
    self.messages = [NSMutableArray new];
    self.filteredAllUsersArray = [NSArray new];
    
    PFQuery *messageQueryFrom = [MessageParse query];
    [messageQueryFrom whereKey:@"fromUserParse" equalTo:[UserParseHelper currentUser]];
    PFQuery *messageQueryTo = [MessageParse query];
    [messageQueryTo whereKey:@"toUserParse" equalTo:[UserParseHelper currentUser]];
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[messageQueryFrom, messageQueryTo]];
    [both orderByDescending:@"createdAt"];
    
    [both findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableSet *users = [NSMutableSet new];
        for (MessageParse *message in objects) {
            if(![message.fromUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
                NSUInteger count = users.count;
                [users addObject:message.fromUserParse];
                if (users.count > count) {
                    [message.fromUserParse fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        [self.messages addObject:message];
                        [self.usersArray addObject:message.fromUserParse];
                        NSInteger position = [self.usersArray indexOfObject:message.fromUserParse];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:position inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }];
                }
            }
            if(![message.toUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
                NSUInteger count = users.count;
                [users addObject:message.toUserParse];
                if (users.count > count) {
                    [message.toUserParse fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        [self.messages addObject:message];
                        [self.usersArray addObject:message.toUserParse];
                        
                        NSInteger position = [self.usersArray indexOfObject:message.toUserParse];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:position inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }];
                }
            }
        }
        [self.tableView reloadData];
    }];
}

#pragma mark TableView Delegate - Includes Blurring

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UserParseHelper *user;
    if (self.filteredAllUsersArray.count) {
        user = [self.filteredAllUsersArray objectAtIndex:indexPath.row];
    } else {
        user = [self.usersArray objectAtIndex:indexPath.row];
    }
    
    [user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
        cell.userImageView.image = [UIImage imageWithData:data];
        
        // Configure Blur ---------------------------------------------------------------
        
        if (!mainUser.isRevealed) { // <-- Test purposes - change to check isRevealed on Matched User - NOT WORKING
            [self blurImages:cell.userImageView];
        }
        
    }];
    
    // Revealed conditional -----------------------------------------------------
    
    if (!mainUser.isRevealed) { // <-- Test purposes, change to test isRevealed on Matched User
        if ([user.isMale isEqualToString:@"true"]) {
            NSString *matchGender = @"Male";
            cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, user.age];
        } else {
            NSString *matchGender = @"Female";
            cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, user.age];
        }
        
    } else cell.nameTextLabel.text = user.nickname;
    
    // ----------------------------------------------------------------------------
    
    //cell.nameTextLabel.textColor = WHITE_COLOR;
    cell.nameTextLabel.textColor = RED_LIGHT;
    cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width / 2;
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.layer.borderWidth = 1.0,
    cell.userImageView.layer.borderColor = WHITE_COLOR.CGColor;
    
    UIImageView *accesory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accesory"]];
    accesory.frame = CGRectMake(15, 0, 15, 15);
    accesory.contentMode = UIViewContentModeScaleAspectFit;
    cell.accessoryView = accesory;
    
    MessageParse *message = [self.messages objectAtIndex:indexPath.row];
    cell.lastMessageLabel.text = message.text;
    if (!message.text && message.image) {
        cell.lastMessageLabel.text = @"Image";
    }
    if (!message.read && [message.toUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
        //cell.lastMessageLabel.textColor = WHITE_COLOR;
        cell.dateLabel.textColor = [UIColor lightGrayColor];
    } else {
        //cell.lastMessageLabel.textColor = WHITE_COLOR;
        cell.dateLabel.textColor = [UIColor lightGrayColor];
    }
    //cell.dateLabel.textColor = WHITE_COLOR;
    cell.dateLabel.textColor = RED_LIGHT;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    if ([[message createdAt] timeIntervalSinceNow] * -1 < SECONDS_DAY) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    
    cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
    UIView *bgColorView = [[UIView alloc] init];
    //bgColorView.backgroundColor = RED_COLOR;
    bgColorView.backgroundColor = WHITE_COLOR;
    [cell setSelectedBackgroundView:bgColorView];
    
    _matchedUsers = [[NSArray alloc] initWithObjects:[UserParseHelper currentUser], user, nil];
    [self setPossibleMatchesFromMessages:_matchedUsers for:cell];
    return cell;
}

#pragma mark - Blur Images

- (void)blurImages:(UIImageView *)imageView
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    UIVisualEffectView *visualEffectView;
    visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    visualEffectView.frame = imageView.bounds;
    [imageView addSubview:visualEffectView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchTextField.text.length) {
        return self.filteredAllUsersArray.count;
    }
    
    if (_usersArray.count) {
        mainUser.numberOfConvos = [[NSString alloc] initWithFormat:@"%lu", (unsigned long)_usersArray.count];
    }
    
    return self.usersArray.count;
}

#pragma mark - TAP TABLEVIEWCELL SEGUE TO CHAT
/*
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"chat" sender:self];
}
*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chat"]) {
        UserMessagesViewController *vc = segue.destinationViewController;
        if (self.filteredAllUsersArray.count) {
            vc.toUserParse = [self.filteredAllUsersArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        } else {
            vc.toUserParse = [self.usersArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        }
    }
}

- (IBAction)searchTextFieldChanged:(UITextField *)textfield
{
    NSLog(@"frame %@", NSStringFromCGRect(self.cameraButton.frame));
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"username CONTAINS %@",textfield.text];
    self.filteredAllUsersArray = [self.usersArray filteredArrayUsingPredicate:predicate];
    [self.tableView reloadData];
}

- (IBAction)searchTextFieldEnd:(id)sender {
    [sender resignFirstResponder];
}

- (IBAction)sendPhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}

#pragma mark KeyBoard Notifications

- (void)keyboardDidShow:(NSNotification *)notification
{
    [UIView animateWithDuration:1.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            CGRect rect = self.cameraButton.frame;
                            rect.origin.y -= 200;
                            self.cameraButton.frame = rect;
                        } completion:^(BOOL finished) {
                            
                        }];
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [UIView animateWithDuration:1.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            CGRect rect = self.cameraButton.frame;
                            rect.origin.y += 200;
                            self.cameraButton.frame = rect;
                        } completion:^(BOOL finished) {
                            
                        }];
}

#pragma mark - PickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image, 0.9)];
    
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        __block int count = 0;
        for (UserParseHelper *user in self.usersArray) {
            MessageParse *message = [MessageParse object];
            message.fromUserParse = [UserParseHelper currentUser];
            message.toUserParse = user;
            message.read = NO;
            message.image = file;
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:count inSection:0];
            count++;
            UserTableViewCell *cell = (UserTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.lastMessageLabel.text = @"Image";
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFQuery *query = [PFInstallation query];
                [query whereKey:@"objectId" equalTo:user.installation.objectId];
                [PFPush sendPushMessageToQueryInBackground:query
                                               withMessage:@"new image!"];
                
            }];
            
        }
    }];
    
}

- (void)reloadView
{
    UIView *parent = self.view.superview;
    [self.view removeFromSuperview];
    self.view = nil; // unloads the view
    [parent addSubview:self.view]; //reloads the view from the nib
}

#pragma mark GADRequest generation

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
    
}



@end