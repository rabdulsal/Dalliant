//
//  UserCollectionViewCell.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "UserCollectionViewCell.h"

@implementation UserCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.photoImageView.contentMode = UIViewContentModeScaleAspectFill;
}

@end
