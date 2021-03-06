//
//  CustomSignInViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#define emailIdentifier @"@"

#import "CustomSignInViewController.h"
#import "UserParseHelper.h"
#import "ProgressHUD.h"
#import "AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "utilities.h"
#import "AppConstant.h"
#import "MainViewController.h"
#import "User.h"
#import "FaceBookLoginDelegate.h"
#import "FacebookLogin.h"

#ifdef __IPHONE_8_0
#import <LocalAuthentication/LocalAuthentication.h>
#endif


@interface CustomSignInViewController () <FaceBookLoginDelegate>
{
    NSString *userImage;
    User *mainUser;
}
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
@property (weak, nonatomic) IBOutlet UIButton *fasebooklogin;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UIImageView *keyImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *containerViewPassword;
@property (nonatomic,retain) MainViewController *startScreen;
@property (nonatomic) NSMutableArray *imageAssets;
@property (strong, nonatomic) UIWindow *window;
@property int profilePhotosCount;
@end
#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

//@end

@implementation CustomSignInViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.topLabel.backgroundColor = RED_DEEP;
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    /*
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    */
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"match"]];
    [self customizeView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
    
    mainUser = [User singleObj];
    mainUser.imageAssets = [NSMutableArray new];
    
}


#pragma mark - Resign the textField's keyboard
- (IBAction)resignTheKeyboard:(UITextField*)sender
{
    [sender resignFirstResponder];
}

#pragma mark - login button pressed
- (IBAction)enterspeeddateWorld:(id)sender
{
    
    ///implement touch id
    
    NSUserDefaults *loginUser = [NSUserDefaults standardUserDefaults];
    
    NSString *touchString = [loginUser objectForKey:@"touchId"];
    
    if ([touchString isEqualToString:@"yes"]) {
    
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Are you the device owner?"
                          reply:^(BOOL success, NSError *error) {
                              
                              if (error) {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"There was a problem verifying your identity."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  return;
                              }
                              
                              if (success) {
                                  
                                  
                                  [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
                                      if (error) {
                                          [self showAlertForInvalidLogin];
                                      } else {
                                          [self performSegueWithIdentifier:@"login" sender:self];
                                      }
                                  }];
   
                              } else {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"You are not the device owner."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                              }
                              
                          }];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device cannot authenticate using TouchID."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
            if (error) {
                [self showAlertForInvalidLogin];
            } else {
                [self performSegueWithIdentifier:@"login" sender:self];
            }
        }];
        
           }
    }
    /// end implement touch id
        if ([touchString isEqualToString:@"no"]) {
    [PFUser logInWithUsernameInBackground:self.emailTextField.text password:self.passwordTextField.text block:^(PFUser *user, NSError *error) {
        if (error) {
            [self showAlertForInvalidLogin];
        } else {
            [self performSegueWithIdentifier:@"login" sender:self];
        }
    }];
            
        }
}

