//
//  TermsViewController.m
//  WallpaperzSocial
//
//  Created by STUDIO76 on 16.07.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import "TermsViewController.h"
#import "config.h"
#import "SWRevealViewController.h"

@interface TermsViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *sidebarButton;
@end

@implementation TermsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _sidebarButton.target = self.revealViewController;
    _sidebarButton.action = @selector(revealToggle:);
   // [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    
    NSString *fullURL = urlTerms;
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webs loadRequest:requestObj];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)back:(id)sender{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
