//
//  TutorialViewController.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 1/31/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "TutorialViewController.h"
#import <EAIntroView.h>
#import <EAIntroPage.h>

@interface TutorialViewController () <EAIntroDelegate>

@property (weak, nonatomic) IBOutlet EAIntroView *introView;
@property NSArray *pageArray;
@property (weak, nonatomic) IBOutlet UIButton *beginningButton;

- (IBAction)jumpToBeginning:(id)sender;

@end

@implementation TutorialViewController

/* ***************************************
 
        MUST ALL BE MOVED TO CUSTOMSIGNIN VC
 
****************************************** */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _introView.delegate = self;
    
    CGFloat titleHeight       = self.view.bounds.size.height/2 + 220;
    CGFloat descriptionHeight = self.view.bounds.size.height/2 + 200;
    
    EAIntroPage *page1      = [EAIntroPage page];
    page1.bgImage           = [UIImage imageNamed:@"Filters_Preferences"];
    page1.title             = @"Set Your Preferences";
    page1.titlePositionY    = titleHeight;
    page1.desc              = @"First Page";
    page1.descPositionY     = descriptionHeight;
    
    // Change heights
    //page1.titlePositionY = self.view.bounds.size.height/2 - 10;
    //page1.descPositionY = self.view.bounds.size.height/2 - 50;
    
    // Change Navigation button (Page Control) height
    //_introView.pageControlY = 250.f;

    EAIntroPage *page2      = [EAIntroPage page];
    page2.bgImage           = [UIImage imageNamed:@"Baedar"];
    page2.title             = @"Start Your Radar";
    page2.titlePositionY    = titleHeight;
    page2.desc              = @"Second Page";
    page2.descPositionY     = descriptionHeight;
    
    EAIntroPage *page3      = [EAIntroPage page];
    page3.bgImage           = [UIImage imageNamed:@"Share_Request"];
    page3.title             = @"Match and Chat Anonymously";
    page3.desc              = @"Third Page";
    page3.titlePositionY    = titleHeight;
    page3.descPositionY     = descriptionHeight;
    
    EAIntroPage *page4      = [EAIntroPage page];
    page4.bgImage           = [UIImage imageNamed:@"Match_Profile"];
    page4.title             = @"Share Identities and Take Photos";
    page4.desc              = @"Fourth Page";
    page4.titlePositionY    = titleHeight;
    page4.descPositionY     = descriptionHeight;
    
    EAIntroPage *page5      = [EAIntroPage page];
    page5.bgImage           = [UIImage imageNamed:@"Match_Meetup"];
    page5.title             = @"Meet if you Connect";
    page5.desc              = @"Fifth Page";
    page5.titlePositionY    = titleHeight;
    page5.descPositionY     = descriptionHeight;
    page5.subviews          = @[_beginningButton]; // Move higher up in View
    
    _pageArray = @[page1,page2,page3,page4,page5];
    [_introView setPages:_pageArray];
    _introView.pageControlY = 420.f;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(250, 30, 80, 30)];
    [btn setTitle:@"Skip" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _introView.skipButton = btn;
    _introView.swipeToExit = NO;
    [_introView showInView:self.view animateDuration:0.0];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IntroView Delegate

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex
{
    /*
    if (pageIndex > [_pageArray count]-1) {
        [self dismissViewControllerAnimated:YES completion:nil];
        //[_introView setCurrentPageIndex:0 animated:YES];
    }
     */
}

- (void)introDidFinish:(EAIntroView *)introView
{
    NSLog(@"Intro Done");
    //[_introView setCurrentPageIndex:0 animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    //[_introView showInView:self.view animateDuration:0.0];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)jumpToBeginning:(id)sender {
    [_introView setCurrentPageIndex:0 animated:YES];
}
@end
