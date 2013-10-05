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

-(void) doneWithVVSiteListViewController:(id)slvc;

@end

@interface VVSiteListViewController : UIViewController <VVCMSAPIDelegate> {
    VVCMSAPI *api;
}

-(id) initWithApi:(VVCMSAPI*)api;

@property(nonatomic,weak) id <VVSiteListViewControllerDelegate> delegate;

@end
