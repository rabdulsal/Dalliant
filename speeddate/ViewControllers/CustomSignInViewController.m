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
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "utilities.h"
#import "AppConstant.h"
#import "MainViewController.h"

#ifdef __IPHONE_8_0
#import <LocalAuthentication/LocalAuthentication.h>
#endif


@interface CustomSignInViewController ()
{
    NSString *userImage;
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
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    [self.view addSubview:backgroundImage];
    [self.view sendSubviewToBack:backgroundImage];
    [self customizeView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

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
    
    NSArray *permissions = @[@"public_profile", @"email", @"user_friends", @"user_birthday", @"user_about_me", @"user_education_history", @"user_work_history", @"user_photos"];
    //NSArray *permissions = @[];
    
    // Login PFUser using Facebook
    [ProgressHUD show:@"Signing in..." Interaction:NO];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        if (!user) {
            NSString *errorMessage = nil;
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
                errorMessage = @"Uh oh. The user cancelled the Facebook login.";
            } else if ([[[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"]
                        isEqualToString:@"com.facebook.sdk:SystemLoginDisallowedWithoutError"])
            { // Facebook Login not allowed on Device
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = @"Please go to Device Settings > Facebook > Toggle 'On' Allow Dalliant to Use Facebook";
                
                [ProgressHUD showError:errorMessage];
            }
            else {
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = [error localizedDescription];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:nil
                                                      otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            
        } else {
            if (user != nil)
            {
                if (user[PF_USER_FACEBOOKID] == nil)
                {
                    [self requestFacebook:user];
                }
                else [self userLoggedIn:user];
            }
            else [ProgressHUD showError:[error.userInfo valueForKey:@"error"]];
        }
    }];
    
    
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
        
    }*/
}

- (void)requestFacebook:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (error == nil)
         {
             NSDictionary *userData = (NSDictionary *)result;
             [self processFacebook:user UserData:userData];
         }
         else
         {
             [PFUser logOut];
             [ProgressHUD showError:@"Failed to fetch Facebook user data."];
         }
     }];
}

#pragma mark - PROCESS FACEBOOK CALLBACK
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UIImage *image = (UIImage *)responseObject;
         //-----------------------------------------------------------------------------------------------------------------------------------------
         if (image.size.width > 140) image = ResizeImage(image, 140, 140);
         //-----------------------------------------------------------------------------------------------------------------------------------------
         PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.9)];
         [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) [ProgressHUD showError:@"Network error."];
          }];
         //-----------------------------------------------------------------------------------------------------------------------------------------
         if (image.size.width > 34) image = ResizeImage(image, 34, 34);
         //-----------------------------------------------------------------------------------------------------------------------------------------
         PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.9)];
         [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) [ProgressHUD showError:@"Network error."];
          }];
         //-----------------------------------------------------------------------------------------------------------------------------------------
         NSLog(@"UDATE - %@",userData);
         
         user[@"email"] = userData[@"email"];
         user[@"username"] = userData[@"id"];
         //user[@"password"] = userData[@"id"];
         user[@"nickname"] = userData[@"first_name"];
         user[@"distance"] = [NSNumber numberWithInt:100];
         user[@"sexuality"] = [NSNumber numberWithInt:2];
         // Age calculation
         user[@"age"] = [NSNumber numberWithInt:[self calculateUserAge:userData[@"birthday"]]];
         // Gender
         if ([userData[@"gender"] isEqualToString:@"male"]) {
             user[@"isMale"] = @"true";
         } else user[@"isMale"] = @"false";
         // About
         if (userData[@"bio"]) {
             user[@"desc"] = userData[@"bio"];
         } else user[@"desc"] = @"No Bio info";
         // Employment
         if (userData[@"work"]) {
             user[@"work"] = userData[@"work"];
             NSLog(@"Work: %@", [userData[@"work"] class]);
         } else NSLog(@"No Work Data");
         // Education
         if (userData[@"education"]) {
             user[@"school"] = userData[@"education"];
             NSLog(@"School: %@", [userData[@"education"] class]);
         } else NSLog(@"No School Data");
         user[@"photo"] = filePicture;
         user[PF_USER_FACEBOOKID] = userData[@"id"];
       //  user[PF_USER_FULLNAME] = userData[@"name"];
        // user[PF_USER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
        // user[PF_USER_FACEBOOKID] = userData[@"id"];
        // user[PF_USER_PICTURE] = filePicture;
         user[@"photo_thumb"] = fileThumbnail;
         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error == nil)
              {
                  [ProgressHUD dismiss];
                //  [self dismissViewControllerAnimated:YES completion:nil];
                   [self performSegueWithIdentifier:@"login" sender:self];
                //  _startScreen =[[MainViewController alloc]initWithNibName:@"Main" bundle:nil];
                 // [self presentViewController:_startScreen animated:YES completion:nil];
              }
              else
              {
                  [PFUser logOut];
                  [ProgressHUD showError:error.userInfo[@"error"]];
              }
          }];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [PFUser logOut];
         [ProgressHUD showError:@"Failed to fetch Facebook profile picture."];
     }];
    //-----------------------------------------------------------------------------------------------------------------------------------------
    [[NSOperationQueue mainQueue] addOperation:operation];
    
}

- (NSInteger)calculateUserAge:(NSString *)birthday
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"MM/dd/yyyy"];
    NSDate *birthdate = [formatter dateFromString:birthday];
    
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSYearCalendarUnit
                                       fromDate:birthdate
                                       toDate:now
                                       options:0];
    return [ageComponents year];
}

#pragma mark - FETCH FACEBOOK PROFILE PHOTOS

- (void)fetchProfilePhotosForUser:(NSDictionary *)userData
{
    // Link for Profile Album Photos
    NSString *link = @"https://graph.facebook.com/[uid]/albums?access_token=[AUTH_TOKEN]";
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)userLoggedIn:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_NICKNAME]]];
   // [self dismissViewControllerAnimated:YES completion:nil];
     [self performSegueWithIdentifier:@"login" sender:self];
    //_startScreen =[[MainViewController alloc]initWithNibName:@"Main" bundle:nil];
   // [self presentViewController:_startScreen animated:YES completion:nil];
}


@end
