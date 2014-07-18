//
//  VVMediaListViewController.m

//
//  Created by Benjamin Askren on 9/20/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#import "VVMediaListViewController.h"
#import "VVMediaCell.h"
#import "B3Utils.h"
#import "Globals.h"
#import <VVMoviePlayer/VVCMSSite.h>
#import "VVUserDefaultsHelper.h"
#import "PRPAlertView.h"

#import "UIImageView+WebCache.h"

#import <EventKit/EventKit.h>

#import "MBProgressHUD.h"
#import "NSArray+Reverse.h"


#define kRowHeight 110.0
#define kNoResultsRowHeight 424.0
#define kResultsPerPage 10

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define iOS7Code(code, alt) if([[[UIDevice currentDevice]systemVersion]floatValue]>=7){code;}
#else
#define iOS7Code(code, alt) alt
#endif

iToast *_VVMediaListViewControllerToast=nil;
CGRect _VVMediaListViewControllerHeaderFrame;
BOOL _VVMediaListViewFreshLoad=YES;
UIView *navBarTapView;

@interface VVMediaListViewController () {
    NSString *domain;
    NSString *siteSlug;
    NSTimer *searchTimer;
    
    IBOutlet UITableView *tv;
    IBOutlet B3SearchBar *searchBar;
    IBOutlet UISegmentedControl *filterSegmentControl;
    UIActivityIndicatorView *footerSpinner;
    VVAppDelegate *appDelegate;
    BOOL visible;
    NSTimer* myTimer;
    UIButton *backButton;
    UISegmentedControl *segCtrl;
    int lastSelectedIndex;
    
    VVCMSAPI *api;
    
    UIImage *audioImage,*schedImage,*liveImage,*archImage;
    
    NSString *userName,*password;
    
    VVPickerViewController *svc;
    NSArray *sections;
    VVCMSBroadcastStatus lastStatusRequested;
    int currPage,numPages,numResults;
    BOOL virginloading,loading;
    
    VVDatePickerViewController *dpc;
}

@property(nonatomic,assign) enum VVMediaCellType type;
@property (nonatomic, strong) NSDictionary *settingsDictionary;
@property (nonatomic, strong) NSMutableArray *broadcasts;
@property (nonatomic, strong) VVMoviePlayerViewController *moviePlayer;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property(nonatomic, strong) UIPopoverController *svpovc, *dpcovc;
@property(nonatomic,strong) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation VVMediaListViewController

@synthesize settingsDictionary,broadcasts,moviePlayer,toolbar,svpovc,dpcovc;

- (id)init {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        [self commonInit];
        
    }
    return self;
}

- (id)initWithSiteSlug:(NSString *)s {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        siteSlug = s;
        [self commonInit];
    }
    return self;
}

-(void) commonInit {
    virginloading = YES;
    loading = NO;
    _VVMediaListViewFreshLoad=YES;
    lastSelectedIndex=-1;
    currPage=0;
    numPages=0;
    numResults=0;
    appDelegate = (VVAppDelegate*)[[UIApplication sharedApplication] delegate];
    segCtrl.selectedSegmentIndex = 2;
    
#if defined(DEMO_APP)
    domain = [VVUserDefaultsHelper getCurrDomain];
#else
    domain = @"vcloud.volarvideo.com";
#endif
    api = [[VVCMSAPI alloc] initWithDomain:domain apiKey:[Globals getAPIKey:domain]];
    [self getData:1 status:VVCMSBroadcastStatusArchived];
}

-(void)VVCMSAPI:(VVCMSAPI *)vvCmsApi requestForSectionsPage:(int)page resultsPerPage:(int)resultsPerPage didFinishWithArray:(NSArray *)results error:(NSError *)error {
    if (vvCmsApi==api) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not get sections" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    sections = results;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    tv.rowHeight = kRowHeight;
    tv.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Folder Wallpaper.JPG"]];
    tv.dataSource = self;
    
    UIButton *imgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 74.0, 27.0)];
    [imgButton setBackgroundImage:[UIImage imageNamed:@"app_logo"] forState:UIControlStateNormal];
    UIBarButtonItem *sourceButton = [[UIBarButtonItem alloc] initWithCustomView:imgButton];
    self.navigationItem.rightBarButtonItem = sourceButton;
	 
    [self makeRefreshButton];
