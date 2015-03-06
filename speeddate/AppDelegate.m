//
//  AppDelegate.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "AppDelegate.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "RageIAPHelper.h"
#import "UserParseHelper.h"
#import "PossibleMatchHelper.h"
#import "UserMessagesViewController.h"
#import "config.h"

@implementation AppDelegate
@synthesize userStart;

// Disable Custom Keyboards
- (BOOL)application:(UIApplication *)application shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier {
    if ([extensionPointIdentifier isEqualToString: UIApplicationKeyboardExtensionPointIdentifier]) {
        return NO;
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:appIdparse
                  clientKey:appKeyparse];
    [PFFacebookUtils initializeFacebook];
    
    // Track Application opens
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
    
    NSDictionary *notificationPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationPayload) {
        
        // Get Match and Relationship
        UserParseHelper *match = [notificationPayload objectForKey:@"match"];
        //PossibleMatchHelper *relationship = [notificationPayload objectForKey:@"relationship"];
        
        // Instantiate ViewController, set values and push
        UserMessagesViewController *vc = [[UserMessagesViewController alloc] init];
        vc.toUserParse = match;
        //vc.matchedUsers = relationship;
        [self.navController pushViewController:vc animated:YES];
    }
    
   
    [[UINavigationBar appearance] setBarTintColor:BLUE_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:[NSDictionary
                             dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil]
     forState:UIControlStateNormal];
    
   // [RageIAPHelper sharedInstance];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    NSUserDefaults *startUser = [NSUserDefaults standardUserDefaults];
    
    NSString *tch = [startUser objectForKey:@"touchId"];
    if ([tch isEqualToString:@"yes"]) {
        
    } else{
        
        [startUser setObject:@"no" forKey:@"touchId"];
        [startUser synchronize];
        
    }
    
    
    
    if ([PFUser currentUser]) {
        PFQuery *usr = [UserParseHelper query];
        [usr whereKey:@"objectId" equalTo:[UserParseHelper currentUser].objectId];
        [usr findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.userStart = [UserParseHelper alloc];
            self.userStart = objects.firstObject;
            self.userStart.online = @"yes";
            [self.userStart saveEventually];
            
        }];
    }
        
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //[FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {

#if (TARGET_IPHONE_SIMULATOR)

#else
    NSLog(@"updating pf installation");
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
    NSLog(@"finish");
#endif



}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    /*
    NSDictionary *userInfoAlert = [userInfo objectForKey:@"aps"];
    NSString *alertMessage = [userInfoAlert objectForKey:@"alert"];
    
    if ([alertMessage isEqualToString:@"Request to Share Identities"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Fetch Reveal Request" object:self];*/
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In-app Reveal Request" message:@"Request received in app" delegate:self cancelButtonTitle:@"Done" otherButtonTitles: @"Anzeigen", nil];
             [alert setTag: 2];
             [alert show];
        */
    /*} else if ([alertMessage isEqualToString:@"Identity Share Reply"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Fetch Reveal Reply" object:self];*/
  //  } else {
    NSLog(@"Did Receive Remote Notification started");
        [[NSNotificationCenter defaultCenter] postNotificationName:receivedMessage object:userInfo];
        NSLog(@"Did Receive Remote Notification ended");
   // }
}
/*
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler
{
    [[NSNotificationCenter defaultCenter] postNotificationName:receivedMessage object:userInfo];
    //[PFPush handlePush:userInfo];

 
 
    }
     else {
     // Push Notification received in the background
     
     }
    
} else {
    
    
}


     
    handler(UIBackgroundFetchResultNewData);
}*/

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    
   // UIApplication * applicationz = [UIApplication sharedApplication];
    
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)])
    {
        NSLog(@"Multitasking Supported");
        
        __block UIBackgroundTaskIdentifier background_task;
        background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
            
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
        }];
        
        //To make the code block asynchronous
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //### background task starts
            NSLog(@"Running in the background\n");
            
            NSLog(@"go out2");
            if ([PFUser currentUser]) {
                PFQuery *usr = [UserParseHelper query];
                self.userStart = [UserParseHelper alloc];
                [usr whereKey:@"objectId" equalTo:[UserParseHelper currentUser].objectId];
                [usr findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    self.userStart = [UserParseHelper alloc];
                    self.userStart = objects.firstObject;
                    self.userStart.online = @"no";
                    [self.userStart saveEventually];
                    NSLog(@"backgrounding success");
                    
                }];
            }
          //  while(TRUE)
           // {
           //     NSLog(@"Background time Remaining: %f",[[UIApplication sharedApplication] backgroundTimeRemaining]);
           //     [NSThread sleepForTimeInterval:1]; //wait for 1 sec
          //  }
            //#### background task ends
            
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid; 
        });
    }
    else
    {
        NSLog(@"Multitasking Not Supported");
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"App Did Enter Background");
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
  /*  if ([PFUser currentUser]) {
        PFQuery *usr = [UserParseHelper query];
        
        self.userStart = [UserParseHelper alloc];
        [usr whereKey:@"objectId" equalTo:[UserParseHelper currentUser].objectId];
        [usr findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            self.userStart = [UserParseHelper alloc];
            self.userStart = objects.firstObject;
            self.userStart.online = @"no";
            [self.userStart saveEventually];
            NSLog(@"save user offline");
            
        }];
    } */

}

#pragma mark - State Resoration Opt-In
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder;
{
    return YES;
}
- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder;
{
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[PFFacebookUtils session] close];
    NSLog(@"App Will Terminate");
}



@end
