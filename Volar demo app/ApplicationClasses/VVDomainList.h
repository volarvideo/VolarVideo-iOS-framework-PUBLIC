//
//  VVDomainList.h
//  mobileapidev
//
//  Created by Benjamin Askren on 1/29/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VVDomainListDelegate

-(void) setDomain:(NSString*)s;
-(void) setUserName:(NSString*)s;
-(void) setPassword:(NSString*)p;


@end

@interface VVDomainList : UIViewController <UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate> {
    IBOutlet UITableView *tv;
    NSMutableArray *domains;
    NSString *domain;
    UIAlertView *loginAlertView;
    UITextField *passwordTV;
}

-(IBAction)addButtonPress:(id)sender;

@property(nonatomic,weak) id<VVDomainListDelegate>delegate;

@end
