//
//  PCViewController.m
//  POC
//
//  Created by MSP on 2/23/15.
//  Copyright (c) 2015 Cognizant. All rights reserved.
//

#import "PCViewController.h"
#import "PCNewsTableViewCell.h"
#import "PCImageDownloader.h"

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define kURL [NSURL URLWithString:@"https://dl.dropboxusercontent.com/s/g41ldl6t0afw9dv/facts.json"]
#define kPlaceHolderImage @"Placeholder.png"
#define kEmptyString @""
#define kFontString @"Times New Roman"
#define kTitle @"title"
#define kDescription @"description"
#define kImageUrl @"imageHref"
#define kRows @"rows"
#define kButtonTitle @"Refersh"
#define kTableViewCell @"PCNewsTableViewCell"

@interface PCViewController ()
@property (nonatomic, strong) NSMutableDictionary *imageDownloadsInProgress;
@property(nonatomic, retain)UIActivityIndicatorView *activityIndicator;
@end

@implementation PCViewController
@synthesize contentArray, newsTableView, activityIndicator;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc]
                                   initWithTitle:kButtonTitle
                                   style:UIBarButtonItemStyleBordered
                                   target:self
                                   action:@selector(refreshContent:)];
    self.navigationItem.rightBarButtonItem = flipButton;
    [flipButton release];
    self.newsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-60)];
    self.newsTableView.delegate = self;
    self.newsTableView.dataSource = self;
    [newsTableView setSeparatorInset:UIEdgeInsetsZero];
    [self.view addSubview:self.newsTableView];
    contentArray = [[NSMutableArray alloc]init];
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.alpha = 1.0;
    activityIndicator.center = CGPointMake(160, 360);
    activityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];

    [self startDownloadingData];
}

-(IBAction)refreshContent:(id)sender
{
    [self startDownloadingData];
}

-(void)startDownloadingData
{

    dispatch_async(kBgQueue, ^{
        NSError* error;
        NSString *string = [NSString stringWithContentsOfURL:kURL encoding:NSISOLatin1StringEncoding error:&error];

        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSelector:@selector(fetchedData:) withObject:data];
        });
    });
}

- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseData
                                                                   options:NSJSONReadingMutableContainers
                                                                     error:&error];
    self.title = [jsonDictionary objectForKey:kTitle];
    NSArray *rowsArray = [jsonDictionary objectForKey:kRows];

    NSMutableArray *newContentArray = [[NSMutableArray alloc]init];
    for (NSDictionary *contentDict in rowsArray) {
        PCNewsRecord *newsRecord = [[PCNewsRecord alloc]init];
        newsRecord.title = [self pcString:[contentDict objectForKey:kTitle]];
        newsRecord.description = [self pcString:[contentDict objectForKey:kDescription]];
        newsRecord.imageUrl = [self pcString:[contentDict objectForKey:kImageUrl]];
        [newContentArray addObject:newsRecord];
        [newsRecord release];
    }
    [activityIndicator stopAnimating];
    contentArray = [[NSMutableArray alloc]initWithArray:newContentArray];
    [self.newsTableView reloadData];
}


#pragma mark - UITableViewDataSource
// number of section(s), now I assume there is only 1 section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)theTableView
{
    return 1;
}

// number of row in the section, I assume there is only 1 row
- (NSInteger)tableView:(UITableView *)theTableView numberOfRowsInSection:(NSInteger)section
{
    return [contentArray count];
}

// the cell will be returned to the tableView
- (UITableViewCell *)tableView:(UITableView *)theTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = kTableViewCell;

    PCNewsTableViewCell *cell = (PCNewsTableViewCell *)[theTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[PCNewsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    cell.backgroundColor = [UIColor colorWithRed:239.0/255.0f green:239.0/255.0f blue:239.0/255.0f alpha:1.0f];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    PCNewsRecord *newsRecord=nil;
    newsRecord = [contentArray objectAtIndex:indexPath.row];

    if (!newsRecord.iconImage)
    {
        [self startIconDownload:newsRecord forIndexPath:indexPath];
        // if a download is deferred or in progress, return a placeholder image
        if (![newsRecord.imageUrl isEqualToString:kEmptyString])
        {
            cell.newsImageView.image = [UIImage imageNamed:kPlaceHolderImage];
        }
        else
        {
            cell.newsImageView.image = nil;
        }
    }
    else
    {
        cell.newsImageView.image = newsRecord.iconImage;
    }

    cell.titleLabel.text = newsRecord.title;
    cell.descriptionLabel.text =  newsRecord.description;
    if(newsRecord.description !=nil)
    {
        CGSize constraint = CGSizeMake(210 - (10 * 2), 20000.0f);
        CGSize size = [newsRecord.description sizeWithFont:[UIFont fontWithName:kFontString size:12.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];

        CGFloat height = MAX(size.height, 44.0f);
        cell.descriptionLabel.frame = CGRectMake(10, 40, 200, height);
        [cell.descriptionLabel sizeToFit];
    }


    return cell;
}

- (void)startIconDownload:(PCNewsRecord *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    PCImageDownloader *imageDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (imageDownloader == nil)
    {
        imageDownloader = [[PCImageDownloader alloc] init];
        imageDownloader.newsRecord = appRecord;
        [imageDownloader setCompletionHandler:^{
            PCNewsTableViewCell *cell = (PCNewsTableViewCell*)[newsTableView cellForRowAtIndexPath:indexPath];
            cell.newsImageView.image = appRecord.iconImage;
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
        }];
        (self.imageDownloadsInProgress)[indexPath] = imageDownloader;
        [imageDownloader imageDownload];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    PCNewsRecord *newsRecord = [contentArray objectAtIndex:[indexPath row]];
    CGFloat height = 0;
    if(![newsRecord.description isEqualToString:kEmptyString])
    {
        CGSize constraint = CGSizeMake(210 - (10 * 2), 20000.0f);
        CGSize size = [newsRecord.description sizeWithFont:[UIFont fontWithName:kFontString size:12.0f] constrainedToSize:constraint lineBreakMode:NSLineBreakByWordWrapping];
        height = MAX(size.height, 44.0f);
    }
    if(![newsRecord.imageUrl isEqualToString:kEmptyString])
    {
        height = MAX(height, 70);
    }
    if ([newsRecord.title isEqualToString:kEmptyString] && [newsRecord.description isEqualToString:@""] && [newsRecord.imageUrl isEqualToString:kEmptyString])
    {
        return 0;
    }

    return height + (10 * 2) + 30;
}

-(NSString *) pcString:(NSString*)string
{
    NSString * str = kEmptyString;
    if((string != nil) && ((NSNull*)string != [NSNull null]))
    {
        string = [NSString stringWithFormat:@"%@",string];
        if([string length] != 0)
        {
            str = string;
        }
    }
    return str;
}

-(void)dealloc
{
    [super dealloc];
    [newsTableView release];
    [contentArray release];
    [activityIndicator release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