#if defined(DEMO_APP)
    [self setupNavbarGestureRecognizer];
#endif
    
    searchBar.barStyle = UIBarStyleBlackTranslucent;
    searchBar.customButtonTitle=@"Change Domain";
#if defined(DEMO_APP)
    searchBar.showsCustomButton=YES;
#else
    searchBar.showsCustomButton=NO;
#endif
    searchBar.delegate = self;

//    [self useEnhancedBackButton];
    
    tv.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);

    audioImage = [UIImage imageNamed:@"iconGenericAudio"];
    schedImage = [UIImage imageNamed:@"scheduledBroadcast"];
    liveImage = [UIImage imageNamed:@"iconLiveBroadcast"];
    archImage = [UIImage imageNamed:@"iconGenericVideo"];
    
    footerSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    
    // Thank god for Stack Overflow:
    // http://stackoverflow.com/questions/19081697/ios-7-navigation-bar-hiding-content
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) { // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone; //layout adjustements
    }
    
    // The first load is always done at this point
    self.spinner.hidden=YES;
    [self.spinner stopAnimating];
}

- (void) setupNavbarGestureRecognizer {
    // recognise taps on navigation bar
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseSite)];
    [gestureRecognizer setNumberOfTapsRequired:1];
    [gestureRecognizer setNumberOfTouchesRequired:1];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    int size = UIInterfaceOrientationIsLandscape(orientation)?screenRect.size.height:screenRect.size.width;
    CGRect frame = CGRectMake(100, 0, size-200, 44);
    if(!navBarTapView) {
        navBarTapView = [[UIView alloc] initWithFrame:frame];
        navBarTapView.backgroundColor = [UIColor clearColor];
        [navBarTapView setUserInteractionEnabled:YES];
        [navBarTapView addGestureRecognizer:gestureRecognizer];
        
        [self.navigationController.navigationBar addSubview:navBarTapView];
    }
    else {
        navBarTapView.frame = frame;
    }
}

-(void) useEnhancedBackButton {
    UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:12];
    CGSize sz = [@"Back" sizeWithFont:font];
    backButton = [[UIButton alloc] initWithFrame:CGRectMake(5,6,sz.width+20,31)];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarBlackOpaqueBack"] stretchableImageWithLeftCapWidth:15 topCapHeight:5] forState:UIControlStateNormal];
    [backButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarBlackOpaqueBackPressed"] stretchableImageWithLeftCapWidth:15 topCapHeight:5] forState:UIControlStateSelected];
    backButton.titleLabel.font = font;
    [backButton setTitle:@" Back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPress) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *sourceButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = sourceButton;
}


-(void) backButtonPress {
    if (_VVMediaListViewControllerToast)
        [_VVMediaListViewControllerToast hideToast:nil];
//    [APIDataLoader showHUDWithMessage:@"Returning..."];
    [self performSelector:@selector(popViewController) withObject:nil afterDelay:0.1];
    if (self.moviePlayer) {
        self.moviePlayer=nil;
    }
}

-(void) refreshButtonPress {
    [self reload];
}

-(void) makeRefreshButton {
    UIButton *refreshButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 18, 22.0)];
    [refreshButton setBackgroundImage:[UIImage imageNamed:@"UIButtonBarRefresh"] forState:UIControlStateNormal];
    [refreshButton addTarget:self action:@selector(refreshButtonPress) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *refreshBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:refreshButton];
    self.navigationItem.leftBarButtonItem = refreshBarButtonItem;
}

-(void) makeSpinner {
    UIActivityIndicatorView *ai = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ai] ;
    [ai startAnimating];
}

-(void) popViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
    broadcasts=nil;
}


BOOL _VVMediaListViewControllerLastReachableTestResult;
BOOL _VVMediaListViewControllerWaitingForReachabilityResult;
dispatch_queue_t _VVMediaListViewControllerBackgroundQueue;

