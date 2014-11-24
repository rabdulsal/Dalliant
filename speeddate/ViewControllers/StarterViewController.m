#import "StarterViewController.h"

@interface StarterViewController () <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>

@end

@implementation StarterViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![PFUser currentUser]) {
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    } else {
        [self performSegueWithIdentifier:@"mainVC" sender:nil];
    }
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user

{
    [signUpController dismissViewControllerAnimated:YES completion:nil];
}



- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user

{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
