//
//  ReportViewController.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 4/19/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "ReportViewController.h"
#import "Report.h"

@interface ReportViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *reportedUserImage;
@property (weak, nonatomic) IBOutlet UITextView *reportText;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;


@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    
    _reportText.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _reportText.layer.borderWidth = 1.0f;
    _reportText.layer.cornerRadius = 5.0f;
    _reportText.clipsToBounds = NO;
    
    _reportedUserImage.image = _reportedImage;
    _reportedUser.text       = _matchUser.nickname;
}

- (void)viewWillAppear {
    [super viewWillAppear:YES];
    
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

- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)submitButtonPressed:(id)sender {
    UIViewController *vc = self;
    Report *report       = [Report object];
    
    [report reportMatch:_matchUser byUser:_user because:_reportText.text inView:vc];
    /* Must convert PFFile into image
     
     */
    
}


@end
