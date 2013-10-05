//
//  B3SplashViewController.m
//  mobileapidev
//
//  Created by Benjamin Askren on 1/24/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import "VVSplashViewController.h"
#import "UIDevice+Resolution.h"


@interface VVSplashViewController ()

@end

@implementation VVSplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //[self viewWillAppear:NO];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (UIDeviceResolution)resolution
{
    UIDeviceResolution resolution = UIDeviceResolution_Unknown;
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGFloat scale = ([mainScreen respondsToSelector:@selector(scale)] ? mainScreen.scale : 1.0f);
    CGFloat pixelHeight = (CGRectGetHeight(mainScreen.bounds) * scale);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if (scale == 2.0f) {
            if (pixelHeight == 960.0f)
                resolution = UIDeviceResolution_iPhoneRetina35;
            else if (pixelHeight == 1136.0f)
                resolution = UIDeviceResolution_iPhoneRetina4;
            
        } else if (scale == 1.0f && pixelHeight == 480.0f)
            resolution = UIDeviceResolution_iPhoneStandard;
        
    } else {
        if (scale == 2.0f && pixelHeight == 2048.0f) {
            resolution = UIDeviceResolution_iPadRetina;
            
        } else if (scale == 1.0f && pixelHeight == 1024.0f) {
            resolution = UIDeviceResolution_iPadStandard;
        }
    }
    
    return resolution;
}

-(void) viewWillDisappear:(BOOL)animated {
    [self hideHUD];
}

-(void) viewWillAppear:(BOOL)animated {
    [self showHUDWithMessage:@"Loading ..."];
    //CGRect bounds = [[UIScreen mainScreen] bounds];
    
    
    UIDeviceResolution res = [self resolution];
    
    NSString *imageName;
    switch (res) {
        case UIDeviceResolution_iPhoneStandard:
        case UIDeviceResolution_iPhoneRetina35:
#ifdef MWC_APP
            imageName = @"DefaultMWC";
#else
            imageName = @"Default";
#endif
            break;
        case UIDeviceResolution_iPhoneRetina4:
#ifdef MWC_APP
            imageName = @"DefaultMWC-568h@2x";
#else
            imageName = @"Default-568h@2x";
#endif
            break;
        case UIDeviceResolution_iPadStandard:
        case UIDeviceResolution_iPadRetina:
#ifdef MWC_APP
            if (((UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation])==UIInterfaceOrientationLandscapeLeft)
                imageName = @"DefaultMWC-Landscape";
            else if (((UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation])==UIInterfaceOrientationLandscapeRight)
                imageName = @"DefaultMWC-Landscape";
            else
                imageName = @"DefaultMWC-Portrait";
#else
            imageName = @"Default-Portrait";
#endif
            break;
        default:
            break;
    }
    self.imageView.image = [UIImage imageNamed:imageName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showHUD {
    [self showHUDWithMessage:@"Loading..."];
}

- (void)showHUDWithMessage:(NSString *) msg {
    //BBBAppDelegate *    appDelegate = (BBBAppDelegate*)[[UIApplication sharedApplication] delegate];
    //UIView *theView = [[appDelegate.navigationController visibleViewController] view];
    UIView *theView = self.view;
    //if (!progressHUD)
    progressHUD = [MBProgressHUD showHUDAddedTo:theView animated:YES];
    progressHUD.mode = MBProgressHUDModeIndeterminate;
    progressHUD.labelText = msg;
}

- (void)hideHUD {
    [progressHUD hide:YES];
}


@end
