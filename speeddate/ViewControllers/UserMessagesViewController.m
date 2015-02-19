//
//  UserMessagesViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "UserMessagesViewController.h"
#import "UserCollectionViewCell.h"
#import "ImageViewController.h"
#import "Report.h"
#import "RevealRequest.h"
#import "GADBannerView.h"
#import "GADRequest.h"
#import "GADInterstitial.h"
#import "User.h"
#import "UserProfileViewController.h"
#import "MatchViewController.h"
#import "MainViewController.h"

@interface UserMessagesViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate>
{
    User *mainUser;
}
@property NSMutableArray *messages;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIView *messagesView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property UIImage *toPhoto;
@property UIImage *fromPhoto;
@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
@property (strong, nonatomic) UIVisualEffectView *blurImageView;
@property (strong, nonatomic) UIActionSheet *actionsheet;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (strong, nonatomic) RevealRequest *receivedRequest;
@property (strong, nonatomic) RevealRequest *sentRequest;
@property (strong, nonatomic) RevealRequest *receivedReply;
@property (strong, nonatomic) RevealRequest *incomingRequest;
@property (strong, nonatomic) RevealRequest *outgoingRequest;
@property (weak, nonatomic) IBOutlet UIView *unMatchedBlocker;
- (IBAction)chatEndedClose:(id)sender;



@end

@implementation UserMessagesViewController
@synthesize adBanner;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainUser = [User singleObj];
    
    [self getPhotos];
    [self getMessages];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    UIImage *btnImage = [UIImage imageNamed:@"user"];
    self.title = @"Chat";
    [_cameraButton setImage:btnImage forState:UIControlStateNormal];
    
    // Fetch Match Relationship
    [self fetchCompatibleMatch];
    
    // Fetch incoming ShareRequest for User to Reply
    //[self checkIncomingShareRequestsAndReplies];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddeKeyBoard)];
    [self.collectionView addGestureRecognizer:tapGestureRecognizer];
    
    // Notification to fetch New Message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessage:) name:receivedMessage object:nil];
    
    // Notification to fetch New Incoming Reveal Request?
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchRevealRequest:) name:@"Fetch Reveal Request" object:nil];
    //
    
    // Notification to fetch New Incoming Reveal Reply
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchRevealReply:) name:@"Fetch Reveal Reply" object:nil];
    
    // Notification Users Revealed
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(usersRevealed) name:@"UsersRevealed" object:nil];
    
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Fetch Reveal Reply" object:self];

    [self customizeApp];
    
    self.restorationIdentifier = @"UserMessagesViewController";
}

- (void)customizeApp
{
    self.view.backgroundColor = WHITE_COLOR;
    self.collectionView.backgroundColor = WHITE_COLOR;
    self.messagesView.backgroundColor = RED_LIGHT;
    UIImage *temp = [[UIImage imageNamed:@"x"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStyleBordered target:self action:@selector(popVC)];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    self.unMatchedBlocker.frame = CGRectMake(0, self.view.frame.size.height, self.unMatchedBlocker.frame.size.width, self.unMatchedBlocker.frame.size.height);
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

- (void)fetchShareRequest
{
    NSLog(@"Fetched share request");
    /*
    PFQuery *requestQuery = [RevealRequest query];
    [requestQuery whereKey:@"requestFromUser" equalTo:self.toUserParse];
    [requestQuery whereKey:@"requestToUser" equalTo:_curUser];
    [requestQuery whereKey:@"requestReply" equalTo:@""];
    
    NSArray *request = [requestQuery findObjects];
    if ([request count] != 0) {
        _receivedRequest = [request objectAtIndex:0];
    }
    */
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
                _receivedReply = request; //Equivalent to receivedReply
                NSLog(@"Request from Me and to %@", _receivedReply.requestToUser.nickname);
            } else if ([toRequestUser isEqual:_curUser]) {
                _receivedRequest = request; //Equivalent to receivedRequest
                NSLog(@"Request from Other User: %@", _receivedRequest.requestFromUser.nickname);
            }
        }

    //_receivedRequest = request objectAtIndex:0];
    /*
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Objects count: %lu", (unsigned long)[objects count]);
        if (!error && [objects count] != 0) {
            NSLog(@"Objects retrieved");
            _receivedRequest = (RevealRequest *)[objects objectAtIndex:0];
            
            NSLog(@"Share Request %@", _receivedRequest);
        }
    }];*/
}

