//
//  VVCMSBroadcast.h
//  mobileapidev
//
//  Created by Benjamin Askren on 1/18/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#import <Foundation/Foundation.h>

/*!
 Properties of a VolarVideo broadcast.  
 
 
 */
typedef enum {
    VVCMSBroadcastStatusUnknown,
    VVCMSBroadcastStatusScheduled,
    VVCMSBroadcastStatusStreaming,
    VVCMSBroadcastStatusArchived,
    VVCMSBroadcastStatusAll    // used for requests to CMS, never returned
} VVCMSBroadcastStatus;

@interface VVCMSBroadcast : NSObject {
}
/*!
 @name CMS index
 */
/*!
 VolarVideo broadcast ID number
 */
@property(nonatomic,strong) NSNumber *ID;

/*!
 @name meta data
 */
/*!
 Title of broadcast
 */
@property(nonatomic,strong) NSString *title;

/*!
 Description of broadcast
 */
@property(nonatomic,strong) NSString *description;

/*!
 @name Stream Status
 */
/*!
 Status of broadcast, one of the following VVCMSBroadcastsStatus values:
 
     VVCMSBroadcastStatusUnknown,
     VVCMSBroadcastStatusScheduled,
     VVCMSBroadcastStatusStreaming,
     VVCMSBroadcastStatusArchived,
     VVCMSBroadcastStatusAll
 
 
 */
@property(nonatomic,assign) VVCMSBroadcastStatus status;

/*!
 String representation of URL where a thumbnail version of the broadcast's Poster can be found.
 */
@property(nonatomic,strong) NSString *thumbnailURL;

/*!
 Date at which the broadcast is (was) scheduled to start.
 */
@property(nonatomic,strong) NSDate *startDate;

/*!
 @name Touch times
 */
/*!
 Last date at which the broadcast or its meta data was changed.
 */
@property(nonatomic,strong) NSDate *editDate;

/*!
 @name Broadcast rating
 */
/*!
 Average rating of this broadcast
 
 #### Availability
 NOT YET AVAILABLE
 */
@property(nonatomic,assign) double rating;

/*!
 YES if broadcast is only available as an audio stream.
 */
@property(nonatomic,assign) BOOL audioOnly;

/*!
 @name Viewer metrics
 */
/*!
 The last known viewing position in the broadcast for the currently authenticated user.
 
 #### Availability
 NOT YET AVAILABLE
 */
@property(nonatomic,assign) double progress;

/*!
 The content creator / owner.
 */
@property(nonatomic,strong) NSString *authorName;

/*!
 YES if the broadcast is live streaming.
 */
@property(nonatomic,assign) BOOL isStreaming;

/*!
 @name Endpoints for content
 */
/*!
 String representing URL of VolarExtended VMAP of broadcast.  Pass this string to [VVMoviePlayerViewController initWithExtendedVMAPURIString:], [VVMoviePlayerViewController initAndStartWithExtendedVMAPURIString:], [VVMoviePlayerController initWithExtendedVMAPURIString:], or [VVMoviePlayerController initAndStartWithExtendedVMAPURIString:] to initialize a VolarVideo broadcast for playback as a movie.
 */
@property(nonatomic,strong) NSString *vmapURL;


@end