-(void) viewDidAppear:(BOOL)animated {
    if (moviePlayer.moviePlayer.errorLog)
        NSLog(@"movie.errorLog: %@",moviePlayer.moviePlayer.errorLog);
    visible=YES;

    if (_VVMediaListViewFreshLoad)
        tv.contentOffset = CGPointMake(0, 44);
    _VVMediaListViewFreshLoad=NO;
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
    
    if (!segCtrl) {
        double width = (UIInterfaceOrientationIsPortrait(orientation)?bounds.size.width:bounds.size.height);
        segCtrl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(5, 5, width-10, 36)];
        [segCtrl addTarget:self action:@selector(segCtrlChanged:) forControlEvents:UIControlEventValueChanged];
        segCtrl.segmentedControlStyle = UISegmentedControlStyleBar;
        segCtrl.tintColor = [UIColor colorWithWhite:0.25 alpha:0.7];
        segCtrl.alpha=0.75;
        segCtrl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [toolbar addSubview:segCtrl];
        CGRect frame = toolbar.frame;
            if (UIInterfaceOrientationIsLandscape(self.parentViewController.interfaceOrientation)) {
                frame.origin.y += 12;
                frame.size.height = 32;
            }
        toolbar.frame=frame;
        [segCtrl insertSegmentWithTitle:@"Upcoming" atIndex:0 animated:NO];
        [segCtrl insertSegmentWithTitle:@"Live" atIndex:1 animated:NO];
        [segCtrl insertSegmentWithTitle:[NSString stringWithFormat:@"Archived (%d)",numResults] atIndex:2 animated:NO];
        
        segCtrl.selectedSegmentIndex=2;
    }
    
	// This iOS7Code is no longer valid and will need to be refactored eventually
	// Since the search bar is now has edgesForExtendedLayout set (iOS7 property to
	// make is play nice with the new status bar) we don't need to manually push
	// everything down like this.
	
	// We can, however, still make the status bar light instead of dark since we have
	// a dark background and it looks pretty that way.
	
    iOS7Code({
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
        [toolbar setTranslucent:NO];
//        CGRect frame = self.view.frame;
//        frame.origin.y +=60;
//        frame.size.height -=60;
//        self.view.frame = frame;
    }, {
        
    });

}

-(void) viewDidLayoutSubviews {
}

-(void) dealloc {
    
}

-(void) viewWillDisappear:(BOOL)animated {
//    [APIDataLoader hideHUD];
    if (_VVMediaListViewControllerToast) [_VVMediaListViewControllerToast hideToast:nil];
    [self performSelector:@selector(tellSuperThatViewWillDisappear) withObject:nil afterDelay:0.1];
    [myTimer invalidate];
}

-(void) tellSuperThatViewWillDisappear {
    [super viewWillDisappear:YES];
}

-(void) viewDidDisappear:(BOOL)animated {
//    [APIDataLoader hideHUD];
    [super viewDidDisappear:animated];
    visible=NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (_VVMediaListViewControllerToast)
        [_VVMediaListViewControllerToast hideToast:nil];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

-(void) setBackButtonOrientation:(UIInterfaceOrientation) orientation {    
    CGRect frame = backButton.frame;
    if (UI_USER_INTERFACE_IDIOM()!= UIUserInterfaceIdiomPad && UIInterfaceOrientationIsLandscape(orientation)) {
        [backButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarMiniBlackOpaqueBack"] stretchableImageWithLeftCapWidth:11 topCapHeight:5] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarMiniBlackOpaqueBackPressed"] stretchableImageWithLeftCapWidth:11 topCapHeight:5] forState:UIControlStateSelected];
        frame.size.height= 24;
    } else {
        [backButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarBlackOpaqueBack"] stretchableImageWithLeftCapWidth:15 topCapHeight:5] forState:UIControlStateNormal];
        [backButton setBackgroundImage:[[UIImage imageNamed:@"UINavigationBarBlackOpaqueBackPressed"] stretchableImageWithLeftCapWidth:15 topCapHeight:5] forState:UIControlStateSelected];
        frame.size.height=31;
    }
    backButton.frame=frame;
    UIBarButtonItem *sourceButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = sourceButton;
}

CGPoint _VVMediaListViewControllerPointBeforeRotate;


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _VVMediaListViewControllerPointBeforeRotate = CGPointMake(tv.contentOffset.x, tv.contentOffset.y);
//    [B3SchoolPage setOrientation:toInterfaceOrientation];
    tv.contentOffset = _VVMediaListViewControllerPointBeforeRotate;
    tv.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    searchBar.hidden=YES;
    [self setBackButtonOrientation:toInterfaceOrientation];
    CGRect frame = toolbar.frame;
    frame.size.height = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)?32:44);
    frame.origin.y += (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)?+12:-12);
    toolbar.frame=frame;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    tv.contentOffset = _VVMediaListViewControllerPointBeforeRotate;
    searchBar.hidden=NO;
    [self reload];
    [self makeRefreshButton];
