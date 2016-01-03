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
// ------- DEPRECATED * USE REVEALREQUEST CLASS METHOD ----------
//- (void)fetchShareRequestWith:(UserParseHelper *)user // Change to FetchShareReply
//{
//    NSLog(@"Fetched share request");
//    
//    // Fetch Reply based on RevealRequest.Id
//    
//    // Once Fetched send reply using RevealRequest method
//    
//    PFQuery *requestFromQuery = [RevealRequest query];
//    [requestFromQuery whereKey:@"requestFromUser" equalTo:[UserParseHelper currentUser]];
//    [requestFromQuery whereKey:@"requestToUser" equalTo:user];
//    
//    PFQuery *requestToQuery = [RevealRequest query];
//    [requestToQuery whereKey:@"requestToUser" equalTo:[UserParseHelper currentUser]];
//    [requestToQuery whereKey:@"requestFromUser" equalTo:user];
//    
//    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:@[requestFromQuery, requestToQuery]];
//    [orQuery findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
//        NSArray *requests = [objects copy];
//        NSLog(@"Requests count: %lu", (unsigned long)[requests count]);
//        
//        for (RevealRequest *request in requests) {
//            UserParseHelper *fromRequestUser = (UserParseHelper *)[request.requestFromUser fetchIfNeeded];
//            
//            UserParseHelper *toRequestUser = (UserParseHelper *)[request.requestToUser fetchIfNeeded];
//            
//            if ([fromRequestUser isEqual:[UserParseHelper currentUser]]) {
//                _outgoingRequest = request; //Equivalent to outgoingRequest
//                NSLog(@"Request from Me and to %@", _outgoingRequest.requestToUser.nickname);
//            } else if ([toRequestUser isEqual:[UserParseHelper currentUser]]) {
//                _incomingRequest = request; //Equivalent to incomingRequest
//                NSLog(@"Request from Other User: %@", _incomingRequest.requestFromUser.nickname);
//            }
//        }
//    }];   
//    
//}

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
    
    PFQuery *messageQueryFrom = [MessageParse query];
    [messageQueryFrom whereKey:@"fromUserParse" equalTo:[UserParseHelper currentUser]];
    PFQuery *messageQueryTo = [MessageParse query];
    [messageQueryTo whereKey:@"toUserParse" equalTo:[UserParseHelper currentUser]];
    PFQuery *both = [PFQuery orQueryWithSubqueries:@[messageQueryFrom, messageQueryTo]];
    [both orderByDescending:@"createdAt"];
    //[both orderByDescending:@"compatibilityIndex"]; // <-- Won't work for now, need a compatibility attribute on messages somehow
    
    [both findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSMutableSet *users = [NSMutableSet new];
        
        //Order Messages
        /*
         NSArray *messages = [NSArray new];
         messages = [objects sortedArrayUsingComparator:^NSComparisonResult(PFObject *a, PFObject *b)
         {
         return [b.createdAt compare:a.createdAt];
         }];
        */
        for (MessageParse *message in objects) {
            
            // Erase old Messages Conditional below
            
//            if ([[message createdAt] timeIntervalSinceNow] * -1 > SECONDS_DAY) {
                
                //[message deleteInBackground];
                
//            } else {
                
            // Display message
            UserParseHelper * __block match;
                
            if(![message.fromUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
                NSUInteger count = users.count;
                [users addObject:message.fromUserParse];
                if (users.count > count) {
                    [message.fromUserParse fetchIfNeededInBackgroundWithBlock:^(PFObject *object, NSError *error) {
                        match = message.fromUserParse;
                        [self.messages addObject:message];
                        [self.usersArray addObject:match];
                        /*
                         * TODO: query PossibleMatch, ShareRelationship & RevealRequest based on message.fromUserParse and add to possibleMatch arraycreate dictionary, of form
                         * { userName:
                         *  {   "message" : message, 
                         *      "possibleMatch" : possMatch,
                         *      "shareRelation" : shareRelation
                         *      "outgoingRequest" : outgoingRequest,
                         *      "incomingRequest" : incomingRequest
                         *  } 
                         * }
                         */
                        // TODO: [self createUserCache]
                        _matchDict[message.fromUserParse.nickname] = @{@"possibleMatch":@"testMatch"};
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
                        
                        match = message.toUserParse;
                        [self.messages addObject:message];
                        [self.usersArray addObject:match];
                        // TODO: [self createUserCache]
                        NSString *userName = message.toUserParse.nickname;
                        _matchDict[userName] = [NSMutableDictionary new];
                        [_matchDict[userName] addObject:match forKey:@"matchUser"];
                        
                        //Fetch PossibleMatch
                        [PossibleMatchHelper getConnectionsBetweenCurrentUser:[UserParseHelper currentUser] andMatch:message.toUserParse completion:^(PossibleMatchHelper *connection, NSError *error) {
                            if (!error) {
                                [_matchDict[userName] addObject:connection forKey:@"matchConnection"];
                                
                                //Fetch ShareRelationship
                                [ShareRelationship fetchShareRelationshipBetween:[UserParseHelper currentUser] andMatch:match completion:^(ShareRelationship * _Nullable shareRelation, NSError * _Nullable error) {
                                    if (error) {
                                        
                                        // No prior ShareRelationship exists, so create one
                                        ShareRelationship *shareRelationship     = [ShareRelationship objectWithClassName:@"ShareRelationship"];
                                        shareRelationship.firstRequestedSharer   = [UserParseHelper currentUser].nickname;
                                        shareRelationship.firstSharerShareState  = ShareStateNotSharing;
                                        shareRelationship.secondRequestedSharer  = match.nickname;
                                        shareRelationship.secondSharerShareState = ShareStateNotSharing;
                                        [shareRelationship saveInBackground];
                                        
                                        [_matchDict[userName] addObject:shareRelationship forKey:@"shareRelation"];
                                        
                                    } else {
                                        // Prior ShareRelation exists
                                        [_matchDict[userName] addObject:shareRelation forKey:@"sharerelation"];
                                    }
                                    
                                    //Fetch Reveal
                                    [RevealRequest getRequestsBetween:[UserParseHelper currentUser] andMatch:match completion:^(RevealRequest *outgoingRequest, RevealRequest *incomingRequest) {
                                        if (outgoingRequest) {
                                            
                                            [_matchDict[userName] addObject:outgoingRequest forKey:@"outgoingRequest"];
                                        }
                                        
                                        if (incomingRequest) {
                                            
                                            [_matchDict[userName] addObject:incomingRequest forKey:@"incomingRequest"];
                                        }
                                    }];
                                }];
                                
                            } else {
                                // Handle error
                            }
                            
                        }];
                        
                        NSInteger position = [self.usersArray indexOfObject:match];
                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:position inSection:0];
                        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }];
                }
            }
//            }// End Chat erase conditional
            //NSLog(@"Message Created at: %@", message.createdAt);
        }
        
        [self.tableView reloadData];
    }];
}

