//
//  B3MediaListViewController.m

//
//  Created by Benjamin Askren on 9/20/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


#import "B3MediaListViewController.h"
#import "B3MediaCell.h"
#import "B3Utils.h"
#import "UITableView+PRPSubviewAdditions.h"
#import "PRPAlertView.h"

#import "UIImageView+WebCache.h"

#import <EventKit/EventKit.h>

#import "MBProgressHUD.h"
#import "NSArray+Reverse.h"

#define kRowHeight 110.0
#define kNoResultsRowHeight 424.0

#define inset -44


NSDictionary *mediaType;
iToast *_B3MediaListViewControllerToast=nil;
CGRect _B3MediaListViewControllerHeaderFrame;
BOOL _B3MediaListViewFreshLoad=YES;

@interface B3MediaListViewController ()

@end

@implementation B3MediaListViewController

@synthesize settingsDictionary, listItems,filteredListItems, moviePlayer, photoItems,toolbar;

- (id)initWithApi:(VVCMSAPI*)x {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        api = x;
        api.delegate = self;
        _B3MediaListViewFreshLoad=YES;
        lastSelectedIndex=-1;
    }
    return self;
}

-(void)VVCMSAPI:(VVCMSAPI *)vvCmsApi authenticationRequestDidFinishWithError:(NSError *)error {
    if (vvCmsApi==api) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not authenticate" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
        [self refreshDataSource];
    }
}

+(void) initialize {
    mediaType = [NSDictionary dictionaryWithObjectsAndKeys:
                 [NSNumber numberWithInt: B3MediaCellTypeAudio],@"audio",
                 [NSNumber numberWithInt:B3MediaCellTypeDOC],@"doc",
                 [NSNumber numberWithInt:B3MediaCellTypeDocument],@"document",
                 [NSNumber numberWithInt:B3MediaCellTypeGallery],@"gallery",
                 [NSNumber numberWithInt:B3MediaCellTypeHTML],@"html",
                 [NSNumber numberWithInt:B3MediaCellTypePDF],@"pdf",
                 [NSNumber numberWithInt:B3MediaCellTypePhoto],@"photo",
                 [NSNumber numberWithInt:B3MediaCellTypeRTF],@"rtf",
                 [NSNumber numberWithInt:B3MediaCellTypeTXT],@"txt",
                 [NSNumber numberWithInt:B3MediaCellTypeVideo],@"video",
                 [NSNumber numberWithInt:B3MediaCellTypeBroadcast],@"broadcast",
                 [NSNumber numberWithInt:B3MediaCellTypeXLS],@"xls",
                 [NSNumber numberWithInt:B3MediaCellTypeArticle],@"article",
                 [NSNumber numberWithInt:B3MediaCellTypeFutureBroadcast],@"futureBroadcast",
                 [NSNumber numberWithInt:B3MediaCellTypeLiveBroadcast],@"liveBroadcast",
                 [NSNumber numberWithInt:B3MediaCellTypeScheduledBroadcast],@"scheduledBroadcast",
                 nil];
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    loadingCells = [[NSMutableDictionary alloc] initWithCapacity:100];
    backgroundQueue = dispatch_queue_create("com.ihigh.b3medialistviewcontroller", NULL);
    
    appDelegate = (BBBAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // Do any additional setup after loading the view from its nib.
    tv.rowHeight = kRowHeight;
    tv.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Folder Wallpaper.JPG"]];
    tv.dataSource = self;
    
    UIButton *imgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 74.0, 27.0)];
    [imgButton setBackgroundImage:[UIImage imageNamed:@"app_logo"] forState:UIControlStateNormal];
    UIBarButtonItem *sourceButton = [[UIBarButtonItem alloc] initWithCustomView:imgButton];
    self.navigationItem.rightBarButtonItem = sourceButton;
    
    [self makeRefreshButton];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contextDidSave:) name:NSManagedObjectContextDidSaveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setVideoReachability) name:@"reachabilityTested" object:nil];
    [self reload];
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
    if (_B3MediaListViewControllerToast)
        [_B3MediaListViewControllerToast hideToast:nil];
//    [APIDataLoader showHUDWithMessage:@"Returning..."];
    [self performSelector:@selector(popViewController) withObject:nil afterDelay:0.1];
    if (self.moviePlayer) {
        self.moviePlayer=nil;
    }
}

-(void) refreshButtonPress {
    [self refreshDataSource];
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


BOOL _B3MediaListViewControllerLastReachableTestResult;
BOOL _B3MediaListViewControllerWaitingForReachabilityResult;
dispatch_queue_t _B3MediaListViewControllerBackgroundQueue;

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    myTimer = [NSTimer scheduledTimerWithTimeInterval: 30.0 target: self selector: @selector(testAndReload) userInfo: nil repeats: YES];
    //NSLog(@"%f %f %f %f",searchBar.frame.origin.x, searchBar.frame.origin.y, searchBar.frame.size.width, searchBar.frame.size.height);
//    [self setBackButtonOrientation:self.parentViewController.interfaceOrientation];
//    [self setBackButtonOrientation:self.interfaceOrientation];
//    [B3SchoolBannerView setOrientation:self.interfaceOrientation];
}