#if defined(DEMO_APP)
    [self setupNavbarGestureRecognizer];
#endif
}

-(void) chooseSite {
    if (visible) {
        VVSiteListViewController *slc = [[VVSiteListViewController alloc] initWithDomain:domain];
        slc.delegate = self;
        [self.navigationController pushViewController:slc animated:YES];
    }
}

-(void) domainDidChange:(id)dl domain:(NSString *)d site:(VVCMSSite *)s {
    NSLog(@"domainDidChange");
    self.spinner.hidden=NO;
    [self.spinner startAnimating];
    
    self.navigationItem.title = s.title;
    domain = d;
    siteSlug = s.slug;
    
    api = [[VVCMSAPI alloc] initWithDomain:domain apiKey:[Globals getAPIKey:domain]];
    [self getData:1];
}

-(void) siteSelected:(id)slvc site:(VVCMSSite *)site {
    NSLog(@"doneWithVVSiteListViewController");
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    self.navigationItem.title = site.title;
    
    self.spinner.hidden=NO;
    [self.spinner startAnimating];
    siteSlug = site.slug;
    [self getData:1];
}

-(void) getData:(int)page {
    VVCMSBroadcastStatus status;
    if (segCtrl.selectedSegmentIndex == 0)
        status = VVCMSBroadcastStatusScheduled;
    else if (segCtrl.selectedSegmentIndex == 1)
        status = VVCMSBroadcastStatusStreaming;
    else
        status = VVCMSBroadcastStatusArchived;
    [self getData:page status:status];
}

-(void) getData:(int)page status:(VVCMSBroadcastStatus)status {
    NSLog(@"getData page=%d", page);
    loading = YES;
    
    if (page > 1) {
        tv.tableFooterView = footerSpinner;
        [footerSpinner startAnimating];
    }
    
    currPage = page;
    lastStatusRequested = status;
    BroadcastParams *params = [[BroadcastParams alloc] init];
    if (searchBar.text)
        params.title = searchBar.text;
    params.sites = siteSlug;
    params.status = status;
    params.page = [[NSNumber alloc] initWithInt:page];
    params.resultsPerPage = [[NSNumber alloc] initWithInt:kResultsPerPage];
    [api requestBroadcasts:params usingDelegate:self];
}

- (void)VVCMSAPI:(VVCMSAPI *)vvapi requestForBroadcastsResult:(NSArray *)events
      withStatus:(VVCMSBroadcastStatus)status page:(int)page totalPages:(int)totalPages
    totalResults:(int)totalResults error:(NSError *)error {
    
    dispatch_async(dispatch_get_main_queue(), ^(void){
        self.spinner.hidden=YES;
        [self.spinner stopAnimating];
        
        if (appDelegate && virginloading) [appDelegate finishedLoadingBroadcastsWithError:error];
        virginloading=NO;
        
        if (!error && ![events isKindOfClass:[NSNull class]]) {
            [self setpuBroadcasts:events status:status page:page totalPages:totalPages totalResults:totalResults];
        } else {
            [broadcasts removeAllObjects];
            [tv reloadData];
        }
        loading = NO;
        if (page > 1) {
            [footerSpinner stopAnimating];
            tv.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        }
        [self checkPagination];
    });
}

-(void) setpuBroadcasts:(NSArray*)b status:(VVCMSBroadcastStatus)status page:(int)page totalPages:(int)totalPages totalResults:(int)totalResults {
    NSLog(@"setupBroadcasts page=%d totalPages=%d totalResults=%d", page, totalPages, totalResults);
    numPages = totalPages;
    numResults = totalResults;
    toolbar.hidden=NO;
    
    if (page == 1) {
        broadcasts = [b mutableCopy];
    }
    else {
        [broadcasts addObjectsFromArray:b];
    }
    
    [segCtrl setTitle:@"Upcoming" forSegmentAtIndex:0];
    [segCtrl setTitle:@"Live" forSegmentAtIndex:1];
    [segCtrl setTitle:@"Archived" forSegmentAtIndex:2];
    
    if (segCtrl.selectedSegmentIndex==0) {
        [segCtrl setTitle:[NSString stringWithFormat:@"Upcoming (%d)",totalResults] forSegmentAtIndex:0];
    } else if (segCtrl.selectedSegmentIndex==1) {
        [segCtrl setTitle:[NSString stringWithFormat:@"Live (%d)",totalResults] forSegmentAtIndex:1];
    } else if (segCtrl.selectedSegmentIndex==2) {
        [segCtrl setTitle:[NSString stringWithFormat:@"Archived (%d)",totalResults] forSegmentAtIndex:2];
    }

    [tv reloadData];
}

