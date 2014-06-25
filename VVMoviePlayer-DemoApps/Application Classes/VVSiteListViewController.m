//
//  VVSiteListViewController.m
//  mobileapidev
//
//  Created by Benjamin Askren on 9/8/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import "VVSiteListViewController.h"
#import "VVDomainList.h"
#import <VVMoviePlayer/VVCMSSite.h>

@interface VVSiteListViewController ()

@end

@implementation VVSiteListViewController

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithApi:(VVCMSAPI *)parentApi {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        api = parentApi;
        // Custom initialization
    }
    return self;
}

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [api.sites count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    VVCMSSite *site = [api.sites objectAtIndex:indexPath.row];
    cell.textLabel.text = site.title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    api.delegate = self;
    [api setCurrentSiteIndex:indexPath.row];
    
    //[self.navigationController popViewControllerAnimated:YES];
    if (delegate)
        [delegate doneWithVVSiteListViewController:self];
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

@end
