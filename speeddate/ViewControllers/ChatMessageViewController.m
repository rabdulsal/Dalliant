//
//  ChatMessageViewController.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 2/16/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "ChatMessageViewController.h"
#import "MatchViewController.h"
#import "Report.h"
#import "RevealRequest.h"


@interface ChatMessageViewController ()
{
    JSQMessagesBubbleImage *bubbleImageOutgoing;
    JSQMessagesBubbleImage *bubbleImageIncoming;
    //JSQMessagesAvatarImage *userAvatar;
    JSQMessagesAvatarImage *matchAvatar;
}
@property NSMutableArray *messages;
@property UIImage *toPhoto;
@property UIImage *fromPhoto;
@property (strong, nonatomic) RevealRequest *receivedRequest;
@property (strong, nonatomic) RevealRequest *receivedReply;

@end

@implementation ChatMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Configure ChatUI NOTE: must set custom image dimensions via CGRectMake
    self.title = @"Chat";
    UIImage *btnImage = [UIImage imageNamed:@"user"];
    CGRect btnImageFrame = CGRectMake(self.inputToolbar.contentView.leftBarButtonItem.frame.origin.x, self.inputToolbar.contentView.leftBarButtonItem.frame.origin.y, 27, 27);
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(actionPressed:)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self.inputToolbar.contentView.leftBarButtonItem setFrame:btnImageFrame];
    [self.inputToolbar.contentView.leftBarButtonItem setImage:btnImage forState:UIControlStateNormal];
    
    self.senderId           = _curUser.objectId;
    self.senderDisplayName  = _curUser.nickname;
    
    /* --------- Maybe instead of blur, hide/un-hide avatars after reveal
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     */
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.messages = [NSMutableArray new];
    [self getAvatarPhotos];
    [self getMessages];
    [self fetchCompatibleMatch];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    //bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:RED_LIGHT];
    
    // Notification to fetch New Message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessage:) name:receivedMessage object:nil];
    
    [self customizeVC];
    
}

- (void)customizeVC
{
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)getAvatarPhotos
{
    //__block int count = 0;
    PFQuery *queryFrom = [UserParseHelper query];
    [queryFrom getObjectInBackgroundWithId:self.toUserParse.objectId
                                     block:^(PFObject *object, NSError *error)
     {
         PFFile *file = [object objectForKey:@"photo"];
         [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             UIImage *chatatar = [UIImage imageWithData:data];
             matchAvatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:chatatar diameter:40];
             /*
             count++;
             if (count == 2) {
                 [self.collectionView reloadData];
             }*/
         }];
     }];
}

#pragma mark - Get Messages

- (void)getMessages
{
    PFQuery *query1 = [MessageParse query];
    [query1 whereKey:@"fromUserParse" equalTo:_curUser];
    [query1 whereKey:@"toUserParse" equalTo:self.toUserParse];
    [query1 whereKey:@"text" notEqualTo:@""];
    
    PFQuery *query2 = [MessageParse query];
    [query2 whereKey:@"fromUserParse" equalTo:self.toUserParse];
    [query2 whereKey:@"toUserParse" equalTo:_curUser];
    [query2 whereKey:@"text" notEqualTo:@""];
    
    
    PFQuery *orQUery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    [orQUery orderByAscending:@"createdAt"];
    
    // orQUery.limit = 3;
    // orQUery.skip = 5;
    [orQUery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Retrieved Messages: %lu", (unsigned long)[objects count]);
        //self.messages = [objects mutableCopy];
        //[self.collectionView reloadData];
        //[self scrollCollectionView];
        if (!error) {
            [self processMessages:objects];
        }
        
        //[self.collectionView reloadData];
    }];
}

#pragma mark - Get Message w/ Notification

- (void)getNewMessage:(NSNotification *)note
{
    
    PFQuery *query = [MessageParse query];
    [query whereKey:@"fromUserParse" equalTo:self.toUserParse];
    [query whereKey:@"toUserParse" equalTo:_curUser];
    [query whereKey:@"read" equalTo:[NSNumber numberWithBool:NO]]; // <-- Key to determine if Message is read - add to TDBadgeCell logic for
    
    
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [self processMessages:objects];
        }
        
    }];
}

