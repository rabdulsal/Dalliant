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
#import "config.h"

@implementation AppDelegate
@synthesize userStart;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
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

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSNotification *)userInfo {
    [[NSNotificationCenter defaultCenter] postNotificationName:receivedMessage object:userInfo];
    //[PFPush handlePush:userInfo];
}

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
                    NSLog(@"go out2 success");
                    
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
    NSLog(@"go out1");
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

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"go out3");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"go out4");
}



@end
