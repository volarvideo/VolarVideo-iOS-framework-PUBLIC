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
//#import "UITableView+PRPSubviewAdditions.h"
#import "PRPAlertView.h"

#import "UIImageView+WebCache.h"

#import <EventKit/EventKit.h>

#import "MBProgressHUD.h"
#import "NSArray+Reverse.h"


#define kRowHeight 110.0
#define kNoResultsRowHeight 424.0

// I don't understand why the inset was originally conceived, however it was the cause
// of the second part of issue #6 (the blank space below the list of videos). The inset
// is only used to change the height of tv.contentInset (in viewDidLoad and other places)

// The documentation on UIEdgeInsetsMake was not extremely helpful. Someting about
// subpixel resampling. It didn't sound related to our table view. So I killed it.

// With fire.

//#define inset -44
#define inset 0

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
#define iOS7Code(code, alt) if([[[UIDevice currentDevice]systemVersion]floatValue]>=7){code;}
#else
#define iOS7Code(code, alt) alt
#endif

iToast *_VVMediaListViewControllerToast=nil;
CGRect _VVMediaListViewControllerHeaderFrame;
BOOL _VVMediaListViewFreshLoad=YES;
int _VVMediaListViewRefreshedQueued=0;
UIView *navBarTapView;

@interface VVMediaListViewController ()

@property(nonatomic,strong) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation VVMediaListViewController

@synthesize settingsDictionary, listItems,filteredListItems, moviePlayer, photoItems,toolbar,svpovc,dpcovc;

- (id)initWithApi:(VVCMSAPI*)x {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        api = x;
        [self commonInit];
        [self refreshDataSource:true];
    }
    return self;
}

- (id)initWithSiteSlug:(NSString *)siteSlug {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        api = [VVCMSAPI vvCMSAPI];
        [self commonInit];
        NSString *domain = @"vcloud.volarvideo.com";
#if defined(DEMO_APP)
        domain = [VVDomainList getCurrDomain];
        NSLog(@"domain: %@", domain);
#endif
        [api authenticationRequestForDomain:domain siteSlug:siteSlug username:nil andPassword:nil];
        if ([siteSlug isEqualToString:@"themwc"])
            api.siteSlugs = [NSArray arrayWithObjects:@"AFA",@"BOSU",@"CSU",@"Fresno",@"Nevada",@"UNM",@"SDSU",@"SJSU",@"UNLV",@"USU",@"UWYO", nil];
    }
    return self;
}

-(void) commonInit {
    virginloading = YES;
    loading = YES;
    api.delegate = self;
    _VVMediaListViewFreshLoad=YES;
    lastSelectedIndex=-1;
    appDelegate = (VVAppDelegate*)[[UIApplication sharedApplication] delegate];
    backgroundQueue = dispatch_queue_create("com.ihigh.VVMedialistviewcontroller", NULL);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVideoReachability) name:@"reachabilityTested" object:nil];
}

-(void)VVCMSAPI:(VVCMSAPI *)vvCmsApi authenticationRequestDidFinishWithError:(NSError *)error {
    if (vvCmsApi==api) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not authenticate" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        [self refreshDataSource:true];
    }
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
    [segCtrl setTitle:@"Sport" forSegmentAtIndex:2];
    api.section_id = 0;
}

