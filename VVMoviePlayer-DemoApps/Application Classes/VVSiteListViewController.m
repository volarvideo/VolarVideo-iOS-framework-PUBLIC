//
//  VVSiteListViewController.m
//  mobileapidev
//
//  Created by Benjamin Askren on 9/8/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import "VVSiteListViewController.h"
#import "Globals.h"
#import "VVDomainList.h"
#import "VVUserDefaultsHelper.h"
#import <VVMoviePlayer/VVCMSSite.h>

#define kResultsPerPage 10

@interface VVSiteListViewController () {
    VVCMSAPI *api;
    NSMutableArray *sites;
    NSTimer *searchTimer;
}
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tv;

@end

@implementation VVSiteListViewController

@synthesize delegate;

- (id) initWithDomain:(NSString*)domain {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        currPage=0;
        numPages=0;
        numResults=0;
        loading = false;
        sites = [[NSMutableArray alloc] initWithCapacity:25];
        api = [[VVCMSAPI alloc] initWithDomain:domain apiKey:[Globals getAPIKey:domain]];
    }
    return self;
}

-(void)dealloc {
    // Without this, crashes happen when list is scrolling
    // while and popping off the view controller
    _tv.delegate = nil;
}

-(void) getData:(int) page {
    loading = YES;
    
    if (page > 1) {
        _tv.tableFooterView = footerSpinner;
        [footerSpinner startAnimating];
    }
    currPage = page;
    
    SiteParams *params = [[SiteParams alloc] init];
    if (_searchBar.text)
        params.title = _searchBar.text;
    params.page = [NSNumber numberWithInt:page];
    params.resultsPerPage = [NSNumber numberWithInt:kResultsPerPage];
    [api requestSites:params usingDelegate:self];
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    [self checkPagination];
}

-(void) checkPagination {
    NSArray *visCells = [_tv indexPathsForVisibleRows];
    if (visCells.count) {
        NSIndexPath *firstPath = [visCells objectAtIndex:0];
        if (!loading && (sites.count-visCells.count) <= (firstPath.row+kResultsPerPage)) {
            if (currPage+1 <= numPages) {
                [self getData:currPage+1];
            }
        }
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [sites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    VVCMSSite *site = [sites objectAtIndex:indexPath.row];
    cell.textLabel.text = site.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.navigationController popViewControllerAnimated:YES];
    VVCMSSite *site = [sites objectAtIndex:indexPath.row];
    [VVUserDefaultsHelper saveCurrSite:site.slug];
    if (delegate)
        [delegate siteSelected:self site:site];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    footerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self getData:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)VVCMSAPI:(VVCMSAPI *)vvapi requestForSitesResult:(NSArray *)s page:(int)page
      totalPages:(int)totalPages totalResults:(int)totalResults error:(NSError *)error {
    NSLog(@"requestForSitesResult page:%d totalPages:%d error:%@", page, totalPages, error);
    dispatch_async(dispatch_get_main_queue(), ^(void){
        numPages = totalPages;
        numResults = totalResults;
        
        if (error || [s isKindOfClass:[NSNull class]]) {
            [[iToast makeText:@"Failed to load sites"]show];
        }
        
        if (page == 1 || !s)
            [sites removeAllObjects];
        if (s)
            [sites addObjectsFromArray:s];

        [self.tv reloadData];
        
        loading = NO;
        if (page > 1) {
            [footerSpinner stopAnimating];
            self.tv.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        [self checkPagination];
    });
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [searchTimer invalidate];
    searchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                   target:self
                                                 selector:@selector(doDelayedSearch:)
                                                 userInfo:searchText
                                                  repeats:NO];
}

-(void)doDelayedSearch:(NSTimer *)t {
    assert(t == searchTimer);
    searchTimer = nil;
    [self getData:1];
}

@end
