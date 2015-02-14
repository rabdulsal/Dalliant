//
//  MatchViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

/* ----------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------

*** TINDER-LIKE VIEW SHOWING YOU MADE A MATCH WITH OPTION TO CHAT OR CONTINUE PLAYING

*** CHANGE THIS VIEW TO NOTIFY USER OF N-NUMBER OF MATCHES AT 5 MINUTE INTERVALS
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */
#import "MatchViewController.h"
#import "UserNearMeViewController.h"
#import "MainViewController.h"
#import "UserMessagesViewController.h"
#import "SidebarTableViewController.h"
#import <KIImagePager.h>
#import "MatchProfileTVC.h"
#import <ILTranslucentView.h>
#import "Report.h"
#import "MessageParse.h"
#import "RevealRequest.h"
#define MARGIN 50

@interface MatchViewController () <UIAlertViewDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *matchingButton;
@property (weak, nonatomic) IBOutlet UIImageView *matchImageView;
@property (weak, nonatomic) IBOutlet UILabel *matchingLabel;
@property (nonatomic) NSData *imageData;
@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;
@property (weak, nonatomic) IBOutlet UIView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (nonatomic) UIVisualEffectView *blurImageView;
@property ILTranslucentView *translucentView;
@property (weak, nonatomic) IBOutlet UIButton *reportUser;
@property (weak, nonatomic) IBOutlet UIButton *matchOptionsLabel;
@property RevealRequest *receivedRequest;
@property RevealRequest *receivedReply;

- (IBAction)matchOptionsButton:(id)sender;

- (IBAction)reportUser:(id)sender;

@end

@implementation MatchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _userName.text = _matchUser.nickname;
    
    NSLog(@"Blocked Users self: %lu", (unsigned long) [_user.blockedUsers count]);
    
    [_scroller setScrollEnabled:YES];
    //[_scroller setContentSize:CGSizeMake(320, 1555)];
    [_scroller setContentSize:CGSizeMake(self.view.frame.size.width, 2400)];
    /*
    [_matchUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _imageData = data;
        _matchImage = [[UIImage alloc] initWithData:data];
    }];*/
    
    [self configureButton:_matchingButton];
    [self configureButton:_reportUser];
    
    [self blurImages:_imageView];

    NSLog(@"Match: %@, Compatibility: %@", _matchUser.nickname, _possibleMatch.compatibilityIndex);
    NSLog(@"User Images: %lu", (unsigned long)[_getPhotoArray count]);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchShareRequest];
    
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    _imagePager.pageControl.center = CGPointMake(CGRectGetWidth(_imagePager.frame) / 2, CGRectGetHeight(_imagePager.frame) - 42);
    
    if (_receivedRequest) {
        if ([_receivedRequest.requestReply isEqualToString:@"Yes"] && [_receivedRequest.requestFromUser isEqual:_matchUser]) {
            NSLog(@"Before TranslucentView removed");
            [_translucentView removeFromSuperview];
            NSLog(@"After TranslucentView removed");
        }
    }
    
    if (_receivedReply) {
        if ([_receivedReply.requestReply isEqualToString:@"Yes"] && [_receivedReply.requestClosed isEqualToNumber:[NSNumber numberWithBool:YES]] && [_receivedReply.requestToUser isEqual:_matchUser]) {
            [_translucentView removeFromSuperview];
        }
    }
    
    /*
    UIImageView *iv = [[UIImageView alloc] initWithFrame:self.view.frame];
    iv.image = [UIImage imageNamed:@"match"];
    [self.view addSubview:iv];
    UIImageView *leftIV = [[UIImageView alloc] initWithImage:self.userImage];
    leftIV.frame = CGRectMake(-100, self.view.frame.size.height/3, 100, 100);
    leftIV.contentMode = UIViewContentModeScaleAspectFill;
    leftIV.layer.borderColor = WHITE_COLOR.CGColor;
    leftIV.layer.borderWidth = 1.0;
    leftIV.layer.cornerRadius = leftIV.frame.size.width/2;
    leftIV.clipsToBounds = YES;
    [self.view addSubview:leftIV];
    [self.view sendSubviewToBack:iv];
    [self.view bringSubviewToFront:self.matchingButton];

    UIImageView *rightIV = [[UIImageView alloc] initWithImage:self.matchImage];
    rightIV.frame = CGRectMake(self.view.frame.size.width+100, self.view.frame.size.height/3, 100, 100);
    rightIV.contentMode = UIViewContentModeScaleAspectFill;
    rightIV.layer.cornerRadius = leftIV.frame.size.width/2;
    rightIV.layer.borderColor = WHITE_COLOR.CGColor;
    rightIV.layer.borderWidth = 1.0;
    rightIV.clipsToBounds = YES;
    [self.view addSubview:rightIV];


    [UIView animateWithDuration:4 delay:0.2 usingSpringWithDamping:0.9 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{
        leftIV.frame = CGRectMake(MARGIN/1.5, self.view.frame.size.height/3, leftIV.frame.size.width, leftIV.frame.size.height);
        rightIV.frame = CGRectMake(self.view.frame.size.width-MARGIN/1.5-100, self.view.frame.size.height/3, leftIV.frame.size.width, leftIV.frame.size.height);
    } completion:^(BOOL finished) {

    }];


    [UIView animateWithDuration:1.5 delay:0.7 usingSpringWithDamping:0.6 initialSpringVelocity:0.3 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.matchingButton.frame = CGRectMake(self.matchingButton.frame.origin.x, 400, self.matchingButton.frame.size.width, self.matchingButton.frame.size.height);
        self.matchingLabel.frame = CGRectMake(self.matchingLabel.frame.origin.x, 415, self.matchingLabel.frame.size.width, self.matchingLabel.frame.size.height);
    } completion:^(BOOL finished) {

    }];
    [UIView animateWithDuration:7 animations:^{
        self.matchImageView.alpha = 1.0;
    } completion:^(BOOL finished) {

    }];
     */
}

