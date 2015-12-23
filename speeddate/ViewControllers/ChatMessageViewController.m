//
//  ChatMessageViewController.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 2/16/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "ChatMessageViewController.h"
#import "speeddate-Swift.h"

@interface ChatMessageViewController ()
{
    JSQMessagesBubbleImage *bubbleImageOutgoing;
    JSQMessagesBubbleImage *bubbleImageIncoming;
    //JSQMessagesAvatarImage *userAvatar;
    JSQMessagesAvatarImage *matchAvatar;
}
@property NSMutableArray *messages;
@property NSArray *sortedMessages;
@property UIImage *toPhoto;
@property UIImage *fromPhoto;
@property (weak, nonatomic) IBOutlet UILabel *prizeIndicator;
@property (strong, nonatomic) RevealRequest *incomingRequest;
@property (weak, nonatomic) IBOutlet UIView *chatTitle;
@property (weak, nonatomic) IBOutlet UILabel *titleText;
@property (weak, nonatomic) IBOutlet UIImageView *titleImage;
@property (strong, nonatomic) RevealRequest *outgoingRequest;
@property (weak, nonatomic) IBOutlet UIView *unMatchedBlocker;
@property UIVisualEffectView *visualEffectView;
@property (weak, nonatomic) IBOutlet UIButton *rewardButton;
@property (nonatomic) ShareRelationship *userShareRelation;
- (IBAction)popFromChat:(id)sender;
- (IBAction)rewardButtonPressed:(id)sender;


@end

@implementation ChatMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
   
    [self configureNavigationTitleView:@"Match" ifRevealed:NO];
    
    UIImage *btnImage = [UIImage imageNamed:@"reveal"];
    CGRect btnImageFrame = CGRectMake(
                                      self.inputToolbar.contentView.leftBarButtonItem.frame.origin.x,
                                      self.inputToolbar.contentView.leftBarButtonItem.frame.origin.y,
                                      27, 27);
    //[self.inputToolbar.contentView.leftBarButtonItem setFrame:btnImageFrame];
    [self.inputToolbar.contentView.leftBarButtonItem setImage:btnImage forState:UIControlStateNormal];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(actionPressed:)];
    //3 Dotted right bar button
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    self.senderId           = _curUser.objectId;
    self.senderDisplayName  = _curUser.nickname;
    
    // Set toUser avatar photo, must set conditional based on revealed or not
    //[self getAvatarPhotos];
    
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    
    self.messages       = [NSMutableArray new];
    _matchedUsers.chatMessages = [NSArray new];
    
    [self getMessages];
    //[self fetchCompatibleMatch];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    //bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:RED_LIGHT];
    
    // Notification to fetch New Message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessage:) name:receivedMessage object:nil];
    
    // Notifications for Reveal Requests and Replies
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchShareRequest:) name:@"FetchShareRequest" object:nil]; // Add 'note' to method to unpack RevealRequest
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchShareReply:) name:@"FetchRevealReply" object:nil]; // Add 'note' to method to unpack RevealRequest

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUnMatched) name:@"chatEnded" object:nil];
    
    [self customizeVC];
    
}

- (void)customizeVC
{
    //BubbleView
    _rewardButton.hidden                                        = YES;
    _prizeIndicator.hidden                                      = YES;
    self.collectionView.collectionViewLayout.messageBubbleFont  = [UIFont fontWithName:@"Helvetica" size:14];
    self.unMatchedBlocker.frame                                 = CGRectMake(0, self.view.frame.size.height, self.unMatchedBlocker.frame.size.width, self.unMatchedBlocker.frame.size.height);
    
    [self.view addSubview:_unMatchedBlocker];
    
}

- (void)configureNavigationTitleView: (NSString *)title ifRevealed: (BOOL)status {
    // Configure ChatUI NOTE: must set custom image dimensions via CGRectMake
    
    _titleImage.layer.borderWidth = 2;
    _titleImage.layer.borderColor = WHITE_COLOR.CGColor;
    _titleImage.layer.cornerRadius =_titleImage.frame.size.width/2;
    _titleImage.clipsToBounds = YES;
    
    [_toUserParse.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _titleImage.image = [UIImage imageWithData:data];
    }];
    
    if (!status) {
        [self blurImages:_titleImage];
        _titleText.text = title;
    } else {
        [_visualEffectView removeFromSuperview];
        _titleText.text = _toUserParse.nickname;
    }
    
    [self.navigationItem setTitleView:_chatTitle];
}

