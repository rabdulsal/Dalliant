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
#import "MatchViewController.h"
#import "RevealRequest.h"
#import "ChatMessageViewController.h"
#import "speeddate-Swift.h"

#define SECONDS_DAY 24*60*60


NSString * const kRequestUpdateNotification = @"requestUpdateNotification";

@interface MessagesViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    int userShareState;
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@property NSArray *filteredAllUsersArray;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property NSMutableArray *messages;
@property (strong, nonatomic) PossibleMatchHelper *matchUser;
@property int progressTotal;
@property int progressCounter;
@property NSArray *matchedUsers;
@property RevealRequest *incomingRequest;
@property RevealRequest *outgoingRequest;
@property UIVisualEffectView *visualEffectView;
@property NSMutableDictionary *matchDict;

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
    
    [self customizeApp];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchShareReply:) name:@"FetchShareReply" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedNotification:) name:receivedMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTableView) name:kRequestUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self loadingChat];
}

- (void)customizeApp
{
    self.tableView.backgroundColor = WHITE_COLOR;
    self.tableView.separatorColor = [UIColor lightGrayColor];
    //self.searchTextField.backgroundColor = RED_DEEP;
  
}

- (void)setPossibleMatchesFromMessages:(NSArray *)matches for:(UserTableViewCell *)cell
{
    
    //PFQuery *both = [PFQuery orQueryWithSubqueries:@[messageQueryFrom, messageQueryTo]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    //[self loadingChat];
    //[self updateTableView];
}

- (void)receivedNotification:(NSNotification *)notification
{
    [self.usersArray removeAllObjects];
    [self.messages removeAllObjects];
    [self loadingChat];
}

- (void)getConversations
{
    self.messages = [NSMutableArray new];
    
    PFQuery *connections = [PossibleMatchHelper query];
    [connections whereKey:@"messagesCount" greaterThan:0];
    [connections orderByDescending:@"updatedAt"];
    [connections findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _messages = [[NSMutableArray alloc] initWithArray:objects];
        }
        
    }];
}

- (void)loadingChat
{
    NSLog(@"Loading chat run");
    _matchDict = [NSMutableDictionary new];
    self.usersArray = [NSMutableArray new];
    self.messages = [NSMutableArray new];
    self.filteredAllUsersArray = [NSArray new];
    
    [MessageParse getAllMessagesFromCurrentUser:[UserParseHelper currentUser] completion:^(NSArray *messages, NSError *error) {
        
        NSMutableSet *users = [NSMutableSet new];
        
        //Order Messages
        /*
         NSArray *messages = [NSArray new];
         messages = [objects sortedArrayUsingComparator:^NSComparisonResult(PFObject *a, PFObject *b)
         {
         return [b.createdAt compare:a.createdAt];
         }];
        */
        for (MessageParse *message in messages) {
            
            // Erase old Messages Conditional below
            
//            if ([[message createdAt] timeIntervalSinceNow] * -1 > SECONDS_DAY) {
                
                //[message deleteInBackground];
                
//            } else {
                
            // Display message
            UserParseHelper * __block match;
            NSString * __block userName;
                
            if(![message.fromUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
                NSUInteger count = users.count;
                [users addObject:message.fromUserParse];
                if (users.count > count) {
                    [message.fromUserParse fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        match = message.fromUserParse;
                        [self.messages addObject:message];
                        [self.usersArray addObject:match];
                        
                        // Set userName key for cache
                        userName = match.nickname;
                        [self fetchAllResources:message
                                 forCurrentUser:[UserParseHelper currentUser]
                                       andMatch:match
                                       forCache:userName];
                        
                        NSInteger position = [self.usersArray indexOfObject:match];
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
                        
                        match = message.toUserParse;
                        [self.messages addObject:message];
                        [self.usersArray addObject:match];
                        
                        // Set userName key for cache
                        userName = match.nickname;
                        [self fetchAllResources:message
                                 forCurrentUser:[UserParseHelper currentUser]
                                       andMatch:match
                                       forCache:userName];
                        
                        NSInteger position = [self.usersArray indexOfObject:match];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:position inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }];
                }
            }
//            }// End Chat erase conditional
            //NSLog(@"Message Created at: %@", message.createdAt);
        }
        
        //[self.tableView reloadData]; NOT NEEDED?
    }];
}

