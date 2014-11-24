//
//  MyAppViewController.h
//  WallpaperzSocial
//
//  Created by studio76 on 14.08.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyAppViewController : UITableViewController {
    
 
    NSArray *news;
     NSDictionary *allData;
}



@property (strong, nonatomic) NSArray *news;
@property (nonatomic,retain) NSDictionary *allData;
@property (nonatomic,retain) IBOutlet UIBarButtonItem  *menuBtn;
@end