-(void)VVCMSAPI:(VVCMSAPI *)vvCmsApi requestForPlaylistsPage:(int)page resultsPerPage:(int)resultsPerPage didFinishWithArray:(NSArray *)results error:(NSError *)error {
    if (vvCmsApi==api) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not get playlists" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    playlists = results;
    api.playlist_id = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    loadingCells = [[NSMutableDictionary alloc] initWithCapacity:100];
    
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

    [self.searchDisplayController.searchResultsTableView setRowHeight:kRowHeight];

//    [self useEnhancedBackButton];
    
    tv.contentInset = UIEdgeInsetsMake(0, 0, -inset, 0);

    audioImage = [UIImage imageNamed:@"iconGenericAudio"];
    schedImage = [UIImage imageNamed:@"scheduledBroadcast"];
    liveImage = [UIImage imageNamed:@"iconLiveBroadcast"];
    archImage = [UIImage imageNamed:@"iconGenericVideo"];
    
    // Thank god for Stack Overflow:
    // http://stackoverflow.com/questions/19081697/ios-7-navigation-bar-hiding-content
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) { // if iOS 7
        self.edgesForExtendedLayout = UIRectEdgeNone; //layout adjustements
    }
    
    [self refreshDataSource:true];
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
    [self refreshDataSource:false];
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
    loadingCells=nil;
    backgroundQueue=nil;
    filteredListItems=nil;
    listItems=nil;
    photoItems=nil;
}


BOOL _VVMediaListViewControllerLastReachableTestResult;
BOOL _VVMediaListViewControllerWaitingForReachabilityResult;
dispatch_queue_t _VVMediaListViewControllerBackgroundQueue;

- (void) viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
}

BOOL _VVMediaListViewControllerSearchToast=NO;

-(void) viewDidAppear:(BOOL)animated {
    if (moviePlayer.moviePlayer.errorLog)
        NSLog(@"movie.errorLog: %@",moviePlayer.moviePlayer.errorLog);
    visible=YES;

    if (!_VVMediaListViewControllerSearchToast) {
        [self performSelector:@selector(searchToast) withObject:nil afterDelay:1.0];
    }
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
        [segCtrl insertSegmentWithTitle:@"" atIndex:0 animated:NO];
        [segCtrl insertSegmentWithTitle:@"" atIndex:1 animated:NO];
        [segCtrl insertSegmentWithTitle:@"" atIndex:2 animated:NO];
        segCtrl.selectedSegmentIndex=2;
    }

    self.navigationItem.title = self.siteName;
    
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


-(void) searchToast {
    _VVMediaListViewControllerSearchToast = YES;
    //    NSString *entityName = [[self.settingsDictionary valueForKey:@"Entity"] lowercaseString];
//    _VVMediaListViewControllerToast = [iToast makeText:@"Drag down to search"];
//    [[iToastSettings getSharedSettings] setImage:[UIImage imageNamed:@"DownArrow"] forType:iToastTypeCustom];
//    [_VVMediaListViewControllerToast show:iToastTypeCustom];
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


-(void) testAndReload {
    //if (!_VVMediaListViewControllerBackgroundQueue)
    //    _VVMediaListViewControllerBackgroundQueue = dispatch_queue_create("com.ihigh.B3MainViewController", NULL);
    //if (!_VVMediaListViewControllerWaitingForReachabilityResult) {
        //dispatch_async(_VVMediaListViewControllerBackgroundQueue, ^(void) {
            //[api isReachable];
            //_VVMediaListViewControllerWaitingForReachabilityResult=NO;
            //NSLog(@"reachability=%@",[api latestReachabilityResult]?@"YES":@"NO");
            //[self refreshDataSource];
        //});
        //_VVMediaListViewControllerWaitingForReachabilityResult=YES;
    //}
}

-(void) setVideoReachability {
    if ([api latestReachabilityResult]!=_VVMediaListViewControllerLastReachableTestResult) {
        //NSLog(@"willReload");
        dispatch_async(dispatch_get_main_queue(),^(void) {
            [self refreshVisibleCells];
        });
    } else {
        //NSLog(@"wontReload");
    }
    _VVMediaListViewControllerLastReachableTestResult = [api latestReachabilityResult];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    tv.contentInset = UIEdgeInsetsMake(0, 0, -inset, 0);
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
        VVSiteListViewController *slc = [[VVSiteListViewController alloc] initWithApi:api];
        slc.delegate = self;
        [self.navigationController pushViewController:slc animated:YES];
    }
}

