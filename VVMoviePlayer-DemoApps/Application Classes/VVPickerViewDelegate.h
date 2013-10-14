//
//  VVPickerViewDelegate.h
//  mobileapidev
//
//  Created by Benjamin Askren on 9/8/13.
//  Copyright (c) 2013 VolarVide. All rights reserved.
//

#ifndef mobileapidev_VVPickerViewDelegate_h
#define mobileapidev_VVPickerViewDelegate_h

@class VVPickerViewController;

@protocol VVPickerViewDelegate <NSObject>
@required
-(void) doneWithVVPickerViewController:(VVPickerViewController*)vvPCV;
@end



#endif
