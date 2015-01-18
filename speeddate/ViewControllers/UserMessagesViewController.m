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
@property UserParseHelper *curUser;
@end

@implementation UserMessagesViewController
@synthesize adBanner;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mainUser = [User singleObj];
    _curUser = [UserParseHelper currentUser];
    
    [self getPhotos];
    [self getMessages];
    
    if (!_toUserParse.isRevealed) {
        self.title = @"Chat";
        UIImage *btnImage = [UIImage imageNamed:@"user"];
        [_cameraButton setImage:btnImage forState:UIControlStateNormal];
        
        //[self fetchRevealRequest];
    } else {
        self.title = self.toUserParse.nickname;
        
        [_blurImageView removeFromSuperview];
        
        UIImage *btnImage = [UIImage imageNamed:@"camera2"];
        [_cameraButton setImage:btnImage forState:UIControlStateNormal];
    }
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddeKeyBoard)];
    [self.collectionView addGestureRecognizer:tapGestureRecognizer];
    
    // Notification to fetch New Message
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNewMessage:) name:receivedMessage object:nil];
    
    // Notification to fetch New Incoming Reveal Request?
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchRevealRequest:) name:@"Fetch Reveal Request" object:nil];
    //
    
    // Notification to fetch New Incoming Reveal Reply
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchRevealReply:) name:@"Fetch Reveal Reply" object:nil];
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"Fetch Reveal Reply" object:self];

    [self customizeApp];
}