-(void) updateBroadcastToolbarAndListItems {
    
}

-(void) segCtrlChanged:(UISegmentedControl *)sc {
    NSLog(@"selectedIndex=[%d]",sc.selectedSegmentIndex);
    self.spinner.hidden=NO;
    [self.spinner startAnimating];
    [self getData:1];
}


- (void) reload {
    self.spinner.hidden=NO;
    [self.spinner startAnimating];
    [self getData:1];
}

- (void) refreshVisibleCells {
    NSArray *visCells = [tv indexPathsForVisibleRows];
    [tv reloadRowsAtIndexPaths:visCells withRowAnimation:UITableViewRowAnimationNone];
}

BOOL _VVMediaListDragging=NO;


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _VVMediaListDragging=NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _VVMediaListDragging=YES;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_VVMediaListDragging) {
        if (scrollView.contentOffset.y<10)
            [tv setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
        else if (scrollView.contentOffset.y>44)
            [tv setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    [self checkPagination];
}

-(void) checkPagination {
    NSArray *visCells = [tv indexPathsForVisibleRows];
    if (visCells.count) {
        NSIndexPath *firstPath = [visCells objectAtIndex:0];
        if (!loading && (broadcasts.count-visCells.count) <= (firstPath.row+kResultsPerPage)) {
            if (currPage+1 <= numPages) {
                [self getData:currPage+1 status:lastStatusRequested];
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [broadcasts count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"mediaCell";
    VVMediaCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"VVMediaCell" owner:self options:nil];
        cell = (VVMediaCell *)[nib objectAtIndex:0];
        cell.backgroundView = [[UIImageView alloc] init];
        ((UIImageView *)cell.backgroundView).image = [UIImage imageNamed:@"Cell Wallpaper.JPG"];
    }

    if (!broadcasts || [broadcasts isKindOfClass:[NSNull class]])
        return cell;
    VVCMSBroadcast *broadcast = [broadcasts objectAtIndex:indexPath.row];

    
    cell.disabled=NO;
//    cell.disabled = ![api latestReachabilityResult];
    cell.tag = indexPath.row;
    cell.type = VVMediaCellTypeBroadcast;
    
    if (broadcast.title && ![broadcast.title isKindOfClass:[NSNull class]])
        cell.title = broadcast.title;
    else
        cell.title = @"";
    
    if (broadcast.description && ![broadcast.description isKindOfClass:[NSNull class]])
        cell.description = broadcast.description;
    else
        cell.description = @"";
    
    NSDate *itemDate = broadcast.startDate;
    if (itemDate)
        cell.meta1 = [B3Utils stringFromDate:itemDate withFormat:@"M-d-yy"];
    else
        cell.meta1 = nil;
    
    switch (broadcast.status) {
    case VVCMSBroadcastStatusStreaming:
        if (broadcast.isStreaming) {
            cell.meta2 = @"streaming";
        }
        else {
            cell.meta2 = @"stopped";
        }
        break;
    default:
        cell.meta2 = nil;
        break;
    }
    
    UIImage *placeholder;
    if (broadcast.audioOnly)
        placeholder = audioImage;
    else if (segCtrl.selectedSegmentIndex==0)
        placeholder = schedImage;
    else if (segCtrl.selectedSegmentIndex==1) {
        if (broadcast.isStreaming)
            placeholder = liveImage;
        else
            placeholder = archImage;
    }
    else if (segCtrl.selectedSegmentIndex==2)
        placeholder = archImage;
    
    if (broadcast.thumbnailURL && ![broadcast.thumbnailURL isEqual:[NSNull null]] && ![broadcast.thumbnailURL isEqualToString:@""] ) {
        [cell.imgThumb setImageWithURL:[NSURL URLWithString:broadcast.thumbnailURL]placeholderImage:placeholder];
    } else {
        [cell.imgThumb setImage:placeholder];
    }

    cell.read = YES;
    cell.favorite = NO;
    return cell;
}

VVCMSBroadcast *_VVMediaListViewSelectedBroadcast;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
 {
    //NSLog(@"index=%d",buttonIndex);
     if (buttonIndex==1) {
         EKEventStore *eventStore=[[EKEventStore alloc] init];
         if([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
             // iOS 6 and later
             [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                 [self performSelectorOnMainThread: @selector(presentEventEditViewControllerWithEventStore:) withObject:eventStore waitUntilDone:NO];
                 if (granted){
                 }else
                 {
                     //----- codes here when user NOT allow your app to access the calendar.
                 }
             }];
             
         } else {
             [self performSelectorOnMainThread: @selector(presentEventEditViewControllerWithEventStore:) withObject:eventStore waitUntilDone:NO];
         }
         
         
     }
}

- (void)presentEventEditViewControllerWithEventStore:(EKEventStore*)eventStore
{
    EKEvent *addEvent=[EKEvent eventWithEventStore:eventStore];
    addEvent.title = _VVMediaListViewSelectedBroadcast.title;
    addEvent.startDate = _VVMediaListViewSelectedBroadcast.startDate;
    [addEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    addEvent.alarms=[NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:addEvent.startDate]];
    //[eventStore saveEvent:addEvent span:EKSpanThisEvent error:nil];
    
    NSError *error;
    BOOL saved = [eventStore saveEvent:addEvent span:EKSpanThisEvent error:&error];
    if (!saved) {
        NSLog(@"error=%@",error);
        [PRPAlertView showWithTitle:@"Failed to Create Event" message:@"There was an error we did not anticipate.  Please excuse the inconvenience." buttonTitle:@"OK"];
    } else {
        _VVMediaListViewControllerToast = [iToast makeText:@"Saved to Calendar"];
        [[_VVMediaListViewControllerToast setDuration:iToastDurationShort] show];
//        [_VVMediaListViewSelectedBroadcast setValue:[NSNumber numberWithBool:YES] forKey:@"onCalendar"];
        [self refreshVisibleCells];
    }

}



-(void) startVMAP:(NSString *)vmapString {
    [self showHUD];
    NSURL *vmapURL = [NSURL URLWithString:vmapString];
    NSArray *vmapURLComponents = [vmapURL pathComponents];

    NSLog(@"comp = [%@]",vmapURLComponents);
    
    [self performSelector:@selector(delayedStartVMAP:) withObject:vmapString afterDelay:0.1];
}

-(void) delayedStartVMAP:(NSString*)vmapString {
    moviePlayer = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidChange:) name:VVVmapPlayerDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    moviePlayer = [[VVMoviePlayerViewController alloc] initWithExtendedVMAPURIString:vmapString];
    NSLog(@"moviePlayer=[%@]", moviePlayer);
    if (self.moviePlayer) {
        moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
        return;
    } else {
        [self hideHUD];
    }

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showHUD];
    NSDictionary *objects = @{@"tableView":tableView, @"indexPath":indexPath};
    [self performSelector:@selector(didSelectRowAtIndexPath:) withObject:objects afterDelay:0.1];
}

- (void) didSelectRowAtIndexPath:(NSDictionary *)objects {
//    UITableView *tableView = [objects objectForKey:@"tableView"];
    NSIndexPath *indexPath = [objects objectForKey:@"indexPath"];
    VVCMSBroadcast *bcast = [broadcasts objectAtIndex:indexPath.row];
    _VVMediaListViewSelectedBroadcast = bcast;
    [self delayedStartVMAP:bcast.vmapURL];
}

-(void) playerDidChange:(NSNotification*)notification {
    NSLog(@"playerDidChange");
    if ([moviePlayer.moviePlayer loadState] == MPMovieLoadStatePlayable)
        [self launchMovie:moviePlayer];
    else
        [self hideHUD];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:VVVmapPlayerDidChangeNotification object:nil];
}

-(void) playbackFinished:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}

