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
#import "SidebarTableViewController.h"
#import <KIImagePager.h>
#import "MatchProfileTVC.h"
#import <ILTranslucentView.h>
#define MARGIN 50

@interface MatchViewController ()
@property (weak, nonatomic) IBOutlet UIButton *matchingButton;
@property (weak, nonatomic) IBOutlet UIImageView *matchImageView;
@property (weak, nonatomic) IBOutlet UILabel *matchingLabel;
@property (nonatomic) NSData *imageData;
@property (weak, nonatomic) IBOutlet KIImagePager *imagePager;
@property (weak, nonatomic) IBOutlet UIView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (nonatomic) UIVisualEffectView *blurImageView;


@end

@implementation MatchViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _getPhotoArray = [[NSMutableArray alloc] init];
    
    [self blurImages:_imageView];
    
    [_scroller setScrollEnabled:YES];
    //[_scroller setContentSize:CGSizeMake(320, 1555)];
    [_scroller setContentSize:CGSizeMake(self.view.frame.size.width, 2200)];
    /*
    [_matchUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        _imageData = data;
        _matchImage = [[UIImage alloc] initWithData:data];
    }];*/
    
    self.matchingButton.layer.cornerRadius = 3;
    self.matchingButton.layer.borderWidth = 1.0;
    self.matchingButton.layer.borderColor = WHITE_COLOR.CGColor;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    _imagePager.pageControl.currentPageIndicatorTintColor = [UIColor lightGrayColor];
    _imagePager.pageControl.pageIndicatorTintColor = [UIColor blackColor];
    _imagePager.pageControl.center = CGPointMake(CGRectGetWidth(_imagePager.frame) / 2, CGRectGetHeight(_imagePager.frame) - 42);
    
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

- (NSArray *) arrayWithImages:(KIImagePager*)pager
{
    return _getPhotoArray;
    //return @[_matchImage,_matchImage1];
}

- (UIViewContentMode) contentModeForImage:(NSUInteger)image inPager:(KIImagePager*)pager
{
    return UIViewContentModeScaleAspectFill;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"matched_user"]) {
        MatchProfileTVC *matchVC = [[MatchProfileTVC alloc] init];
        matchVC = segue.destinationViewController;
        matchVC.matchUser = _matchUser;
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
    ILTranslucentView *translucentView = [[ILTranslucentView alloc] initWithFrame:CGRectMake(_imagePager.frame.origin.x, _imagePager.frame.origin.y, _imagePager.frame.size.width, _imagePager.frame.size.height)];
    
    translucentView.translucentAlpha = 1;
    translucentView.translucentStyle = UIBarStyleDefault;
    translucentView.translucentTintColor = [UIColor clearColor];
    translucentView.backgroundColor = [UIColor clearColor];
    [_imageView addSubview:translucentView];
}

/* ----------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 
 *** TINDER-LIKE VIEW SHOWING YOU MADE A MATCH WITH OPTION TO CHAT OR CONTINUE PLAYING
 
 *** CHANGE THIS VIEW TO NOTIFY USER OF N-NUMBER OF MATCHES AT 5 MINUTE INTERVALS
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */


@end
