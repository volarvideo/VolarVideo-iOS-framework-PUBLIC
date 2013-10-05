
#import "B3WebViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PRPAlertView.h"
#import "BBBAppDelegate.h"

@interface B3WebViewController ()

- (void)fadeWebViewIn;

@end

@implementation B3WebViewController

@synthesize url,progressHUD;

@synthesize content,settingsDictionary;
@synthesize webView;
@synthesize toolbar,back,forward,scale;

- (id)initWithContent:(NSString*)str andSettingsDictionary:(NSDictionary*)settingsDict {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        content = str;
        url=nil;
        settingsDictionary = settingsDict;
    }
    return self;
}

- (id)initWithURL:(NSURL *)thisUrl andSettingsDictionary:(NSDictionary*)settingsDict {
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        content = nil;
        url = thisUrl;
        settingsDictionary = settingsDict;
    }
    return self;
}

- (void)dealloc {
    url = nil;
    content=nil;
    [webView stopLoading];
}

- (void)showHUD {
    UIView *theView = [[[(BBBAppDelegate*)[[UIApplication sharedApplication] delegate] navigationController] visibleViewController] view];
    self.progressHUD = [MBProgressHUD showHUDAddedTo:theView animated:YES];
    self.progressHUD.mode = MBProgressHUDModeIndeterminate;
    self.progressHUD.labelText = @"Loading...";
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    webView.scalesPageToFit = YES;
    webView.delegate = self;
    webView.dataDetectorTypes = UIDataDetectorTypeAll;

    UIImageView *iv = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.settingsDictionary valueForKey:@"Image"]]];
    [iv setContentMode:UIViewContentModeScaleAspectFit];
    [iv setFrame:CGRectMake(0, 0, 27.0, 27.0)];
    self.navigationItem.titleView = iv;

    UIButton *imgButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 74.0, 27.0)];
    [imgButton setBackgroundImage:[UIImage imageNamed:@"app_logo"] forState:UIControlStateNormal];
    UIBarButtonItem *sourceButton = [[UIBarButtonItem alloc] initWithCustomView:imgButton];
    self.navigationItem.rightBarButtonItem = sourceButton;
    
    /*
    if (content)
        [webView loadHTMLString:content baseURL:nil];
    else if (url)
        [webView loadRequest:[NSURLRequest requestWithURL:url]];
    */
    [back setEnabled:NO];
    [forward setEnabled:NO];
    [self reload];
}

-(void) viewWillAppear:(BOOL)animated  {
//    [APIDataLoader hideHUD];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Actions

- (void)fadeWebViewIn {
    [UIView animateWithDuration:0.5
                     animations:^ {
                         self.webView.alpha = 1.0;                         
                     }];
}

- (void)reload {
    if (content && (back.enabled == NO)) {
        [webView loadHTMLString:content baseURL:nil];
        self.webView.alpha = 0.0;
        [self showHUD];
    } else if (self.url) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
        self.webView.alpha = 0.0;
        [self showHUD];
    }
    else {
        [self.webView reload];
        self.webView.alpha = 0.0;
        [self showHUD];
    }
    
}

#pragma mark -
#pragma mark Accessor overrides

- (void)updateBrowserButtons {
    if (url) {  //webview loaded with url, std back/forward behavior works
        [back setEnabled:self.webView.canGoBack];       //back
    }
    
    [forward setEnabled:self.webView.canGoForward];    //forward
    scale.image = [UIImage imageNamed:  (webView.scalesPageToFit?@"scaleUp":@"scaleDown")];
}


-(IBAction) buttonBack:(id)sender {
    if (self.webView.canGoBack)
        [self.webView goBack];
    else {
        [self.webView loadHTMLString:content baseURL:nil];
        [back setEnabled:NO];
        [forward setEnabled:YES];   //must enable manually as going back manually doesn't enable forward
    }
}

-(IBAction) buttonForward:(id)sender {
	[self.webView goForward];
    [back setEnabled:YES];
}

-(IBAction) buttonScale:(id)sender {
    webView.scalesPageToFit = !webView.scalesPageToFit;
    //scale.image = [UIImage imageNamed:  (webView.scalesPageToFit?@"scaleUp":@"scaleDown")];
    [self reload];
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)wv{
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self updateBrowserButtons];
}

- (void)webViewDidFinishLoad:(UIWebView *)wv {
    [self.progressHUD hide:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self fadeWebViewIn];
    [self updateBrowserButtons];
}

- (void)webView:(UIWebView *)wv didFailLoadWithError:(NSError *)error {
    //NSLog(@"webView fail: %@", error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.progressHUD hide:YES];
    if (error.code != NSURLErrorCancelled) {	//Ignore Error -999
        // report the error inside the webview
        NSString* errorString = [NSString stringWithFormat:@"<html><center><font size=+2 color='red'>An error occurred:<br>%@</font></center></html>",error.localizedDescription];
        [self.webView loadHTMLString:errorString baseURL:nil];
    }
    [self updateBrowserButtons];
}

- (BOOL)webView:(UIWebView *)wv shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{    
    if ((navigationType == UIWebViewNavigationTypeLinkClicked) && !url) {
        [back setEnabled:YES];      //link clicked, manually enable back button to return to initially loaded content
    }
    return YES;
}


@end