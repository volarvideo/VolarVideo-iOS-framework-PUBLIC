//
//  VVUserDefaultsHelper.m
//  VVMoviePlayer-DemoApps
//
//  Created by user on 7/17/14.
//  Copyright (c) 2014 VolarVideo. All rights reserved.
//

#import "VVUserDefaultsHelper.h"
#import "Globals.h"

static NSString *CURR_DOMAIN = @"curr_domain";
static NSString *CURR_SITE = @"curr_site";

@implementation VVUserDefaultsHelper

+(NSString*) getCurrDomain {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSString *domain = [prefs stringForKey:CURR_DOMAIN];
    
    if (!domain) {
        domain = STAGING;
        [VVUserDefaultsHelper saveCurrDomain:domain];
    }
    
    return domain;
}

+(void) saveCurrDomain:(NSString*)domain {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:domain forKey:CURR_DOMAIN];
    [prefs synchronize];
}

+(NSString*) getCurrSite {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSString *site = [prefs stringForKey:CURR_SITE];
    
    if (!site) {
        site = @"volar";
        [VVUserDefaultsHelper saveCurrSite:site];
    }
    
    return site;
}

+(void) saveCurrSite:(NSString*)slug {
    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:slug forKey:CURR_SITE];
    [prefs synchronize];
}
@end
