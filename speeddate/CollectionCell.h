//
//  CollectionCell.h
//  WallpaperzSocial
//
//  Created by studio76 on 17.08.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionCell : UICollectionViewCell {
    
    UIImageView *photoImage;
   
}

@property (nonatomic,retain) IBOutlet UIImageView *photoImage;

@property (nonatomic, weak) NSString *key;
@property (nonatomic, weak) PFObject *obj;

@end
