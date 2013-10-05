//
//  VVDomainList.h
//  mobileapidev
//
//  Created by Benjamin Askren on 1/29/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VVMoviePlayer/VVCMSAPI.h>
#import "iToast.h"
#import "VVSiteListViewController.h"


@interface VVDomainList : UIViewController <UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,VVCMSAPIDelegate,VVSiteListViewControllerDelegate> {
    IBOutlet UITableView *tv;
    NSMutableArray *domains;
    NSString *domain;
    UIAlertView *loginAlertView;
    UITextField *passwordTV;
    VVCMSAPI *api;
    iToast *toast;
    VVSiteListViewController *sitesListController;
}

-(IBAction)addButtonPress:(id)sender;

//@property(nonatomic,weak) id<VVDomainListDelegate>delegate;


-(id) initWithApi:(VVCMSAPI*)api;


@end
