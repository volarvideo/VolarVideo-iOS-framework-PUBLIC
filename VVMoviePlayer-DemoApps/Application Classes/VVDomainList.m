//
//  VVDomainList.m
//  mobileapidev
//
//  Created by Benjamin Askren on 1/29/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import "VVDomainList.h"
#import "VVUserDefaultsHelper.h"
#import "Globals.h"

@implementation VVDomainList

- (id) init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        domains = [NSArray arrayWithObjects: VCLOUD, IHIGH, STAGING, MASTER, nil];
    }
    
	return self;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [domains objectAtIndex:indexPath.row];
    return cell;
}

// tableviewDelegate calls
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *domain = [domains objectAtIndex:indexPath.row];
    currDomain = indexPath.row;
    
    sitesListController = [[VVSiteListViewController alloc] initWithDomain:domain];
    sitesListController.delegate = self;
    [self.navigationController pushViewController:sitesListController animated:YES];
    
//    [[iToast makeText:@"loading sites ..."]show];
}


-(void) VVCMSAPI:(VVCMSAPI *)vvCmsApi authenticationRequestDidFinishWithError:(NSError *)error {
    if (vvCmsApi==api) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not authenticate" message:error.localizedDescription delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
            [alert show];
            return;
        }
    }
}

-(void) siteSelected:(id)slvc site:(VVCMSSite *)site {
    if (slvc==sitesListController) {
        NSString *domain = [domains objectAtIndex:currDomain];
        [VVUserDefaultsHelper saveCurrDomain:domain];
        [_delegate domainDidChange:self domain:domain site:site];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end