- (void)processMessages:(NSArray *)objects
{
    for (MessageParse *message in objects) {
        message.read = YES;
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            NSString *displayName   = nil;
            NSString *senderId      = nil;
            if ([message.fromUserParse isEqual:_curUser]) {
                senderId    = _curUser.objectId;
                displayName = _curUser.nickname;
            } else {
                senderId    = _toUserParse.objectId;
                displayName = _toUserParse.nickname;
            }
            __block JSQMessage *chatMessage = nil;
            
            //PhotoMediaItem?
            if (message.image) {
                NSLog(@"Image file found, sender = %@", displayName);
                PFFile *filePicture = message.image;
                NSData *imageData = [filePicture getData];
                
                JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
                
                if ([senderId isEqualToString:_curUser.objectId]) {
                    mediaItem.appliesMediaViewMaskAsOutgoing = YES;
                } else mediaItem.appliesMediaViewMaskAsOutgoing = NO;
                
                
                chatMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                 senderDisplayName:displayName
                                                              date:message.createdAt
                                                             media:mediaItem];
                
            } else {
                
                chatMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                 senderDisplayName:displayName
                                                              date:message.createdAt
                                                              text:message.text];
            }
            
            [self.messages addObject:chatMessage];
            NSLog(@"Chat messages count: %lu", (unsigned long)[_messages count]);
            [self finishReceivingMessage];
            
        }];
        
    }
}

- (void)fetchCompatibleMatch
{
    NSArray *matchedUsers = [[NSArray alloc] initWithObjects:_curUser, _toUserParse, nil];
    PFQuery *possMatch1 = [PossibleMatchHelper query];
    [possMatch1 whereKey:@"matches" containsAllObjectsInArray:matchedUsers];
    //[possMatch1 findObjects];
    [possMatch1 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //for (PossibleMatchHelper *match in objects) {
        _matchedUsers = [objects objectAtIndex:0];
    }];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    MessageParse *message = [MessageParse object];
    message.text = text;
    message.createdAt = date;
    message.fromUserParse = _curUser;
    message.toUserParse = self.toUserParse;
    message.read = NO;
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            
            JSQMessage *chatMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                         senderDisplayName:senderDisplayName
                                                                      date:date
                                                                      text:text];
            [self.messages addObject:chatMessage];
            [self sendMessageNotification:message.text];
            [self finishSendingMessage];
        }
        
    }];
    
}

- (void)sendMessageNotification:(NSString *)message
{
    if (self.toUserParse.installation.objectId) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
        PFUser *pushUser = _curUser;
        NSString *pushUserto = pushUser[@"nickname"];
        
        NSString *pushMessage = nil;
        
        if ((!_receivedRequest && !_receivedReply) || !([_receivedRequest.requestReply isEqualToString:@"Yes"] && [_receivedRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) || !([_receivedReply.requestReply isEqualToString:@"Yes"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])) {
            pushMessage = [NSString stringWithFormat:@"Your Match says: %@", message];
        } else pushMessage = [NSString stringWithFormat:@"%@ says: %@",pushUserto,message];
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              pushMessage, @"alert",
                              @"Increment", @"badge",
                              @"Ache.caf", @"sound",
                              nil];
        
        PFPush *push = [[PFPush alloc] init];
        
        [push setQuery:query];
        [push setData:data];
        [push sendPushInBackground];
        NSLog(@"Push Message sent");
    }
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return bubbleImageOutgoing;
    }
    
    return bubbleImageIncoming;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:_toUserParse.objectId]) {
        
        return matchAvatar;
        
    } else return nil;

    //return [self.demoData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *chatMessage = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([chatMessage.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:chatMessage.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:chatMessage.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    
    // if-conditional for using camera vs. photolibrary
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    //imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType]; <-- Comment-out Video option
    [self presentViewController:imagePicker animated:YES completion:nil];
    
}

- (void)addPhotoMediaMessageWithImage:(UIImage *)image
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:_curUser.objectId displayName:_curUser.nickname media:photoItem];
    
    [self.messages addObject:photoMessage];
    [self finishSendingMessage];
}