- (void)fetchShareReply
{
    NSLog(@"Share Reply run");
    PFQuery *replyQuery = [RevealRequest query];
    [replyQuery whereKey:@"requestFromUser" equalTo:_curUser];
    [replyQuery whereKey:@"requestToUser" equalTo:self.toUserParse];
    [replyQuery whereKey:@"requestReply" notEqualTo:@""];
    
    NSMutableArray *reply = [[NSMutableArray alloc] initWithArray:[replyQuery findObjects]];

    NSLog(@"Share reply count: %lu", (unsigned long)[reply count]);
    if ([reply count] != 0) {
        
        //_receivedReply = [request objectAtIndex:0];
    }
    
    /*
    [replyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
     
        if (!error && [objects count] != 0) {
            _receivedReply = (RevealRequest *)[objects objectAtIndex:0];
            
            NSLog(@"%@'s Share Reply found.", _receivedReply.requestFromUser.nickname);
        }
    }];*/
}

- (void)usersRevealed
{
    self.title = self.toUserParse.nickname;
    _cameraButton.enabled = YES;
    [_blurImageView removeFromSuperview];
    UIImage *btnImage = [UIImage imageNamed:@"camera2"];
    [_cameraButton setImage:btnImage forState:UIControlStateNormal];

}

- (void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)shareRequestRejected
{
    UIImage *btnImage = [UIImage imageNamed:@"No_icon"];
    [_cameraButton setImage:btnImage forState:UIControlStateNormal];
    _cameraButton.enabled = NO;
    _cameraButton.alpha = 1.0;
}