-(void) doneWithVVSiteListViewController:(id)slvc {
    [self refreshDataSource:true];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void) refreshDataSource:(BOOL) cleanSlate {
    _VVMediaListViewRefreshedQueued++;
    self.spinner.hidden=NO;
    [self.spinner startAnimating];
    
    if (cleanSlate) {
        api.delegate = self;
        loading=YES;
        lastSelectedIndex=-1;
        live=0;
        upcoming=0;
        archived=0;
        scheduledBroadcasts = [NSMutableArray arrayWithCapacity:5];
        streamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
        archivedBroadcasts  = [NSMutableArray arrayWithCapacity:5];
    }
    
    self.siteName = [api siteName];
    self.navigationItem.title = self.siteName;
    if (loading) {
        api.sortDir = vvCMSAPISortAscending;
        api.sortBy = VVCMSAPISortByDate;
        [api requestBroadcastsWithStatus:VVCMSBroadcastStatusScheduled page:1 resultsPerPage:50];
        [api requestBroadcastsWithStatus:VVCMSBroadcastStatusStreaming page:1 resultsPerPage:50];
        api.sortDir = vvCMSAPISortDescending;
        [api requestBroadcastsWithStatus:VVCMSBroadcastStatusArchived page:1 resultsPerPage:50];
        [api requestSectionsPage:1 resultsPerPage:50];
        [api requestPlaylistsPage:1 resultsPerPage:50];
    } else {
        switch (segCtrl.selectedSegmentIndex) {
            case 0: // upcoming (scheduled)
                api.sortDir = vvCMSAPISortAscending;
                api.sortBy = VVCMSAPISortByDate;
                [api requestBroadcastsWithStatus:VVCMSBroadcastStatusScheduled page:1 resultsPerPage:50];
                break;
            case 1: // live
                api.sortDir = vvCMSAPISortAscending;
                api.sortBy = VVCMSAPISortByDate;
                [api requestBroadcastsWithStatus:VVCMSBroadcastStatusStreaming page:1 resultsPerPage:50];
                break;
            case 2: // archived
                api.sortDir = vvCMSAPISortDescending;
                [api requestBroadcastsWithStatus:VVCMSBroadcastStatusArchived page:1 resultsPerPage:50];
                break;
            default:
                api.sortDir = vvCMSAPISortAscending;
                api.sortBy = VVCMSAPISortByDate;
                [api requestBroadcastsWithStatus:VVCMSBroadcastStatusScheduled page:1 resultsPerPage:50];
                [api requestBroadcastsWithStatus:VVCMSBroadcastStatusStreaming page:1 resultsPerPage:50];
                api.sortDir = vvCMSAPISortAscending;
                [api requestBroadcastsWithStatus:VVCMSBroadcastStatusArchived page:1 resultsPerPage:50];
                break;
        }
    }
}