- (void)blurImages:(UIImageView *)imageView
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    _visualEffectView.frame = imageView.bounds;
    [imageView addSubview:_visualEffectView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
//    matchAvatar = nil;
    /*
     * Fetch ShareRelationship
     *
     *
     * [self fetchShareRelationship];
     */
    [self checkIncomingShareRequestsAndReplies];
    
    // If Matches have both Shared Profile, show Prize Indicator
}



- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    
    
    /** Originally in ViewDidAppear
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    //self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)checkIncomingShareRequestsAndReplies
{
    NSLog(@"Check Incoming request");
    // Fetch incoming ShareRequest for User to Reply
    //[self fetchShareRequest]; TODO: Erase once refactored
    
    [RevealRequest getRequestsBetween:_curUser andMatch:_toUserParse completion:^(RevealRequest *outgoingRequest, RevealRequest *incomingRequest) {
        if (outgoingRequest) {
            _outgoingRequest = outgoingRequest;
            self.inputToolbar.contentView.leftBarButtonItem.enabled = NO;
        }
        
        if (incomingRequest) {
            _incomingRequest = incomingRequest;
        }
    }];
    
    if (_incomingRequest && ![_incomingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        NSLog(@"Received Request Reply: %@", _incomingRequest.requestReply);
        // Reply Null
        if (![_incomingRequest.requestReply isEqualToString:@"Yes"] && ![_incomingRequest.requestReply isEqualToString:@"No"]) {
            NSLog(@"ReplyAlertView");
            [self replyAlertView];
            
            // 'Yes' Reply
        } else if ([_incomingRequest.requestReply isEqualToString:@"Yes"]) {
            NSLog(@"Users Revealed!");
            [self usersRevealed];
            
        }
    } else if ([_incomingRequest.requestReply isEqualToString:@"Yes"]) {
        NSLog(@"Users Revealed!");
        [self usersRevealed];
        
    }
    
    // Fetch incoming ShareReply for User to acknowledge
    //[self fetchShareReply];
    
    if (_outgoingRequest && [_outgoingRequest.requestToUser isEqual:_toUserParse]) {
        NSLog(@"Share Reply run");
        
        //Null Reply, Null Confirm
        if (![_outgoingRequest.requestReply isEqualToString:@"Yes"] && ![_outgoingRequest.requestReply isEqualToString:@"No"] && ![_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            self.inputToolbar.contentView.leftBarButtonItem.enabled = NO;
            NSLog(@"No Request Reply, No Confirm");
        }
        // 'Yes' Reply, Null Confirm or 'No' Reply, Null confirm
        else if (([_outgoingRequest.requestReply isEqualToString:@"Yes"] && ![_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) || ([_outgoingRequest.requestReply isEqualToString:@"No"] && ![_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])) {
            self.inputToolbar.contentView.leftBarButtonItem.enabled = NO;
            // Show AcknowledgeAlertView
            [self acknowledgeAlertView];
            NSLog(@"Acknowledgement View");
            
            // 'Yes' Reply, 'Yes' Confirm
        } else if ([_outgoingRequest.requestReply isEqualToString:@"Yes"] && [_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]){ // User's acknowledged and shared profile
            [self usersRevealed];
            NSLog(@"Revealed View");
            
            // 'No' Reply, 'Yes' Confirm
        } else if ((!_incomingRequest && [_outgoingRequest.requestReply isEqualToString:@"No"] && [_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) || ([_incomingRequest.requestReply isEqualToString:@"No"] && [_outgoingRequest.requestReply isEqualToString:@"No"] && [_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:NO]])) {
            // Request rejected
            [self shareRequestRejected];
            NSLog(@"Rejected View");
            
            // No Reply, No confirm -> Acknow AlertView
        }
    }
}

- (void)getAvatarPhotos
{
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeMake(30, 30);
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
//    --- DEPRECATED * USER MESSAGEPARSE CLASS METHOD
//    PFQuery *query1 = [MessageParse query];
//    [query1 whereKey:@"fromUserParse" equalTo:_curUser];
//    [query1 whereKey:@"toUserParse" equalTo:self.toUserParse];
//    [query1 whereKey:@"text" notEqualTo:@""];
//    
//    PFQuery *query2 = [MessageParse query];
//    [query2 whereKey:@"fromUserParse" equalTo:self.toUserParse];
//    [query2 whereKey:@"toUserParse" equalTo:_curUser];
//    [query2 whereKey:@"text" notEqualTo:@""];
//    
//    
//    PFQuery *orQUery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
//    [orQUery orderByAscending:@"createdAt"];
//    
//    // orQUery.limit = 3;
//    // orQUery.skip = 5;
//    [orQUery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        NSLog(@"Retrieved Messages: %lu", (unsigned long)[objects count]);
//        //self.messages = [objects mutableCopy];
//        //[self.collectionView reloadData];
//        //[self scrollCollectionView];
//        if ([objects count] > 0) {
//            /*
//            NSArray *messages = [NSArray new];
//            messages = [objects sortedArrayUsingComparator:^NSComparisonResult(PFObject *a, PFObject *b)
//                       {
//                           return [a.createdAt compare:b.createdAt];
//                       }];
//            
//            */
//            [self processMessages:objects];
//        }
//        
//        //[self.collectionView reloadData];
//    }];
    
    [MessageParse getMessagesBetween:_curUser andMatch:self.toUserParse completion:^(NSArray *conversation, NSError *error) {
        if (conversation.count > 0) {
            [self processMessages:conversation];
        }
    }];
}

