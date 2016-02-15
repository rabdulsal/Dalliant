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
#import "User.h"

@interface FacebookLogin () {
    User *mainUser;
}

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
        mainUser = [User singleObj];
    }
    return self;
    
}


- (void)loginUser
{
    NSArray *permissions = [[NSArray alloc] initWithObjects:@"public_profile", @"email", @"user_friends", @"user_birthday", @"user_about_me", @"user_education_history", @"user_work_history", @"user_photos", nil];
    //NSArray *permissions = @[];
    
    // Login PFUser using Facebook
    [ProgressHUD show:@"Signing in..." Interaction:NO];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        
        NSString *errorMessage = nil;
        if (user != nil)
        {
            self.user = user;
            if (_user[PF_USER_FACEBOOKID] == nil)
            {
                // New USer
                [self requestFacebook];
            }
            else { // Comment-out for testing

                // Old User
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
    }];
}

#pragma mark - Private Methods

- (void)requestFacebook
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"/me?fields=birthday,first_name,bio,work,email,photos"
                                                                   parameters:nil
                                                                   HTTPMethod:@"GET"];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
     {
         if (error == nil)
         {
             self.userData = (NSDictionary *)result;
             self.accessToken = [FBSDKAccessToken currentAccessToken];
             NSLog(@"Facebook Token: %@", _accessToken);
             [self processFacebookDataWithCompletion:^(BOOL success, NSError *error) {
                 if (success) {
                     [loginDelegate newUserLoggedIn:_user];
                 } else {
                     [PFUser logOut];
                     [ProgressHUD showError:error.userInfo[@"error"]];
                 }
             }];
         }
         else if ([[[[error userInfo] objectForKey:@"error"] objectForKey:@"type"]
                   isEqualToString: @"OAuthException"]) { // Since the request failed, we can check if it was due to an invalid session
             NSLog(@"The facebook session was invalidated");
             [PFUser logOut];
             [ProgressHUD showError:@"Failed to fetch Facebook user data."];
         }
     }];
}

- (void)processFacebookDataWithCompletion:(void(^)(BOOL success, NSError *error))callBack
{
    // Load User Info
    [self configureUserInfoWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            callBack(success,nil);
        } else {
            callBack(!success,error);
        }
    }];
    
    // Fetch and store Album photos
}

- (void)configureUserInfoWithCompletion:(void(^)(BOOL success, NSError *error))callBack
{
    _user[@"email"]     = _userData[@"email"];
    _user[@"username"]  = _userData[@"id"];
    //user[@"password"] = userData[@"id"];
    _user[@"nickname"]  = _userData[@"first_name"];
    _user[@"distance"]  = [NSNumber numberWithDouble:1.6];
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
    [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        
        if (!error)
         {
             [self getFacebookPhotosWithCompletion:^(BOOL photosRetrieved, NSArray *photos, NSError *error) {
                 if (photosRetrieved) {
                     
                     // Loop through photos and save to Parse/add to Singleton
                     [self processFacebookPhotos:photos withCompletion:^(BOOL photoProcessed, NSError *error) {
                         if (photoProcessed) {
                             
                             // Trigger callBack
                             callBack(photoProcessed,nil);
                         } else callBack(!photoProcessed,error);
                     }];
                 } else callBack(!photosRetrieved,error);
             }];
         }
         else callBack(!succeeded, error);
     }];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processFacebook // Only fetches Large Photo?
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
         //[self fetchProfileAlbum:_userData[@"id"]];
         
         
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

- (void)getFacebookPhotosWithCompletion:(void(^)(BOOL photosRetrieved, NSArray *photos, NSError *error))callBack
{
    [self fetchProfileAlbumWithCompletion:^(BOOL albumFetched, NSArray *profilePhotos, NSError *error) {
        if (albumFetched) {
            callBack(albumFetched,profilePhotos,nil);
        } else {
            callBack(!albumFetched,nil,error);
        }
    }];
}

