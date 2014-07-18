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

@protocol VVDomainListDelegate <NSObject>

-(void) domainDidChange:(id)dl domain:(NSString*)domain site:(VVCMSSite *)site;

@end

@interface VVDomainList : UIViewController <UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate,VVCMSAPIDelegate,VVSiteListViewControllerDelegate> {
    IBOutlet UITableView *tv;
    NSArray *domains;
    NSInteger currDomain;
    UIAlertView *loginAlertView;
    UITextField *passwordTV;
    VVCMSAPI *api;
    iToast *toast;
    VVSiteListViewController *sitesListController;
}
@property(nonatomic,weak) id <VVDomainListDelegate> delegate;


@end
