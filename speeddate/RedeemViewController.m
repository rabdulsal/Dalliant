//
//  RedeemViewController.m
//  speeddate
//
//  Created by Rashad Abdul-Salaam on 5/5/15.
//  Copyright (c) 2015 Studio76. All rights reserved.
//

#import "RedeemViewController.h"
#import <SCLAlertView.h>
#import "ProgressHUD.h"

@interface RedeemViewController ()

@property NSTimer *changeBgColourTimer;
@property NSTimer *vcView;
@property NSInteger num;

@end

@implementation RedeemViewController

- (void)showPrizeUI {
    NSString *redeemCode = [NSString stringWithFormat:@"Code: %@", _prizeID];
    
    // Eventually move into a medthod, and implement within redeemPrize Blocks and start an Activity Indicator
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    [alert showWaiting:self title:redeemCode subTitle:@"Enjoy your drink, and have fun matching on Dalliant!" closeButtonTitle:nil duration:10.0f];
    
    // Set up a repeating timer.
    // This is a property,
    NSTimer *vcView = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(closeView) userInfo:nil repeats:NO];
    self.changeBgColourTimer = [NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(changeColour) userInfo:nil repeats:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set up the initial background colour
    self.view.backgroundColor = [UIColor redColor];
    _num = 0;
    [ProgressHUD showSuccess:nil];
    [self redeemPrize];
    
    
}

- (void)changeColour
{
    // Don't just change the colour - give it a little animation.
    [UIView animateWithDuration:0.25 animations:^{
        // No need to set a flag, just test the current colour.
        /*
        if ([self.view.backgroundColor isEqual:[UIColor redColor]]) {
            self.view.backgroundColor = [UIColor greenColor];
        } else {
            self.view.backgroundColor = [UIColor redColor];
        }
         */
        //while (_num < 4) {
            switch (_num) {
                case 0:
                    _num = 1;
                    self.view.backgroundColor = [UIColor orangeColor];
                    break;
                case 1:
                    _num = 2;
                    self.view.backgroundColor = [UIColor yellowColor];
                    break;
                case 2:
                    _num = 3;
                    self.view.backgroundColor = [UIColor blueColor];
                    break;
                case 3:
                    _num = 4;
                    self.view.backgroundColor = [UIColor purpleColor];
                    break;
                case 4:
                    _num = 0;
                    self.view.backgroundColor = [UIColor redColor];
                default:
                    break;
            }
        //}
        
    }];
    
    // Now we're done with the timer.
    /*
    [self.changeBgColourTimer invalidate];
    self.changeBgColourTimer = nil;
     */
}

- (void)redeemPrize
{
    if ([_matchRedmption.toUser isEqual:self.currentUser] && ![self.matchRedmption.toUserRedeem isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        
        self.matchRedmption.toUserRedeem = [NSNumber numberWithBool:YES];
        [self.matchRedmption saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                // Here and below, stop Activity Indicator, run PrizeUI
                [ProgressHUD dismiss];
                [self showPrizeUI];
                NSLog(@"ToUser Redeemed");
            }
        }];
        
    } else if ([self.matchRedmption.fromUser isEqual:self.currentUser] && ![self.matchRedmption.fromUserRedeem isEqualToNumber:[NSNumber numberWithInt:YES]]) {
        
        self.matchRedmption.fromUserRedeem = [NSNumber numberWithBool:YES];
        [self.matchRedmption saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                [ProgressHUD dismiss];
                [self showPrizeUI];
                NSLog(@"FromUser Redeemed");
            }
            
        }];
    }
}

- (void)closeView
{
    [self.changeBgColourTimer invalidate];
    self.changeBgColourTimer = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