- (void)checkIncomingShareRequestsAndReplies
{
    NSLog(@"Check Incoming request");
    // Fetch incoming ShareRequest for User to Reply
    [self fetchShareRequest];
    
    if (_receivedRequest && ![_receivedRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        NSLog(@"Received Request Reply: %@", _receivedRequest.requestReply);
        // Reply Null
        if (![_receivedRequest.requestReply isEqualToString:@"Yes"] && ![_receivedRequest.requestReply isEqualToString:@"No"]) {
            NSLog(@"ReplyAlertView");
            [self replyAlertView];
            
            // Yes Reply
        } else if ([_receivedRequest.requestReply isEqualToString:@"Yes"]) {
            NSLog(@"Users Revealed!");
            [self usersRevealed];
            
        }
    } else if ([_receivedRequest.requestReply isEqualToString:@"Yes"]) {
        NSLog(@"Users Revealed!");
        [self usersRevealed];
        
    }
    
    // Fetch incoming ShareReply for User to acknowledge
    //[self fetchShareReply];
    
    if (_receivedReply && [_receivedReply.requestToUser isEqual:_toUserParse]) {
    NSLog(@"Share Reply run");
        
        //Null Reply, Null Confirm
        if (![_receivedReply.requestReply isEqualToString:@"Yes"] && ![_receivedReply.requestReply isEqualToString:@"No"] && ![_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) {
            _cameraButton.enabled = NO;
        }
            // Yes Reply, Null Confirm or No Reply, Null confirm
        else if (([_receivedReply.requestReply isEqualToString:@"Yes"] && ![_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) || ([_receivedReply.requestReply isEqualToString:@"No"] && ![_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])) {
            _cameraButton.enabled = NO;
            // Show AcknowledgeAlertView
            [self acknowledgeAlertView];
            NSLog(@"Acknowledgement View");
        
            // Yes Reply, Yes Confirm
        } else if ([_receivedReply.requestReply isEqualToString:@"Yes"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]){ // User's acknowledged and shared profile
            [self usersRevealed];
            NSLog(@"Revealed View");
            
            // No Reply, Yes Confirm
        } else if ((!_receivedRequest && [_receivedReply.requestReply isEqualToString:@"No"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) || ([_receivedRequest.requestReply isEqualToString:@"No"] && [_receivedReply.requestReply isEqualToString:@"No"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:NO]])) {
            // Request rejected
            [self shareRequestRejected];
            NSLog(@"Rejected View");
            
            // No Reply, No confirm -> Acknow AlertView
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self checkIncomingShareRequestsAndReplies];
    //[self fetchShareRequest];
}

#pragma mark - Send Button Pressed

- (IBAction)sendPressed:(id)sender
{
    if ([self.textField.text isEqualToString:@""]) {
        return;
    }
    MessageParse *message = [MessageParse object];
    message.text = self.textField.text;
    message.createdAt = [NSDate date];
    message.fromUserParse = _curUser;
    message.toUserParse = self.toUserParse;
    message.read = NO;
    [message saveInBackground];
    [self.messages addObject:message];
    NSInteger item = [self.collectionView numberOfItemsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item  inSection:0];

    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];

    [self scrollCollectionView];
    if (self.toUserParse.installation.objectId) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
        PFUser *pushUser = _curUser;
        NSString *pushUserto = pushUser[@"nickname"];
        
        NSString *pushMessage = nil;
        
        if ((!_receivedRequest && !_receivedReply) || !([_receivedRequest.requestReply isEqualToString:@"Yes"] && [_receivedRequest.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]]) || !([_receivedReply.requestReply isEqualToString:@"Yes"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])) {
            pushMessage = [NSString stringWithFormat:@"Your Match says: %@", message.text];
        } else pushMessage = [NSString stringWithFormat:@"%@ says: %@",pushUserto,message.text];
       
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

    self.textField.text = @"";
    
}


#pragma mark - UICollectionViewDatasource
#define MARGIN 10
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageParse *message = [self.messages objectAtIndex:indexPath.row];
    UserCollectionViewCell *cell;

    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDoesRelativeDateFormatting:YES];
    if ([[message createdAt] timeIntervalSinceNow] * -1 < 60 * 60 * 24) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
    } else {
        dateFormatter.dateStyle = NSDateFormatterShortStyle;
    }

   
    if ((message.sendImage || message.image) && [message.fromUserParse.objectId isEqualToString:_curUser.objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fromCellImage" forIndexPath:indexPath];
        cell.userImageView.image = self.fromPhoto;

        __block UIImage *image;
        if (message.sendImage) {
            image = message.sendImage;
            cell.photoImageView.image = message.sendImage;
            cell.photoImageView.layer.cornerRadius = 8;
            cell.photoImageView.clipsToBounds = YES;
        } else {
            [message.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                image = [UIImage imageWithData:data];
                cell.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
                cell.photoImageView.image = image;
                cell.photoImageView.layer.cornerRadius = 8;
                cell.photoImageView.clipsToBounds = YES;            }];
        }
        cell.photoImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
        [cell.photoImageView addGestureRecognizer:tap];
    }

   
    if (message.image && [message.fromUserParse.objectId isEqualToString:self.toUserParse.objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"toCellImage" forIndexPath:indexPath];
        cell.userImageView.image = self.toPhoto;
        /*
        // Blur conditional ********************
        if (!_receivedRequest || ![_receivedRequest.requestReply isEqualToString:@"Yes"]) {
            [self blurImages:cell.userImageView];
            NSLog(@"BlurView Text Image run w/ Null Request, or No Request");
        }
        
        if (_receivedReply) {
            if (!([_receivedReply.requestReply isEqualToString:@"Yes"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])) {
                [self blurImages:cell.userImageView];
            }
            NSLog(@"BlurView Text Image run w/ Reply No and Reply Closed");
        }
        // *************************************
        */
        
        [self blurImages:cell.userImageView];
        
        cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
        __block UIImage *image;
        [message.image getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            image = [UIImage imageWithData:data];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.photoImageView.image = image;
                cell.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
                cell.photoImageView.layer.cornerRadius = 8;
                cell.photoImageView.clipsToBounds = YES;            });

        }];
        cell.photoImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedImage:)];
        [cell.photoImageView addGestureRecognizer:tap];
    }

    
    if (!message.image && !message.sendImage && [message.fromUserParse.objectId isEqualToString:_curUser.objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fromCell" forIndexPath:indexPath];
        cell.userImageView.image = self.fromPhoto;
        cell.messageLabel.textColor = WHITE_COLOR;
    }

   
    if (!message.image && !message.sendImage &&[message.fromUserParse.objectId isEqualToString:self.toUserParse.objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"toCell" forIndexPath:indexPath];
        cell.userImageView.image = self.toPhoto;
        /*
         // Blur conditional ********************
         if (!_receivedRequest || ![_receivedRequest.requestReply isEqualToString:@"Yes"]) {
         [self blurImages:cell.userImageView];
         NSLog(@"BlurView Text Image run w/ Null Request, or No Request");
         }
         
         if (_receivedReply) {
         if (!([_receivedReply.requestReply isEqualToString:@"Yes"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]])) {
         [self blurImages:cell.userImageView];
         }
         NSLog(@"BlurView Text Image run w/ Reply No and Reply Closed");
         }
        */
        
        [self blurImages:cell.userImageView];
        // *************************************
        
        cell.messageLabel.textColor = WHITE_COLOR;
    }
    UIView *view = [cell.contentView viewWithTag:666];
    [view removeFromSuperview];
    cell.userImageView.layer.cornerRadius = cell.userImageView.frame.size.width/2;
    cell.userImageView.clipsToBounds = YES;
    cell.userImageView.layer.borderWidth = 0.0,
    cell.userImageView.layer.borderColor = BLUE_COLOR.CGColor;

    cell.dateLabel.text = [dateFormatter stringFromDate:[message createdAt]];
    cell.dateLabel.textColor = RED_DEEP;
    cell.messageLabel.text = message.text;

    if (!message.image && !message.sendImage) {
        NSDictionary *attributes = @{NSFontAttributeName: cell.messageLabel.font};
        cell.messageLabel.numberOfLines = 0;
        CGRect rect = [message.text boundingRectWithSize:CGSizeMake(200, 130)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attributes
                                                 context:nil];
        
        // Message Label Coordinates ******************
        
        rect.origin = cell.messageLabel.frame.origin;
        CGRect outlineRect = CGRectInset(rect, -15, -10); // <-- Sets text position in BubbleView
        if (!message.image && !message.sendImage && [message.fromUserParse.objectId isEqualToString:_curUser.objectId]) {
            rect.origin.x = cell.userImageView.frame.origin.x - outlineRect.size.width;
            //rect.origin.x = cell.userImageView.frame.origin.x - outlineRect.size.width + 25; // <-- Pushes current User text bubble toward righ margin
        }
        
        // ***********************************************
        
        outlineRect.origin = rect.origin;
        outlineRect.origin.x -= MARGIN*1.5; //<-- Adds left/right padding to Bubbleview
        outlineRect.origin.y -= MARGIN/1.5; //<-- Adds top/bottom padding to Bubbleview
        
        UIView *bubbleView = [[UIView alloc] initWithFrame:outlineRect];
        if ( [message.fromUserParse.objectId isEqualToString:_curUser.objectId]) {
            bubbleView.backgroundColor = RED_LIGHT;
        } else {
            //bubbleView.backgroundColor = MENU_GRAY_LIGHT;
            bubbleView.backgroundColor = [UIColor lightGrayColor];
        }
        bubbleView.alpha = 1.0;
        bubbleView.layer.cornerRadius = 5.0f;
        bubbleView.tag = 666;


        cell.messageLabel.frame = rect;
        [cell.contentView addSubview:bubbleView];
        [cell.contentView sendSubviewToBack:bubbleView];
         
    }
    
    if ((_receivedReply && _receivedRequest) || _receivedRequest) {
        if ([_receivedRequest.requestReply isEqualToString:@"Yes"] && [_receivedRequest.requestFromUser isEqual:_toUserParse]) {
            [_blurImageView removeFromSuperview];
        }
    }
    
    if ((_receivedRequest && _receivedReply) || _receivedReply) {
        if ([_receivedReply.requestReply isEqualToString:@"Yes"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]] && [_receivedReply.requestToUser isEqual:_toUserParse]) {
            [_blurImageView removeFromSuperview];
        }
    }
    
    return cell;
}