- (void)updateTableView
{
    [self reloadView];
}

- (void)fetchAllResources:(MessageParse *)message
           forCurrentUser:(UserParseHelper *)currentUser
                 andMatch:(UserParseHelper *)match
                 forCache:(NSString *)userName;
{
    _matchDict[userName] = [NSMutableDictionary new];
    [_matchDict[userName] addObject:match forKey:@"matchUser"];
    [_matchDict[userName] addObject:message forKey:@"message"];
    
    //Fetch PossibleMatch
    [PossibleMatchHelper getConnectionsBetweenCurrentUser:currentUser andMatch:match completion:^(PossibleMatchHelper *connection, NSError *error) {
        if (!error) {
            [_matchDict[userName] addObject:connection forKey:@"matchConnection"];
            
            //Fetch ShareRelationship
            [ShareRelationship fetchShareRelationshipBetween:currentUser andMatch:match completion:^(ShareRelationship * _Nullable shareRelation, NSError * _Nullable error) {
                
                NSInteger __block shareState;
                if (error) {
                    
                    // No prior ShareRelationship exists, so create one
                    [ShareRelationship createShareRelationshipBetween:currentUser andMatch:match completion:^(ShareRelationship * _Nullable shareRelation, NSError * _Nullable error) {
                        shareState = [shareRelation getCurrentUserShareState:currentUser];
                    }];
                    
                } else {
                    // Prior ShareRelation exists
                    shareState = [shareRelation getCurrentUserShareState:currentUser];
                }
                
                if (shareState) {
                    NSNumber *state = [NSNumber numberWithInteger:shareState];
                   [_matchDict[userName] addObject:state forKey:@"shareState"];
                }
                
                //Fetch Reveal
                [RevealRequest getRequestsBetween:currentUser andMatch:match completion:^(RevealRequest *outgoingRequest, RevealRequest *incomingRequest) {
                    if (outgoingRequest) {
                        
                        [_matchDict[userName] addObject:outgoingRequest forKey:@"outgoingRequest"];
                    }
                    
                    if (incomingRequest) {
                        
                        [_matchDict[userName] addObject:incomingRequest forKey:@"incomingRequest"];
                    }
                    
                    [self.tableView reloadData];
                }];
                
                [self.tableView reloadData];
            }];
            
        } else {
            // Handle error
        }
        
    }];
}

#pragma mark TableView Delegate - Includes Blurring

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    UserParseHelper *user;
    if (self.filteredAllUsersArray.count) {
        user = [self.filteredAllUsersArray objectAtIndex:indexPath.row];
    } else {
        user = [self.usersArray objectAtIndex:indexPath.row];
    }
    
    [cell configureCellWithUserCache:_matchDict[user.nickname]];
    
    CGRect frame = CGRectMake(190, 8, 45, 45);
    [cell configureRadialViewForFrame:frame];
    
    return cell;
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

#pragma marks - Swipe to Delete Delegates

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
    {
        // Return NO if you do not want the specified item to be editable.
        return YES;
    }

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
    {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            // Delete the row from the data source
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else if (editingStyle == UITableViewCellEditingStyleInsert) {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
 }

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        return @"Un-Match";
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
    // Try to use this code in AppDelegate for Chat Notification
    if ([segue.identifier isEqualToString:@"chat"]) {
        ChatMessageViewController *vc = segue.destinationViewController;
        vc.toUserParse      = [self.usersArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        vc.curUser          = [UserParseHelper currentUser];
        vc.matchedUsers     = _matchUser;
        vc.fromConversation = true;
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
    
    [self.tableView reloadData];
}

#pragma mark GADRequest generation

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 0;
    
}



@end