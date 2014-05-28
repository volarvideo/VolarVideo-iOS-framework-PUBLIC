//
//  VVMediaListViewController.h

//
//  Created by Benjamin Askren on 9/20/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import <VVMoviePlayer/VVCMSAPI.h>

#import <UIKit/UIKit.h>
#import "VVMediaCell.h"
#import <QuickLook/QuickLook.h>
#import "VVAppDelegate.h"
#import "B3SearchBar.h"
#import "VVDomainList.h"
#import "VVSiteListViewController.h"

#import <VVMoviePlayer/VVMoviePlayerViewController.h>
#import "VVPickerViewController.h"
#import "VVDatePickerDelegate.h"
#import "VVDatePickerViewController.h"


@interface VVMediaListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
    UISearchDisplayDelegate, UINavigationBarDelegate, B3SearchBarDelegate, \
    UIAlertViewDelegate, VVCMSAPIDelegate, VVSiteListViewControllerDelegate, \
    VVDomainListDelegate, VVPickerViewDelegate, UIPopoverControllerDelegate,
    VVDatePickerDelegate> {
    
    IBOutlet UITableView *tv;
    IBOutlet UISearchDisplayController *searchDisplayController;
    IBOutlet B3SearchBar *searchBar;
    IBOutlet UISegmentedControl *filterSegmentControl;
    VVAppDelegate *appDelegate;
    NSMutableDictionary *loadingCells;
    dispatch_queue_t backgroundQueue;
    BOOL visible;
    NSTimer* myTimer;
    UIButton *backButton;
    UISegmentedControl *segCtrl;
    int upcoming,live,archived;
    int lastSelectedIndex;
    
    VVCMSAPI *api;
    
    NSMutableArray *archivedBroadcasts,*scheduledBroadcasts,*streamingBroadcasts;
    
    UIImage *audioImage,*schedImage,*liveImage,*archImage;
        
    NSString *userName,*password;
    
    VVPickerViewController *svc;
    NSArray *sections,*playlists;
    
    BOOL virginloading,loading;
    
    VVDatePickerViewController *dpc;
}

//@property(nonatomic, unsafe_unretained) IBOutlet B3SchoolBannerView *banner;        //for iOS 4.3 support
@property(nonatomic,assign) enum VVMediaCellType type;
@property(nonatomic,strong) NSString* siteName;
//@property (nonatomic, strong) School *currentSchool;
@property (nonatomic, strong) NSDictionary *settingsDictionary;
@property (nonatomic, strong) NSMutableArray *listItems;
@property (nonatomic, strong) NSMutableArray *filteredListItems;
@property (nonatomic, strong) NSMutableArray *photoItems;
@property (nonatomic, strong) VVMoviePlayerViewController *moviePlayer;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property(nonatomic, strong) UIPopoverController *svpovc, *dpcovc;

 -(IBAction) filterSegmentValueChanged:(id)sender;


//- (IBAction)cellButtonFavoriteTouched:(id)sender;
- (void)customButtonPressedInSearchBar:(B3SearchBar *)searchBar;

//- (id)initWithSchool:(School*)theSchool andSettingsDictionary:(NSDictionary*)settingsDict;
- (id)initWithApi:(VVCMSAPI*)api;
- (id)initWithSiteSlug:(NSString*)site;

-(void) startVMAP:(NSString *)vmapString;

@end