-(void) VVCMSAPI:(VVCMSAPI *)vvCmsApi requestForBroadcastsOfStatus:(VVCMSBroadcastStatus)status didFinishWithArray:(NSArray *)events error:(NSError *)error {
    _VVMediaListViewRefreshedQueued--;
    if (_VVMediaListViewRefreshedQueued<=0) {
        self.spinner.hidden=YES;
        [self.spinner stopAnimating];
    }
    static BOOL archiveSet=NO,streamingSet=NO,scheduledSet=NO;
    if (!error && ![events isKindOfClass:[NSNull class]]) {
        switch (status) {
            case VVCMSBroadcastStatusAll:
                upcoming=0; live=0; archived=0;
                scheduledBroadcasts = [NSMutableArray arrayWithCapacity:5];
                streamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
                archivedBroadcasts  = [NSMutableArray arrayWithCapacity:5];
                break;
            case VVCMSBroadcastStatusScheduled:
                upcoming=0;
                scheduledBroadcasts = [NSMutableArray arrayWithCapacity:5];
                break;
            case VVCMSBroadcastStatusStreaming:
                live=0;
                streamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
                break;
            case VVCMSBroadcastStatusArchived:
                archived=0;
                archivedBroadcasts  = [NSMutableArray arrayWithCapacity:5];
                break;
            case VVCMSBroadcastStatusUnknown:
                return;
        }
        for (VVCMSBroadcast *b in events) {
            switch (b.status) {
                case VVCMSBroadcastStatusAll:
                case VVCMSBroadcastStatusUnknown:
                    break;
                case VVCMSBroadcastStatusScheduled:
                    [scheduledBroadcasts addObject:b];
                    upcoming++;
                    break;
                case VVCMSBroadcastStatusStreaming:
                    live++;
                    [streamingBroadcasts addObject:b];
                    break;
                case VVCMSBroadcastStatusArchived:
                    archived++;
                    [archivedBroadcasts addObject:b];
                    break;
            }
        }
        BOOL oldState = (archiveSet && streamingSet && scheduledSet);
        switch (status) {
            case VVCMSBroadcastStatusAll:
                archiveSet=YES;
                streamingSet=YES;
                scheduledSet=YES;
                break;
            case VVCMSBroadcastStatusScheduled:
                scheduledSet=YES;
                break;
            case VVCMSBroadcastStatusStreaming:
                streamingSet=YES;
                break;
            case VVCMSBroadcastStatusArchived:
                archiveSet=YES;
                break;
            case VVCMSBroadcastStatusUnknown:
                return;
        }
        BOOL newState = (archiveSet && streamingSet && scheduledSet);
        if (oldState != newState) {
            if (archived)
                segCtrl.selectedSegmentIndex=2;
            else if (live)
                segCtrl.selectedSegmentIndex=1;
            else
                segCtrl.selectedSegmentIndex=0;
        }
        if (loading) {
            loading=NO;
            [archivedBroadcasts reverse];
            if (appDelegate && virginloading) [appDelegate finishedLoadingBroadcastsWithError:error];
            virginloading=NO;
        }
    } else {
        upcoming=0; live=0; archived=0;
        scheduledBroadcasts=nil;
        streamingBroadcasts=nil;
        archivedBroadcasts=nil;
    }
    [self dataSourceRefreshComplete];
}

-(void) dataSourceRefreshComplete {
    toolbar.hidden=NO;
    
    if (loading)
        return;
    
    
    if (segCtrl.selectedSegmentIndex==0) {
        listItems = scheduledBroadcasts; // upcoming (incomplete)
    } else if (segCtrl.selectedSegmentIndex==1) {
        listItems = streamingBroadcasts; // live (streaming)
    } else if (segCtrl.selectedSegmentIndex==2) {
        listItems = archivedBroadcasts; // archived (complete)
    }
    //[segCtrl setEnabled:(upcoming>0) forSegmentAtIndex:0];
    //[segCtrl setEnabled:(live>0) forSegmentAtIndex:1];
    //[segCtrl setEnabled:(archived>0) forSegmentAtIndex:2];
    [segCtrl setTitle:[NSString stringWithFormat:@"Upcoming (%d)",upcoming] forSegmentAtIndex:0];
    [segCtrl setTitle:[NSString stringWithFormat:@"Live (%d)",live] forSegmentAtIndex:1];
    [segCtrl setTitle:[NSString stringWithFormat:@"Archived (%d)",archived] forSegmentAtIndex:2];
    
    int index = [segCtrl selectedSegmentIndex];
    
    if ((index==0 && !upcoming) || (index==1 && !live) || (index==2 && !archived) )
        lastSelectedIndex=-1;
    /*
    if (lastSelectedIndex==-1) {
        if (live)
            [segCtrl setSelectedSegmentIndex:1];
        else if (archived)
            [segCtrl setSelectedSegmentIndex:2];
        else if (upcoming)
            [segCtrl setSelectedSegmentIndex:0];
        lastSelectedIndex = segCtrl.selectedSegmentIndex;
    }
    if (!live && !archived && !upcoming)
        lastSelectedIndex = -1;
    */

    
    filteredListItems = [NSMutableArray array];
    [tv reloadData];
}

