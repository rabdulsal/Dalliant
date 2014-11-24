//
//  UserNearCollectionViewCell.h
//  speeddate
//
//  Created by studio76 on 19.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserNearCollectionViewCell : UICollectionViewCell{
    
    UIImageView *profileImage;
    UILabel *distance;
    UILabel *agez;
    UIActivityIndicatorView *loading;
    UIImageView *online;
}
@property (nonatomic,retain) IBOutlet UIImageView *profileImage;
@property (nonatomic,retain) IBOutlet UILabel *distance;
@property (nonatomic,retain) IBOutlet UILabel *agez;
@property (nonatomic,retain) IBOutlet UIActivityIndicatorView *loading;
@property (nonatomic,retain) IBOutlet UIImageView *online;
@end