- (void)updateTableView
{
    [self reloadView];
}

#pragma mark TableView Delegate - Includes Blurring

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    // TODO: cell method configureCell
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indicatorLabel.hidden = YES;
    cell.indicatorLabel.layer.cornerRadius = cell.indicatorLabel.frame.size.width/2;
    cell.indicatorLabel.layer.masksToBounds = YES;
    
    UserParseHelper *user;
    if (self.filteredAllUsersArray.count) {
        user = [self.filteredAllUsersArray objectAtIndex:indexPath.row];
    } else {
        user = [self.usersArray objectAtIndex:indexPath.row];
    }
    
    //[self fetchShareRequestWith:user];
    // Get Match Relationship based on index position, query done above
    _matchedUsers = [[NSArray alloc] initWithObjects:[UserParseHelper currentUser], user, nil];
    PFQuery *possMatch1 = [PossibleMatchHelper query];
    [possMatch1 whereKey:@"matches" containsAllObjectsInArray:_matchedUsers];
    //[possMatch1 findObjects];
    [possMatch1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //for (PossibleMatchHelper *match in objects) {
        _matchUser = [objects objectAtIndex:0];
        
        CGRect frame = CGRectMake(190, 8, 45, 45);
        [_matchUser configureRadialViewForView:cell.contentView withFrame:frame];
        //[self configureRadialView:cell];
        //}
        if (!cell.userImageView.image) {
            [user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                cell.userImageView.image = [UIImage imageWithData:data];
                if (_visualEffectView == nil && userShareState != ShareStateSharing) {
                    [self blurImages:cell.userImageView];
                    NSString *matchGender;
                    matchGender = [user.isMale isEqualToString:@"true"] ? @"Male" : @"Female";
                    cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, user.age];
                }
    //            [self blurImages:cell.userImageView];
    //            
    //            if ([user.isMale isEqualToString:@"true"]) {
    //                NSString *matchGender = @"Male";
    //                cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, user.age];
    //            } else {
    //                NSString *matchGender = @"Female";
    //                cell.nameTextLabel.text = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, user.age];
    //            }
    //          DEPRECATED USE SHARESTATE
    //            if ((_outgoingRequest && _incomingRequest) || _incomingRequest) {
    //                if (_incomingRequest.requestReply isEqualToNumber:[NSNumber numberWithBool:YES] && [_incomingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]] && [_incomingRequest.requestFromUser isEqual:user]) {
    //                    cell.nameTextLabel.text = user.nickname;
    //                    [_visualEffectView removeFromSuperview];
    //                    NSLog(@"%@ revealed!", user.nickname);
    //                }
    //            }
    //            
    //            if ((_incomingRequest && _outgoingRequest) || _outgoingRequest) {
    //                if (_outgoingRequest.requestReply isEqualToNumber:[NSNumber numberWithBool:YES] && [_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]] && [_outgoingRequest.requestToUser isEqual:user]) {
    //                    cell.nameTextLabel.text = user.nickname;
    //                    [_visualEffectView removeFromSuperview];
    //                    NSLog(@"%@ revealed!", user.nickname);
    //                }
    //            }
                [ShareRelationship fetchShareRelationshipBetween:[UserParseHelper currentUser]
                                                        andMatch:user
                                                      completion:^(ShareRelationship * _Nullable relationship, NSError * _Nullable error) {
                    if (relationship) {
                        userShareState = [relationship getCurrentUserShareState:[UserParseHelper currentUser]];
    //                    if (userShareState == ShareStateSharing) {
    //                        cell.nameTextLabel.text = user.nickname;
    //                        [_visualEffectView removeFromSuperview];
    //                    }
                        if (userShareState == ShareStateSharing && _visualEffectView != nil) {
                            cell.nameTextLabel.text = user.nickname;
                            [_visualEffectView removeFromSuperview];
                        }
                    } else if (error) {
                        // Handle Error
                    }
                }];
            }];
        }
    }];
    
    //[self setPossibleMatchesFromMessages:_matchedUsers for:cell];
    
    
    // Revealed conditional -----------------------------------------------------
    
    
    
    // ----------------------------------------------------------------------------
    
    //cell.nameTextLabel.textColor = WHITE_COLOR;
    cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.height / 2;
    cell.userImageView.layer.masksToBounds = YES;
    /*
    cell.userImageView.layer.borderWidth = 1.0,
    cell.userImageView.layer.borderColor = WHITE_COLOR.CGColor;
    */
    UIImageView *accesory = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"accesory"]];
    accesory.frame = CGRectMake(15, 0, 15, 15);
    accesory.contentMode = UIViewContentModeScaleAspectFit;
    cell.accessoryView = accesory;
    
    MessageParse *message = [self.messages objectAtIndex:indexPath.row];
    
    // TODO: cell method updateLabelsFromMessage:message
    cell.lastMessageLabel.text = message.text;
    if (!message.text && message.image) {
        cell.lastMessageLabel.text = @"Image";
    }
    if (!message.read && [message.toUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
        cell.nameTextLabel.textColor = RED_LIGHT;
        [cell.lastMessageLabel setFont:[UIFont boldSystemFontOfSize:13]];
        cell.lastMessageLabel.textColor = RED_LIGHT;
        cell.dateLabel.textColor = RED_LIGHT;
    } else {
        //cell.lastMessageLabel.textColor = WHITE_COLOR;
        cell.nameTextLabel.textColor = [UIColor lightGrayColor];
        cell.lastMessageLabel.textColor = [UIColor lightGrayColor];
        cell.dateLabel.textColor = [UIColor lightGrayColor];
    }
    //cell.dateLabel.textColor = WHITE_COLOR;
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    if ([[message createdAt] timeIntervalSinceNow] * -1 < SECONDS_DAY) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }
    
    cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
    
    // TODO: add to configureCell method
    UIView *bgColorView = [[UIView alloc] init];
    //bgColorView.backgroundColor = RED_COLOR;
    bgColorView.backgroundColor = WHITE_COLOR;
    [cell setSelectedBackgroundView:bgColorView];
    
    // TODO: Query Requests above with Messages and PossibleMatch; add here via index position
    [RevealRequest getRequestsBetween:[UserParseHelper currentUser] andMatch:user completion:^(RevealRequest *outgoingRequest, RevealRequest *incomingRequest) {
        if (incomingRequest) {
            _incomingRequest = incomingRequest;
            if (_incomingRequest.requestReply == nil /*[NSNumber numberWithBool:YES] && _incomingRequest.requestReply != [NSNumber numberWithBool:YES]*/) {
                cell.indicatorLabel.hidden = NO;
                cell.indicatorLabel.backgroundColor = [UIColor purpleColor];
            }
        }
        
        if (outgoingRequest) {
            _outgoingRequest = outgoingRequest;
            if ((_outgoingRequest.requestReply != nil && ![_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) /*|| (_outgoingRequest.requestReply isEqualToNumber:[NSNumber numberWithBool:NO] && ![_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])*/) {
                cell.indicatorLabel.hidden = NO;
                cell.indicatorLabel.backgroundColor = RED_LIGHT;
            }
        }
    }];
    
    return cell;
}

