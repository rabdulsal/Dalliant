//
//  MySignUpViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "CustomSignUpViewController.h"
#import "UserParseHelper.h"

@interface CustomSignUpViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *nameImageView;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIImageView *emailImageView;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImageView;
@property (weak, nonatomic) IBOutlet UIImageView *nicknameImageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@property (nonatomic,retain) IBOutlet UIButton *signUpButtonHide;
@property (nonatomic,retain) IBOutlet UIButton *checkTerms;

@property NSString* errorMessage;

@property UserParseHelper *theUser;

@end

@implementation CustomSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topLabel.backgroundColor = BLUE_COLOR;
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    [self customizeView];
    [self setTextDelegates];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.checkTerms setImage:[UIImage imageNamed:@"normBtn.png"] forState:UIControlStateNormal];
    
}

- (void)customizeView
{
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.nicknameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Nick" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.signUpButton.layer setBorderWidth:0];
    [self.signUpButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.signUpButton.backgroundColor = RED_DEEP;
    self.signUpButton.hidden = YES;



}

#pragma mark - textField delegates
-(void)endTheEditing
{
    [self.nameTextField resignFirstResponder];
    [self.nicknameTextField resignFirstResponder];
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

-(void)setTextDelegates
{
    self.nameTextField.delegate = self;
    self.nicknameTextField.delegate = self;
    self.emailTextField.delegate = self;
    self.passwordTextField.delegate = self;
    [self.nameTextField addTarget:self
                           action:@selector(endTheEditing)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.nicknameTextField addTarget:self
                           action:@selector(endTheEditing)
                 forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.emailTextField addTarget:self
                            action:@selector(endTheEditing)
                  forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.passwordTextField addTarget:self
                               action:@selector(endTheEditing)
                     forControlEvents:UIControlEventEditingDidEndOnExit];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}


- (IBAction)signUpHit:(id)sender
{
    if ([self checkForValidSignUp]) {
        [self onValidSignUpCreateUser];
    } else {
        [self presentErrorMessage];
    }
}

#pragma mark - create user
-(BOOL)checkForValidSignUp
{
    [self populateErrorMessage];
    if (self.errorMessage.length > 0) {
        return NO;
    }

    return YES;
}

-(void) populateErrorMessage
{
    self.errorMessage = @"";

    if ([self.nameTextField.text isEqualToString:@""]) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Missing a username\n"];
    }
    if ([self.nicknameTextField.text isEqualToString:@""]) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Missing a nickname\n"];
    }

    if ([self.emailTextField.text isEqualToString:@""]) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Missing an email\n"];
    }
    if ([self.passwordTextField.text isEqualToString:@""]) {
        self.errorMessage = [self.errorMessage stringByAppendingString:@"Missing a password\n"];
    }
}

-(void) onValidSignUpCreateUser
{
    self.theUser = [UserParseHelper object];
    self.theUser.username = self.nameTextField.text;
    self.theUser.nickname = self.nicknameTextField.text;
    self.theUser.email = self.emailTextField.text;
    self.theUser.password = self.passwordTextField.text;
    self.theUser.distance = [NSNumber numberWithInt:100];
    self.theUser.sexuality = [NSNumber numberWithInt:2];
    self.theUser.age = [NSNumber numberWithInt:30];
    self.theUser.isMale = @"true";
    self.theUser.membervip = @"novip";
    self.theUser.desc = @"Hi all))) I am now with you !!!";
    self.theUser.photo = [PFFile fileWithData:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholderNew"],0.9)];
    [self.theUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self performSegueWithIdentifier:@"signup" sender:self];
        } else {
            if (error.code == 202) {
                self.errorMessage = [NSString stringWithFormat:@"username: %@ already taken", self.nameTextField.text];
            }
            if (error.code == 203) {
                self.errorMessage = [NSString stringWithFormat:@"email: %@ already taken", self.emailTextField.text];
            }
            if (error.code == 125) {
                self.errorMessage = [NSString stringWithFormat:@"Please enter a valid email."];
            }
            [self presentErrorMessage];
        }
    }];
}

-(void)presentErrorMessage
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:self.errorMessage delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
    alert.backgroundColor = RED_DEEP;
    [alert show];
}

- (IBAction)nameBegin:(id)sender {
    self.nameTextField.alpha = 1.0;
    self.nicknameTextField.alpha = 0.5;
    self.emailTextField.alpha = 0.5;
    self.passwordTextField.alpha = 0.5;
    self.nameImageView.alpha = 1.0;
    self.emailImageView.alpha = 0.5;
    self.passwordImageView.alpha = 0.5;
    self.nicknameImageView.alpha = 0.5;
}
- (IBAction)nameEnd:(id)sender {
}
- (IBAction)emailBegin:(id)sender {
    self.nameTextField.alpha = 0.5;
    self.nicknameTextField.alpha = 0.5;
    self.emailTextField.alpha = 1;
    self.passwordTextField.alpha = 0.5;
    self.nameImageView.alpha = 0.5;
    self.emailImageView.alpha = 1.0;
    self.passwordImageView.alpha = 0.5;
    self.nicknameImageView.alpha = 0.5;
}
- (IBAction)emailEnd:(id)sender {
}
- (IBAction)passwordBegin:(id)sender {
    self.nameTextField.alpha = 0.5;
    self.emailTextField.alpha = 0.5;
    self.nicknameTextField.alpha = 0.5;
    self.passwordTextField.alpha = 1;
    self.nameImageView.alpha = 0.5;
    self.emailImageView.alpha = 0.5;
    self.passwordImageView.alpha = 1;
    self.nicknameImageView.alpha = 0.5;
}
- (IBAction)passwordEnd:(id)sender {
    
    self.nameTextField.alpha = 0.5;
    self.emailTextField.alpha = 0.5;
    self.nicknameTextField.alpha = 1;
    self.passwordTextField.alpha = 0.5;
    self.nameImageView.alpha = 0.5;
    self.emailImageView.alpha = 0.5;
    self.passwordImageView.alpha = 0.5;
    self.nicknameImageView.alpha = 1.0;
}

-(IBAction)nicknameBegin:(id)sender{
    
    
}

-(IBAction)nicknameEnd:(id)sender{
    
    
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    [UIView animateWithDuration:1.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            CGRect rect = self.view.frame;
                            rect.origin.y -= 85;
                            [self.view setFrame:rect];
                        } completion:^(BOOL finished) {

                        }];
}

-(void)keyboardDidHide:(NSNotification *)notification
{
    [UIView animateWithDuration:1.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            CGRect rect = self.view.frame;
                            rect.origin.y += 85;
                            [self.view setFrame:rect];
                        } completion:^(BOOL finished) {
                            
                        }];
}

-(IBAction)fbsignUp:(id)sender{
    
    
}

-(IBAction)checkTermsbtn:(id)sender{
    
    UIImage *img=[(UIButton *) sender currentImage];
    if(img == [UIImage imageNamed:@"normBtn.png"])
    {
               
        [_checkTerms setImage:[UIImage imageNamed:@"normBtn.png"] forState:UIControlStateNormal];
        _signUpButton.hidden = YES;
        
    } else{
        
        
        [_checkTerms setImage:[UIImage imageNamed:@"chekBtn.png"] forState:UIControlStateNormal];
        _signUpButton.hidden = NO;
        
    }
  
    
    
}

@end

