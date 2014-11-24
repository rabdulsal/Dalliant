//
//  APIDownload.h
//  Download
//
//  Created by Alximik on 08.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface APIDownload : NSObject {
    id delegate;
    NSInteger tag;
    NSMutableData *downloadData;
    NSURLResponse *response;
}

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) NSInteger tag;
@property (nonatomic, retain) NSMutableData *downloadData;
@property (nonatomic, retain) NSURLResponse *response;

+(id)downloadWithURL:(NSString*)url delegate:(id)delegate;


@end