- (void)repliedToShareRequest
{
    NSLog(@"Start Replied To Share Request");
    /* _matchedUsers.usersRevealed = [NSNumber numberWithBool:YES];
     } else if ([_receivedRequest.requestReply isEqualToString:@"No"]){
     [_matchedUsers.usersRevealed isEqualToNumber:[NSNumber numberWithBool:NO]];
     }*/
    
    //[_matchedUsers saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //    if (succeeded) {
    
    /*PFUser *pushUser = _curUser;
     NSString *pushUserto = pushUser[@"nickname"];*/
    
    // Push does not work from Sim-to-Phone!
    PFQuery *query = [PFInstallation query];
    [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Identity Share Reply"], @"alert",
                          @"Increment", @"badge",
                          @"Ache.caf", @"sound",nil];
    
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push setData:data];
    [push sendPushInBackground];
    
    if ([_receivedRequest.requestReply isEqualToString:@"Yes"]) {
        NSLog(@"Received Request Reply: %@", _receivedRequest.requestReply);
        //[self reloadView];
        [self.collectionView reloadData];
        [self performSegueWithIdentifier:@"view_match" sender:nil];
        NSLog(@"Pushed to Match User Profile");
    } else {
        NSLog(@"Notification pushed, but Request Reply code not run");
    }
    // Must set check in @"match_view" ViewWillAppear
    //    }
    // }];
}

- (void)shareRequestRejected
{
    UIImage *btnImage = [UIImage imageNamed:@"No_icon"];
    /* Replace with Left Input button configuration
    [_cameraButton setImage:btnImage forState:UIControlStateNormal];
    _cameraButton.enabled = NO;
    _cameraButton.alpha = 1.0;*/
}

#pragma mark - ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    //Save image to Parse
    
    MessageParse *message   = [MessageParse object];
    message.fromUserParse   = _curUser;
    message.toUserParse     = self.toUserParse;
    message.read            = NO;
    //[self.messages addObject:message];
    
    message.sendImage = image;
    /*
    NSInteger item = [self.collectionView numberOfItemsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    [self scrollCollectionView];
    */
    
    PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image, 0.9)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        message.image = file;
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            PFQuery *query = [PFInstallation query];
            PFUser *pushUser = _curUser;
            NSString *pushUserto = pushUser[@"nickname"];
            [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@ send image",pushUserto], @"alert",
                                  [NSString stringWithFormat:@"%@", _toUserParse], @"match",
                                  @"Increment", @"badge",
                                  @"Ache.caf", @"sound",
                                  nil];
            PFPush *push = [[PFPush alloc] init];
            
            [push setQuery:query];
            [push setData:data];
            [push sendPushInBackground];
            
            [self addPhotoMediaMessageWithImage:image];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }];
     
}

#pragma mark - Report / UnMatch Actionsheet

- (IBAction)actionPressed:(id)sender
{
    if (self.fromConversation) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Match Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Profile", @"End Chat",@"Report",@"Block", nil];
        sheet.tag = 3;
        [sheet showInView:self.view];
    } else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Match Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"End Chat",@"Report",@"Block", nil];
        sheet.tag = 2;
        [sheet showInView:self.view];
    }
    
}

