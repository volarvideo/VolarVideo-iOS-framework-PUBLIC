//
//  VVCMSAPIDelegate.h
//  VVMoviePlayer
//
//  Created by Benjamin Askren on 6/7/13.
//  Copyright (c) 2013 Zach Freeman. All rights reserved.
//

#ifndef VVMoviePlayer_VVCMSAPIDelegate_h
#define VVMoviePlayer_VVCMSAPIDelegate_h

@class VVCMSAPI;

/*!
 @discussion Completion handlers for asynchronous VVCMSAPI calls.
 */
@protocol VVCMSAPIDelegate <NSObject>
@optional

/*!
 Completion method for initiateDomain
 @param vvCmsApi The VVCMSAPI instance used in the initialDomain: call.
 @param error An error detailing what went wrong (or nil if no error).
 */
- (void)VVCMSAPI:(VVCMSAPI*)vvCmsApi domainRequestCompleteWithError:(NSError*) error;

/*!
 Completion method for authenticateWithUsername:Password:
 @param vvCmsApi The instance of the VVAPI used in the authenticateWithUsername:Password: call.
 @param error An error detailing what went wrong (or nil if no error)
 */
- (void)VVCMSAPI:(VVCMSAPI *)vvCmsApi authenticationRequestDidFinishWithError:(NSError *)error;

/*!
 Completion method for logout
 @param vvCmsApi The instance of the VVAPI used in the logoutRequestDidFinishWithError: call.
 @param error An error detailing what went wrong (or nil if no error)
 */
- (void)VVCMSAPI:(VVCMSAPI *)vvCmsApi logoutRequestDidFinishWithError:(NSError *)error;

/*!
 Completion method for requestUserName:
 @param vvCmsApi The instance of the VVAPI used in the requestForUserNameComplete:withError: call.
 @param userName The user name.  nil will be return in non-authenticated sessions.
 @param  error An error detailing what went wrong (or nil if no error)
 */
- (void)VVCMSAPI:(VVCMSAPI *)vvCmsApi requestForUserNameComplete:(NSString*)userName withError:(NSError*)error;


/*!
 Completion Method for broadcasts list requests
 @param vvapi The instance of the VVAPI used in the
 @param status The status of the broadcasts contained in the didFinishWithArray: parameter.
 @param events An array of scheduled streaming events
 @param error An error detailing what went wrong (or nil if no error)
 */
- (void)VVCMSAPI:(VVCMSAPI *)vvapi requestForBroadcastsOfStatus:(VVCMSBroadcastStatus)status didFinishWithArray:(NSArray *)events error:(NSError *)error;


@end


#endif