BOOL _B3MediaListViewControllerSearchToast=NO;

-(void) viewDidAppear:(BOOL)animated {
    if (moviePlayer.moviePlayer.errorLog)
        NSLog(@"movie.errorLog: %@",moviePlayer.moviePlayer.errorLog);
//    [banner redraw];
    visible=YES;
    lastSelectedIndex=-1;
    live=0;
    upcoming=0;
    archived=0;
    scheduledBroadcasts = [NSMutableArray arrayWithCapacity:5];
    streamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
    notStreamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
    archivedBroadcasts  = [NSMutableArray arrayWithCapacity:5];


    if (!_B3MediaListViewControllerSearchToast) {
        [self performSelector:@selector(searchToast) withObject:nil afterDelay:1.0];
    }
    //NSLog(@"%f %f %f %f",searchBar.frame.origin.x, searchBar.frame.origin.y, searchBar.frame.size.width, searchBar.frame.size.height);
    if (_B3MediaListViewFreshLoad)
        tv.contentOffset = CGPointMake(0, 44);
    _B3MediaListViewFreshLoad=NO;
    
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
    [self refreshDataSource];
}

-(void) dealloc {
}


-(void) searchToast {
    _B3MediaListViewControllerSearchToast = YES;
    //    NSString *entityName = [[self.settingsDictionary valueForKey:@"Entity"] lowercaseString];
//    _B3MediaListViewControllerToast = [iToast makeText:@"Drag down to search"];
//    [[iToastSettings getSharedSettings] setImage:[UIImage imageNamed:@"DownArrow"] forType:iToastTypeCustom];
//    [_B3MediaListViewControllerToast show:iToastTypeCustom];
}

-(void) viewWillDisappear:(BOOL)animated {
//    [APIDataLoader hideHUD];
    if (_B3MediaListViewControllerToast) [_B3MediaListViewControllerToast hideToast:nil];
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
    if (!_B3MediaListViewControllerBackgroundQueue)
        _B3MediaListViewControllerBackgroundQueue = dispatch_queue_create("com.ihigh.B3MainViewController", NULL);
    if (!_B3MediaListViewControllerWaitingForReachabilityResult) {
        dispatch_async(_B3MediaListViewControllerBackgroundQueue, ^(void) {
            //[api isReachable];
            //_B3MediaListViewControllerWaitingForReachabilityResult=NO;
            //NSLog(@"reachability=%@",[api latestReachabilityResult]?@"YES":@"NO");
            //[self refreshDataSource];
        });
        _B3MediaListViewControllerWaitingForReachabilityResult=YES;
    }
}

-(void) setVideoReachability {
    if ([api latestReachabilityResult]!=_B3MediaListViewControllerLastReachableTestResult) {
        //NSLog(@"willReload");
        dispatch_async(dispatch_get_main_queue(),^(void) {
            [self refreshVisibleCells];
        });
    } else {
        //NSLog(@"wontReload");
    }
    _B3MediaListViewControllerLastReachableTestResult = [api latestReachabilityResult];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (_B3MediaListViewControllerToast)
        [_B3MediaListViewControllerToast hideToast:nil];
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

CGPoint _B3MediaListViewControllerPointBeforeRotate;

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _B3MediaListViewControllerPointBeforeRotate = CGPointMake(tv.contentOffset.x, tv.contentOffset.y);
//    [B3SchoolPage setOrientation:toInterfaceOrientation];
    tv.contentOffset = _B3MediaListViewControllerPointBeforeRotate;
    tv.contentInset = UIEdgeInsetsMake(0, 0, -inset, 0);
    searchBar.hidden=YES;
    [self setBackButtonOrientation:toInterfaceOrientation];
    CGRect frame = toolbar.frame;
    frame.size.height = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)?32:44);
    frame.origin.y += (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)?+12:-12);
    toolbar.frame=frame;
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    tv.contentOffset = _B3MediaListViewControllerPointBeforeRotate;
    searchBar.hidden=NO;
    [self reload];
    [self makeRefreshButton];
}


-(void) refreshDataSource {
    self.siteName = [api siteName];
    self.navigationItem.title = self.siteName;
    [api requestBroadcastsWithStatus:VVCMSBroadcastStatusAll page:1 resultsPerPage:200];
}

