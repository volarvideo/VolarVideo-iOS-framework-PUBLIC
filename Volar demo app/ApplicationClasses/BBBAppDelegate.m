//
//  BBBAppDelegate.m

//
//  Created by Benjamin Askren on 9/11/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#define TESTING 1



#import "BBBAppDelegate.h"

#import "B3MediaListViewController.h"
#import "B3NavigationController.h"
#import "B3Utils.h"
#import "VVSplashViewController.h"

#if defined DEMO_APP
#define kSite nil
#elif defined MWC_APP
#define kSite @"vcloud.volarvideo.com/The Mountain-West Conference"
#endif

@implementation BBBAppDelegate

@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize navigationController = _navigationController;
@synthesize moviePlayer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [UIApplication sharedApplication].statusBarHidden=NO;

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // only use during testin
    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    
    CFBundleRef myBundle = CFBundleGetMainBundle ();
    CFStringRef key = (CFStringRef) @"CFBundleShortVersionString";
	NSString *versionString = (NSString *) CFBridgingRelease(CFBundleGetValueForInfoDictionaryKey( myBundle, key));
    [[NSUserDefaults standardUserDefaults] setObject:versionString forKey:@"Version"];
    [NSUserDefaults standardUserDefaults];
    
#if defined DEMO_APP
    [TestFlight takeOff:@"9167ed2a-8b8e-43c2-9a3b-9d0d18c10a86"];
#elif defined MWC_APP
    [TestFlight takeOff:@"f4a58e54-2340-4bba-96f9-dcd00a8263d5"];
#else
    [TestFlight takeOff:@"b25f3cfa-046e-4807-a696-5276ebc359c3"];
#endif
    
#if defined VOLAR_PLAYER
    if (moviePlayer)
        moviePlayer=nil;
    moviePlayer = [[VVMoviePlayerViewController alloc] initAndStartWithExtendedVMAPURIString:nil];
    self.window.rootViewController = moviePlayer;
#else
    VVSplashViewController *svc = [[VVSplashViewController alloc] initWithNibName:nil bundle:nil];
    self.window.rootViewController = svc;
#endif
    [self.window makeKeyAndVisible];
    // Override point for customization after application launch.
    
    VVCMSAPI *api = [VVCMSAPI vvCMSAPI];
    api.delegate = self;
    [api authenticationRequestForDomain:kSite username:nil andPassword:nil];
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


- (void) VVCMSAPI:(VVCMSAPI *)vvCmsApi authenticationRequestDidFinishWithError:(NSError *)error {
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not connect" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
#if !defined VOLAR_PLAYER
    listViewController = [[B3MediaListViewController alloc] initWithApi:vvCmsApi];
    listViewController.siteName = [vvCmsApi siteName];
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //NSLog(@"Background time remaining:%f", [[UIApplication sharedApplication] backgroundTimeRemaining]);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // required for VolarVideo web launch capability
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}





@end
