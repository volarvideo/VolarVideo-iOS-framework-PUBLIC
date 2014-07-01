//
//  VVCMSSite.h
//  VVMoviePlayer
//
//  Created by user on 6/24/14.
//  Copyright (c) 2014 VolarVideo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VVCMSSite : NSObject

@property(nonatomic,strong,readonly) NSNumber *ID;
@property(nonatomic,strong,readonly) NSString *slug;
@property(nonatomic,strong,readonly) NSString *title;
@property(nonatomic,strong,readonly) NSString *authURL;
@property(nonatomic,strong,readonly) NSString *userURL;
@property(nonatomic,strong,readonly) NSString *broadcastsAll;
@property(nonatomic,strong,readonly) NSString *broadcastsScheduled;
@property(nonatomic,strong,readonly) NSString *broadcastsStreaming;
@property(nonatomic,strong,readonly) NSString *broadcastsArchived;

-(id) initWithDictionary:(NSDictionary*)dict;

@end
