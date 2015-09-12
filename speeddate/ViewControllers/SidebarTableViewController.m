//
//  SidebarTableViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

/* ----------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 
 *** SIDEBAR - REORDER AND REMOVE 'START MATCH', 'USEFUL APPS' AND 'VIP' (FOR NOW) TABLECELLS FROM STORYBOARD
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */

#import "SidebarTableViewController.h"
#import "SWRevealViewController.h"
#import "UserParseHelper.h"
#import "CHTumblrMenuView.h"
#import "UIImage+Resize.h"
#import "config.h"
#import "UserParseHelper.h"
#import "User.h"
#import "MessageParse.h"
#import <TDBadgedCell.h>

#define DOCUMENTS [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@interface SidebarTableViewController ()
{
    User *user;
}
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UIImageView *matchImageView;
@property (weak, nonatomic) IBOutlet UILabel *profileLabel;
@property (weak, nonatomic) IBOutlet UIImageView *messagesImageView;
@property (weak, nonatomic) IBOutlet UILabel *messagesLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellShare;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationImageView;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellLocation;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *matchLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellMatch;
//@property (weak, nonatomic) IBOutlet UITableViewCell *cellMessage;
@property (weak, nonatomic) IBOutlet TDBadgedCell *cellMessage;
@property (weak, nonatomic) IBOutlet UITableViewCell *profileCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *vipMemberCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *termsCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *appCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *userNearCell;
@property (weak, nonatomic) IBOutlet UILabel *matchLableInCell;
@property (weak, nonatomic) IBOutlet UILabel *messageLableInCell;
@property (weak, nonatomic) IBOutlet UILabel *profileLableInCell;
@property (weak, nonatomic) IBOutlet UILabel *shareLableInCell;
@property (weak, nonatomic) IBOutlet UILabel *VipLableInCell;
@property (weak, nonatomic) IBOutlet UILabel *termsLableInCell;
@property (weak, nonatomic) IBOutlet UILabel *appLableInCell;
@property (weak, nonatomic) IBOutlet UILabel *logoutLableInCell;

@property (strong,nonatomic) UserParseHelper *userStart;
@property (weak, nonatomic) NSData *imgsData;

@end

@implementation SidebarTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    user = [User singleObj];
    
    self.profileCell.backgroundColor = RED_LIGHT;
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"back-m.png"]];

    UIView *backgroundSelectedCell = [[UIView alloc] init];
    [backgroundSelectedCell setBackgroundColor:RED_DEEP];
    

    for (int section = 0; section < [self.tableView numberOfSections]; section++)
        for (int row = 0; row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            NSIndexPath* cellPath = [NSIndexPath indexPathForRow:row inSection:section];
            UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:cellPath];

            [cell setSelectedBackgroundView:backgroundSelectedCell];
        }
    
    self.matchLableInCell.text = NSLocalizedString(@"start_match", nil);
    self.messageLableInCell.text = NSLocalizedString(@"menu_message", nil);
    self.profileLableInCell.text = NSLocalizedString(@"menu_profile", nil);
    self.shareLableInCell.text = NSLocalizedString(@"menu_share", nil);
    self.VipLableInCell.text = NSLocalizedString(@"menu_vip", nil);
    self.termsLableInCell.text = NSLocalizedString(@"menu_terms", nil);
    self.appLableInCell.text = NSLocalizedString(@"menu_app", nil);
    self.logoutLableInCell.text = NSLocalizedString(@"menu_logout", nil);
    
}


- (void)viewWillAppear:(BOOL)animated
{
    // ------------ MESSAGES BADGE -------------------
    
    [self getUnreadMessages];
    
    // ------------------------------------------------
    
    if ([animationMenu isEqualToString:@"YES"]) {
     
        for (int i = 1; i < 10; i++) { // <-- Must change 10 to 7
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            CGRect cellFrame = cell.frame;
            cellFrame.origin.x -= cellFrame.size.width;
            cell.frame = cellFrame;
            
            [UIView animateWithDuration:0.5
                                  delay:i*0.12+0.4
                 usingSpringWithDamping:0.5
                  initialSpringVelocity:0.05
                                options:UIViewAnimationOptionCurveEaseIn animations:^{
                                    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
                                    CGRect cellFrame = cell.frame;
                                    cellFrame.origin.x += cellFrame.size.width;
                                    cell.frame = cellFrame;
                                    
                                } completion:^(BOOL finished) {
                                    
                                }];
        }
    }
}

- (void)getUnreadMessages
{
    PFQuery *messageQueryTo = [MessageParse query];
    [messageQueryTo whereKey:@"toUserParse" equalTo:[UserParseHelper currentUser]];
    [messageQueryTo whereKey:@"read" notEqualTo:[NSNumber numberWithBool:YES]];
    
    [messageQueryTo findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if ([objects count] != 0) {
            int numberMessagesUnread = (int)[objects count];
            _cellMessage.badgeString = [[NSString alloc] initWithFormat:@"%d", numberMessagesUnread];
            _cellMessage.badge.radius = 5;
            _cellMessage.badge.fontSize = 15;
            _cellMessage.badgeColor = [UIColor whiteColor];
        }
    }];
}

