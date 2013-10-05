//
//  VVPickerViewController.h
//
//  Created by Benjamin Askren on 2/1/13.
//  Copyright 2013 VolarVideo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVPickerViewDelegate.h"

@interface VVPickerViewController : UIViewController <UIPickerViewDelegate> {
	UIPickerView *pv;
    __weak id <VVPickerViewDelegate> viewDelegate;
    int currentSelectedIndex;
}

@property (nonatomic, strong) IBOutlet UIPickerView *pv;
@property (nonatomic, weak) id <VVPickerViewDelegate> viewDelegate;
@property (nonatomic, strong) NSArray *dataDictionaries;
@property (nonatomic, strong) NSString *titleKey,*valueKey,*selectedTitle,*selectedValue;

-(IBAction) svcDone: (id) sender;

@end
