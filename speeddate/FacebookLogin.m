//
//  FacebookLogin.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 1/15/16.
//  Copyright © 2016 Studio76. All rights reserved.
//

#import "FacebookLogin.h"
#import "CustomSignInViewController.h"
#import "UserParseHelper.h"
#import "ProgressHUD.h"
#import "AFNetworking.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "AppConstant.h"
#import "utilities.h"

@interface FacebookLogin ()

@property (nonatomic) id <FaceBookLoginDelegate> loginDelegate;
@property (nonatomic) PFUser *user;
@property (nonatomic) NSInteger profilePhotosCount;
@property (nonatomic) NSMutableArray *fbImageAssets;
@property (nonatomic) NSDictionary *userData;
@property (nonatomic) FBSDKAccessToken *accessToken;

@end

@implementation FacebookLogin

@synthesize loginDelegate;

- (id)initWithDelegate:(id)delegate {
    
    if ((self = [super init])) {
        
        self.loginDelegate = delegate;
        
    }
    return self;
    
}


- (void)loginUser
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile", @"email", @"user_friends", @"user_birthday", @"user_about_me", @"user_education_history", @"user_work_history", @"user_photos", nil];
    //NSArray *permissions = @[];
    
    // Login PFUser using Facebook
    [ProgressHUD show:@"Signing in..." Interaction:NO];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser *user, NSError *error) {
        
        NSString *errorMessage = nil;
        if (user != nil)
        {
            self.user = user;
            if (_user[PF_USER_FACEBOOKID] == nil)
            {
                NSLog(@"User in new");
                [self requestFacebook];
            }
            else {
                NSLog(@"User is cached");
                //[self userLoggedIn:user];
                [loginDelegate oldUserLoggedIn:_user];
            }
        }
        
        else if (error)
            
        {
            if ([[[error userInfo] objectForKey:@"com.facebook.sdk:ErrorLoginFailedReason"]
                 isEqualToString:@"com.facebook.sdk:SystemLoginDisallowedWithoutError"])
            { // Facebook Login not allowed on Device
                NSLog(@"Uh oh. An error occurred: %@", error);
                errorMessage = @"Please go to Device Settings > Facebook > Toggle 'On' Allow Dalliant to Use Facebook";
                
                [ProgressHUD showError:errorMessage];
            }
            else {
                errorMessage = @"Ooops, an error occurred....please try logging-in again.";
                [ProgressHUD showError:errorMessage];
            }
            
        }
        /*
         if (!user) {
         NSLog(@"There is no User for some reason.");
         
         
         if (!error) {
         NSLog(@"Uh oh. The user cancelled the Facebook login.");
         errorMessage = @"Uh oh. The user cancelled the Facebook login.";
         
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
         
         } */
    }];
}

#pragma mark - Private Methods

- (void)requestFacebook
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me"
                                                                   parameters:nil
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
     {
         if (error == nil)
         {
             self.userData = (NSDictionary *)result;
             self.accessToken = [FBSDKAccessToken currentAccessToken];
             NSLog(@"Facebook Token: %@", _accessToken);
             [self processFacebook];
         }
         else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                   isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
             NSLog(@"The facebook session was invalidated");
             [PFUser logOut];
             [ProgressHUD showError:@"Failed to fetch Facebook user data."];
         }
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processFacebook
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"Process Facebook run");
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", _userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {/*
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
       }];*/
         //-----------------------------------------------------------------------------------------------------------------------------------------
         NSLog(@"AFNetworking operation started");
         [self fetchProfileAlbum:_userData[@"id"]];
         
         
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"AFNetworking failed");
         [PFUser logOut];
         [ProgressHUD showError:@"Failed to fetch Facebook profile picture."];
     }];
    //-----------------------------------------------------------------------------------------------------------------------------------------
    [[NSOperationQueue mainQueue] addOperation:operation];
    
}