- (void)processFacebookPhotos:(NSArray *)facebookPhotos withCompletion:(void(^)(BOOL photoProcessed, NSError *error))callBack
{
//    for (int i=0; i < [facebookPhotos count]; i++) {
//        
//        UIImage *photo = facebookPhotos[i];
//        NSString *pPhotoStr = [NSString stringWithFormat:@"photo%d",i];
//        
//        if (photo.size.width > 140) photo = ResizeImage(photo, 140, 140);
//        
//        PFFile *file = [PFFile fileWithName:pPhotoStr data:UIImageJPEGRepresentation(photo, 0.9)];
//        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            if (succeeded) {
//                
//                NSString *uPhotoStr = [NSString stringWithFormat:@"photo%d",i+1];
//                _user[uPhotoStr] = file;
//                callBack(succeeded,nil);
//                
//            } else callBack(!succeeded,error);
//            
//        }];
//    }
    
    mainUser.imageAssets = _fbImageAssets;
    if ([mainUser.imageAssets count] > 0) {
        callBack(true,nil);
    } else callBack (false, nil);
    
}

- (void)fetchProfileAlbumWithCompletion:(void(^)(BOOL albumFetched, NSArray *profilePhotos, NSError *error))callBack
{
    NSString *photosLink =[NSString stringWithFormat:@"https://graph.facebook.com/%@/albums?access_token=%@",_userData[@"id"],[_accessToken tokenString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:photosLink]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSArray *allAlbums = [[NSArray alloc] initWithArray:(NSArray *)[(NSDictionary *)responseObject objectForKey:@"data"]];
        int allAlbumsCount = (int)allAlbums.count;
        
        for (int i=0; i < allAlbumsCount; i++) {
            NSString *album = [[[(NSDictionary *)responseObject objectForKey:@"data"] objectAtIndex:i] objectForKey:@"name"];
            
            if ([album isEqualToString:@"Profile Pictures"])
            {
                _profilePhotosCount = (int)[[[(NSDictionary *)responseObject objectForKey:@"data"] objectAtIndex:i] objectForKey:@"count"]; // Cache value and use to check if there are new FB Profile Photos
                
                [self fetchProfilePhotos:responseObject atIndex:i withCompletion:^(BOOL photosFetched, NSArray *albumPhotos, NSError *error) {
                    if (photosFetched) {
                        callBack(photosFetched,albumPhotos,nil);
                    } else {
                        callBack(!photosFetched,nil,error);
                    }
                }];
                break;
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callBack(false,nil,error);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)fetchProfilePhotos:(NSDictionary *)responseObject atIndex:(int)index withCompletion:(void(^)(BOOL photosFetched, NSArray *albumPhotos, NSError *error))callBack
{
    NSString *albumid       = [[[responseObject objectForKey:@"data"]objectAtIndex:index]objectForKey:@"id"];
    NSString *albumUrl      = [NSString stringWithFormat:@"https://graph.facebook.com/%@/photos?type=album&access_token=%@",albumid,[_accessToken tokenString]];
    NSURLRequest *albumReq  = [NSURLRequest requestWithURL:[NSURL URLWithString:albumUrl]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:albumReq];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [self configureUserImageForResponse:(NSDictionary *)responseObject withCompletion:^(BOOL photosSaved, NSArray *albumPhotos, NSError *error) {
            if (photosSaved) {
                callBack(photosSaved,albumPhotos,nil);
            } else callBack(!photosSaved,nil,error);
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        callBack(false,nil,error);
    }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)configureUserImageForResponse:(NSDictionary *)response withCompletion:(void(^)(BOOL photosSaved, NSArray *albumPhotos, NSError *error))callBack // TODO: turn into public callback method on UserParseHelper
{
    _fbImageAssets = [NSMutableArray new];
    NSInteger photoCount = _profilePhotosCount < 4 ? _profilePhotosCount : 4;

    for (int i = 0; i < photoCount; i++) {
        // Get Pic URL
        NSString *picURL = [[[[[response objectForKey:@"data"]objectAtIndex:i]objectForKey:@"images"]objectAtIndex:1]objectForKey:@"source"];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:picURL]];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFImageResponseSerializer serializer];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            UIImage *image = (UIImage *)responseObject;
            
            [_fbImageAssets addObject:image];
            
            if (i == 3) {//<-- must be changed to a variable looking at the last image available in an array
                
                callBack([_fbImageAssets count] > 0,_fbImageAssets,nil);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            callBack(false,nil,error);
        }];
        [[NSOperationQueue mainQueue] addOperation:operation];
    }
    
}

@end