#pragma mark - Get Message w/ Notification

- (void)getNewMessage:(NSNotification *)note
{
//    --- DEPRECATED * USE CLASS METHOD ---
//    PFQuery *query = [MessageParse query];
//    [query whereKey:@"fromUserParse" equalTo:self.toUserParse];
//    [query whereKey:@"toUserParse" equalTo:_curUser];
//    [query whereKey:@"read" equalTo:[NSNumber numberWithBool:NO]]; // <-- Key to determine if Message is read - add to TDBadgeCell logic for
//    
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if ([objects count] > 0) {
//            
//            /**
//             *  Show the typing indicator to be shown
//             */
//            self.showTypingIndicator = !self.showTypingIndicator;
//            
//            /**
//             *  Scroll to actually view the indicator
//             */
//            [self scrollToBottomAnimated:YES];
//
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self processMessages:objects];
//            });
//        }
//        
//    }];
    
    [MessageParse getNewMessageBetween:_curUser andMatch:self.toUserParse completion:^(NSArray *messages, NSError *error) {
        if (!error) {
            /**
             *  Show the typing indicator to be shown
             */
            self.showTypingIndicator = !self.showTypingIndicator;
            
            /**
             *  Scroll to actually view the indicator
             */
            [self scrollToBottomAnimated:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self processMessages:messages];
            });
        }
    }];
}

- (void)processMessages:(NSArray *)messages
{
    //Order Messages
    /*
    objects = [objects sortedArrayUsingComparator:
               ^NSComparisonResult(PFObject *a, PFObject *b)
               {
                   return [a.createdAt compare:b.createdAt];
               }];
    */
        
    for (MessageParse *message in messages) {
        message.read = YES;
        [message saveInBackground];
            
        NSString *displayName   = nil;
        NSString *senderId      = nil;
        NSString *matchGender   = nil;
        
        if ([_toUserParse.isMale isEqualToString:@"true"]) {
            matchGender = @"Male";
        } else {
            matchGender = @"Female";
        }
        
        if ([message.fromUserParse isEqual:_curUser]) {
            senderId    = _curUser.objectId;
            displayName = @"You";
        } else {
            senderId    = _toUserParse.objectId;
            displayName = [[NSString alloc] initWithFormat:@"%@, %@", matchGender, _toUserParse.age];
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
            
            chatMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:displayName date:message.createdAt media:mediaItem];
            
        } else {
            
            chatMessage = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:displayName date:message.createdAt text:message.text];
        }
        
        [self.messages addObject:chatMessage];
    
    //[_matchedUsers addChatMessageToConveration:message];
    
        //[self sortMessages:_messages byDate:@"createdAt"];
        [self finishReceivingMessage];
    
    }
}

