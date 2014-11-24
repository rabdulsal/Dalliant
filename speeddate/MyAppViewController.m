//
//  MyAppViewController.m
//  WallpaperzSocial
//
//  Created by studio76 on 14.08.14.
//  Copyright (c) 2014 studio76. All rights reserved.
//

#import "MyAppViewController.h"
#import "UIImageView+WebCache.h"
#import "APIDownload.h"
#import "CJSONDeserializer.h"
#import "config.h"
#import "MyappTableViewCell.h"
#import "SWRevealViewController.h"


#define kBgQueue dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1
#define kLatestKivaLoansURL [NSURL URLWithString:MyAppUrl ] //2

@implementation MyAppViewController

//@synthesize newsList;
@synthesize news,allData;

- (void)viewDidLoad
{
    [super viewDidLoad];
	
   // [APIDownload downloadWithURL:@"https://itunes.apple.com/search?term=digitalfunk&country=ru&entity=software" delegate:self];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:
                        kLatestKivaLoansURL];
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });
    
    _menuBtn.target = self.revealViewController;
    _menuBtn.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}

- (void)fetchedData:(NSData *)responseData {
    
    NSError* error;
   
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    news = [json objectForKey:@"results"]; //2
    
    NSLog(@"DATA - %@",json);

    
    
    
    [self.tableView reloadData];

}
- (void)viewDidUnload
{
    [super viewDidUnload];
  
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.news.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
  
    
    MyappTableViewCell *cell = (MyappTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"MyappTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    NSDictionary *story = [news objectAtIndex:indexPath.row];

    cell.nameApp.text = [story objectForKey:@"trackName"];
    cell.priceApp.text = [NSString stringWithFormat:@"Price: %@",[story objectForKey:@"price"] ];
    
    [cell.iconApp sd_setImageWithURL:[NSURL URLWithString:[story objectForKey:@"artworkUrl100"]]
                  placeholderImage:[UIImage imageNamed:@"1024_gm.png"]];
    [cell.iconApp.layer setMasksToBounds:YES];
    [cell.iconApp.layer setCornerRadius:10];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 100;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
     NSDictionary *story = [news objectAtIndex:indexPath.row];
    
    NSString *urlApp = [story objectForKey:@"trackViewUrl"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlApp]];
}

- (IBAction)showMenu
{
    
   
}



@end