-(void) updateBroadcastToolbarAndListItems {
    
}

-(void) segCtrlChanged:(UISegmentedControl *)sc {
    NSLog(@"selectedIndex=[%d]",sc.selectedSegmentIndex);
    [self refreshDataSource:false];
}


- (void) reload {
    [self refreshDataSource:false];
    [tv reloadData];
//    [banner redraw];
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
            [tv setContentInset:UIEdgeInsetsMake(0, 0, -inset, 0)];
        else if (scrollView.contentOffset.y>44)
            [tv setContentInset:UIEdgeInsetsMake(inset, 0, -inset, 0)];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //if (model) return model.numberOfItems;
    NSUInteger rows = 0;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rows = [filteredListItems count];
    }
    else {
        rows = [listItems count];
    }
    return rows;
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
    VVCMSBroadcast *broadcast;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (!filteredListItems || [filteredListItems isKindOfClass:[NSNull class]])
            return cell;
        broadcast = [filteredListItems objectAtIndex:indexPath.row];
    } else {
        if (!listItems || [listItems isKindOfClass:[NSNull class]])
            return cell;
        broadcast = [listItems objectAtIndex:indexPath.row];
    }

    
    cell.disabled=NO;
        cell.disabled = ![api latestReachabilityResult];
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
    
    cell.meta2 = nil;

    UIImage *placeholder;;
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
    if ([api isReachable]) {
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
    else {
        [self hideHUD];
    }

}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self showHUD];
    NSDictionary *objects = @{@"tableView":tableView, @"indexPath":indexPath};
    [self performSelector:@selector(didSelectRowAtIndexPath:) withObject:objects afterDelay:0.1];
}

- (void) didSelectRowAtIndexPath:(NSDictionary *)objects {
    UITableView *tableView = [objects objectForKey:@"tableView"];
    NSIndexPath *indexPath = [objects objectForKey:@"indexPath"];
    VVCMSBroadcast *bcast;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        bcast = [filteredListItems objectAtIndex:indexPath.row];
    }
    else {
        bcast = [listItems objectAtIndex:indexPath.row];
    }
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

double _VVMediaPlayerRestartSkip=0;
BOOL   _VVMediaPlayerSkipLockout=NO;



-(void) requeVideo:(AVPlayerLayer *) playerLayer {
    _VVMediaPlayerSkipLockout=YES;
    [self performSelector:@selector(resumePlayingMovie:) withObject:playerLayer afterDelay:5];
    moviePlayer.moviePlayer.currentPlaybackTime+=_VVMediaPlayerRestartSkip;
    _VVMediaPlayerRestartSkip=0;
}


-(void) customButtonPressedInSearchBar:(B3SearchBar *)searchBar {    
    VVDomainList *domainListView;
    domainListView = [[VVDomainList alloc] initWithApi:api];
    domainListView.delegate = self;
    if (self.navigationController)
        [self.navigationController pushViewController:domainListView animated:YES];
    else
        [self presentModalViewController:domainListView animated:YES];
}

-(void) domainDidChange:(id)dl {
    [self refreshDataSource:true];
}