- (void)customizeApp
{
    self.view.backgroundColor = WHITE_COLOR;
    self.collectionView.backgroundColor = WHITE_COLOR;
    self.messagesView.backgroundColor = RED_LIGHT;
    UIImage *temp = [[UIImage imageNamed:@"x"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:temp style:UIBarButtonItemStyleBordered target:self action:@selector(popVC)];
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

- (void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
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
    message.fromUserParse = [UserParseHelper currentUser];
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
        PFUser *pushUser = [PFUser currentUser];
        NSString *pushUserto = pushUser[@"nickname"];
       
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSString stringWithFormat:@"%@ say: %@",pushUserto,message.text], @"alert",
                              @"Increment", @"badge",
                              @"Ache.caf", @"sound",
                              nil];
        
        PFPush *push = [[PFPush alloc] init];
      
        [push setQuery:query];
        [push setData:data];
        [push sendPushInBackground];
        
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

   
    if ((message.sendImage || message.image) && [message.fromUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
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
        
        // Blur conditional ********************
        if (!_toUserParse.isRevealed) {
            [self blurImages:cell.userImageView];
        }
        
        // *************************************
        
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

    
    if (!message.image && !message.sendImage && [message.fromUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"fromCell" forIndexPath:indexPath];
        cell.userImageView.image = self.fromPhoto;
        cell.messageLabel.textColor = WHITE_COLOR;
    }

   
    if (!message.image && !message.sendImage &&[message.fromUserParse.objectId isEqualToString:self.toUserParse.objectId]) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"toCell" forIndexPath:indexPath];
        cell.userImageView.image = self.toPhoto;
        
        // Blur conditional ********************
        
        if (!_toUserParse.isRevealed) {
            [self blurImages:cell.userImageView];
        }
        
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
        if (!message.image && !message.sendImage && [message.fromUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
            rect.origin.x = cell.userImageView.frame.origin.x - outlineRect.size.width;
            //rect.origin.x = cell.userImageView.frame.origin.x - outlineRect.size.width + 25; // <-- Pushes current User text bubble toward righ margin
        }
        
        // ***********************************************
        
        outlineRect.origin = rect.origin;
        outlineRect.origin.x -= MARGIN*1.5; //<-- Adds left/right padding to Bubbleview
        outlineRect.origin.y -= MARGIN/1.5; //<-- Adds top/bottom padding to Bubbleview

        UIView *bubbleView = [[UIView alloc] initWithFrame:outlineRect];
        if ( [message.fromUserParse.objectId isEqualToString:[UserParseHelper currentUser].objectId]) {
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
    [query1 whereKey:@"fromUserParse" equalTo:[PFUser currentUser]];
    [query1 whereKey:@"toUserParse" equalTo:self.toUserParse];
    [query1 whereKey:@"text" notEqualTo:@""];

    PFQuery *query2 = [MessageParse query];
    [query2 whereKey:@"fromUserParse" equalTo:self.toUserParse];
    [query2 whereKey:@"toUserParse" equalTo:[PFUser currentUser]];
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
    [query whereKey:@"toUserParse" equalTo:[PFUser currentUser]];
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
    [queryFrom getObjectInBackgroundWithId:[UserParseHelper currentUser].objectId
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

#pragma mark - Send Photo Camera Press

- (IBAction)sendPhoto:(id)sender
{
    if (!_toUserParse.isRevealed) { // <-- Change to check on Matched User attribute
        _actionsheet = [[UIActionSheet alloc] initWithTitle:@"Send Reveal request?" delegate:self cancelButtonTitle:@"Don't Request" destructiveButtonTitle:nil otherButtonTitles:@"Yes", nil];
        _actionsheet.tag = 1;
        [_actionsheet showInView:self.view];
        
    } else {
        
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
    message.fromUserParse = [UserParseHelper currentUser];
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
            PFUser *pushUser = [PFUser currentUser];
            NSString *pushUserto = pushUser[@"nickname"];
            [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
            
            NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:@"%@ send image",pushUserto], @"alert",
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
        MatchViewController *matchVC = [[MatchViewController alloc]init];
        matchVC = segue.destinationViewController;
        //matchVC.userFBPic.image             = _toUserParse.photo;
        matchVC.matchUser = _toUserParse;
        
        if (matchVC.matchUser.photo) {
            [matchVC.matchUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                matchVC.matchImage = [[UIImage alloc] initWithData:data];
                NSLog(@"Image 0");
                [matchVC.getPhotoArray addObject:matchVC.matchImage];
            }];
        } else NSLog(@"No Main photo");
        if (matchVC.matchUser.photo1) {
            [matchVC.matchUser.photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                matchVC.matchImage1 = [[UIImage alloc] initWithData:data];
                NSLog(@"Image 1");
                [matchVC.getPhotoArray addObject:matchVC.matchImage1];
            }];
        } else NSLog(@"No Main1 photo");
        if (matchVC.matchUser.photo2) {
            
            [matchVC.matchUser.photo2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                matchVC.matchImage2 = [[UIImage alloc] initWithData:data];
                NSLog(@"Image 2");
                [matchVC.getPhotoArray addObject:matchVC.matchImage2];
            }];
        } else NSLog(@"No Main2 photo");
        if (matchVC.matchUser.photo3) {
            
            [matchVC.matchUser.photo3 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                matchVC.matchImage3 = [[UIImage alloc] initWithData:data];
                NSLog(@"Image 3");
                [matchVC.getPhotoArray addObject:matchVC.matchImage3];
            }];
        } else NSLog(@"No Main3 photo");
        
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
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Match Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"View Profile",@"Report",@"Un-Match", nil];
    sheet.tag = 2;
    [sheet showInView:self.view];
}

- (void)deleteConversation
{
    PFQuery *query1 = [MessageParse query];
    [query1 whereKey:@"fromUserParse" equalTo:[PFUser currentUser]];
    [query1 whereKey:@"toUserParse" equalTo:self.toUserParse];

    PFQuery *query2 = [MessageParse query];
    [query2 whereKey:@"fromUserParse" equalTo:self.toUserParse];
    [query2 whereKey:@"toUserParse" equalTo:[PFUser currentUser]];


    PFQuery *orQUery = [PFQuery orQueryWithSubqueries:@[query1, query2]];

    [orQUery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MessageParse deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
          //  [self popVC];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
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
    PFQuery *requestQuery = [RevealRequest query];
    [requestQuery whereKey:@"requestFromUser" equalTo:self.toUserParse];
    [requestQuery whereKey:@"requestToUser" equalTo:_curUser];
    [requestQuery whereKey:@"requestReply" equalTo:@""];
    
    [requestQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (!error && [objects count] != 0) {
            
            _receivedRequest = (RevealRequest *)[objects objectAtIndex:0];
            
            /*for (RevealRequest *request in objects) {
                NSLog(@"For Loop");
                request.requestReply = @"No";
                NSLog(@"Request Reply: %@", request.requestReply);
                
                // Save to Parse
                [request saveInBackground];
            }*/
            
            NSLog(@"Query run");
            // Reveal AlertView
            NSString *alertTitle = [[NSString alloc] initWithFormat:@"%@ Has Sent You a Share Request: %@", _toUserParse.nickname, _receivedRequest.objectId];
            NSString *alertMessage = [[NSString alloc] initWithFormat:@"Do you want to share your Profile? If so, click 'Yes' to share your name and pictures."];
        
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                        message:alertMessage
                                                       delegate:self
                                              cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
            alert.tag = 1;
            [alert show];
            
        } else NSLog(@"Reply sent");
    }];
   
}

#pragma mark - Incoming Reveal Reply

- (void)fetchRevealReply:(NSNotification *)note
{
    NSLog(@"Fetch Reveal Reply run");
    // Query for Incoming RevealRequest
    PFQuery *replyQuery = [RevealRequest query];
    [replyQuery whereKey:@"requestFromUser" equalTo:[PFUser currentUser]];
    [replyQuery whereKey:@"requestToUser" equalTo:self.toUserParse];
    [replyQuery whereKey:@"requestReply" notEqualTo:@""];
    
    [replyQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        NSLog(@"Reveal Reply query run");
        for (RevealRequest *request in objects) {
            if ([request.requestReply isEqualToString:@"Yes"]) {
                // Request Accepted
                // Reveal AlertView
                NSString *alertTitle = [[NSString alloc] initWithFormat:@"%@ Shared Their Profile!", _toUserParse.nickname];
                NSString *alertMessage = [[NSString alloc] initWithFormat:@"You and %@ have shared profiles...have fun!", _toUserParse.nickname];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:alertTitle
                                                                message:alertMessage
                                                               delegate:self
                                                      cancelButtonTitle:@"Okay"
                                                      otherButtonTitles:nil];
                NSLog(@"Reply AlertView run");
                alert.tag = 3;
                [alert show];
                
                // Reveal Current User and update view
                _curUser.isRevealed = [NSNumber numberWithBool:YES];
                [_curUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [self reloadView];
                    }
                }];
            
            } else {
                // Request Rejected
                NSString *alertTitle = [[NSString alloc] initWithFormat:@"%@ Declined Sharing Profiles", _toUserParse.nickname];
                NSString *alertMessage = [[NSString alloc] initWithFormat:@"Right now %@ doesn't want to share. Maybe they'll request to share with you.", _toUserParse.nickname];
                
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
        
    }];

}

