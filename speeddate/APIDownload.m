//
//  APIDownload.m
//  Download
//
//  Created by Alximik on 08.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "APIDownload.h"





@implementation APIDownload

@synthesize delegate;
@synthesize tag;
@synthesize downloadData;
@synthesize response;


- (void)dealloc {
    self.downloadData = nil;
    self.response = nil;
    [super dealloc];
}

+(id)downloadWithURL:(NSString*)url delegate:(id)delegate {
    APIDownload *request = [[APIDownload alloc] init];
    request.delegate = delegate;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSURL *dounloadURL = [NSURL URLWithString:url];
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:dounloadURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0f];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:request];
    if (theConnection) {
        request.downloadData = [NSMutableData data];
    } else {
       
    }
    
    [theConnection release];
    
    return [request autorelease];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)aResponse
{
    if ([aResponse expectedContentLength] < 0) {
       
    } else {
        self.response = aResponse;
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [downloadData appendData:data];
    
    if (self.response)
	{
		CGFloat expectedLength = [self.response expectedContentLength];
		CGFloat currentLength = downloadData.length;
		CGFloat percent = currentLength / expectedLength;
        
        SEL selector = @selector(dataDownloadAtPercent:);
        
        
        
        if (delegate && [delegate respondsToSelector:selector]) {
            [delegate performSelector:selector withObject:[NSNumber numberWithFloat:percent]];
        }
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    SEL selector = @selector(APIDownload:);
    
    
    
	if (delegate && [delegate respondsToSelector:selector]) {
		[delegate performSelector:selector withObject:self];
     }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
   
}

-(void)dataDownloadAtPercent:(NSString*)ss{
    
    
}

-(void)APIDownload:(NSString*)ww{
    
    
}

@end