- (void)sortMessages:(NSMutableArray *)messages byDate:(NSString *)date
{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:date
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [messages sortUsingDescriptors:@[date]];
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

-(void)fetchShareRelationship
{
    [ShareRelationship fetchShareRelationshipBetween:_curUser andMatch:_toUserParse completion:^(ShareRelationship * _Nullable relationship, NSError * _Nullable error) {
        if (relationship) {
            self.userShareRelation = relationship;
        } else {
            // TODO: Handle error
        }
    }];
}

#pragma mark - Incoming Reveal Request

- (void)fetchRevealRequest:(NSNotification *)note
{
    NSLog(@"Fetch Reveal Request run");
    // Query for Incoming RevealRequest
    //[self fetchShareRequest]; TODO: Erase once refactored
    
    /*for (RevealRequest *request in objects) {
     NSLog(@"For Loop");
     request.requestReply = @"No";
     NSLog(@"Request Reply: %@", request.requestReply);
     
     // Save to Parse
     [request saveInBackground];
     }*/
    
    NSLog(@"Query run");
    // Reveal AlertView
    [self replyAlertView];
}

#pragma mark - Incoming Reveal Reply

- (void)fetchRevealReply:(NSNotification *)note
{
    
    // Query for Incoming RevealRequest fromUser = _curUser with Reply
    //[self fetchShareReply]; TODO: Erase once refactored
    
    NSLog(@"Reveal Reply query run");
    
}

- (void)fetchShareRequest:(NSNotification *)notification
{
    NSLog(@"Fetched share request");
    
    // Get requestId from NSNotification note
    NSString *requestId = [notification.userInfo objectForKey:@"requestId"];
    [RevealRequest fetchShareRequestWithId:requestId completion:^(RevealRequest *incomingRequest, BOOL fetched) {
        if (fetched) {
            _incomingRequest = incomingRequest;
            [self replyAlertView];
        }
    }];
    
    // * ----------- OLD CODE ---------------- //
    
    PFQuery *requestFromQuery = [RevealRequest query];
    [requestFromQuery whereKey:@"requestFromUser" equalTo:_curUser];
    [requestFromQuery whereKey:@"requestToUser" equalTo:_toUserParse];
    
    PFQuery *requestToQuery = [RevealRequest query];
    [requestToQuery whereKey:@"requestToUser" equalTo:_curUser];
    [requestToQuery whereKey:@"requestFromUser" equalTo:_toUserParse];
    
    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:@[requestFromQuery, requestToQuery]];
    
    
    NSArray *requests = [[NSArray alloc] initWithArray:[orQuery findObjects]];
    NSLog(@"Requests count: %lu", (unsigned long)[requests count]);
    
    for (RevealRequest *request in requests) {
        UserParseHelper *fromRequestUser = (UserParseHelper *)[request.requestFromUser fetchIfNeeded];
        NSLog(@"Request from %@", fromRequestUser.nickname);
        
        UserParseHelper *toRequestUser = (UserParseHelper *)[request.requestToUser fetchIfNeeded];
        NSLog(@"Request to %@", toRequestUser.nickname);
        
        if ([fromRequestUser isEqual:_curUser]) {
            _outgoingRequest = request; //Equivalent to outgoingRequest
            NSLog(@"Request from Me and to %@", _outgoingRequest.requestToUser.nickname);
        } else if ([toRequestUser isEqual:_curUser]) {
            _incomingRequest = request; //Equivalent to incomingRequest
            NSLog(@"Request from Other User: %@", _incomingRequest.requestFromUser.nickname);
        }
    }
    // * ---------------- END ---------------- //
    
    //_incomingRequest = request objectAtIndex:0];
    /*
     [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     NSLog(@"Objects count: %lu", (unsigned long)[objects count]);
     if (!error && [objects count] != 0) {
     NSLog(@"Objects retrieved");
     _incomingRequest = (RevealRequest *)[objects objectAtIndex:0];
     
     NSLog(@"Share Request %@", _incomingRequest);
     }
     }];*/
}