#pragma mark - ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) { // <-- Clicked Reveal Request Button
        
        if (!_toUserParse.isRevealed && buttonIndex == 0) { // <-- Change to isRevealed check on PossibleMatchHelper
            // Test purposes
            /*mainUser.isRevealed = true;
            [self reloadView];*/
            
            // <-- Apparently this works when app is in background, a notification is sent and appears as alert
            // RevealRequest setup
            RevealRequest *revealRequest = [RevealRequest object];
            revealRequest.requestFromUser = [UserParseHelper currentUser];
            revealRequest.requestToUser = self.toUserParse;
            revealRequest.requestReply = @"";
            
            [revealRequest saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                PFQuery *query = [PFInstallation query];
                [query whereKey:@"objectId" equalTo:self.toUserParse.installation.objectId];
                
                NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSString stringWithFormat:@"Request to Share Identities"], @"alert",
                                      @"Increment", @"badge",
                                      @"Ache.caf", @"sound",
                                      nil];
                PFPush *push = [[PFPush alloc] init];
                
                [push setQuery:query];
                [push setData:data];
                [push sendPushInBackground];
            }];
         }
        
    } else if (actionSheet.tag == 2) { // <-- Clicked Match Options Button
        
        if (buttonIndex == 0) {
            //[self performSegueWithIdentifier:@"view_profile" sender:nil];
            [self performSegueWithIdentifier:@"match_view" sender:nil];
        }
            
        if (buttonIndex == 1) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Report"
                                                         message:@"Are you sure you want to report this user? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Report", nil];
            av.tag = 2;
            [av show];
        }
            
        if (buttonIndex == 2) {
            NSLog(@"Delete button pressed");
            //[self deleteConversation];
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

                RevealRequest *request = [[RevealRequest alloc] init];
                request = _receivedRequest;
                request.requestReply = reply;
                //NSLog(@"Reply: %@", request.requestReply);
                [request saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    /*
                    if (succeeded) {
                    
                        [_curUser saveInBackground];
                    
                        // Push Reveal Reply Updates Notification
                        PFQuery *query = [PFInstallation query];
                        PFUser *pushUser = [PFUser currentUser];
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
                        
                    }*/
                }];
                
                
            //}); // 6
        //});
        
        
    } else if (alertView.tag == 2) {
        
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
        
    }
}




@end