#pragma mark - TABLEVIEW SEGUES

/* ----------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 
 *** REORDER:
 
    1. PROFILE
    2. BAEDAR
    3. CONNECTIONS
    4. SHARE
    5. TERMS
    6. LOGOUT
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */

- (void) prepareForSegue: (UIStoryboardSegue *) segue sender: (id) sender
{
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    
    if (indexPath.row == 1) { // <-- Should be 1st
        self.profileCell.backgroundColor    = RED_LIGHT;
        self.cellMatch.backgroundColor      = [UIColor clearColor];
        self.cellShare.backgroundColor      = [UIColor clearColor];
        self.cellMessage.backgroundColor    = [UIColor clearColor];
        self.cellLocation.backgroundColor   = [UIColor clearColor];
        self.vipMemberCell.backgroundColor  = [UIColor clearColor];
        self.termsCell.backgroundColor      = [UIColor clearColor];
        self.userNearCell.backgroundColor   = [UIColor clearColor];
    }
    
    if (indexPath.row == 2) {
        
        self.userNearCell.backgroundColor   = RED_LIGHT;
        self.cellMatch.backgroundColor      = [UIColor clearColor];
        self.cellMessage.backgroundColor    = [UIColor clearColor];
        self.profileCell.backgroundColor    = [UIColor clearColor];
        self.cellShare.backgroundColor      = [UIColor clearColor];
        self.vipMemberCell.backgroundColor  = [UIColor clearColor];
        self.termsCell.backgroundColor      = [UIColor clearColor];
        self.appCell.backgroundColor        = [UIColor clearColor];
    }

// ----------------------------------- REMOVE -----------------------------------------
    /*
    if (indexPath.row == 4) {
      
        self.userNearCell.backgroundColor = [UIColor clearColor];
        self.cellMatch.backgroundColor = RED_LIGHT;
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.vipMemberCell.backgroundColor = [UIColor clearColor];
        self.termsCell.backgroundColor = [UIColor clearColor];
        self.appCell.backgroundColor = [UIColor clearColor];
    }
*/
// ------------------------------------------------------------------------------------
    
    if (indexPath.row == 3) {
      
        self.userNearCell.backgroundColor   = [UIColor clearColor];
        self.cellMatch.backgroundColor      = [UIColor clearColor];
        self.cellMessage.backgroundColor    = RED_LIGHT;
        self.profileCell.backgroundColor    = [UIColor clearColor];
        self.cellShare.backgroundColor      = [UIColor clearColor];
        self.vipMemberCell.backgroundColor  = [UIColor clearColor];
        self.termsCell.backgroundColor      = [UIColor clearColor];
        self.appCell.backgroundColor        = [UIColor clearColor];
    }
    /*
    if (indexPath.row == 5) {
        
        self.cellShare.backgroundColor = RED_LIGHT;
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.cellLocation.backgroundColor = [UIColor clearColor];
        self.vipMemberCell.backgroundColor = [UIColor clearColor];
        self.termsCell.backgroundColor = [UIColor clearColor];
        self.userNearCell.backgroundColor = [UIColor clearColor];
       
    }

// ------------------------------ REMOVE (for now) -------------------------------------
    
    if (indexPath.row == 6) {
     
        self.vipMemberCell.backgroundColor = RED_LIGHT;
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.cellLocation.backgroundColor = [UIColor clearColor];
        self.termsCell.backgroundColor = [UIColor clearColor];
        self.userNearCell.backgroundColor = [UIColor clearColor];
       
    }
    
// ------------------------------------------------------------------------------------
    
    if (indexPath.row == 7) {
        
        self.termsCell.backgroundColor = RED_LIGHT;
        self.vipMemberCell.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.cellLocation.backgroundColor = [UIColor clearColor];
        self.userNearCell.backgroundColor = [UIColor clearColor];
    }
    
// ----------------------------------- REMOVE -----------------------------------------
    
    if (indexPath.row == 8) {
        
        self.appCell.backgroundColor =  RED_LIGHT;
        self.termsCell.backgroundColor = [UIColor clearColor];
        self.vipMemberCell.backgroundColor = [UIColor clearColor];
        self.cellShare.backgroundColor = [UIColor clearColor];
        self.cellMatch.backgroundColor = [UIColor clearColor];
        self.profileCell.backgroundColor = [UIColor clearColor];
        self.cellMessage.backgroundColor = [UIColor clearColor];
        self.cellLocation.backgroundColor = [UIColor clearColor];
        self.userNearCell.backgroundColor = [UIColor clearColor];
    }*/

// ------------------------------------------------------------------------------------
    
    if (indexPath.row == 9) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          
            NSLog(@"go out2");
            if ([PFUser currentUser]) {
                PFQuery *usr = [UserParseHelper query];
                self.userStart = [UserParseHelper alloc];
                [usr whereKey:@"objectId" equalTo:[UserParseHelper currentUser].objectId];
                [usr findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    self.userStart = [UserParseHelper alloc];
                    self.userStart = objects.firstObject;
                    self.userStart.online = @"no";
                    [self.userStart saveEventually];
                    NSLog(@"go out2 unlogin success");
                    
                }];
            }

            dispatch_sync(dispatch_get_main_queue(), ^{
               
                [UserParseHelper logOut];
                
            });
            
        });
        
        return;
    }

    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] ) {
        SWRevealViewControllerSegue *swSegue = (SWRevealViewControllerSegue*) segue;

        swSegue.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc) {
            UINavigationController* navController = (UINavigationController*)self.revealViewController.frontViewController;
            [navController setViewControllers: @[dvc] animated: YES ];
            [self.revealViewController setFrontViewPosition: FrontViewPositionLeft animated: YES];
        };
    }
    
}