#pragma mark -
#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText
{
    [filteredListItems removeAllObjects]; // First clear the filtered array.
    
    NSString *searchString = nil;
    id item;
    for (item in listItems) {
        searchString = [item valueForKey:@"title"];
        if (searchString && ![searchString isKindOfClass:[NSNull class]]) {
            NSRange range = [searchString rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if (range.length > 0) {
                [filteredListItems addObject:item];
            } else {
                searchString = [item valueForKey:@"description"];
                if (searchString && ![searchString isKindOfClass:[NSNull class]]) {
                    range = [searchString rangeOfString:searchText options:NSCaseInsensitiveSearch];
                    if (range.length > 0)
                        [filteredListItems addObject:item];
                }
            }
        }
    }
}


#pragma mark -
#pragma mark UISearchDisplayController Delegate Methods



- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    //[self filterContentForSearchText:[self.searchDisplayController.searchBar text]];
    
    // Return YES to cause the search result table view to be reloaded.
    return NO;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)aTableView {
    //NSLog(@"didshowsearchresultstableview");
    [self setupSearchResultsTableView];
    
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    //NSLog(@"");
    // In iOS 7.0 (and presumably later), the UISearchBar will automatically attach
    // itself to the navigation controller. The navigation controller will also
    // automatically hide itself while leaving the search bar visible. Therefore we
    // don't need to worry about this.
    if([[[UIDevice currentDevice]systemVersion]floatValue]<7){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //NSLog(@"");
    if([[[UIDevice currentDevice]systemVersion]floatValue]<7){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
}

- (void)setupSearchResultsTableView {
    self.searchDisplayController.searchResultsTableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Folder Wallpaper.JPG"]];
    self.searchDisplayController.searchResultsTableView.backgroundColor = [UIColor clearColor];
    self.searchDisplayController.searchResultsTableView.separatorStyle = tv.separatorStyle;
    self.searchDisplayController.searchResultsTableView.separatorColor = tv.separatorColor;
    
    if ([filteredListItems count] > 0)
        [self.searchDisplayController.searchResultsTableView setRowHeight:kRowHeight];
    else {
        [self.searchDisplayController.searchResultsTableView setRowHeight:kNoResultsRowHeight];
    }
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


-(void) setDomain:(NSString *)domain {
    [api authenticationRequestForDomain:domain username:userName andPassword:password];
    
    
    // need to replace below logic with an asynchronous wait for the results from the authentication to be used to determine if we're ready to leave the domain switching screen.
    
    api.searchTitle=nil;
    [filterSegmentControl setTitle:@"Sport" forSegmentAtIndex:2];
}

-(void) setUserName:(NSString*) s {
    userName = s;
}

-(void) setPassword:(NSString *) s {
    password = s;
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
        if ([svc.selectedValue isEqualToString:@"0"]) {
            [filterSegmentControl setTitle:@"Sport" forSegmentAtIndex:2];
        } else
            [filterSegmentControl setTitle:svc.selectedTitle forSegmentAtIndex:2];
        api.section_id = svc.selectedValue;
        [self refreshDataSource:true];
        filterSegmentControl.selectedSegmentIndex=-1;
        [self retractSportPicker];
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
    NSDate *date;
    if (filterSegmentControl.selectedSegmentIndex==0)
        date = api.afterDate;
    else
        date = api.beforeDate;
    if (!date)
        date = [NSDate date];
    dpc.dp.date = date;

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
            api.afterDate=dpc.dp.date;
            [filterSegmentControl setTitle:dateString forSegmentAtIndex:0];
        } else {
            api.beforeDate=dpc.dp.date;
            [filterSegmentControl setTitle:dateString forSegmentAtIndex:1];
        }
        [self refreshDataSource:true];
        filterSegmentControl.selectedSegmentIndex=-1;
        [self retractDatePicker];
    }
}

-(void) clearCalledFromVVDatePicker:(VVDatePickerViewController*)dpvc {
    if (dpc==dpvc) {
        if (filterSegmentControl.selectedSegmentIndex==0) {
            api.afterDate=nil;
            [filterSegmentControl setTitle:@"From Date" forSegmentAtIndex:0];
        } else {
            api.beforeDate=nil;
            [filterSegmentControl setTitle:@"To Date" forSegmentAtIndex:1];
        }
        [self refreshDataSource:true];
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
