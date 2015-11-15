//
//  AppDelegate.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>
#import "RageIAPHelper.h"
#import "UserParseHelper.h"
#import "PossibleMatchHelper.h"
#import "MessageParse.h"
#import "ChatMessageViewController.h"
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [Parse setApplicationId:appIdparse
                  clientKey:appKeyparse];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
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
        
        // Updated: Payload should be id for PossibleMatchHelper, which can be used to fetch chatMessages array
        // Create Conversation from chatMessages array
        
        NSString *connectionId = [notificationPayload objectForKey:@"matchId"];
        PFQuery *connectionsQuery = [PossibleMatchHelper query];
        [connectionsQuery getObjectInBackgroundWithId:connectionId block:^(PFObject *object, NSError *error) {
            
            if (!error) {
                
                PossibleMatchHelper *connection = (PossibleMatchHelper *)object;
                PFRelation *conversation = [connection relationForKey:@"chatMessages"];
                
                [[conversation query] findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                    if (error) {
                        // There was an error
                    } else {
                        // objects has all the chatMessages the current user liked.
                        // instantiate ChatMessageVC and initialize with objects array
                        
                        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                        ChatMessageViewController *chatVC = (ChatMessageViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ChatMessagesVC"];
                        
                        for (UserParseHelper *user in connection.matches) {
                            
                            if (user != [PFUser currentUser]) {
                                chatVC.toUserParse = user;
                            } else {
                                chatVC.curUser = user;
                            }
                        }
                        
                        chatVC.fromConversation = true;
                        
                        UINavigationController *navController   = (UINavigationController *)self.window.rootViewController;
                        [navController.visibleViewController.navigationController pushViewController:chatVC animated:YES];
                        //[nav pushViewController:chatVC animated:YES];
                    }
                }];
            } else {
                // Handle error
            }
        }];
        
        /* ------ PUSH TO SWREVEALVC CODE --------- //
         
        UIStoryboard *st = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        DestinationController *descController = (DestinationController*)[st instantiateViewControllerWithIdentifier: @"storyboardID_DestController"];
        UINavigationController *frontNavigationController = [[UINavigationController alloc] initWithRootViewController:descController];
        SidebarViewController *rearViewController = (SidebarViewController*)[st instantiateViewControllerWithIdentifier: @"storyboardID_SidebarMenu"];
        
        RevealViewController *mainRevealController = [[SWRevealViewController alloc]  init];
        
        mainRevealController.rearViewController = rearViewController;
        mainRevealController.frontViewController= frontNavigationController;
        
        self.window.rootViewController = mainRevealController;
        
        // ----------------------------------------- */
        
        NSLog(@"Notification in AppDelegate: %@", [notificationPayload objectForKey:@"messageId"]);
        //Query if NotificationPayload is from Chat or ShareRequest based on string
        
        
        NSString *messageId   = [notificationPayload objectForKey:@"messageId"];
        PFQuery *messageQuery = [MessageParse query];
        
        [messageQuery getObjectInBackgroundWithId:messageId block:^(PFObject *object, NSError *error) {
            if (!error) {
                
                MessageParse *message                   = (MessageParse *)object;
                // Instantiate ViewController, set values and push
                //UINavigationController *navController   = (UINavigationController *)self.window.rootViewController;
                //ChatMessageViewController *chatVC       = [navController.storyboard instantiateViewControllerWithIdentifier:@"ChatPushNotificationView"];
                SWRevealViewController *navigationController = (SWRevealViewController *)self.window.rootViewController;
                UIStoryboard *mainStoryboard                 = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
                UINavigationController *nav                  = (UINavigationController *)navigationController.frontViewController;
                ChatMessageViewController *chatVC            = (ChatMessageViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ChatMessagesVC"];
                chatVC.toUserParse                           = message.toUserParse;
                chatVC.curUser                               = message.fromUserParse;
                chatVC.fromConversation                      = true;
                
                //[navController.visibleViewController.navigationController pushViewController:chatVC animated:YES];
                [nav pushViewController:chatVC animated:YES];
            }
        }];
         
        
        //PossibleMatchHelper *relationship = [notificationPayload objectForKey:@"relationship"];
        
    }
    
    //[[UINavigationBar appearance] setBarTintColor:BLUE_COLOR];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
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
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken {

//#if (TARGET_IPHONE_SIMULATOR)

//#else
    NSLog(@"updating pf installation");
    
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:newDeviceToken];
    //currentInstallation[@"user"] = [UserParseHelper currentUser].objectId;
    currentInstallation.channels = @[@"global"];
    [currentInstallation saveInBackground];
    NSLog(@"finish");
//#endif



}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    NSDictionary *userInfoAlert = [userInfo objectForKey:@"aps"];
    NSString *alertMessage      = [userInfoAlert objectForKey:@"alert"];
    
    if ([alertMessage isEqualToString:@"Request to Share Identities"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchRevealRequest" object:self userInfo:userInfo];
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"In-app Reveal Request" message:@"Request received in app" delegate:self cancelButtonTitle:@"Done" otherButtonTitles: @"Anzeigen", nil];
             [alert setTag: 2];
             [alert show];
        */
    } else if ([alertMessage isEqualToString:@"Identity Share Reply"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchRevealReply" object:self userInfo:userInfo];
        
    } else if ([alertMessage isEqualToString:@"Match Ended Chat"]) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"chatEnded" object:self];
        
    } else {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:receivedMessage object:userInfo];
        
    }
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
    NSLog(@"App Will Terminate");
}



@end
