//
//  B3BadgeButton.h

//
//  Created by Benjamin Askren on 9/13/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface B3BadgeButton : UIButton {
    @private
    UIImage *sourceImage;
    NSString *title;
}

@property(nonatomic,assign) int notifications;

+(id) badgeButtonWithImage:(UIImage *)image andTitle:(NSString *)title;
-(id) initWithImage:(UIImage *)image andTitle:(NSString *)title;
-(void) setImage:(UIImage *)image andTitle:(NSString *)title andNotifications:(int) i ;
-(void) setImage:(UIImage *)image andTitle:(NSString *)title;
-(void) setTitle:(NSString *)title;
-(NSString *) title;
-(void) setNotifications:(int)i;
-(void) setImage:(UIImage *)image;

@end