-(CGPoint)centerOfCGFrame:(CGRect)rect
{
    return CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageParse *message = [self.messages objectAtIndex:indexPath.row];
    if (message.image || message.sendImage) {
        return CGSizeMake(310, 142);
    } else {
        return CGSizeMake(310, 80);
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messages.count;
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
        self.messages = [objects mutableCopy];
        [self.collectionView reloadData];
        [self scrollCollectionView];
        for (MessageParse *message in objects) {
            message.read = YES;
            [message saveInBackground];
        }
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
        for (MessageParse *message in objects) {
            [self.messages addObject:message];
            message.read = YES;
            [message saveInBackground];

            NSInteger item = [self.collectionView numberOfItemsInSection:0];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item  inSection:0];
            [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
        }
        [self scrollCollectionView];

    }];
}

- (void)getPhotos
{
    __block int count = 0;
    PFQuery *queryFrom = [UserParseHelper query];
    [queryFrom getObjectInBackgroundWithId:_curUser.objectId
                                     block:^(PFObject *object, NSError *error)
     {
         PFFile *file = [object objectForKey:@"photo"];
         [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             self.fromPhoto = [UIImage imageWithData:data];
             count++;
             if (count == 2) {
                 [self.collectionView reloadData];
             }
         }];
     }];
    
    // Query for Incoming Chatter
    PFQuery *queryTo = [UserParseHelper query];

    [queryTo getObjectInBackgroundWithId:self.toUserParse.objectId
                                   block:^(PFObject *object, NSError *error)
     {
         PFFile *file = [object objectForKey:@"photo"];
         [file getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             self.toPhoto = [UIImage imageWithData:data];
             count++;
             if (count == 2) {
                 [self.collectionView reloadData];
             }
         }];
     }];


}

