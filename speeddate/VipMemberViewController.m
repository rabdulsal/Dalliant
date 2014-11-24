//
//  VipMemberViewController.m
//  speeddate
//
//  Created by studio76 on 06.10.14.
//  Copyright (c) 2014 ivan. All rights reserved.
//

#import "VipMemberViewController.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
//#import "PurchaseHelper.h"
#import "SWRevealViewController.h"

@interface VipMemberViewController ()<UINavigationControllerDelegate>{
    
    SKProduct *findProduct;
    UIImageView *logoMember;
    NSArray *allproduct;
}

@property (nonatomic,retain) IBOutlet UIBarButtonItem  *menuBtn;


@property (nonatomic,retain) IBOutlet UIImageView *logoMember;

@end

@implementation VipMemberViewController
@synthesize logoMember;



- (void)viewDidLoad {
    [super viewDidLoad];
    
    _menuBtn.target = self.revealViewController;
     _menuBtn.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
     UINavigationBar *navigationBar = self.navigationController.navigationBar;
    [navigationBar setShadowImage:[UIImage new]];
    
    [self reload];
    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reload {
   
    
    PFUser *chekUser = [PFUser currentUser];
    NSString *vip = chekUser[@"membervip"];
    if ([vip isEqualToString:@"vip"]) {
        
        [logoMember setImage:[UIImage imageNamed:@"mvip.png"]];
        
    }else{
        
        [logoMember setImage:[UIImage imageNamed:@"mnvip.png"]];
        
    }
    

}



- (void)viewWillAppear:(BOOL)animated {
  
    
  
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
