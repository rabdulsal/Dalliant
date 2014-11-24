//
//  PurchaseHelper.m
//  speeddate
//
//  Created by studio76 on 12.10.14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "PurchaseHelper.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>

@implementation PurchaseHelper
    
    



-(void)checkPurcaseVipMemberHelper{
    
   
        
        [[RageIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
            if (success) {
                allproduct = products;
                
                count = (int)products.count;
                for (int i=0; i<count; i++) {
                    findProduct = [products objectAtIndex:i];
                    if ([[RageIAPHelper sharedInstance] productPurchased:findProduct.productIdentifier]) {
                        
                        NSLog(@"subscribe Yeee On Appdelegate!!");
                        
                        
                        break;
                        
                    } else{
                        
                      
                    }
                    
                };
                
            }
            
        }];
   
    
}
    


@end
