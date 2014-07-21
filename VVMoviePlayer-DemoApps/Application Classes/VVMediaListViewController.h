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
#import "VVSectionPickerViewController.h"
#import "VVDatePickerDelegate.h"
#import "VVDatePickerViewController.h"


@interface VVMediaListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,
    UISearchBarDelegate, UINavigationBarDelegate, B3SearchBarDelegate, \
    UIAlertViewDelegate, VVCMSAPIDelegate, VVSiteListViewControllerDelegate, \
    VVDomainListDelegate, VVSectionPickerViewDelegate, UIPopoverControllerDelegate,
    VVDatePickerDelegate> {
}

- (id)initWithSiteSlug:(NSString*)site;
-(void) startVMAP:(NSString *)vmapString;

@end