- (void)fetchProfileAlbum:(NSString *)uid
{
    NSLog(@"Fetch Profile Album started");
    NSString *photosLink =[NSString stringWithFormat:@"https://graph.facebook.com/%@/albums?access_token=%@",uid,_accessToken];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photosLink]];
    NSLog(@"Photoslink: %@", photosLink);
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *allAlbums = [[NSArray alloc] initWithArray:(NSArray *)[(NSDictionary *)responseObject objectForKey:@"data"]];
        int allAlbumsCount = (int)allAlbums.count;
        
        for (int i=0; i < allAlbumsCount; i++) {
            NSString *album = [[[(NSDictionary *)responseObject objectForKey:@"data"] objectAtIndex:i] objectForKey:@"name"];
            NSLog(@"Fetch album: %@", album);
            if ([album isEqualToString:@"Profile Pictures"])
            {
                _profilePhotosCount = (int)[[[(NSDictionary *)responseObject objectForKey:@"data"] objectAtIndex:i] objectForKey:@"count"];
                //NSLog(@"Profile count: %@", _profilePhotosCount);
                [self fetchProfilePhotos:responseObject atIndex:i];
                i = allAlbumsCount;
            }
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)fetchProfilePhotos:(NSDictionary *)responseObject atIndex:(int)index
{
    NSString *albumid       = [[[responseObject objectForKey:@"data"]objectAtIndex:index]objectForKey:@"id"];
    NSString *albumUrl      = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos?type=album&access_token=%@",albumid,_accessToken];
    NSURLRequest *request2  = [NSURLRequest requestWithURL:[NSURL URLWithString:albumUrl]];
    NSLog(@"Photo URL: %@", albumUrl);
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request2];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        // Check the below URL in the browser - initialize Loop thru indices here
        //NSString *profilePicURL=[[[[[(NSDictionary *)responseObject objectForKey:@"data"]objectAtIndex:0]objectForKey:@"images"]objectAtIndex:0]objectForKey:@"source"];
        //NSLog(@"Pic URL: %@", profilePicURL);
        [self configureUserImageForResponse:(NSDictionary *)responseObject];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error.description);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)configureUserImageForResponse:(NSDictionary *)response // TODO: turn into public callback method on UserParseHelper
{
    
    NSInteger photoCount = 4;
    
    if (_profilePhotosCount < 4) {
        photoCount = _profilePhotosCount;
    }
    
    for (int i = 0; i < photoCount; i++) {
        // Get Pic URL
        NSString *picURL = [[[[[response objectForKey:@"data"]objectAtIndex:i]objectForKey:@"images"]objectAtIndex:1]objectForKey:@"source"];
        // Set Image (May need to make network request to retrieve Image)
        NSLog(@"PicString: %@", picURL);
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:picURL]];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *image = (UIImage *)responseObject;
            // Declare Pic name
            NSString *picName;
            [_fbImageAssets addObject:image];
            // Set Pic name based on image # iteration
            /*
             if (i == 0) {
             NSLog(@"Run i = 0");
             //-----------------------------------------------------------------------------------------------------------------------------------------
             if (image.size.width > 140) image = ResizeImage(image, 140, 140);
             //-----------------------------------------------------------------------------------------------------------------------------------------
             PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(image, 0.9)];
             [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
             if (error != nil) [ProgressHUD showError:@"Network error."];
             }];
             
             user[@"photo"] = filePicture;
             
             //-----------------------------------------------------------------------------------------------------------------------------------------
             if (image.size.width > 34) image = ResizeImage(image, 34, 34);
             //-----------------------------------------------------------------------------------------------------------------------------------------
             PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(image, 0.9)];
             [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
             if (error != nil) [ProgressHUD showError:@"Network error."];
             }];
             
             user[@"photo_thumb"] = fileThumbnail;
             
             }*/ /*else { <-- PROBABLY DELETE
                  picName = [[NSString alloc] initWithFormat:@"photo%@", [NSNumber numberWithInt:i]];
                  NSLog(@"picName: %@", picName);
                  // Store image as file then set user[picName]
                  //[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
                  PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image,0.9)];
                  [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                  if (succeeded) {
                  user[picName] = file;
                  NSLog(@"Saved User pic: %@", user[picName]);
                  } else [ProgressHUD showError:@"Network error."];
                  
                  }];
                  }*/
            
            if (i == 3) {//<-- must be changed to a variable looking at the last image available in an array
                NSLog(@"Run i = %d", i);
                if (image.size.width > 140) image = ResizeImage(image, 140, 140);
                PFFile *file = [PFFile fileWithName:@"photo.jpg" data:UIImageJPEGRepresentation(image, 0.9)];
                [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        _user[@"photo1"] = file;
                        
                    } else [ProgressHUD showError:@"Network error."];
                    
                }];
                
                _user[@"email"] = _userData[@"email"];
                _user[@"username"] = _userData[@"id"];
                //user[@"password"] = userData[@"id"];
                _user[@"nickname"] = _userData[@"first_name"];
                _user[@"distance"] = [NSNumber numberWithDouble:1.6];
                _user[@"sexuality"] = [NSNumber numberWithInt:2];
                // Age calculation
                _user[@"age"] = [NSNumber numberWithInteger:[UserParseHelper calculateUserAge:_userData[@"birthday"]]];
                // Gender
                if ([_userData[@"gender"] isEqualToString:@"male"]) {
                    _user[@"isMale"] = @"true";
                } else _user[@"isMale"] = @"false";
                // About
                if (_userData[@"bio"]) {
                    _user[@"desc"] = _userData[@"bio"];
                } else _user[@"desc"] = @"No Bio info";
                // Employment
                if (_userData[@"work"]) {
                    _user[@"work"] = _userData[@"work"];
                } else NSLog(@"No Work Data");
                // Education
                if (_userData[@"education"]) {
                    _user[@"school"] = _userData[@"education"];
                } else NSLog(@"No School Data");
                //user[@"photo"] = filePicture;
                _user[PF_USER_FACEBOOKID] = _userData[@"id"];
                //  user[PF_USER_FULLNAME] = userData[@"name"]; // <-- Be sure to uncomment
                // user[PF_USER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
                // user[PF_USER_FACEBOOKID] = userData[@"id"];
                // user[PF_USER_PICTURE] = filePicture;
                //user[@"photo_thumb"] = fileThumbnail; // <-- Be sure to uncomment
                if (_user[@"photo"]) {
                    NSLog(@"Photo exists");
                }else NSLog(@"Photo DOESN'T exist");
                if (_user[@"photo_thumb"]) {
                    NSLog(@"Photo Thumb exists");
                }else NSLog(@"Photo Thumb DOESN'T exist");
                NSLog(@"Image assets count: %ld", (unsigned long)[_fbImageAssets count]);
                [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     if (error == nil)
                     {
                         //  [self dismissViewControllerAnimated:YES completion:nil];
                         [loginDelegate newUserLoggedIn:_user];
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
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error.description);
        }];
        [[NSOperationQueue mainQueue] addOperation:operation];
    }
    
}

@end
