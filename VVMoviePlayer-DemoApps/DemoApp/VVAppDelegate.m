//
//  VVAppDelegate.m

//
//  Created by Benjamin Askren on 9/11/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#define TESTING 1

#import "VVAppDelegate.h"

#import "TestFlight.h"
#import "VVMediaListViewController.h"
#import "B3NavigationController.h"
#import "B3Utils.h"
#import "VVSplashViewController.h"

#if defined MWC_APP
#define kSite @"themwc"
#else
#define kSite @"volar"
#endif

@implementation VVAppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize moviePlayer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UIApplication sharedApplication].statusBarHidden=NO;
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    CFBundleRef myBundle = CFBundleGetMainBundle ();
    CFStringRef key = (CFStringRef) @"CFBundleShortVersionString";
	NSString *versionString = (NSString *) CFBridgingRelease(CFBundleGetValueForInfoDictionaryKey( myBundle, key));
    [[NSUserDefaults standardUserDefaults] setObject:versionString forKey:@"Version"];
    [NSUserDefaults standardUserDefaults];
    
#if defined DEMO_APP
    [TestFlight takeOff:@"969b7296-9022-4464-827a-a67c1892d719"];
#endif
    
#if defined VOLAR_PLAYER
    if (moviePlayer)
        moviePlayer=nil;
    moviePlayer = [[VVMoviePlayerViewController alloc] initWithExtendedVMAPURIString:nil];
    self.window.rootViewController = moviePlayer;
#else
    VVSplashViewController *svc = [[VVSplashViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = svc;
#endif
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    
    listViewController = [[VVMediaListViewController alloc] initWithSiteSlug:kSite];
    
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
#if defined VOLAR_PLAYER
    if (moviePlayer) {
        [moviePlayer startVMAP:[url description]];
        vmapString=nil;
        return YES;
#else
    if (listViewController) {
        [listViewController startVMAP:[url description]];
        vmapString=nil;
        return YES;
#endif
    } else {
        NSLog(@"DOH!!!!");
        return YES;
    }
}
    
    
- (void) finishedLoadingBroadcastsWithError:(NSError *)error {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not connect" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
#if !defined VOLAR_PLAYER
    self.navigationController = [[B3NavigationController alloc]initWithRootViewController:(UIViewController*)listViewController];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    if (vmapString) {
        [listViewController startVMAP:vmapString];
        vmapString=nil;
    }
    
#endif
}
    
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}
    
- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    //NSLog(@"Background time remaining:%f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
}
    
- (void)applicationWillEnterForeground:(UIApplication *)application {

}
    
- (void)applicationDidBecomeActive:(UIApplication *)application {
    // required for VolarVideo web launch capability
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}
    
- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
    

@end
