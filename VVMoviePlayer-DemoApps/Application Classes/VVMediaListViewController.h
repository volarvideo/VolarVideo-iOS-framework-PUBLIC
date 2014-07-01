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
@property (nonatomic, strong) NSMutableArray *filteredListItems;
@property (nonatomic, strong) NSMutableArray *photoItems;
@property (nonatomic, strong) VVMoviePlayerViewController *moviePlayer;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property(nonatomic, strong) UIPopoverController *svpovc, *dpcovc;

 -(IBAction) filterSegmentValueChanged:(id)sender;
- (void)customButtonPressedInSearchBar:(B3SearchBar *)searchBar;
- (id)initWithSiteSlug:(NSString*)site;
-(void) startVMAP:(NSString *)vmapString;

@end
