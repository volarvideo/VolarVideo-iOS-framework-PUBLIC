//
//  B3BadgeButton.m

//
//  Created by Benjamin Askren on 9/13/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import "B3BadgeButton.h"

#define labelFontSize  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?30:15) 
#define padding  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?40:20)



@implementation B3BadgeButton

@synthesize notifications;

+(id) badgeButtonWithImage:(UIImage *)image andTitle:(NSString *)title {
    B3BadgeButton *btn = [[B3BadgeButton alloc]initWithImage:image andTitle:title];
    btn.enabled=YES;
    return btn;
}

-(id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:labelFontSize];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

-(id) initWithImage:(UIImage *)image andTitle:(NSString *)t {
    self = [super init];
    if (self) {
        [self setImage:image andTitle:t];
        self.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:labelFontSize];
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

-(void) setImage:(UIImage *)image andTitle:(NSString *)t andNotifications:(int) i {
    title = t;
    sourceImage = image;
    notifications = i;
    [self drawButton];
}

-(void) setImage:(UIImage *)image andTitle:(NSString *)t {
    title = t;
    sourceImage = image;
    [self drawButton];
}

-(void) setTitle:(NSString *)t {
    title = t;
    [self drawButton];
}

-(NSString *) title {
    return title;
}

-(void) setNotifications:(int)i {
    notifications = i;
    [self drawButton];
}

-(void) setImage:(UIImage *)image {
    sourceImage = image;
    [self drawButton];
}

-(void) drawButton {
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(sourceImage.size.width+30, sourceImage.size.height+padding), NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //[image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    [[self enabledAndBadgedImageOfImage:sourceImage notifications:notifications] drawInRect:CGRectMake(15, 0, sourceImage.size.width, sourceImage.size.height)];
    
    CGSize sz = [title sizeWithFont:self.titleLabel.font];
    CGPoint p = CGPointMake((sourceImage.size.width+30-sz.width)/2.0, sourceImage.size.height);
    CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
    CGContextSetTextDrawingMode(ctx, kCGTextFill);
    [title drawAtPoint:p withFont:self.titleLabel.font];
    
    //UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self setImage:UIGraphicsGetImageFromCurrentImageContext() forState:UIControlStateNormal];
    //[super setTitle:title forState:UIControlStateNormal];
    UIGraphicsEndImageContext();
}

- (UIImage *) enabledAndBadgedImageOfImage:(UIImage *)image notifications:(int)i {
    float overlap=7;
    NSString *fontName=@"HelveticaNeue-Medium";
    
    NSString *text = [NSString stringWithFormat:@"%d",i];
    CGSize sz  = [text sizeWithFont:[UIFont fontWithName:fontName size:17] ];
    float stretch = sz.width-2*overlap;
    if (stretch<0) stretch=0;
    
    UIGraphicsBeginImageContextWithOptions(image.size, FALSE, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    UIImage *enabledImage = [self imageFromImage:image withAlpha:0.7];
    [enabledImage drawInRect:CGRectMake( 0, 0, image.size.width, image.size.height)];
    
    if (i) {
        UIImage *right = [UIImage imageNamed:@"unreadNoteRight"];
        [right   drawInRect:CGRectMake( image.size.width-right.size.width, 0, right.size.width, right.size.height)];
        if (stretch) {
            UIImage *center = [UIImage imageNamed:@"unreadNoteCenter"];
            [center   drawInRect:CGRectMake( image.size.width-right.size.width-stretch, 0, stretch, center.size.height)];
            
        }
        
        UIImage *left = [UIImage imageNamed:@"unreadNoteLeft"];
        [left   drawInRect:CGRectMake( image.size.width-right.size.width-stretch-left.size.width, 0, left.size.width, left.size.height)];
        
        CGPoint p = CGPointMake(image.size.width-right.size.width-stretch/2.0 - sz.width/2.0 + 0.5, 2);
        CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
        CGContextSetTextDrawingMode(ctx, kCGTextFill);
        
        /*
         CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5] CGColor]);
         CGContextSetLineWidth(ctx, 0.5);
         CGContextSetTextDrawingMode(ctx, kCGTextFillStroke);
         */
        [text drawAtPoint:p withFont:[UIFont fontWithName:fontName size:17]];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



-(UIImage *) imageFromImage:(UIImage *)image withAlpha:(double)alpha {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextScaleCTM(ctx, 1, -1);
    CGContextTranslateCTM(ctx, 0, -area.size.height);
    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
    CGContextSetAlpha(ctx, alpha);
    CGContextDrawImage(ctx, area, image.CGImage);
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
