


#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface B3WebViewController : UIViewController <UIWebViewDelegate> {}

@property (nonatomic, strong) NSDictionary *settingsDictionary;
@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *back;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forward;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *scale;
@property (nonatomic, strong) MBProgressHUD *progressHUD;

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *content;

@property (nonatomic, strong) IBOutlet UIWebView *webView;

-(IBAction) buttonBack:(id)sender ;
-(IBAction) buttonForward:(id)sender ;
-(IBAction) buttonScale:(id)sender ;

- (id)initWithContent:(NSString*)str andSettingsDictionary:(NSDictionary*)settingsDict; 
- (id)initWithURL:(NSURL *)thisUrl andSettingsDictionary:(NSDictionary*)settingsDict ;


@end