#pragma mark - ActionSheetDelegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) { // <-- Clicked Reveal Request Button
        
        // No Received Request and No Received Reply
        /*
         if (!_receivedRequest && !_receivedReply && buttonIndex == 0) {
         [self sendShareRequest];
         }
         
         // Rejected Received Reply
         
         if (!([_receivedReply.requestReply isEqualToString:@"Yes"] && [_receivedReply.requestFromUser isEqual:_toUserParse] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) && buttonIndex == 0) { // <-- Change to isRevealed check on PossibleMatchHelper
         // Test purposes
         /*mainUser.isRevealed = true;
         [self reloadView];// Closed comment here
         
         // <-- Apparently this works when app is in background, a notification is sent and appears as alert
         // RevealRequest setup
         [self sendShareRequest];
         }
         */
        if (buttonIndex == 0) {
            //[self sendShareRequest];
            NSLog(@"Share Request button pressed.");
        }
        
    } else if (actionSheet.tag == 2) { // <-- Clicked Match Options Button
        
        if (buttonIndex == 0) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"End Chat"
                                                         message:@"Are you sure you want to End this Chat? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"End Chat", nil];
            av.tag = 5;
            [av show];
        }
        
        if (buttonIndex == 1) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Report"
                                                         message:@"Are you sure you want to Block this user? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Report", nil];
            av.tag = 2;
            [av show];
        }
        
        if (buttonIndex == 2) { //<-- Block User
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Block User"
                                                         message:@"Are you sure you want to Block this user? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Block", nil];
            av.tag = 6;
            [av show];
            
        }
        
    } else if (actionSheet.tag == 3) {
        
        if (buttonIndex == 0) {
            [self performSegueWithIdentifier:@"view_match" sender:nil];
            NSLog(@"View Profile Pressed");
        }
        
        if (buttonIndex == 1) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"End Chat"
                                                         message:@"Are you sure you want to End this Chat? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"End Chat", nil];
            av.tag = 5;
            [av show];
        }
        
        if (buttonIndex == 2) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Report"
                                                         message:@"Are you sure you want to Block this user? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Report", nil];
            av.tag = 2;
            [av show];
        }
        
        if (buttonIndex == 3) { //<-- Block User
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Block User"
                                                         message:@"Are you sure you want to Block this user? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Block", nil];
            av.tag = 6;
            [av show];
            
        }
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"view_match"]){
        //if ([[segue identifier] isEqualToString:@"userprofileSee"]) {
        // Move to ViewDidLoad
        NSLog(@"View Profile Pressed");
        MatchViewController *matchVC    = [[MatchViewController alloc]init];
        matchVC                         = segue.destinationViewController;
        //matchVC.userFBPic.image             = _toUserParse.photo;
        matchVC.matchUser               = _toUserParse;
        matchVC.possibleMatch           = _matchedUsers;
        matchVC.fromConversation        = true;
        
        [matchVC setUserPhotosArray:matchVC.matchUser];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Handle the Alert after Current User has Replied to Received Request
    
    if (alertView.tag == 1) {
        /*
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{ // 1
         dispatch_group_t downloadGroup = dispatch_group_create(); // 2
         dispatch_group_enter(downloadGroup); // 3
         NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
         NSString *reply = [[NSString alloc] init];
         
         if([title isEqualToString:@"Yes"]){
         NSLog(@"Clicked Yes");
         reply = @"Yes";
         //_curUser.isRevealed = [NSNumber numberWithBool:YES]; <-- Update isRevealed in PossibleMatchHelper
         //[self reloadView];
         // Show "You've Revealed' animation
         
         } else if ([title isEqualToString:@"No"]) {
         NSLog(@"Clicked No");
         reply = @"No";
         //_curUser.isRevealed = [NSNumber numberWithBool:NO]; //<-- No reason to update the database
         // Show "No Reveal" animation
         }
         dispatch_group_leave(downloadGroup); // 4
         dispatch_group_wait(downloadGroup, DISPATCH_TIME_FOREVER); // 5
         dispatch_async(dispatch_get_main_queue(), ^{
         */
        NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
        
        if([title isEqualToString:@"Yes"]){
            NSLog(@"Clicked Yes");
            _receivedRequest.requestReply = @"Yes";
            //_curUser.isRevealed = [NSNumber numberWithBool:YES]; <-- Update isRevealed in PossibleMatchHelper
            //[self reloadView];
            // Show "You've Revealed' animation
            
        } else if ([title isEqualToString:@"No"]) {
            NSLog(@"Clicked No");
            _receivedRequest.requestReply = @"No";
            //_curUser.isRevealed = [NSNumber numberWithBool:NO]; //<-- No reason to update the database
            // Show "No Reveal" animation
        }
        
        //NSLog(@"Reply: %@", request.requestReply);
        [_receivedRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
            if (succeeded) {
                
                // Push Reveal Reply Updates Notification
                NSLog(@"Request-Reply saved.");
                
                // if _curUSer Reply = YES
                [self repliedToShareRequest];
                /*
                 // Push Reveal Reply Updates Notification
                 PFQuery *query = [PFInstallation query];
                 PFUser *pushUser = _curUser;
                 NSString *pushUserto = pushUser[@"nickname"];
                 [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
                 
                 NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSString stringWithFormat:@"Identity Share Reply"], @"alert",
                 @"Increment", @"badge",
                 @"Ache.caf", @"sound",
                 nil];
                 
                 PFPush *push = [[PFPush alloc] init];
                 [push setQuery:query];
                 [push setData:data];
                 [push sendPushInBackground];
                 */
            }
        }];
        
        
        //}); // 6
        //});
        
        
    } else if (alertView.tag == 2) { // Report User from ActionSheet
        
        if (buttonIndex == 1) {
            [self deleteConversation];
            PFQuery *query = [Report query];
            [query whereKey:@"user" equalTo:self.toUserParse];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                Report *report = objects.firstObject;
                if (!report) {
                    Report *repo = [Report object];
                    report = repo;
                    report.user = self.toUserParse;
                }
                report.report = [NSNumber numberWithInt:report.report.intValue + 1];
                [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    [self popVC];
                }];
                
            }];
        }
        
        
    } else if (alertView.tag == 3) { // Share Request fromUser = _curUser, toUser Replied YES
        
        // Reload View after Current User Clicks 'Okay' in Revealed AlertView
        
        //if ([_matchedUsers.usersRevealed isEqualToNumber:[NSNumber numberWithBool:YES] ]) {
        
        _receivedReply.requestClosed = [NSNumber numberWithBool:YES];
        [_receivedReply saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                
                // Send UserRevealed notification
                //[[NSNotificationCenter defaultCenter] postNotificationName:@"UsersReveal" object:nil];
                //[self reloadView];
                [self.collectionView reloadData];
                [self performSegueWithIdentifier:@"view_match" sender:nil];
            }
        }];
        
        //}
        
    } else if (alertView.tag == 4) { // Share Request fromUser = _curUser, toUser Replied NO
        
        // Request rejected
        _receivedReply.requestClosed = [NSNumber numberWithBool:YES];
        [_receivedReply saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //[self reloadView];
            [self.collectionView reloadData];
            [self shareRequestRejected];
        }];
        
        
    } else if (alertView.tag == 5) {
        if (buttonIndex == 1) {
            NSLog(@"End Chat pressed");
            //[self popVC];
            //[self deleteConversation];
            
            //Block un-Matched Notification
        }
    } else if (alertView.tag == 6) {
        if (buttonIndex == 1) {
            // Add toUserParse to _curUser.blockedUsers
            [_curUser.blockedUsers addObject:_toUserParse.objectId];
            [_curUser save];
            
            // Add _curUser to toUserParse .blockedBy attrib
            [_toUserParse.blockedBy addObject:_curUser.objectId];
            [_toUserParse save];
            
            // Delete Chat
            //[self deleteConversation];
            
            // Delete Match Relationship
            [self deleteMatch];
            
            //[self popVC];
            // Pop to MainViewController
            NSArray *arrayVCs = [self.navigationController viewControllers];
            [self.navigationController popToViewController:[arrayVCs objectAtIndex:1] animated:YES];
            
            //Notification to MainViewController to update TableView?
            [[NSNotificationCenter defaultCenter] postNotificationName:@"TableUpdated" object:nil];
            
        }
    }
}

- (void)deleteMatch
{
    PFQuery *matchQuery = [PossibleMatchHelper query];
    [matchQuery whereKey:@"matches" containsAllObjectsInArray:_matchedUsers.matches];
    
    [matchQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            [PossibleMatchHelper deleteAll:objects];
        }
        
    }];
}

- (void)deleteConversation
{
    PFQuery *query1 = [MessageParse query];
    [query1 whereKey:@"fromUserParse" equalTo:_curUser];
    [query1 whereKey:@"toUserParse" equalTo:self.toUserParse];
    
    PFQuery *query2 = [MessageParse query];
    [query2 whereKey:@"fromUserParse" equalTo:self.toUserParse];
    [query2 whereKey:@"toUserParse" equalTo:_curUser];
    
    
    PFQuery *orQUery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    
    [orQUery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MessageParse deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
            //  [self popVC];
            // [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

- (void)scrollCollectionView
{
    if (self.messages.count > 0) {
        NSInteger item = [self.collectionView numberOfItemsInSection:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item -1 inSection:0];
        
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