- (void)fetchShareReply:(NSNotification *)notification
{
    NSLog(@"Share Reply run");
    
    NSString *requestId = [notification.userInfo objectForKey:@"requestId"];
    [RevealRequest fetchShareReplyWithId:requestId completion:^(RevealRequest *incomingReply, BOOL fetched) {
        
        if (fetched) {
            _outgoingRequest = incomingReply;
            [self acknowledgeAlertView];
        }
    }];
    
    // * ------------- OLD CODE ----------------- //
    
    PFQuery *replyQuery = [RevealRequest query];
    [replyQuery whereKey:@"requestFromUser" equalTo:_curUser];
    [replyQuery whereKey:@"requestToUser" equalTo:self.toUserParse];
    [replyQuery whereKey:@"requestReply" notEqualTo:@""];
    
    NSMutableArray *reply = [[NSMutableArray alloc] initWithArray:[replyQuery findObjects]];
    
    NSLog(@"Share reply count: %lu", (unsigned long)[reply count]);
    if ([reply count] != 0) {
        
        _outgoingRequest = [reply objectAtIndex:0];
        [self acknowledgeAlertView];
    }
    
    // -------------- END ---------------- //
    /*
     [replyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     
     if (!error && [objects count] != 0) {
     _outgoingRequest = (RevealRequest *)[objects objectAtIndex:0];
     
     NSLog(@"%@'s Share Reply found.", _outgoingRequest.requestFromUser.nickname);
     }
     }];*/
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
    message.text          = text;
    message.fromUserParse = _curUser;
    message.toUserParse   = self.toUserParse;
    message.read          = NO;
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        if (!error) {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
            
            JSQMessage *chatMessage = [[JSQMessage alloc] initWithSenderId:senderId
                                                         senderDisplayName:senderDisplayName
                                                                      date:date
                                                                      text:text];
            
            // Store in chatMessages array of PossibleMatchHelper *** NOT WORKING ***
            //[_matchedUsers addChatMessageToConveration:message];
            
            [self.messages addObject:chatMessage];
            [self sendMessageNotification:message];
            //[self sortMessages:_messages byDate:@"createdAt"];
            [self finishSendingMessage];
        }
        
    }];
    
}

