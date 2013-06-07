//
//  B3SplashViewController.h
//  mobileapidev
//
//  Created by Benjamin Askren on 1/24/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface VVSplashViewController : UIViewController {
    MBProgressHUD *progressHUD;
}

@property(nonatomic,strong) IBOutlet UIImageView *imageView;

@end
