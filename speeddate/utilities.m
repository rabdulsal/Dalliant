//  iradio
//
//  Created by studio76 on 22.08.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "utilities.h"



BOOL ShouldStartPhotoLibrary(id object, BOOL canEdit)

{
	if (([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO
		 && [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)) return NO;
	
	UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]
		&& [[UIImagePickerController availableMediaTypesForSourceType:
			 UIImagePickerControllerSourceTypePhotoLibrary] containsObject:(NSString *)kUTTypeImage])
	{
		cameraUI.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
	}
	else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]
			 && [[UIImagePickerController availableMediaTypesForSourceType:
				  UIImagePickerControllerSourceTypeSavedPhotosAlbum] containsObject:(NSString *)kUTTypeImage])
	{
		cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
		cameraUI.mediaTypes = [NSArray arrayWithObject:(NSString *) kUTTypeImage];
	}
	else return NO;
	
	cameraUI.allowsEditing = canEdit;
	cameraUI.delegate = object;
	
	[object presentViewController:cameraUI animated:YES completion:nil];
	
	return YES;
}


void LoginUser(id target)

{
	
}


UIImage* ResizeImage(UIImage *image, CGFloat width, CGFloat height)

{
	CGSize size = CGSizeMake(width, height);
	UIGraphicsBeginImageContextWithOptions(size, NO, 0);
	[image drawInRect:CGRectMake(0, 0, size.width, size.height)];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return image;
}


void PostNotification(NSString *notification)

{
	[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}