#pragma mark - alert message
-(void) showAlertForInvalidLogin
{
    NSString* message = @"";
    if ([self.emailTextField.text isEqualToString:@""]) {
        message = [message stringByAppendingString:@"Blank login field\n"];
    }
    if ([self.passwordTextField.text isEqualToString:@""]) {
        message = [message stringByAppendingString:@"Blank password field\n"];
    }
    message = [message stringByAppendingString:@"Enter valid login credentials"];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error with login" message:message delegate:self cancelButtonTitle:@"Done" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - customize view

- (void)customizeView
{
    self.emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    self.passwordTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    [self.signInButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [[self.signInButton layer] setBorderWidth:0.0f];

    [self.containerView.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.containerView.layer setBorderWidth:0.0f];
    [self.containerViewPassword.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.containerViewPassword.layer setBorderWidth:0.0f];
    self.signInButton.backgroundColor = RED_DEEP;

}

- (IBAction)passBegin:(UITextField *)textfield
{
    textfield.alpha = 1;
    self.keyImageView.alpha = 1;

}
- (IBAction)endPassword:(UITextField *)textField {
    textField.alpha = 0.5;
    self.keyImageView.alpha = 0.5;

}

- (IBAction)endUsername:(UITextField *)textField {

    textField.alpha = 0.5;
    self.userImageView.alpha = 0.5;

}

- (IBAction)usernameBegin:(UITextField *)textfield {
    textfield.alpha = 1;
    self.userImageView.alpha = 1;
}


- (void)keyboardDidShow:(NSNotification *)notification
{
    [UIView animateWithDuration:1.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.2
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
                            CGRect rect = self.view.frame;
                            rect.origin.y -= 80;
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
                            rect.origin.y += 80;
                            [self.view setFrame:rect];
                            NSLog(@"entr");

                        } completion:^(BOOL finished) {
                            
                        }];
}

#pragma mark - FACEBOOK LOGIN

-(IBAction)faceLogin:(id)sender{
    
    FacebookLogin *login = [[FacebookLogin alloc] initWithDelegate:self];
    [login loginUser];    
    
    /* TOUCHID LOGIN JUNK
     
    NSUserDefaults *touchFb = [NSUserDefaults standardUserDefaults];
    NSString *touchFbString = [touchFb objectForKey:@"touchId"];
    
    if ([touchFbString isEqualToString:@"yes"]) {
     
    LAContext *context = [[LAContext alloc] init];
    
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                localizedReason:@"Are you the device owner?"
                          reply:^(BOOL success, NSError *error) {
                              
                              if (error) {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"There was a problem verifying your identity."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                                  return;
                              }
                              
                              if (success) {
                                 // UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                //                                                  message:@"You are the device owner!"
                               //                                                  delegate:nil
                               //                                         cancelButtonTitle:@"Ok"
                               //                                         otherButtonTitles:nil];
                               //   [alert show];
                                  
                                  [ProgressHUD show:@"Signing in..." Interaction:NO];
                                  
                                  [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
                                   {
                                       if (user != nil)
                                       {
                                           if (user[PF_USER_FACEBOOKID] == nil)
                                           {
                                               [self requestFacebook:user];
                                           }
                                           else [self userLoggedIn:user];
                                       }
                                       else [ProgressHUD showError:[error.userInfo valueForKey:@"error"]];
                                   }];
    
                              } else {
                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                  message:@"You are not the device owner."
                                                                                 delegate:nil
                                                                        cancelButtonTitle:@"Ok"
                                                                        otherButtonTitles:nil];
                                  [alert show];
                              }
                              
                          }];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Your device cannot authenticate using TouchID."
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
        [ProgressHUD show:@"Signing in..." Interaction:NO];
        
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
         {
             if (user != nil)
             {
                 if (user[PF_USER_FACEBOOKID] == nil)
                 {
                     [self requestFacebook:user];
                 }
                 else [self userLoggedIn:user];
             }
             else [ProgressHUD showError:[error.userInfo valueForKey:@"error"]];
         }];
   
    }
        
}
    
    if ([touchFbString isEqualToString:@"no"]) {
     
    [ProgressHUD show:@"Signing in..." Interaction:NO];
    
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             if (user[PF_USER_FACEBOOKID] == nil)
             {
                 [self requestFacebook:user];
             }
             else [self userLoggedIn:user];
         }
         else [ProgressHUD showError:[error.userInfo valueForKey:@"error"]];
     }];
        
    } --- END TOUCHID --- */
}

#pragma mark - FacebookLogin Delegate Methods

- (void)oldUserLoggedIn:(PFUser *)user
{
    [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_NICKNAME]]];
    [self performSegueWithIdentifier:@"login" sender:self];
}

- (void)newUserLoggedIn:(PFUser *)user
{
    [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome %@!", user[PF_USER_NICKNAME]]];
    [self performSegueWithIdentifier:@"login" sender:self];
}


@end