-(void) VVCMSAPI:(VVCMSAPI *)vvCmsApi requestForBroadcastsOfStatus:(VVCMSBroadcastStatus)status didFinishWithArray:(NSArray *)events error:(NSError *)error {
    static BOOL archiveSet=NO,streamingSet=NO,scheduledSet=NO;
    if (!error) {
        switch (status) {
            case VVCMSBroadcastStatusAll:
                upcoming=0; live=0; archived=0;
                scheduledBroadcasts = [NSMutableArray arrayWithCapacity:5];
                streamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
                notStreamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
                archivedBroadcasts  = [NSMutableArray arrayWithCapacity:5];
                break;
            case VVCMSBroadcastStatusScheduled:
                upcoming=0;
                scheduledBroadcasts = [NSMutableArray arrayWithCapacity:5];
                break;
            case VVCMSBroadcastStatusStreaming:
                live=0;
                notStreaming = 0;
                streamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
                notStreamingBroadcasts = [NSMutableArray arrayWithCapacity:5];
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
                    if (b.isStreaming) {
                        live++;
                        [streamingBroadcasts addObject:b];
                    } else  {
                        notStreaming++;
                        [notStreamingBroadcasts addObject:b];
                    }
                    break;
                case VVCMSBroadcastStatusArchived:
                    archived++;
                    [archivedBroadcasts addObject:b];
                    break;
            }
        }
        upcoming += notStreaming;
        [scheduledBroadcasts addObjectsFromArray:notStreamingBroadcasts];
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
        [archivedBroadcasts reverse];
        if (status==VVCMSBroadcastStatusAll || status==VVCMSBroadcastStatusScheduled)
            [self dataSourceRefreshComplete];
    } else {
        upcoming=0; live=0; archived=0; notStreaming=0;
        scheduledBroadcasts=nil;
        streamingBroadcasts=nil;
        notStreamingBroadcasts=nil;
        archivedBroadcasts=nil;
        [self dataSourceRefreshComplete];
    }
}

-(void) dataSourceRefreshComplete {
    toolbar.hidden=NO;
    
    if (segCtrl.selectedSegmentIndex==0) {
        listItems = scheduledBroadcasts; // upcoming (incomplete)
    } else if (segCtrl.selectedSegmentIndex==1) {
        listItems = streamingBroadcasts; // live (streaming)
    } else if (segCtrl.selectedSegmentIndex==2) {
        listItems = archivedBroadcasts; // archived (complete)
    }
    [segCtrl setEnabled:(upcoming>0) forSegmentAtIndex:0];
    [segCtrl setEnabled:(live>0) forSegmentAtIndex:1];
    [segCtrl setEnabled:(archived>0) forSegmentAtIndex:2];
    [segCtrl setTitle:[NSString stringWithFormat:@"Upcoming (%d)",upcoming] forSegmentAtIndex:0];
    [segCtrl setTitle:[NSString stringWithFormat:@"Live (%d)",live] forSegmentAtIndex:1];
    [segCtrl setTitle:[NSString stringWithFormat:@"Archived (%d)",archived] forSegmentAtIndex:2];
    
    int index = [segCtrl selectedSegmentIndex];
    
//    NSLog(@"index=[%d]",index);
    if ((index==0 && !upcoming) || (index==1 && !live) || (index==2 && !archived) )
        lastSelectedIndex=-1;
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
    

    
    filteredListItems = [NSMutableArray array];
    [tv reloadData];
}

-(void) updateBroadcastToolbarAndListItems {
    
}

-(void) segCtrlChanged:(UISegmentedControl *)sc {
    NSLog(@"selectedIndex=[%d]",sc.selectedSegmentIndex);
    [self refreshDataSource];
    [tv reloadData];
}


- (void) reload {
    [self refreshDataSource];
    [tv reloadData];
//    [banner redraw];
}

- (void) refreshVisibleCells {
    NSArray *visCells = [tv indexPathsForVisibleRows];
    [tv reloadRowsAtIndexPaths:visCells withRowAnimation:UITableViewRowAnimationNone];
}

BOOL _B3MediaListDragging=NO;


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    _B3MediaListDragging=NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _B3MediaListDragging=YES;
}

-(void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_B3MediaListDragging) {
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
    B3MediaCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"B3MediaCell" owner:self options:nil];
        cell = (B3MediaCell *)[nib objectAtIndex:0];
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
    cell.type = [[mediaType objectForKey:@"broadcast"] intValue];
    
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
    
