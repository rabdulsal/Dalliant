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


@end

@implementation TutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _introView.delegate = self;
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.bgImage = [UIImage imageNamed:@"match"];
    page1.title = @"Hello world";
    page1.desc = @"First Page";
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.bgImage = [UIImage imageNamed:@"match"];
    page2.title = @"This is Dalliant";
    page2.desc = @"Second Page";
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.bgImage = [UIImage imageNamed:@"match"];
    page3.title = @"It's and AWESOME App";
    page3.desc = @"Third Page";
    
    [_introView setPages:@[page1,page2,page3]];
    
    [_introView showInView:self.view animateDuration:0.0];
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
