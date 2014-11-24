//
//  MessagesViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "MessagesViewController.h"
#import "UserParseHelper.h"
#import "MessageParse.h"
#import "UserTableViewCell.h"
#import "UserMessagesViewController.h"

#import "GADBannerView.h"
#import "GADRequest.h"
#import "GADInterstitial.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "IAPHelper.h"


#define SECONDS_DAY 24*60*60

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;

@property NSMutableArray *usersArray;
@property NSArray *filteredAllUsersArray;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property NSMutableArray *messages;
@end

@implementation MessagesViewController
@synthesize adBanner;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
    
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
    self.tableView.backgroundColor = RED_LIGHT;
    self.tableView.separatorColor = RED_DEEP;
    self.searchTextField.backgroundColor = RED_DEEP;
  
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self loadingChat];
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

#pragma mark TableView Delegate

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
    
    cell.nameTextLabel.text = user.nickname;
    cell.nameTextLabel.textColor = WHITE_COLOR;
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
        cell.lastMessageLabel.textColor = WHITE_COLOR;
    } else {
        cell.lastMessageLabel.textColor = WHITE_COLOR;
    }
    cell.dateLabel.textColor = WHITE_COLOR;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    if ([[message createdAt] timeIntervalSinceNow] * -1 < SECONDS_DAY) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
    UIView *bgColorView = [[UIView alloc] init];
    bgColorView.backgroundColor = RED_COLOR;
    [cell setSelectedBackgroundView:bgColorView];
    [user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        cell.userImageView.image = [UIImage imageWithData:data];
    }];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchTextField.text.length) {
        return self.filteredAllUsersArray.count;
    }
    return self.usersArray.count;
}
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

#pragma mark GADRequest generation

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    
    
    return 0;

    
}



@end