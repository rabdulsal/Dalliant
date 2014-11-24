//
//  PurchaseHelper.h
//  speeddate
//
//  Created by studio76 on 12.10.14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PurchaseHelper : NSObject{
    
    NSArray *allproduct;
    int count;
    SKProduct *findProduct;

}

-(void) checkPurcaseVipMemberHelper;

@end
