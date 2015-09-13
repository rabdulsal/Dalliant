//
//  UserRatingViewController.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 4/20/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "UserRatingViewController.h"
#import "UserRating.h"

@interface UserRatingViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *badRatingDetails;
@property (weak, nonatomic) IBOutlet UILabel *matchUserLabel;
@property (weak, nonatomic) IBOutlet UIImageView *matchUserImageView;
@property (weak, nonatomic) IBOutlet UIButton *badRatingButton;
@property (weak, nonatomic) IBOutlet UIButton *goodRatingButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UITextView *badRatingDescription;
- (IBAction)badRatingPressed:(id)sender;
- (IBAction)goodRatingPressed:(id)sender;
- (IBAction)cancelButtonPressed:(id)sender;
- (IBAction)submitButtonPressed:(id)sender;


@end

@implementation UserRatingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _badRatingDescription.delegate = self;
    
    NSLog(@"ModalView presented for %@", _matchUser.nickname);
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7f];
    
    _badRatingDescription.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _badRatingDescription.layer.borderWidth = 1.0f;
    _badRatingDescription.layer.cornerRadius = 5.0f;
    _badRatingDescription.clipsToBounds = NO;
    [_badRatingDetails setHidden:YES];
    _matchUserLabel.text = _matchUser.nickname; // Refer to Relationship Model
    _matchUserImageView.layer.cornerRadius = _matchUserImageView.frame.size.width/2;
    _matchUserImageView.layer.masksToBounds = YES;
    _matchUserImageView.image = _matchUserImage;
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (IBAction)badRatingPressed:(id)sender {
    [_badRatingDetails setHidden:NO];
}

- (IBAction)goodRatingPressed:(id)sender {
    UserRating *userRating = [UserRating object];
    [userRating giveMatch:_matchUser ratingOf:@"Good" byUser:_user inView:self forConnection:_relationship because:nil];
}

- (IBAction)cancelButtonPressed:(id)sender {
    [_badRatingDetails setHidden:YES];
}

- (IBAction)submitButtonPressed:(id)sender {
    UserRating *userRating = [UserRating object];
    [userRating giveMatch:_matchUser ratingOf:@"Bad" byUser:_user inView:self forConnection:_relationship because:_badRatingDescription.text];
}
@end
