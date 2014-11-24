//
//  SidebarTableViewController.h
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>

@interface SidebarTableViewController : UITableViewController<UIDocumentInteractionControllerDelegate, MFMailComposeViewControllerDelegate>

@property (retain)UIDocumentInteractionController *documentController;

@end
