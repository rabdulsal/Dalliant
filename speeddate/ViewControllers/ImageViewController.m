//
//  ImageViewController.m
//  speeddate
//
//  Created by STUDIO76 on 08.09.14.
//  Copyright (c) 2014 studio76. All rights reserved..
//

#import "ImageViewController.h"
#define MIN_SCALE 1.8
#define MAX_SCALE 2

@interface ImageViewController () <UIScrollViewDelegate, UIActionSheetDelegate>
@property UIImageView *imageView;
@end

@implementation ImageViewController

- (void)loadView {


}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	scroll.backgroundColor = RED_LIGHT;
	scroll.delegate = self;
	self.imageView = [[UIImageView alloc] initWithImage:self.image];
	scroll.contentSize = self.imageView.frame.size;
	[scroll addSubview:self.imageView];

	scroll.minimumZoomScale = scroll.frame.size.width / self.imageView.frame.size.width;
	scroll.maximumZoomScale = 4.0;
	[scroll setZoomScale:scroll.minimumZoomScale];

	self.view = scroll;
}


- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
	CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;

    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }

   
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 100;
    }

	return frameToCenter;
}

#pragma mark -
#pragma mark UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.imageView.frame = [self centeredFrameForScrollView:scrollView andUIView:self.imageView];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.imageView;
}

- (IBAction)actionPressed:(UIBarButtonItem *)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Save&Copy" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save",@"Copy", nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

#pragma mark ActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil);
    }
    if (buttonIndex == 1) {
        [UIPasteboard generalPasteboard].image = self.image;
    }
}
@end