//    NSNumber *nViews = [theObject valueForKey:@"numberOfViews"];
//    if (nViews && nViews.intValue>0)
//        cell.meta2 = [NSString stringWithFormat:@"%@ views",[nViews stringValue]];
//    else
        cell.meta2 = nil;

    UIImage *placeholder;;
    if (broadcast.audioOnly)
        placeholder = audioImage;
    else if (segCtrl.selectedSegmentIndex==0)
        placeholder = schedImage;
    else if (segCtrl.selectedSegmentIndex==1)
        placeholder = liveImage;
    else if (segCtrl.selectedSegmentIndex==2)
        placeholder = archImage;
    
    if (broadcast.thumbnailURL && ![broadcast.thumbnailURL isEqualToString:@""] ) {
        [cell.imgThumb setImageWithURL:[NSURL URLWithString:broadcast.thumbnailURL]placeholderImage:placeholder];
    } else {
        [cell.imgThumb setImage:placeholder];
    }

    cell.read = YES;
    cell.favorite = NO;
    return cell;
}

VVCMSBroadcast *_B3MediaListViewSelectedBroadcast;

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
    //EKEventStore *eventStore=[[EKEventStore alloc] init];
    EKEvent *addEvent=[EKEvent eventWithEventStore:eventStore];
//    addEvent.title=_B3MediaListViewEventName;
//    addEvent.startDate=_B3MediaListViewEventDate;
//    addEvent.title = [_B3MediaListViewSelectedBroadcast valueForKey:@"title"];
//    addEvent.startDate = [_B3MediaListViewSelectedBroadcast valueForKey:@"itemDate"];
//    addEvent.endDate=[addEvent.startDate dateByAddingTimeInterval:3600];
    addEvent.title = _B3MediaListViewSelectedBroadcast.title;
    addEvent.startDate = _B3MediaListViewSelectedBroadcast.startDate;
    [addEvent setCalendar:[eventStore defaultCalendarForNewEvents]];
    addEvent.alarms=[NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:addEvent.startDate]];
    //[eventStore saveEvent:addEvent span:EKSpanThisEvent error:nil];
    
    NSError *error;
    BOOL saved = [eventStore saveEvent:addEvent span:EKSpanThisEvent error:&error];
    if (!saved) {
        NSLog(@"error=%@",error);
        [PRPAlertView showWithTitle:@"Failed to Create Event" message:@"There was an error we did not anticipate.  Please excuse the inconvenience." buttonTitle:@"OK"];
    } else {
        _B3MediaListViewControllerToast = [iToast makeText:@"Saved to Calendar"];
        [[_B3MediaListViewControllerToast setDuration:iToastDurationShort] show];
//        [_B3MediaListViewSelectedBroadcast setValue:[NSNumber numberWithBool:YES] forKey:@"onCalendar"];
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
        
        if (moviePlayer)
            moviePlayer=nil;
        moviePlayer = [[VVMoviePlayerViewController alloc] initWithExtendedVMAPURIString:vmapString];
        
        if (self.moviePlayer) {
            moviePlayer.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
            [moviePlayer.moviePlayer prepareToPlay];
            [self performSelector:@selector(prelaunchMovie:) withObject:moviePlayer afterDelay:0.1];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
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
    _B3MediaListViewSelectedBroadcast = bcast;
    [self delayedStartVMAP:bcast.vmapURL];
}

-(void) playbackFinished:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
}


- (void) prelaunchMovie:(MPMoviePlayerViewController *) mpvc {
    if ([[mpvc moviePlayer] loadState] == MPMovieLoadStateUnknown) { // before you wreck yourself
        [self performSelector:@selector(prelaunchMovie:) withObject:mpvc afterDelay:0.1];
    } else if ([[mpvc moviePlayer] loadState]== MPMovieLoadStateStalled) {
        [self hideHUD];
    } else {
        [self hideHUD];
        [self performSelector:@selector(launchMovie:) withObject:mpvc afterDelay:0.05];
    }
}

-(void) launchMovie:(VVMoviePlayerViewController *)mpvc {
    [appDelegate.navigationController presentVolarMoviePlayerViewControllerAnimated:mpvc];
}



double _B3MediaPlayerRestartSkip=0;
BOOL   _B3MediaPlayerSkipLockout=NO;



-(void) requeVideo:(AVPlayerLayer *) playerLayer {
    _B3MediaPlayerSkipLockout=YES;
    [self performSelector:@selector(resumePlayingMovie:) withObject:playerLayer afterDelay:5];
    moviePlayer.moviePlayer.currentPlaybackTime+=_B3MediaPlayerRestartSkip;
    _B3MediaPlayerRestartSkip=0;
}


-(void) customButtonPressedInSearchBar:(B3SearchBar *)searchBar {    
    VVDomainList *domainListView;
    domainListView = [[VVDomainList alloc] initWithNibName:nil bundle:nil];
    domainListView.delegate=self;
    if (self.navigationController)
        [self.navigationController pushViewController:domainListView animated:YES];
    else
        [self presentModalViewController:domainListView animated:YES];
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    //NSLog(@"");
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
}

-(void) setUserName:(NSString*) s {
    userName = s;
}

-(void) setPassword:(NSString *) s {
    password = s;
}
@end