#pragma mark - Blur Images

- (void)blurImages:(UIImageView *)imageView
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _visualEffectView.frame = imageView.bounds;
    [imageView addSubview:_visualEffectView];
}

- (void)setUserData:(UserParseHelper *)user forCell:(UserTableViewCell *)cell
{
    
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
        /*
        UserMessagesViewController *vc = segue.destinationViewController;
        //vc.matchedUsers = _matchUser;
        
        if (self.filteredAllUsersArray.count) {
            vc.toUserParse = [self.filteredAllUsersArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
            vc.curUser = [UserParseHelper currentUser];
            vc.fromConversation = true;
        } else {
            vc.toUserParse = [self.usersArray objectAtIndex:self.tableView.indexPathForSelectedRow.row];
            vc.curUser = [UserParseHelper currentUser];
            vc.fromConversation = true;
        }
         */
        /*
        MatchViewController *matchVC = [[MatchViewController alloc]init];
        matchVC = segue.destinationViewController;
        //PossibleMatchHelper *matchRelationship = [self.matchRelationships objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        //matchVC.userFBPic.image             = _toUserParse.photo;
        UserParseHelper *match  = _matchUser.toUser;
        matchVC.matchUser       = (UserParseHelper *)[match fetchIfNeeded];
        matchVC.possibleMatch   = _matchUser;
        matchVC.getPhotoArray   = [NSMutableArray new];
        matchVC.user            = [UserParseHelper currentUser];
        
        [matchVC setUserPhotosArray:matchVC.matchUser];
         */
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