#pragma mark - Blur Images

- (void)blurImages:(UIImageView *)imageView
{
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    // BlurImageCell conditional
    
    _blurImageView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
    _blurImageView.frame = imageView.bounds;
    [imageView addSubview:_blurImageView];
    NSLog(@"Applied BlurView");
}

- (void)scrollCollectionView
{
    if (self.messages.count > 0) {
        NSInteger item = [self.collectionView numberOfItemsInSection:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item -1 inSection:0];

        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
}

- (void)hiddeKeyBoard
{
    [self.textField resignFirstResponder];
    CGRect messagesViewFrame = self.messagesView.frame;
    CGRect collectionViewFrame = self.collectionView.frame;

    messagesViewFrame.origin.y = self.view.frame.size.height - messagesViewFrame.size.height;
    collectionViewFrame.size.height = self.view.frame.size.height - messagesViewFrame.size.height;

    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            self.messagesView.frame = messagesViewFrame;
                            self.collectionView.frame = collectionViewFrame;

                        } completion:^(BOOL finished) {

                        }];
}

- (void)shareRequestActionSheet
{
    NSLog(@"Share Request Action Sheet");
    _actionsheet = [[UIActionSheet alloc] initWithTitle:@"Send Reveal request?" delegate:self cancelButtonTitle:@"Don't Request" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
    _actionsheet.tag = 1;
    [_actionsheet showInView:self.view];
}

#pragma mark - Send Photo Camera Press

- (IBAction)sendPhoto:(id)sender
{
    if (!_receivedRequest && !_receivedReply) { // <-- Change to check on Matched User attribute
        
        [self shareRequestActionSheet];
        
    } else if ([_receivedRequest.requestReply isEqualToString:@"No"] && [_receivedRequest.requestFromUser isEqual:_toUserParse] && !_receivedReply) {
        [self shareRequestActionSheet];
    } else if ([_receivedReply.requestReply isEqualToString:@"No"] && [_receivedReply.requestToUser isEqual:_toUserParse] && !_receivedRequest) {
        [self shareRequestActionSheet];
    }
    
    else {
        
        [self hiddeKeyBoard];
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
}

#pragma mark - TextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.messages.count>2) {
        [self performSelector:@selector(scrollCollectionView) withObject:nil afterDelay:0.0];
    }
    CGRect messagesViewFrame = self.messagesView.frame;
    CGRect collectionViewFrame = self.collectionView.frame;

    messagesViewFrame.origin.y = self.view.frame.size.height - KEYBOARD_HEIGHT - messagesViewFrame.size.height;
    collectionViewFrame.size.height = messagesViewFrame.origin.y;

    [UIView animateWithDuration:1
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            self.messagesView.frame = messagesViewFrame;
                            self.collectionView.frame = collectionViewFrame;

                        } completion:^(BOOL finished) {

                        }];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{

        return self.textField.text.length + (string.length - range.length) <= 80;
}

#pragma mark - ImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    MessageParse *message = [MessageParse object];
    message.fromUserParse = _curUser;
    message.toUserParse = self.toUserParse;
    message.read = NO;
    [self.messages addObject:message];

    message.sendImage = image;
    NSInteger item = [self.collectionView numberOfItemsInSection:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];
    [self.collectionView insertItemsAtIndexPaths:@[indexPath]];
    [self scrollCollectionView];


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
            
        }];
    }];
}

