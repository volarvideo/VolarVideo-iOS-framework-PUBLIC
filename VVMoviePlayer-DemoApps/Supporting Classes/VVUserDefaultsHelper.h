//
//  VVUserDefaultsHelper.h
//  VVMoviePlayer-DemoApps
//
//  Created by user on 7/17/14.
//  Copyright (c) 2014 VolarVideo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VVMoviePlayer/VVCMSSite.h>

@interface VVUserDefaultsHelper : NSObject

+(NSString*) getCurrDomain;
+(void) saveCurrDomain:(NSString*)domain;

+(NSString*) getCurrSite;
+(void) saveCurrSite:(NSString*)slug;

@end