-(void) launchMovie:(VVMoviePlayerViewController *)mpvc {
    NSLog(@"launchMovie");
    [self hideHUD];
    [appDelegate.navigationController presentVolarMoviePlayerViewControllerAnimated:mpvc];
}

-(void) customButtonPressedInSearchBar:(B3SearchBar *)searchBar {    
    VVDomainList *domainListView;
    domainListView = [[VVDomainList alloc] init];
    domainListView.delegate = self;
    if (self.navigationController)
        [self.navigationController pushViewController:domainListView animated:YES];
    else
        [self presentModalViewController:domainListView animated:YES];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"textDidChange");
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

MBProgressHUD *progressHUD;

- (void)showHUD {
    [self showHUDWithMessage:@"Loading..."];
}

- (void)showHUDWithMessage:(NSString *) msg {
    UIView *theView = self.view;
    progressHUD = [MBProgressHUD showHUDAddedTo:theView animated:YES];
    progressHUD.mode = MBProgressHUDModeIndeterminate;
    progressHUD.labelText = msg;
}

- (void)hideHUD {
    [progressHUD hide:YES];
}

-(IBAction) filterSegmentValueChanged:(id)sender {
    if (sender==filterSegmentControl) {
        switch(filterSegmentControl.selectedSegmentIndex) {
            case 0: // From Date
            case 1: // To Date
                [self displayDatePicker];
                break;
            case 2: // Sport
                NSLog(@"sport");
                [self displaySportPicker];
                break;
        }
    }
}

