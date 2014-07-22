//
//  VVSiteListViewController.h
//  mobileapidev
//
//  Created by Benjamin Askren on 9/8/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <VVMoviePlayer/VVCMSAPI.h>
#import "iToast.h"

@protocol VVSiteListViewControllerDelegate <NSObject>

-(void) siteSelected:(id)slvc site:(VVCMSSite *)site;

@end

@interface VVSiteListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,VVCMSAPIDelegate,UISearchBarDelegate>

-(id) initWithDomain:(NSString*)domain;

@property(nonatomic,weak) id <VVSiteListViewControllerDelegate> delegate;

@end
