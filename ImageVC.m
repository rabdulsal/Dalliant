//
//  ImageVC.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 3/9/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "ImageVC.h"

@interface ImageVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@end

@implementation ImageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    _closeButton.layer.borderWidth = 2.0;
    _closeButton.layer.borderColor = WHITE_COLOR.CGColor;
    _closeButton.layer.cornerRadius = _closeButton.frame.size.width/2;
    _imageView.image = _image;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)closeView:(id)sender {
    
    [self dismissViewControllerAnimated:NO
                             completion:nil];
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
