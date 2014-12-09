//
//  UserProfileViewController.m
//  speeddate
//
//  Created by studio76 on 20.10.14.
//  Copyright (c) 2014 Studio76. All rights reserved.
//

#import "UserProfileViewController.h"
#import "UserMessagesViewController.h"
#import "UIImageView+WebCache.h"
#import "WhoSeeMeHelper.h"
#import "MBProgressHUD.h"

/*
 _profilePhoto has not been set
 */

@interface UserProfileViewController ()<MBProgressHUDDelegate,UIActionSheetDelegate>{
    
    
}

@property (nonatomic,strong) WhoSeeMeHelper *whosee;
@property (nonatomic,retain) IBOutlet UIView *photoView;
@property (readwrite, nonatomic, strong) NSMutableArray *assetsPhoto;
@property (nonatomic,strong) IBOutlet UIScrollView *photoScroll;
@property (nonatomic,strong) UserParseHelper *photoUser;
@property (nonatomic,retain) MBProgressHUD *hud;
@property (nonatomic,retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic,retain) IBOutlet UILabel *statuses;


@end

@implementation UserProfileViewController
@synthesize mainUser, profileImage,photoUserArray,nameUser,ageUser,descriptionUser,loadImageView;



- (void)viewDidLoad {
    [super viewDidLoad];
    
   self.photoScroll.delegate = self;
    self.hud.delegate = self;

   self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    PFQuery *seeUserQuery = [UserParseHelper query];
    [seeUserQuery whereKey:@"objectId" equalTo:self.userId];
    
    [seeUserQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
      
        self.mainUser = [UserParseHelper alloc];
        self.mainUser  = objects.firstObject;
        nameUser.text = mainUser.nickname;
        ageUser.text = [NSString stringWithFormat:@"%@",mainUser.age];
        descriptionUser.text = mainUser.desc;

        // Set profileImage - Fbook photo blurry
        [mainUser.photo getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            UIImage *userImage = [[UIImage alloc] initWithData:data];
            profileImage.image = userImage;
        }];
        
        if ([self.status isEqualToString:@"yes"]) {
            self.statuses.text = @"online";
            self.statuses.textColor = [UIColor greenColor];
        }
        if ([self.status isEqualToString:@"no"]) {
            self.statuses.text = @"offline";
            self.statuses.textColor = [UIColor redColor];
        }
        
       self.assetsPhoto =[[NSMutableArray alloc]init];
        
        WhoSeeMeHelper *see = [WhoSeeMeHelper object];
        
        see.userSee = [UserParseHelper currentUser].objectId;
        see.seeUser = mainUser.objectId;
        [see saveInBackground];
      
    }];
    
    self.pageControl.numberOfPages = 1;
    
}

-(void)viewDidAppear:(BOOL)animated{
    
    [self createGallery];
    
    NSLog(@"Out");
}

-(void)viewWillAppear:(BOOL)animated{
    
  
}