- (void)sendMessageNotification:(MessageParse *)message
{
    if (self.toUserParse.installation.objectId) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
        PFUser *pushUser = _curUser;
        NSString *pushUserto = pushUser[@"nickname"];
        
        NSString *pushMessage = nil;
        
        if ((!_incomingRequest && !_outgoingRequest) || !([_incomingRequest.requestReply isEqualToString:@"Yes"] && [_incomingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) || !([_outgoingRequest.requestReply isEqualToString:@"Yes"] && [_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])) {
            pushMessage = [NSString stringWithFormat:@"Your Match says: %@", message.text];
        } else pushMessage = [NSString stringWithFormat:@"%@ says: %@",pushUserto,message.text];
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              pushMessage, @"alert",
                              [NSString stringWithFormat:@"%@", message.objectId], @"messageId", // Must change to PossMatchHelper convoId
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
    return [_messages objectAtIndex:indexPath.item];
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
    /*
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:_toUserParse.objectId]) {
        
        return matchAvatar;
        
    } else return nil;
*/
    //return [self.demoData.avatars objectForKey:message.senderId];
    return nil;
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

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    if (message.isMediaMessage) {
        id<JSQMessageMediaData> copyMediaData = message.media;
        JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
        photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
        UIImage *imageMessage = photoItemCopy.image;
        
            /**
             *  Set image to nil to simulate "downloading" the image
             *  and show the placeholder view
             */
        
        [self performSegueWithIdentifier:@"chatImage" sender:imageMessage];
    } else {
        
        
        
    }
    
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    // TODO: Refactor to using Enums set by Protocol
    // if currentUser's shareState == NotSharing
    if (!_incomingRequest && !_outgoingRequest) { // <-- Change to check on Matched User attribute
        
        [self shareRequestActionSheet];
        
    } else if ([_incomingRequest.requestReply isEqualToString:@"No"] && [_incomingRequest.requestFromUser isEqual:_toUserParse] && !_outgoingRequest) {
        [self shareRequestActionSheet];
    } else if ([_outgoingRequest.requestReply isEqualToString:@"No"] && [_outgoingRequest.requestToUser isEqual:_toUserParse] && !_incomingRequest) {
        [self shareRequestActionSheet];
    } else {
    
        // If currentUser's shareState == Sharing, allow camera
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = NO;
        
        // if-conditional for using camera vs. photolibrary
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        } else {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        
        //imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; <-- PhotoLibrary on device for Testing purposes
        imagePicker.navigationBarHidden = YES;
        imagePicker.toolbarHidden = YES;
        //imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:imagePicker.sourceType]; <-- Comment-out Video option
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)shareRequestActionSheet
{
    NSLog(@"Share Request Action Sheet");
    UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"Send Share Request?" delegate:self cancelButtonTitle:@"Don't Request" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
    actionsheet.tag = 1;
    [actionsheet showInView:self.view];
}

- (void)addPhotoMediaMessageWithImage:(UIImage *)image
{
    JSQPhotoMediaItem *photoItem    = [[JSQPhotoMediaItem alloc] initWithImage:image];
    JSQMessage *photoMessage        = [JSQMessage messageWithSenderId:_curUser.objectId displayName:_curUser.nickname media:photoItem];
    
    [self.messages addObject:photoMessage];
    //[self sortMessages:_messages byDate:@"createdAt"];
    [self finishSendingMessage];
}

- (void)repliedToShareRequest // TODO: Erase after Refactor
{
    NSLog(@"Start Replied To Share Request");
    /* _matchedUsers.usersRevealed = [NSNumber numberWithBool:YES];
     } else if ([_incomingRequest.requestReply isEqualToString:@"No"]){
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
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            if ([_incomingRequest.requestReply isEqualToString:@"Yes"]) {
                NSLog(@"Received Request Reply: %@", _incomingRequest.requestReply);
                //[self reloadView];
                [self.collectionView reloadData];
                [self performSegueWithIdentifier:@"view_match" sender:nil];
                NSLog(@"Pushed to Match User Profile");
            } else {
                NSLog(@"Notification pushed, but Request Reply code not run");
            }
        }
    }];
    
    
    // Must set check in @"match_view" ViewWillAppear
    //    }
    // }];
}

- (void)usersRevealed
{
    CGFloat chatCam = self.inputToolbar.contentView.frame.origin.y + 5;
    [self configureNavigationTitleView:_toUserParse.nickname ifRevealed:YES];
    self.inputToolbar.contentView.leftBarButtonItem.enabled = YES;
    //[_blurImageView removeFromSuperview];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.inputToolbar.contentView.leftBarButtonItem.frame.origin.x, chatCam, 30, 23)];
    UIImage *btnImage = [UIImage imageNamed:@"camera"];
    [button setImage:btnImage forState:UIControlStateNormal];
    self.inputToolbar.contentView.leftBarButtonItem = button;
    [self showCameraTooltip];
    
    [self showPrizeIndicator];
    
    //[self getAvatarPhotos];
}

- (void)shareRequestRejected
{
    UIImage *btnImage = [UIImage imageNamed:@"No_icon"];
    //Disable left input button
    // Replace with Left Input button configuration
    [self.inputToolbar.contentView.leftBarButtonItem setImage:btnImage forState:UIControlStateNormal];
    self.inputToolbar.contentView.leftBarButtonItem.enabled = NO;
    self.inputToolbar.contentView.leftBarButtonItem.alpha = 1.0;
    //No Avatar photo
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    matchAvatar = nil;
}

- (void)showCameraTooltip
{
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"firstTimeRevealed"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"firstTimeRevealed"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    [[AMPopTip appearance] setPopoverColor:[UIColor blueColor]];
    AMPopTip *popTip = [AMPopTip popTip];
    CGRect chatCam = CGRectMake(self.inputToolbar.contentView.leftBarButtonItem.frame.origin.x+5, self.inputToolbar.contentView.leftBarButtonItem.frame.origin.y, self.inputToolbar.contentView.leftBarButtonItem.frame.size.width, self.inputToolbar.contentView.leftBarButtonItem.frame.size.height);
    [popTip showText:@"Awesome sauce! You unlocked the camera and can now send photos!" direction:AMPopTipDirectionUp maxWidth:250 inView:self.inputToolbar.contentView fromFrame:chatCam duration:5];
        
    }
}

- (void)showPrizeIndicator
{
    // Logic will eventually be moved to last part of usersRevealed
    if ([_matchedUsers.toUser isEqual:_curUser] && ![self.matchedUsers.toUserRedeem isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        NSLog(@"Current User is ToUser");
        [self configurePrizeIndicator];
        
    } else if ([self.matchedUsers.fromUser isEqual:_curUser] && ![self.matchedUsers.fromUserRedeem isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        NSLog(@"Current User is FromUser");
        [self configurePrizeIndicator];
        
    } else NSLog(@"User Redeemed Prize.");
}

- (void)configurePrizeIndicator
{
    // If
    _prizeIndicator.frame               = CGRectMake(_titleText.bounds.origin.x+_titleText.frame.size.width+5, _chatTitle.bounds.origin.y, 20, 20);
    _prizeIndicator.backgroundColor     = [UIColor purpleColor];
    _prizeIndicator.layer.cornerRadius  = _prizeIndicator.frame.size.width/2;
    _prizeIndicator.clipsToBounds       = YES;
    _prizeIndicator.hidden              = NO;
    _rewardButton.hidden                = NO;
    
    // Should only be shown once
    [[AMPopTip appearance] setPopoverColor:[UIColor blueColor]];
    AMPopTip *popTip = [AMPopTip popTip];
    CGRect titleFrame = CGRectMake(self.chatTitle.frame.origin.x, self.chatTitle.frame.origin.y+7, self.chatTitle.frame.size.width, self.chatTitle.frame.size.height);
    [popTip showText:@"Unlocked a prize! Press here!" direction:AMPopTipDirectionDown maxWidth:100 inView:self.navigationController.view fromFrame:titleFrame duration:5];
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
    message.sendImage       = image;
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
                                  [NSString stringWithFormat:@"%@", message.objectId], @"messageId",
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

#pragma mark - Reveal Request

- (void)sendShareRequest
{
    //Check if prior ShareRelationship exists
    
    //If so...
    
    //If not...create new ShareRelationship, send RevealRequest
    ShareRelationship *shareRelationship     = [ShareRelationship objectWithClassName:@"ShareRelationship"];
    shareRelationship.firstRequestedSharer   = _curUser.nickname;
    shareRelationship.firstSharerShareState  = ShareStateNotSharing;
    shareRelationship.secondRequestedSharer  = _toUserParse.nickname;
    shareRelationship.secondSharerShareState = ShareStateNotSharing;
    [shareRelationship saveInBackground];
    
    RevealRequest *revealRequest = [RevealRequest object];
    revealRequest.identityDelegate = shareRelationship;
    [revealRequest sendShareRequestFromUser:_curUser toMatch:_toUserParse completion:^(BOOL success) {
        
        if (success) {
            self.inputToolbar.contentView.leftBarButtonItem.enabled = NO;
                
            [self.collectionView reloadData];
        }
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
         if (!_incomingRequest && !_outgoingRequest && buttonIndex == 0) {
         [self sendShareRequest];
         }
         
         // Rejected Received Reply
         
         if (!([_outgoingRequest.requestReply isEqualToString:@"Yes"] && [_outgoingRequest.requestFromUser isEqual:_toUserParse] && [_outgoingRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) && buttonIndex == 0) { // <-- Change to isRevealed check on PossibleMatchHelper
         // Test purposes
         mainUser.isRevealed = true;
         [self reloadView];// Closed comment here
         
         // <-- Apparently this works when app is in background, a notification is sent and appears as alert
         // RevealRequest setup
         [self sendShareRequest];
         }
         */
        if (buttonIndex == 0) {
            [self sendShareRequest];
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

- (void)replyAlertView
{
    NSString *alertTitle = [[NSString alloc] initWithFormat:@"A Match Has Sent You a Share Request!"];
    NSString *alertMessage = [[NSString alloc] initWithFormat:@"Do you want to share your Profile? If so, click 'Yes' to share your name and pictures."];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = 1;
    [alert show];
}

- (void)acknowledgeAlertView
{
    if ([_outgoingRequest.requestReply isEqualToString:@"Yes"]) {
        
        // Request Accepted
        // Reveal AlertView
        NSString *alertTitle = [[NSString alloc] initWithFormat:@"Your Match %@ Agreed to Share Profiles!", _toUserParse.nickname];
        NSString *alertMessage = [[NSString alloc] initWithFormat:@"You two can now view and send each other photos - have fun!"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        NSLog(@"Reply AlertView run");
        alert.tag = 3;
        [alert show];
        
        
    } else if ([_outgoingRequest.requestReply isEqualToString:@"No"]) {
        // Request Rejected
        NSString *alertTitle = [[NSString alloc] initWithFormat:@"Your Match Declined Sharing Profiles"];
        NSString *alertMessage = [[NSString alloc] initWithFormat:@"Right now your Match doesn't want to share, but maybe they'll request to share with you later."];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        NSLog(@"Reply AlertView run");
        alert.tag = 4;
        [alert show];
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
        matchVC.user                    = _curUser;
        matchVC.matchUser               = _toUserParse;
        matchVC.possibleMatch           = _matchedUsers;
        matchVC.fromConversation        = true;
        
        [matchVC setUserPhotosArray:matchVC.matchUser];
    } else if ([segue.identifier isEqualToString:@"chatImage"]) {
        
        ImageVC *vc = segue.destinationViewController;
        [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        //UIImageView *imageView = (UIImageView *)sender;
        vc.user                    = _curUser;
        vc.matchUser               = _toUserParse;
        vc.image                   = (UIImage *)sender;
        //vc.imageFrame.image     = vc.image;
         
    } else if ([segue.identifier isEqualToString:@"redeemView"]) {
        
        RedeemViewController *redeemVC  = segue.destinationViewController;
        redeemVC.prizeID                = _matchedUsers.objectId;
        redeemVC.currentUser            = self.curUser;
        redeemVC.matchRedmption         = self.matchedUsers;
        _rewardButton.hidden            = YES;
        _prizeIndicator.hidden          = YES;
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
            [_incomingRequest acceptShareRequestWithCompletion:^(BOOL shared) {
                if (shared) {
                    [self.collectionView reloadData];
                    [self performSegueWithIdentifier:@"view_match" sender:nil];
                }
            }];
            // TODO: Erase after Refactor
            _incomingRequest.requestReply = @"Yes";
            //_curUser.isRevealed = [NSNumber numberWithBool:YES]; <-- Update isRevealed in PossibleMatchHelper
            //[self reloadView];
            // Show "You've Revealed' animation
            
        } else if ([title isEqualToString:@"No"]) {
            NSLog(@"Clicked No");
            [_incomingRequest rejectShareRequestWithCompletion:^(BOOL rejected) {
                if (rejected) {
                    // Do nothing?
                }
            }];
            // TODO: Erase after Refactor
            _incomingRequest.requestReply = @"No";
            //_curUser.isRevealed = [NSNumber numberWithBool:NO]; //<-- No reason to update the database
            // Show "No Reveal" animation
        }
        
        //NSLog(@"Reply: %@", request.requestReply);
        [_incomingRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            
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
                    report.reportedUser = self.toUserParse;
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
        
        _outgoingRequest.requestClosed = [NSNumber numberWithBool:YES];
        [_outgoingRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
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
        _outgoingRequest.requestClosed = [NSNumber numberWithBool:YES];
        [_outgoingRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //[self reloadView];
            [self.collectionView reloadData];
            [self shareRequestRejected];
        }];
        
        
    } else if (alertView.tag == 5) {
        if (buttonIndex == 1) {
            NSLog(@"End Chat pressed");
            
            //[self deleteConversation];
            
            //Post blockUnMatched Notification to toUserParse
            PFQuery *query = [PFInstallation query];
            [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"Match Ended Chat", @"alert",
                                  [NSString stringWithFormat:@"%@", _toUserParse.nickname], @"match",
                                  /*[NSString stringWithFormat:@"%@", _matchedUsers], @"relationship",*/
                                  @"Increment", @"badge",
                                  @"Ache.caf", @"sound",
                                  nil];
            PFPush *push = [[PFPush alloc] init];
            [push setQuery:query];
            [push setData:data];
            [push sendPushInBackground];
            
            //[self popVC];
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

- (void)blockUnMatched
{
    // Below should be in separate method and triggered on toParseUser UI via notification
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.9 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.unMatchedBlocker.frame = CGRectMake(0, self.view.frame.size.height-self.unMatchedBlocker.frame.size.height, self.unMatchedBlocker.frame.size.width, self.unMatchedBlocker.frame.size.height);
    } completion:^(BOOL finished) {
        
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

- (IBAction)popFromChat:(id)sender {
    [self popVC];
}

- (IBAction)rewardButtonPressed:(id)sender {
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    
    [alert addButton:@"OK" actionBlock:^(void) {
        [self performSegueWithIdentifier:@"redeemView" sender:nil];
    }];
    
    NSString *alertText = [NSString stringWithFormat:@"When ready with %@ press 'OK' to show your Redemption Code to your Dalliant Host. The Redemption code is only shown ONCE.", self.toUserParse.nickname];
    [alert showSuccess:self title:@"Drink Prize Unlocked!" subTitle:alertText closeButtonTitle:@"Cancel" duration:0.0f];
}
@end