- (void)tappedImage:(UITapGestureRecognizer *)tap
{
    [self performSegueWithIdentifier:@"image" sender:tap.view];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"image"]) {
        ImageViewController *vc = segue.destinationViewController;
        UIImageView *imageView = (UIImageView *)sender;
        vc.image = imageView.image;
    } else if ([segue.identifier isEqualToString:@"match_view"]){
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
        
        /*
        for (int i = 0; i < (int)_photoArray.count; ++i) {
            PFFile *photo = [_photoArray objectAtIndex:i];
            NSLog(@"Photo set");
            [photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                
                if (i == 0) {
                    matchVC.matchImage = [[UIImage alloc] initWithData:data];
                    NSLog(@"%d",i);
                }
                
                if (i == 1) {
                    matchVC.matchImage1 = [[UIImage alloc] initWithData:data];
                    NSLog(@"%d",i);
                }
                
                if (i == 2) {
                    matchVC.matchImage2 = [[UIImage alloc] initWithData:data];
                    NSLog(@"%d",i);
                }
                
                if (i == 3) {
                    matchVC.matchImage3 = [[UIImage alloc] initWithData:data];
                    NSLog(@"%d",i);
                }
                
                //UserProfileViewController *prVC = [[UserProfileViewController alloc]initWithNibName:@"UserVC" bundle:nil];
                //prVC = segue.destinationViewController;
                //_cellUser = [userFilesArray objectAtIndex:indexPath.row];
                
                
                //[[segue destinationViewController]setGetPhotoArray:self.photoArray];
                //[[segue destinationViewController] setUserId:_toUserParse.objectId];
                //[[segue destinationViewController]setStatus:_toUserParse.online];
                
            }];
        }
        */
    }
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
    if ([_receivedReply.requestReply isEqualToString:@"Yes"]) {
        
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
        
        
    } else {
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

#pragma mark - Incoming Reveal Request

- (void)fetchRevealRequest:(NSNotification *)note
{
    // Reveal AlertView
   /* NSString *alertTitle = [[NSString alloc] initWithFormat:@"Your Match Has Sent You a Reveal Request!"];
    NSString *alertMessage = [[NSString alloc] initWithFormat:@"Do you want to Reveal yourself? If so, click 'Yes' to Reveal your name and picture."];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                    message:alertMessage
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Yes", nil];
    alert.tag = 1;
    [alert show];*/

    NSLog(@"Fetch Reveal Request run");
    // Query for Incoming RevealRequest
    [self fetchShareRequest];
            
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
    [self fetchShareReply];
    
    NSLog(@"Reveal Reply query run");
    
    [self acknowledgeAlertView];

}

- (void)sendShareRequest
{
    RevealRequest *revealRequest    = [RevealRequest object];
    revealRequest.requestFromUser   = _curUser;
    revealRequest.requestToUser     = self.toUserParse;
    revealRequest.requestReply      = @"";
    
    [revealRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        PFQuery *query = [PFInstallation query];
        [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              @"Request to Share Identities", @"alert",
                              [NSString stringWithFormat:@"%@", _toUserParse], @"match",
                              /*[NSString stringWithFormat:@"%@", _matchedUsers], @"relationship",*/
                              @"Increment", @"badge",
                              @"Ache.caf", @"sound",
                              nil];
        PFPush *push = [[PFPush alloc] init];
        
        [push setQuery:query];
        [push setData:data];
        [push sendPushInBackground];
        
        _cameraButton.enabled = NO;
        NSLog(@"Share Request Sent!");
    }];
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
            [self sendShareRequest];
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
            [self performSegueWithIdentifier:@"match_view" sender:nil];
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

- (void)reloadView
{
    UIView *parent = self.view.superview;
    [self.view removeFromSuperview];
    self.view = nil; // unloads the view
    [parent addSubview:self.view]; //reloads the view from the nib
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
        [self reloadView];
        [self performSegueWithIdentifier:@"match_view" sender:nil];
        NSLog(@"Pushed to Match User Profile");
    } else {
        NSLog(@"Notification pushed, but Request Reply code not run");
    }
            // Must set check in @"match_view" ViewWillAppear
    //    }
   // }];
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
                    [self reloadView];
                    [self performSegueWithIdentifier:@"match_view" sender:nil];
                }
            }];
            
        //}
        
    } else if (alertView.tag == 4) { // Share Request fromUser = _curUser, toUser Replied NO
        
        // Request rejected
        _receivedReply.requestClosed = [NSNumber numberWithBool:YES];
        [_receivedReply saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self reloadView];
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

- (void)blockUnMatched
{
    // Below should be in separate method and triggered on toParseUser UI via notification
    [UIView animateWithDuration:1 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.9 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.unMatchedBlocker.frame = CGRectMake(0, self.view.frame.size.height-self.unMatchedBlocker.frame.size.height, self.unMatchedBlocker.frame.size.width, self.unMatchedBlocker.frame.size.height);
    } completion:^(BOOL finished) {
        
    }];
}


- (IBAction)chatEndedClose:(id)sender {
    [self popVC];
}
@end