-(void) doneWithVVPickerViewController:(VVPickerViewController *)vvPCV {
    if (vvPCV==svc) {
//        if ([svc.selectedValue isEqualToString:@"0"]) {
//            [filterSegmentControl setTitle:@"Sport" forSegmentAtIndex:2];
//        } else
//            [filterSegmentControl setTitle:svc.selectedTitle forSegmentAtIndex:2];
//        api.section_id = svc.selectedValue;
//        [self getData:1];
//        filterSegmentControl.selectedSegmentIndex=-1;
//        [self retractSportPicker];
    }
}

-(void) displaySportPicker {
	CGRect keypadFrame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        keypadFrame = CGRectMake(0, 0, 320, 260);
        if (svc==nil) {
            svc = [[VVPickerViewController alloc] initWithNibName:nil bundle:nil];
            svc.contentSizeForViewInPopover = keypadFrame.size;
        }
        if (svpovc==nil) {
            svpovc = [[UIPopoverController alloc] initWithContentViewController:svc];
            if (svpovc)
                svpovc.delegate = self;
        }
    } else {
        //      keypadFrame = CGRectMake(0, Global_windowHeight,        320, 260);
        keypadFrame = CGRectMake(0, self.view.frame.size.height,320, 260);
        if (svc==nil) {
            svc = [[VVPickerViewController alloc] initWithNibName:nil bundle:nil];
            [self.view.window addSubview:svc.view];
        }
    }
    svc.titleKey=@"title";
    svc.valueKey=@"id";
    NSDictionary *sportDict = [NSDictionary dictionaryWithObjectsAndKeys:@"- none -",@"title",@"0",@"id", nil];
    NSArray *baseArray = [NSArray arrayWithObject:sportDict];
    svc.dataDictionaries = [baseArray arrayByAddingObjectsFromArray:sections];
    svc.viewDelegate = self;
    [svc.pv reloadAllComponents];
    
    svc.view.hidden = NO;
	svc.view.frame = keypadFrame;
	
#ifndef TEST
	[UIView beginAnimations:@"PresentKeypad" context:nil];
#endif
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        svpovc.passthroughViews = nil;
        CGRect rect = [self popOverFrame];
        UIPopoverArrowDirection dir = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
        [svpovc presentPopoverFromRect:rect inView:self.view permittedArrowDirections:dir animated:YES];
    } else {
        keypadFrame = CGRectMake(0, self.view.window.frame.size.height-260, 320, 260);
        svc.view.frame = keypadFrame;
        tv.contentInset = UIEdgeInsetsMake(0, 0, 224, 0);
    }
#ifndef TEST
	[UIView commitAnimations];
#endif
}

-(void) retractSportPicker {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [svpovc dismissPopoverAnimated:YES];
    } else {
#ifndef TEST
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
#endif
        CGRect keypadFrame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 260);
        svc.view.frame = keypadFrame;
        tv.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
#ifndef TEST
        [UIView commitAnimations];
#endif
    }
	svc.view.hidden = YES;
}