-(void)createGallery{
    
     self.pageControl.numberOfPages = (int)self.getPhotoArray.count;
    
    
     for(int i=10;i<(int)self.getPhotoArray.count;++i){
    
         self.photoScroll.contentSize = CGSizeMake(320 *(int)self.getPhotoArray.count, self.photoScroll.frame.size.height);
         self.photoScroll.pagingEnabled = YES;
         
         if (i==0) {
             NSURL *mainUrl = [NSURL URLWithString:[self.getPhotoArray objectAtIndex:i]];
             
             [SDWebImageDownloader.sharedDownloader downloadImageWithURL:mainUrl
                                                                 options:0
                                                                progress:^(NSInteger receivedSize, NSInteger expectedSize)
              {
                  _hud = [MBProgressHUD showHUDAddedTo:self.photoScroll animated:YES];
                  _hud.mode = MBProgressHUDModeAnnularDeterminate;
                  _hud.labelText = @"Loading";
                  
                      _hud.progress = (float)  receivedSize/expectedSize;
                  
              }
                                                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
              {
                  if (image && finished)
                  {
                      [_hud hide:YES];
                     
                       UIImage *imagez = image;
                       UIImageView *addImage = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 320, self.photoScroll.frame.size.height)];
                      addImage.contentMode = UIViewContentModeScaleAspectFill;
                      addImage.clipsToBounds = YES;
                      [addImage setImage:imagez];
                      [self.photoScroll addSubview:addImage];
                      
                  }
              }];
            
         }
         
         if (i==1) {
             
             NSURL *mainUrl = [NSURL URLWithString:[self.getPhotoArray objectAtIndex:i]];
             
             [SDWebImageDownloader.sharedDownloader downloadImageWithURL:mainUrl
                                                                 options:0
                                                                progress:^(NSInteger receivedSize, NSInteger expectedSize)
              {
                 
              }
                                                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
              {
                  if (image && finished)
                  {
                      [_hud hide:YES];
                      
                      UIImage *image1 = image;
                      UIImageView *addImage1 = [[UIImageView alloc] initWithFrame:CGRectMake(0+320,0, 320, self.photoScroll.frame.size.height)];
                      addImage1.contentMode = UIViewContentModeScaleAspectFill;
                      addImage1.clipsToBounds = YES;
                      [addImage1 setImage:image1];
                      [self.photoScroll addSubview:addImage1];
                  }
              }];
         }
         
         if (i==2) {
             
             NSURL *mainUrl = [NSURL URLWithString:[self.getPhotoArray objectAtIndex:i]];
             
             [SDWebImageDownloader.sharedDownloader downloadImageWithURL:mainUrl
                                                                 options:0
                                                                progress:^(NSInteger receivedSize, NSInteger expectedSize)
              {
                  
              }
                                                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
              {
                  if (image && finished)
                  {
                      UIImage *image2 = image;
                      UIImageView *addImage2 = [[UIImageView alloc] initWithFrame:CGRectMake(0+640,0, 320, self.photoScroll.frame.size.height)];
                      addImage2.contentMode = UIViewContentModeScaleAspectFill;
                      addImage2.clipsToBounds = YES;
                      [addImage2 setImage:image2];
                      [self.photoScroll addSubview:addImage2];
                  }
              }];
            
         }
         if (i == 3) {
             
             NSURL *mainUrl1 = [NSURL URLWithString:[self.getPhotoArray objectAtIndex:i]];
                 
             [SDWebImageDownloader.sharedDownloader downloadImageWithURL:mainUrl1
                                                                 options:0
                                                                progress:^(NSInteger receivedSize, NSInteger expectedSize)
              {
                  
              }
                                                               completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished)
              {
                  if (image && finished)
                  {
                      
                   
                      UIImage *image3 = image;
                      UIImageView *addImage3 = [[UIImageView alloc] initWithFrame:CGRectMake(0+960,0, 320, self.photoScroll.frame.size.height)];
                      addImage3.contentMode = UIViewContentModeScaleAspectFill;
                      addImage3.clipsToBounds = YES;
                      [addImage3 setImage:image3];
                      [self.photoScroll addSubview:addImage3];
                  
                  }
              }];
                 
             }
         }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(IBAction)chat:(id)sender{
    
    
    
}

- (IBAction)closeProfileView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chatProfile"]) {
        UserMessagesViewController *vc = segue.destinationViewController;
        
            vc.toUserParse = mainUser;
        
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    CGFloat pageWidth = self.photoScroll.frame.size.width;
    CGFloat pageWidtall =  self.photoScroll.contentSize.width;
    int page = floor((self.photoScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    int allpage = floor(pageWidtall/320);
    self.pageControl.currentPage = page;
    self.pageControl.numberOfPages = allpage;
}

- (IBAction)changePage {
    
    CGRect frame;
    frame.origin.x = self.photoScroll.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.photoScroll.frame.size;
    [self.photoScroll scrollRectToVisible:frame animated:YES];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // pageControlBeingUsed = NO;
}

-(IBAction)report:(id)sender{
    
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Report this photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report", nil];
    [sheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Report" message:@"Are you sure you want to report this user? " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Report", nil];
        [av show];
        
        [self reportUserPhoto];
    }
    
}

-(void)reportUserPhoto{
    
    PFObject *reportPhoto =[PFObject objectWithClassName:@"reportPhoto"];
    
    reportPhoto [@"user"] = mainUser;
    
    
    NSLog(@"numberPhoto - %d",(int)self.pageControl.currentPage);
    if (self.pageControl.currentPage == 0) {
     reportPhoto  [@"photo"]= mainUser.photo;
        
    }
    if (self.pageControl.currentPage == 1) {
        reportPhoto  [@"photo"]= mainUser.photo1;
        
    }
    if (self.pageControl.currentPage == 2) {
        reportPhoto  [@"photo"]= mainUser.photo2;
        
    }
    if (self.pageControl.currentPage == 3) {
        reportPhoto  [@"photo"]= mainUser.photo3;
        
    }
    
    [reportPhoto saveInBackground];
    
}



@end
