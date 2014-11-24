//
//  UserNearMeViewController.h
//  speeddate
//
//  Created by studio76 on 19.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserNearCollectionViewCell.h"

@interface UserNearMeViewController : UIViewController{
    
    NSArray *imageFilesArray;
    NSMutableArray *imagesArray;
    int sexy;
   
}

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollection;

@end