- (void)fetchShareRequest
{
    PFQuery *requestFromQuery = [RevealRequest query];
    [requestFromQuery whereKey:@"requestFromUser" equalTo:[UserParseHelper currentUser]];
    [requestFromQuery whereKey:@"requestToUser" equalTo:_matchUser];
    
    PFQuery *requestToQuery = [RevealRequest query];
    [requestToQuery whereKey:@"requestToUser" equalTo:[UserParseHelper currentUser]];
    [requestToQuery whereKey:@"requestFromUser" equalTo:_matchUser];
    
    PFQuery *orQuery = [PFQuery orQueryWithSubqueries:@[requestFromQuery, requestToQuery]];
    
    
    NSArray *requests = [[NSArray alloc] initWithArray:[orQuery findObjects]];
    NSLog(@"Requests count: %lu", (unsigned long)[requests count]);
    
    for (RevealRequest *request in requests) {
        UserParseHelper *fromRequestUser = (UserParseHelper *)[request.requestFromUser fetchIfNeeded];
        
        UserParseHelper *toRequestUser = (UserParseHelper *)[request.requestToUser fetchIfNeeded];
        
        if ([fromRequestUser isEqual:[UserParseHelper currentUser]]) {
            _receivedReply = request; //Equivalent to receivedReply
            NSLog(@"Request from Me");
        } else if ([toRequestUser isEqual:[UserParseHelper currentUser]]) {
            _receivedRequest = request; //Equivalent to receivedRequest
            NSLog(@"Request from Other User");
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

- (void)configureButton:(UIButton *)button
{
    button.layer.cornerRadius = 3;
    button.layer.borderWidth = 1.0;
    button.layer.borderColor = RED_LIGHT.CGColor;
}

- (void)setUserPhotosArray:(UserParseHelper *)match
{
    // Fetch the matchUser
    self.getPhotoArray = [NSMutableArray new];
    
    if (match.photo) {
        NSData *imageData = [match.photo getData];
        if (imageData) {
            UIImage *matchImage = [[UIImage alloc] initWithData:imageData];
            NSLog(@"MatchImage: %@", matchImage);
            [self.getPhotoArray addObject:matchImage];
        }
    }
    
    if (match.photo1) {
        NSData *imageData = [match.photo1 getData];
        if (imageData) {
            UIImage *matchImage = [[UIImage alloc] initWithData:imageData];
            NSLog(@"MatchImage: %@", matchImage);
            [self.getPhotoArray addObject:matchImage];
        }
    }
    
    if (match.photo2) {
        NSData *imageData = [match.photo2 getData];
        if (imageData) {
            UIImage *matchImage = [[UIImage alloc] initWithData:imageData];
            NSLog(@"MatchImage: %@", matchImage);
            [self.getPhotoArray addObject:matchImage];
        }
    }
    
    if (match.photo3) {
        NSData *imageData = [match.photo3 getData];
        if (imageData) {
            UIImage *matchImage = [[UIImage alloc] initWithData:imageData];
            NSLog(@"MatchImage: %@", matchImage);
            [self.getPhotoArray addObject:matchImage];
        }
        
        
    }
}

- (NSArray *) arrayWithImages:(KIImagePager*)pager
{
    return _getPhotoArray;
    //return @[_matchImage,_matchImage1];
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image inPager:(KIImagePager*)pager
{
    return UIViewContentModeScaleAspectFill;
}

- (void)generateMatchMessage // Don't Need?
{
    // Check if a Message already exists
    PFQuery* query = [MessageParse query];
    [query whereKey:@"fromUserParse" equalTo:_matchUser];
    [query whereKey:@"toUserParse" equalTo:_user];
    
    PFQuery* query2 = [MessageParse query];
    [query2 whereKey:@"toUserParse" equalTo:_matchUser];
    [query2 whereKey:@"fromUserParse" equalTo:_user];
    
    if ([query findObjects].firstObject || [query2 findObjects].firstObject) {
        NSLog(@"Message with %@ exists", _matchUser.nickname);
    } else {
        //NSLog(@"Compatibility with %@ is: %@%%", match.nickname, [NSNumber numberWithDouble:*(_otherUser.compatibilityIndex)]);
        
        MessageParse* message       = [MessageParse object];
        message.fromUserParse       = _user;
        message.fromUserParseEmail  = _user.email;
        message.toUserParse         = _matchUser;
        message.toUserParseEmail    = _matchUser.email;
        message.text                = @"";
        [message saveInBackground];
        NSLog(@"Created message for %@", _matchUser.nickname);
        
    }
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"matched_user"]) {
        MatchProfileTVC *vc = [[MatchProfileTVC alloc] init];
        vc                      = segue.destinationViewController;
        vc.matchUser            = _matchUser;
        vc.matchCompatibility   = _possibleMatch;
    }
    if ([segue.identifier isEqualToString:@"matchChat"]) {
        UserMessagesViewController *vc  = [[UserMessagesViewController alloc] init];
        vc                              = segue.destinationViewController;
        vc.toUserParse                  = _matchUser;
        vc.curUser                      = _user;
        
        [self generateMatchMessage];
        //Check for prior Chat b/w 2 Users, if so, don't subtract credits
        //[_user calculateCredits];
        //NSLog(@"%@'s credits: %@", _user.nickname, _user.credits);
    }
}
// START CHAT BUTTON

- (IBAction)keepMatching:(id)sender
{
    // Dismiss ViewController and Pop to UserNearMeViewController
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // Pop to RootViewController
    //[self performSegueWithIdentifier:@"viewMatches" sender:nil];
    
}

#pragma mark - GESTURE RECOGNIZER

- (void) setTapGestureRecognizer
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.matchingButton addGestureRecognizer:tap];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    NSLog(@"MatchingButton was tapped");
}

