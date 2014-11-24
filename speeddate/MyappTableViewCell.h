//
//  MyappTableViewCell.h
//  WallpaperzSocial
//
//  Created by studio76 on 14.08.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyappTableViewCell : UITableViewCell {
    
    UILabel *nameApp;
    UILabel *priceApp;
    UILabel *categoryApp;
    UIImageView *iconApp;
}

@property (nonatomic,retain) IBOutlet UILabel *nameApp;
@property (nonatomic,retain) IBOutlet UILabel *priceApp;
@property (nonatomic,retain) IBOutlet UILabel *categoryApp;
@property (nonatomic,retain) IBOutlet UIImageView *iconApp;

@end