#pragma mark - SHARE BUTTONS
/*
- (IBAction)shareButton:(id)sender
{
    CHTumblrMenuView *menuShare = [[CHTumblrMenuView alloc] init];
    UIImage *attach =[UIImage imageNamed:@"1024_gm.png"];
    
    [menuShare addMenuItemWithTitle:@"Instagram" andIcon:[UIImage imageNamed:@"instagram-share.png"] andSelectedBlock:^{
        
        [self shareImageOnInstagram:attach];
        
    }];
    
    [menuShare addMenuItemWithTitle:@"Facebook" andIcon:[UIImage imageNamed:@"fbshare.png"] andSelectedBlock:^{
       
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"Join the new application. I'm here! Download app  %@", AppUrl]];
        [mySLComposerSheet addImage:attach];
        
        
        [self presentViewController:mySLComposerSheet animated:YES completion:^{
            
        }];
        
    }];
    
    [menuShare addMenuItemWithTitle:@"WhatsApp" andIcon:[UIImage imageNamed:@"washare.png"] andSelectedBlock:^{
       
        
        [self shareimageOnWhatsapp:attach];
        
    }];
    
    [menuShare addMenuItemWithTitle:@"Twitter" andIcon:[UIImage imageNamed:@"twshare.png"] andSelectedBlock:^{
       
        
        SLComposeViewController *mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"Join the new application. I'm here! Download app  %@", AppUrl]];
        
        [mySLComposerSheet addImage:attach];
        
        
        [self presentViewController:mySLComposerSheet animated:YES completion:^{
            
        }];
        
        
    }];
    
    [menuShare addMenuItemWithTitle:@"Mail" andIcon:[UIImage imageNamed:@"maiz.png"] andSelectedBlock:^{
       
        
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        if ([MFMailComposeViewController canSendMail]) {
            
            [mail setToRecipients:[NSArray arrayWithObjects:@"email@email.com",nil]];
            [mail setSubject:@"Subject of Email"];
            
            [mail setMessageBody:[NSString stringWithFormat:@"Join the new application. I'm here! Download app  %@", AppUrl] isHTML:NO];
            
            
            
            NSData *dataImage = [NSData dataWithData:UIImagePNGRepresentation(attach)];
            
            [mail addAttachmentData:dataImage
                           mimeType:@"image/png"
                           fileName:@"Photo.png"];
            
            [self presentViewController:mail animated:YES completion:nil];
            
        }
    }];
    
    [menuShare show];
    
}

-(void)shareimageOnWhatsapp: (UIImage*)shareImage{
    
    if ([[UIApplication sharedApplication] canOpenURL: [NSURL URLWithString:@"whatsapp://app"]]){
        
        UIImage     * iconImage = [UIImage imageNamed:@"1024_gm.png"];

        NSString    * savePath  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/whatsAppTmp.wai"];
        
        [UIImageJPEGRepresentation(iconImage, 1.0) writeToFile:savePath atomically:YES];
        
        _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
        _documentController.UTI = @"net.whatsapp.image";
        _documentController.delegate = self;
        
        [_documentController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated: YES];
        
    }
    
}

-(void)shareImageOnInstagram:(UIImage*)shareImage
{
    
    UIImage *instaImage = shareImage;
    CGSize constraint = CGSizeMake(612, 612);
    UIImage* scaledImgH = [instaImage resizedImageToSize:constraint];
    NSString* imagePath = [NSString stringWithFormat:@"%@/image.igo", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    [UIImagePNGRepresentation(scaledImgH) writeToFile:imagePath atomically:YES];
   
    _documentController = [[UIDocumentInteractionController alloc]init];
    _documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:imagePath]];
    _documentController.delegate=self;
    
    NSString *captinText = [NSString stringWithFormat:@"Join the new application. I'm here! Download app  %@", AppUrl];
    _documentController.annotation=[NSDictionary dictionaryWithObjectsAndKeys:captinText,@"InstagramCaption", nil];
    _documentController.UTI = @"com.instagram.exclusivegram";
    
    [_documentController presentOpenInMenuFromRect:CGRectZero
                                            inView:self.view
                                          animated:YES];
   
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
           
            break;
        case MFMailComposeResultSaved:
           
            break;
        case MFMailComposeResultSent:
           
            break;
        case MFMailComposeResultFailed:
           
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}
*/
/* ----------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 
 *** SIDEBAR - REORDER AND REMOVE 'START MATCH' TABLECELL FROM STORYBOARD
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */

@end
