//
//  Globals.h
//  VVMoviePlayer-DemoApps
//
//  Created by user on 7/17/14.
//  Copyright (c) 2014 VolarVideo. All rights reserved.
//

#import <Foundation/Foundation.h>

#define VCLOUD  @"vcloud.volarvideo.com"
#define IHIGH   @"ihigh.volarvideo.com"
#define STAGING @"staging.platypusgranola.com"
#define MASTER  @"master.platypusgranola.com"

@interface Globals : NSObject

+(NSString*)getAPIKey:(NSString*)domain;

@end