#pragma mark - Blur Images
- (void)blurImages:(UIView *)imageView
{
    _translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(_imagePager.frame.origin.x, _imagePager.frame.origin.y, _imagePager.frame.size.width, _imagePager.frame.size.height)];
    
    _translucentView.translucentAlpha = 1;
    _translucentView.translucentStyle = UIBarStyleDefault;
    _translucentView.translucentTintColor = [UIColor clearColor];
    _translucentView.backgroundColor = [UIColor clearColor];
    [_imageView addSubview:_translucentView];
}

/* ----------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 
 *** TINDER-LIKE VIEW SHOWING YOU MADE A MATCH WITH OPTION TO CHAT OR CONTINUE PLAYING
 
 *** CHANGE THIS VIEW TO NOTIFY USER OF N-NUMBER OF MATCHES AT 5 MINUTE INTERVALS
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */
- (void)deleteConversation
{
    PFQuery *query1 = [MessageParse query];
    [query1 whereKey:@"fromUserParse" equalTo:[PFUser currentUser]];
    [query1 whereKey:@"toUserParse" equalTo:_matchUser];
    
    PFQuery *query2 = [MessageParse query];
    [query2 whereKey:@"fromUserParse" equalTo:_matchUser];
    [query2 whereKey:@"toUserParse" equalTo:[PFUser currentUser]];
    
    
    PFQuery *orQUery = [PFQuery orQueryWithSubqueries:@[query1, query2]];
    
    [orQUery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [MessageParse deleteAllInBackground:objects block:^(BOOL succeeded, NSError *error) {
            //  [self popVC];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }];
}

- (IBAction)matchOptionsButton:(id)sender {
    
    if (!self.fromConversation) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Match Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", @"Chat", nil];
        sheet.tag = 2;
        [sheet showInView:self.view];
        
    }
    
    else {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Match Options" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", nil];
        sheet.tag = 7;
        [sheet showInView:self.view];
    }
}

- (IBAction)reportUser:(id)sender {
    [self deleteConversation];
    PFQuery *query = [Report query];
    [query whereKey:@"user" equalTo:_matchUser];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        Report *report = objects.firstObject;
        if (!report) {
            Report *repo = [Report object];
            report = repo;
            report.user = _matchUser;
        }
        report.report = [NSNumber numberWithInt:report.report.intValue + 1];
        [report saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
    }];
}

#pragma mark - ActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 2) { // <-- Clicked Match Options Button
        
        if (buttonIndex == 1) {
            //[self performSegueWithIdentifier:@"view_profile" sender:nil];
            [self performSegueWithIdentifier:@"matchChat" sender:nil];
        }
        
        if (buttonIndex == 0) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Report"
                                                         message:@"Are you sure you want to report this user? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Report", nil];
            av.tag = 2;
            [av show];
        }
    } else if (actionSheet.tag == 7) {
        if (buttonIndex == 0) {
            UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Report"
                                                         message:@"Are you sure you want to report this user? The conversation will be deleted."
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                               otherButtonTitles:@"Report", nil];
            av.tag = 2;
            [av show];
        }
    }
    
}

#pragma mark - AlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 2) {
        /*
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
        */
    }
}

@end
