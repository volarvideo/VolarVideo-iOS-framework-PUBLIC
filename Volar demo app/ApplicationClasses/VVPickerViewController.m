//
//  MultiValuePickerViewController.m
//
//  Created by Benjamin Askren on 2/1/13.
//  Copyright 2013 VolarVideo. All rights reserved.
//

//#import "os3.h"
#import "VVPickerViewController.h"

//static NSMutableArray *svcBarItems;


@implementation VVPickerViewController

@synthesize pv;
@synthesize viewDelegate;
@synthesize dataDictionaries,titleKey,valueKey,selectedTitle,selectedValue;



- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([[UIMenuController sharedMenuController] isMenuVisible]) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    [super viewWillAppear:animated];
	pv.exclusiveTouch=NO;
}





#pragma mark Table view methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (dataDictionaries!=nil)
        return [dataDictionaries count];
    return 0;
}


// Customize the appearance of table view cells.
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)subRow forComponent:(NSInteger)component {
    NSString *title = nil;
    if (dataDictionaries!=nil)
        title = [[dataDictionaries objectAtIndex:subRow] objectForKey:titleKey];
	return title;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)subRow inComponent:(NSInteger) component {
    currentSelectedIndex = subRow;
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
	return 30;
}

-(IBAction) svcDone: (id) sender {
    selectedValue = [[dataDictionaries objectAtIndex:currentSelectedIndex] objectForKey:valueKey];
    selectedTitle = [[dataDictionaries objectAtIndex:currentSelectedIndex] objectForKey:titleKey];
    [viewDelegate doneWithVVPickerViewController:self];
}


@end

