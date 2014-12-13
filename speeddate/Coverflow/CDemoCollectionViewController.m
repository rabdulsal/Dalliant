
#import "CDemoCollectionViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>

//#import "CDemoCollectionViewCell.h"
//#import "CCoverflowCollectionViewLayout.h"
//#import "CReflectionView.h"
#import "UserParseHelper.h"
#import "PhotoCollectionViewCell.h"
#import "RageIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "utilities.h"

/* ----------------------------------------------------------------------------------------------
 -------------------------------------------------------------------------------------------------
 
 *** USER PROFILE IMAGES EDITING
 
 *** ADD FACEBOOK PROFILE IMAGES
 
 -------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------- */

@interface CDemoCollectionViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    
    NSArray *allproduct;
    int count;
    SKProduct *findProduct;
}
@property (readwrite, nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (readwrite, nonatomic, strong) NSMutableArray *assets;
@property (readwrite, nonatomic, strong) NSMutableArray *assets_thumb;
@property (readwrite, nonatomic, strong) NSCache *imageCache;
@property int selectedImage;
@property UserParseHelper *user;
@property int myCounter;
@end

@implementation CDemoCollectionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];

    self.assets = [NSMutableArray new];
    self.assets_thumb = [NSMutableArray new];
    PFQuery *query = [UserParseHelper query];
    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    [query getObjectInBackgroundWithId:[UserParseHelper currentUser].objectId
                                 block:^(PFObject *object, NSError *error)
     {
         UIImage *image = [UIImage imageNamed:@"userPlaceholder"]; // <-- Circle w/ plus-sign in middle; Replace w/ Facebook Profile Images
         for (int i = 0; i < 4; i++) {
             [self.assets addObject:image];
         }
         self.user = (UserParseHelper *)object;

// ---------------------------------- REPLACE WITH IMAGES FROM FACEBOOK ----------------------------------------
         
         self.user = (UserParseHelper *)object;
         [self.user.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:0 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
         [self.user.photo1 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:1 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
         [self.user.photo2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:2 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
         [self.user.photo3 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:3 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
         [self.user.photo4 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
             if (!error) {
[self.assets replaceObjectAtIndex:4 withObject:[UIImage imageWithData:data]];             }
             [self.collectionView reloadData];
         }];
     }];
}
// -------------------------------------------------------------------------------------------------------------

#pragma mark -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;
{
	return self.assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
	   PhotoCollectionViewCell*theCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"DEMO_CELL" forIndexPath:indexPath];

	if (theCell.gestureRecognizers.count == 0)
    {
		[theCell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCell:)]];
    }

    UIImage *theImage = [self.assets objectAtIndex:indexPath.row];
  
    theCell.imageView.image = theImage;
    theCell.backgroundColor = [UIColor clearColor];

	return(theCell);
}


#pragma mark - TAP PROFILE CELL

- (void)tapCell:(UITapGestureRecognizer *)inGestureRecognizer
{
	NSIndexPath *theIndexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)inGestureRecognizer.view];
    self.selectedImage = (int)theIndexPath.row;
    
    if ((int)theIndexPath.row == 0) {
        
        NSLog(@"Photo1");
        
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Photo profile" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo",@"Choose from library",@"Delete Photo",nil];
        [sheet showInView:self.parentViewController.view];
        
    }else {
        // VIP Check
        /*PFUser *chekUser = [PFUser currentUser];
        NSString *vip = chekUser[@"membervip"];
        if ([vip isEqualToString:@"vip"]) {*/
            
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Photo profile" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take photo",@"Choose from library",@"Delete Photo",nil];
            [sheet showInView:self.parentViewController.view];
            
        /*}else{
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Upss...." message:@"Additional photos are available only VIP users" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
        }*/
    }
}

#pragma mark - IMAGEPICKERCONTROLLER VIA ACTIONSHEET

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    
    if (buttonIndex == 0) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePickerController animated:YES completion:nil];
    }
    if (buttonIndex ==  1) {
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:imagePickerController animated:YES completion:nil];

    }
    if (buttonIndex == 2) { // Deletes Image
       
        UIImage *image = [UIImage imageNamed:@"nouserphoto.jpg"]; // <-- "No" sign User-image
        [self.assets replaceObjectAtIndex:self.selectedImage withObject:image];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedImage inSection:0];
        // Refactored code
        [self configureImage:image atIndexPath:indexPath];
        /*
        [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
         PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image,0.9)];
        
        //
        [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                return ;
            }
            switch (self.selectedImage) {
                case 1:
                    self.user.photo1 = file;
                    
                    break;
                case 2:
                    self.user.photo2 = file;
                    break;
                case 3:
                    self.user.photo3 = file;
                    break;
                case 4:
                    self.user.photo4 = file;
                    break;
                default:
                    self.user.photo = file;
                    
                    break;
            }
            [self.user saveInBackground];
           // [self.user deleteEventually];
            
        }];*/

    }
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    /// save original image
    [self.assets replaceObjectAtIndex:self.selectedImage withObject:image];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.selectedImage inSection:0];
    // Refactored code
    [self configureImage:image atIndexPath:indexPath];
    /*
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image,0.9)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            return ;
        }
        switch (self.selectedImage) {
            case 1:
                self.user.photo1 = file;
                break;
            case 2:
                self.user.photo2 = file;
                break;
            case 3:
                self.user.photo3 = file;
                break;
            case 4:
                self.user.photo4 = file;
                break;
            default:
                self.user.photo = file;
                break;
        }
        [self.user saveInBackground];
    }];*/
    
    ////// save thumb
    UIImage *image_thumb = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image_thumb.size.width > 140) image_thumb = ResizeImage(image_thumb, 140, 140);
    
  //  [self.assets_thumb replaceObjectAtIndex:self.selectedImage withObject:image];
    
    NSIndexPath *indexPath_thumb = [NSIndexPath indexPathForItem:self.selectedImage inSection:0];
    
    [self configureImage:image_thumb atIndexPath:indexPath_thumb];
    /*
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath_thumb]];
    PFFile *file_thumb = [PFFile fileWithData:UIImageJPEGRepresentation(image_thumb,0.9)];
    [file_thumb saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            return ;
        }
        switch (self.selectedImage) {
            case 1:
                self.user.photo1_thumb = file_thumb;
                break;
            case 2:
                self.user.photo2_thumb = file_thumb;
                break;
            case 3:
                self.user.photo3_thumb = file_thumb;
                break;
            case 4:
                self.user.photo4_thumb = file_thumb;
                break;
            default:
                self.user.photo_thumb = file_thumb;
                break;
        }
        [self.user saveInBackground];
    }]; */
}

- (void)configureImage:(UIImage *)image atIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    PFFile *file = [PFFile fileWithData:UIImageJPEGRepresentation(image,0.9)];
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            return ;
        }
        switch (self.selectedImage) {
            case 1:
                self.user.photo1 = file;
                break;
            case 2:
                self.user.photo2 = file;
                break;
            case 3:
                self.user.photo3 = file;
                break;
            case 4:
                self.user.photo4 = file;
                break;
            default:
                self.user.photo = file;
                break;
        }
        [self.user saveInBackground];
    }];
}


@end
