//
//  Globals.m
//  VVMoviePlayer-DemoApps
//
//  Created by user on 7/17/14.
//  Copyright (c) 2014 VolarVideo. All rights reserved.
//

#import "Globals.h"

@implementation Globals

+(NSString*)getAPIKey:(NSString*)domain {
    if ([domain isEqualToString:VCLOUD])
        return @"2Uqf8zXMk4EZv63sGugy5DtsJASGrR4t";
    else if ([domain isEqualToString:IHIGH])
        return @"4M7NrxXJ9NF2lZVxPn9avA6euyZb8Bv8";
    else if ([domain isEqualToString:STAGING])
        return @"WBZf52PXLNRzQVgC6jKyouL8hOCAYCY9";
    else if ([domain isEqualToString:MASTER])
        return @"She75oIgnPrAKDVxPSaXem2ZSeafmOet";
    else
        return nil;
}

@end
