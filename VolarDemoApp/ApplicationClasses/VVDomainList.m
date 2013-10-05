//
//  VVDomainList.m
//  mobileapidev
//
//  Created by Benjamin Askren on 1/29/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import "VVDomainList.h"

@interface VVDomainList ()

@end

@implementation VVDomainList

- (id) initWithApi:(VVCMSAPI *)parentApi {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        api = parentApi;
        // Custom initialization
        [self loadDomains];
    }
    return self;
}

-(void) loadDomains {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *path = [paths objectAtIndex:0];
	path = [path stringByAppendingPathComponent:@"domains.plist"];
	domains = [NSMutableArray arrayWithContentsOfFile:path];
    if (!domains || ![domains count]) {
        path = [[NSBundle mainBundle] bundlePath];
        path = [path stringByAppendingPathComponent:@"domains.plist"];
        domains = [NSMutableArray arrayWithContentsOfFile:path];
    }
}

-(void) saveDomains {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    path = [path stringByAppendingPathComponent:@"domains.plist"];
    [domains writeToFile:path atomically:YES];
    
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
            [self saveDomains];
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
    [self saveDomains];
}

// tableviewDelegate calls
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    domain = [domains objectAtIndex:indexPath.row];
    api.delegate = self;
    [api authenticationRequestForDomain:domain username:nil andPassword:nil];
    [[iToast makeText:@"loading sites ..."]show];
    //[self.delegate setDomain:domain];
    //[self.navigationController popToRootViewControllerAnimated:YES];

    
    /*
	loginAlertView = [[UIAlertView alloc] initWithTitle:@"Login"
                                                    message:@"\n\n"
                                                   delegate:self cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"OK", nil];
    
    
    
	UITextField *utextfield = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 40.0, 259.0, 25.0)];
	utextfield.text = @"";
	utextfield.placeholder = @"username";
	utextfield.clearButtonMode = YES;
	[utextfield setBackgroundColor:[UIColor whiteColor]];
	utextfield.keyboardType = UIKeyboardTypeASCIICapable;
	utextfield.tag=888;
	[loginAlertView addSubview:utextfield];
	utextfield.returnKeyType=UIReturnKeyNext;
    utextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    utextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[utextfield becomeFirstResponder];
//    [utextfield setDelegate:self];
	[utextfield addTarget:self action:@selector(userNameTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];

	passwordTV = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 60.0, 259.0, 25.0)];
	passwordTV.text = @"";
	passwordTV.placeholder = @"password";
	passwordTV.clearButtonMode = YES;
	[passwordTV setBackgroundColor:[UIColor whiteColor]];
	passwordTV.keyboardType = UIKeyboardTypeASCIICapable;
	passwordTV.tag=999;
	[loginAlertView addSubview:passwordTV];
	passwordTV.returnKeyType=UIReturnKeyDone;
    passwordTV.secureTextEntry=YES;
//    [passwordTV setDelegate:self];
	[passwordTV addTarget:self action:@selector(passwordTextFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	
    [loginAlertView show];
    */
}


-(void) VVCMSAPI:(VVCMSAPI *)vvCmsApi authenticationRequestDidFinishWithError:(NSError *)error {
    if (vvCmsApi==api) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not authenticate" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
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
    
	UITextField *utextfield = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 45.0, 259.0, 25.0)];
	utextfield.text = @"";
	utextfield.placeholder = @"enter domain name";
	utextfield.clearButtonMode = YES;
	[utextfield setBackgroundColor:[UIColor whiteColor]];
    utextfield.autocorrectionType = UITextAutocorrectionTypeNo;
    utextfield.autocapitalizationType = UITextAutocapitalizationTypeNone;
	utextfield.keyboardType = UIKeyboardTypeASCIICapable;
	utextfield.tag=777;
	[alert addSubview:utextfield];
	utextfield.returnKeyType=UIReturnKeyDone;
	[utextfield becomeFirstResponder];
    //	[utextfield setDelegate:self];
	[utextfield addTarget:self action:@selector(textFieldFinished:) forControlEvents:UIControlEventEditingDidEndOnExit];
	alert.tag = 1;
	[alert show];
    //	alert=nil;
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
        UITextField *domainTextField = (UITextField *) [localActionSheet viewWithTag: 777];
        if (domainTextField) {
            if(buttonIndex > 0) {
                if(localActionSheet.tag == 1) {
                    NSString *textValue = domainTextField.text;
                    if(textValue==nil) {
                        //alert = nil;
                        //return;
                    } else {
                        [domains addObject:domainTextField.text];
                        [self saveDomains];
                    }
                }
            }
            [domainTextField resignFirstResponder];
            [tv reloadData];
        }
    }
	//alert = nil;
}

@end
