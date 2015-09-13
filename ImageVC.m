//
//  ImageVC.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 3/9/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "ImageVC.h"
#import "ReportViewController.h"

@interface ImageVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;

- (IBAction)reportButtonPressed:(id)sender;

@end

@implementation ImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    _closeButton.layer.borderWidth = 2.0;
    _closeButton.layer.borderColor = WHITE_COLOR.CGColor;
    _closeButton.layer.cornerRadius = _closeButton.frame.size.width/2;
    
    _reportButton.layer.borderWidth = 2.0;
    _reportButton.layer.borderColor = WHITE_COLOR.CGColor;
    _reportButton.layer.cornerRadius = _reportButton.frame.size.width/2;
    
    _imageView.image = _image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeView:(id)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    ReportViewController *vc = segue.destinationViewController;
    vc.user                    = _user;
    vc.matchUser               = _matchUser;
    vc.reportedImage           = _image;
    [vc setModalPresentationStyle:UIModalPresentationOverCurrentContext];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)reportButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"reportMatch" sender:nil];
}
@end