-(void) displayDatePicker {
    CGRect keypadFrame;
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        keypadFrame = CGRectMake(0, 0, 320, 260);
        if (dpc==nil) {
            dpc = [[VVDatePickerViewController alloc] initWithNibName:nil bundle:nil];
            dpc.contentSizeForViewInPopover = keypadFrame.size;
        }
        if (dpcovc==nil) {
            dpcovc = [[UIPopoverController alloc] initWithContentViewController:dpc];
            if (dpcovc) dpcovc.delegate = self;
        }
    } else {
        keypadFrame = CGRectMake(0, self.view.frame.size.height,320, 260);
        if (dpc==nil) {
            dpc = [[VVDatePickerViewController alloc] initWithNibName:nil bundle:nil];
            [self.view.window addSubview:dpc.view];
        }
    }
    dpc.view.hidden=NO;
    dpc.delegate=self;
    dpc.view.frame=keypadFrame;
//    NSDate *date;
//    if (filterSegmentControl.selectedSegmentIndex==0)
//        date = api.afterDate;
//    else
//        date = api.beforeDate;
//    if (!date)
//        date = [NSDate date];
//    dpc.dp.date = date;

#ifndef TEST
	[UIView beginAnimations:@"PresentKeypad" context:nil];
#endif
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        dpcovc.passthroughViews = nil;
        CGRect rect = [self popOverFrame];
        UIPopoverArrowDirection dir = UIPopoverArrowDirectionDown | UIPopoverArrowDirectionUp;
        [dpcovc presentPopoverFromRect:rect inView:self.view permittedArrowDirections:dir animated:YES];
    } else {
        keypadFrame = CGRectMake(0, self.view.window.frame.size.height-260, 320, 260);
        dpc.view.frame = keypadFrame;
        tv.contentInset = UIEdgeInsetsMake(0, 0, 224, 0);
    }
#ifndef TEST
	[UIView commitAnimations];
#endif

}

-(CGRect) popOverFrame {
    float x = filterSegmentControl.frame.origin.x+filterSegmentControl.frame.size.width*((float)filterSegmentControl.selectedSegmentIndex)/((float)filterSegmentControl.numberOfSegments);
    float y = filterSegmentControl.frame.origin.y;
    float w = filterSegmentControl.frame.size.width/((float)filterSegmentControl.numberOfSegments);
    float h = filterSegmentControl.frame.size.height;
    CGRect rect;
    //if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]))
    //    rect = CGRectMake(y, x, h, w);
    //else
        rect = CGRectMake(x, y, w, h);
    return rect;
    
}

-(void) doneWithVVDatePicker:(VVDatePickerViewController *)dpvc {
    if (dpc==dpvc) {
        NSString *dateString = [self stringFromDate:dpc.dp.date withFormat:@"MM/dd/yy"];
        if (filterSegmentControl.selectedSegmentIndex==0) {
//            api.afterDate=dpc.dp.date;
            [filterSegmentControl setTitle:dateString forSegmentAtIndex:0];
        } else {
//            api.beforeDate=dpc.dp.date;
            [filterSegmentControl setTitle:dateString forSegmentAtIndex:1];
        }
        [self getData:1];
        filterSegmentControl.selectedSegmentIndex=-1;
        [self retractDatePicker];
    }
}

-(void) clearCalledFromVVDatePicker:(VVDatePickerViewController*)dpvc {
    if (dpc==dpvc) {
        if (filterSegmentControl.selectedSegmentIndex==0) {
//            api.afterDate=nil;
            [filterSegmentControl setTitle:@"From Date" forSegmentAtIndex:0];
        } else {
//            api.beforeDate=nil;
            [filterSegmentControl setTitle:@"To Date" forSegmentAtIndex:1];
        }
        [self getData:1];
        filterSegmentControl.selectedSegmentIndex=-1;
        [self retractDatePicker];
    }
}

-(void) retractDatePicker {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        [dpcovc dismissPopoverAnimated:YES];
    } else {
#ifndef TEST
        [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
#endif
        CGRect keypadFrame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 260);
        dpc.view.frame = keypadFrame;
        tv.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
#ifndef TEST
        [UIView commitAnimations];
#endif
    }
	dpc.view.hidden = YES;
}

- (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)format {
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:format];
	[outputFormatter setTimeZone:[NSTimeZone localTimeZone]];			//display time in local time zone
	NSString *timestamp_str = [outputFormatter stringFromDate:date];
	return timestamp_str;
}


@end
