//
//  VVDomainList.m
//  mobileapidev
//
//  Created by Benjamin Askren on 1/29/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import "VVDomainList.h"

// This interface is defined in VVDomainList.h
// Having a second definition of the interface will just be confusing
/*
@interface VVDomainList ()

@end
*/

@implementation VVDomainList

static NSString *VCLOUD = @"vcloud.volarvideo.com";
static NSString *IHIGH = @"ihigh.volarvideo.com";
static NSString *STAGING = @"staging.platypusgranola.com";
static NSString *MASTER = @"master.platypusgranola.com";

static NSString *DOMAINS = @"domains";
static NSString *CURR_DOMAIN = @"curr_domain";

- (id) initWithApi:(VVCMSAPI *)parentApi {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        api = parentApi;
        // Custom initialization
        domains = [VVDomainList getDomains];
    }
    
	return self;
}

+(NSMutableArray*) getDomains {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSString *domains = [prefs stringForKey:DOMAINS];
    
    NSMutableArray *domainList = [NSMutableArray arrayWithCapacity:5];
    if (domains) {
        domainList = [[domains componentsSeparatedByString:@";"] mutableCopy];
        [self saveDomains:domainList];
    }
    else {
        domainList = [NSMutableArray arrayWithObjects: VCLOUD, IHIGH, STAGING, MASTER, nil];
    }
    
    return domainList;
}

+(void) saveDomains:(NSArray*)domainList {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    NSString *domains = [domainList componentsJoinedByString:@";"];
    
    [prefs setObject:domains forKey:DOMAINS];
    [prefs synchronize];
}

+(NSString*) getCurrDomain {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSString *domain = [prefs stringForKey:CURR_DOMAIN];
    
    if (!domain) {
        NSLog(@"couldn't find seeting STAGIG");
        domain = STAGING;
        [VVDomainList saveCurrDomain:domain];
    }
    
    return domain;
}

+(void) saveCurrDomain:(NSString*)domain {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:domain forKey:CURR_DOMAIN];
    [prefs synchronize];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [domains count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [domains objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (editingStyle) {
        case UITableViewCellEditingStyleDelete:
            [domains removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
            [VVDomainList saveDomains:domains];
            break;
        case UITableViewCellEditingStyleInsert:
            [domains insertObject:@"" atIndex:indexPath.row];
            [tableView reloadData];
            break;
        case UITableViewCellEditingStyleNone:
        default:
            break;
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    NSString *local_domain = [domains objectAtIndex:fromIndexPath.row];
    [domains insertObject:local_domain atIndex:toIndexPath.row];
    [domains removeObjectAtIndex:fromIndexPath.row];
    [VVDomainList saveDomains:domains];
}

// tableviewDelegate calls
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *domain = [domains objectAtIndex:indexPath.row];
    currDomain = indexPath.row;
    api.delegate = self;
    [api authenticationRequestForDomain:domain username:nil andPassword:nil];
    [[iToast makeText:@"loading sites ..."]show];
    //[self.delegate setDomain:domain];
    //[self.navigationController popToRootViewControllerAnimated:YES];
}


-(void) VVCMSAPI:(VVCMSAPI *)vvCmsApi authenticationRequestDidFinishWithError:(NSError *)error {
    if (vvCmsApi==api) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not authenticate" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
    sitesListController = [[VVSiteListViewController alloc] initWithApi:api];
    sitesListController.delegate = self;
    [self.navigationController pushViewController:sitesListController animated:YES];
}

-(void) doneWithVVSiteListViewController:(id)slvc {
    if (slvc==sitesListController) {
        [VVDomainList saveCurrDomain:[domains objectAtIndex:currDomain]];
        [_delegate domainDidChange:self];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn:");
    if (textField.tag == 1) {
        UITextField *passwordTextField = (UITextField *)[self.view viewWithTag:2];
        [passwordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void) userNameTextFieldFinished:(id) sender {
	//NSLog(@"textFieldFinished");
	[passwordTV becomeFirstResponder];
	//[alert resignFirstResponder];
}

/*
-(void) passwordTextFieldFinished:(id) sender {
	//NSLog(@"textFieldFinished");
//	[sender resignFirstResponder];
    [loginAlertView dismissWithClickedButtonIndex:1 animated:YES];
	//[alert resignFirstResponder];
}

-(void) textFieldFinished:(id) sender {
	//NSLog(@"textFieldFinished");
	[sender resignFirstResponder];
	//[alert resignFirstResponder];
}
*/

-(IBAction)addButtonPress:(id)sender {
    [self store];
}

-(void) store {
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add Domain"
                                                    message:@"\n\n"
                                                   delegate:self cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    
	// In iOS7 you can no longer modify the UIAlertView directly
	// http://stackoverflow.com/questions/18549519/unable-to-add-uitextfield-to-uialertview-on-ios7-works-in-ios-6
	// Fortunately this code is backwards compatible with iOS 6
	// Note that this also changed how we access the text field in didDismissWithButtonIndex
	
	alert.alertViewStyle = UIAlertViewStylePlainTextInput;
	alert.tag = 1;
	
	[alert show];
}

- (void) alertView:(UIAlertView*)localActionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	// use "buttonIndex" to decide your action
	//NSLog(@"alertView didDismissWithButtonIn  dex:%d",buttonIndex);
    if (localActionSheet == loginAlertView) {
        /*
        if(buttonIndex > 0) {
            NSString *userName = [(UITextField*) [localActionSheet viewWithTag:888] text];
            NSString *password = [(UITextField*) [localActionSheet viewWithTag:999] text];
            if (userName && [userName length]>0 && password && [password length]>0) {
                [self.delegate setPassword:password];
                [self.delegate setUserName:userName];
            } else {
                [self.delegate setPassword:nil];
                [self.delegate setUserName:nil];
            }
            [self.delegate setDomain:domain];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
         */
    } else {
		
		// This is how we access the alert textfield in iOS7:
		UIAlertView *alert = (UIAlertView *)[localActionSheet viewWithTag:1];
		UITextField *domainTextField = [alert textFieldAtIndex:0];
        
		if (domainTextField) {
            if(buttonIndex > 0) {
				NSString *textValue = domainTextField.text;
				if(textValue==nil) {
					//alert = nil;
					//return;
				} else {
					[domains addObject:domainTextField.text];
					[VVDomainList saveDomains:domains];
				}
            }
            [domainTextField resignFirstResponder];
            [tv reloadData];
        }
    }
	//alert = nil;
}

@end
