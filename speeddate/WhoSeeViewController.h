//
//  WhoSeeViewController.h
//  speeddate
//
//  Created by studio76 on 21.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WhoSeeViewController : UIViewController{
    
    
    NSArray *userFilesArray;
    NSMutableArray *userArray;
    int sexy;
}

@property (weak, nonatomic) IBOutlet UICollectionView *whoCollectionView;

@end
