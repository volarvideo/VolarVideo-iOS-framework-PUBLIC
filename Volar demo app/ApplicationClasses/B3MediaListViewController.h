//
//  B3MediaListViewController.h

//
//  Created by Benjamin Askren on 9/20/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import <VVMoviePlayer/VVCMSAPI.h>

#import <UIKit/UIKit.h>
//#import "B3SchoolBannerView.h"
#import "B3MediaCell.h"
#import <QuickLook/QuickLook.h>
//#import "School.h"
#import "BBBAppDelegate.h"
#import "B3SearchBar.h"
#import "VVDomainList.h"

#import <VVMoviePlayer/VVMoviePlayerViewController.h>


@interface B3MediaListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, UINavigationBarDelegate, B3SearchBarDelegate, UIAlertViewDelegate, VVCMSAPIDelegate, VVDomainListDelegate> {
    
    IBOutlet UITableView *tv;
    IBOutlet UISearchDisplayController *searchDisplayController;
    IBOutlet B3SearchBar *searchBar;
    BBBAppDelegate *appDelegate;
    NSMutableDictionary *loadingCells;
    dispatch_queue_t backgroundQueue;
    BOOL visible;
    NSTimer* myTimer;
    UIButton *backButton;
    UISegmentedControl *segCtrl;
    int upcoming,live,archived,notStreaming;
    int lastSelectedIndex;
    
    VVCMSAPI *api;
    
    NSMutableArray *archivedBroadcasts,*scheduledBroadcasts, *streamingBroadcasts, *notStreamingBroadcasts;
    
    UIImage *audioImage,*schedImage,*liveImage,*archImage;
        
    NSString *userName,*password;
}

//@property(nonatomic, unsafe_unretained) IBOutlet B3SchoolBannerView *banner;        //for iOS 4.3 support
@property(nonatomic,assign) enum B3MediaCellType type;
@property(nonatomic,strong) NSString* siteName;
//@property (nonatomic, strong) School *currentSchool;
@property (nonatomic, strong) NSDictionary *settingsDictionary;
@property (nonatomic, strong) NSMutableArray *listItems;
@property (nonatomic, strong) NSMutableArray *filteredListItems;
@property (nonatomic, strong) NSMutableArray *photoItems;
@property (nonatomic, strong) VVMoviePlayerViewController *moviePlayer;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;


//- (IBAction)cellButtonFavoriteTouched:(id)sender;
- (void)customButtonPressedInSearchBar:(B3SearchBar *)searchBar;

//- (id)initWithSchool:(School*)theSchool andSettingsDictionary:(NSDictionary*)settingsDict;
- (id)initWithApi:(VVCMSAPI*)api;

-(void) startVMAP:(NSString *)vmapString;

@end
