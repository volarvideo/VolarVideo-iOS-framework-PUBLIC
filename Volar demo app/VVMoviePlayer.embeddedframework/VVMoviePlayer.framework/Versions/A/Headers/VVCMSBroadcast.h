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
 The content creator / owner.
 */
@property(nonatomic,strong) NSString *authorName;


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
 YES if broadcast is only available as an audio stream.
 */
@property(nonatomic,assign) BOOL audioOnly;
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

/*!
 String representation of URL where a thumbnail version of the broadcast's Poster can be found.
 */
@property(nonatomic,strong) NSString *thumbnailURL;

/*!
 @name Touch times
 */
/*!
 Last date at which the broadcast or its meta data was changed.
 */
@property(nonatomic,strong) NSDate *editDate;

/*!
 Date at which the broadcast is (was) scheduled to start.
 */
@property(nonatomic,strong) NSDate *startDate;

/*!
 @name Reviews
 */
/*!
 Number of reviews for the broadcast.
 */
@property(nonatomic,assign) int numberOfReviews;

/*!
 Average review for the broadcast.
 */
@property(nonatomic,assign) double averageReview;

/*!
 Review of the broadcast given by the user currently authenticated to the VolarVideo CMS
 */
@property(nonatomic,assign) double userReview;

/*!
 @name Viewer metrics
 */
/*!
 The last known viewing position in the broadcast for the currently authenticated user.
 
 #### Availability
 NOT YET AVAILABLE
 */
@property(nonatomic,assign) double progress;

@end
