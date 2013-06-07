//
//  VVCMIAPI.h
//  ProductionTruckSandbox
//
//  Created by Justin Raney on 12/14/12.
//  Copyright (c) 2012 Apax Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVCMSBroadcast.h"
#import "VVCMSAPIDelegate.h"

typedef enum {
    vvCMSAPIErrorInvalidDelegate=100,
    vvCMSAPIErrorNoDomainURL,
    vvCMSAPIErrorDomainUnreachable,
    vvCMSAPIErrorInvalidDomainURL,
    vvCMSAPIErrorNotLoggedIn,
    vvCMSAPIErrorUnknownEndpoint=999
} vvCMSAPIError;

// hard coded endpoints
#define kVVCMSAPILoginEP                @"api/auth/login"
#define kVVCMSAPIKeyUsername            @"email"
#define kVVCMSAPIKeyPassword            @"password"
#define kVVCMSAPIDomainInfoEP           @"api/info/domain"

// domain response keys
#define kVVCMSAPIKeySuccess             @"success"
#define kVVCMSAPIKeyError               @"error"
#define kVVCMSAPIKeyErrorCode           @"code"
#define kVVCMSAPIKeyErrorMessage        @"message"
#define kVVCMSAPIKeySites               @"sites"
#define kVVCMSAPIKeySiteTitle           @"title"
#define kVVCMSAPIKeySiteEndPoints       @"endpoints"
#define kVVCMSAPIKeyEventId             @"id"

// user name response keys
#define kVVCMSAPIKeyUser                @"user"
#define kVVCMSAPIKeyUserName            @"name"

// end point keys
#define kVVCMSAPIKeyAuthLogout          @"auth/logout"
#define kVVCMSAPIKeyUserInfo            @"user/info"
#define kVVCMSAPIKeyAllBroadcasts       @"broadcast/all"
#define kVVCMSAPIKeyScheduledBroadcast  @"broadcast/scheduled"
#define kVVCMSAPIKeyStreamingBroadcast  @"broadcast/streaming"
#define kVVCMSAPIKeyArchivedBroadcast   @"broadcast/archived"
#define kVVCMSAPIKeyVMAPURL             @"broadcast/vmap"

#define kVVCMSAPIErrorDomain @"com.vv.cmsapi"

// broadcast(s) responds keys
#define kVVCMSAPIKeyBroadcastsArray     @"broadcasts"
#define kVVCMSAPIKeyBroadcastStatus     @"status"
#define kVVCMSAPIKeyBroadcastStatusScheduled    @"scheduled"
#define kVVCMSAPIKeyBroadcastStatusStreaming    @"streaming"
#define kVVCMSAPIKeyBroadcastStatusArchived @"archived"
#define kVVCMSAPIKeyBroadcastID         @"id"
#define kVVCMSAPIKeyBroadcastTitle      @"title"
#define kVVCMSAPIKeyBroadcastDescr      @"description"
#define kVVCMSAPIKeyBroadcastVMAPURL    @"vmap"
#define kVVCMSAPIKeyBroadcastThumbURL   @"thumbnail"
#define kVVCMSAPIKeyBroadcastStartDate  @"start_date"
#define kVVCMSAPIKeyBroadcastEditDate   @"edit_date"
#define kVVCMSAPIKeyBroadcastRating     @"rating"
#define kVVCMSAPIKeyBroadcastAudioOnly  @"audioOnly"
#define kVVCMSAPIKeyBroadcastProgress   @"progress"
#define kVVCMSAPIKeyBroadcastAuthorDict @"author"
#define kVVCMSAPIKeyAuthorDictName      @"full_name"
#define kVVCMSAPIKeyBroadcastIsStreaming @"isStreaming"


@class VVCMSAPI;

/*!
 @discussion VVCMSAPI is used to authenticate and query a VolarVideo site for the current broadcasts (additional document types will be added over time).  The following outlines the squence of usage:
 
 1. Instantiation
 2. Initialization
 3. Authentication
 4. Query
 ...
 n. Logout
 
 
 */

@interface VVCMSAPI : NSObject {
	NSArray *_sitesArray;
    int _currentSiteIndex;
    NSDictionary *_endpointDict;
    BOOL _loggedIn;
    NSString *_userName;
    NSString *_currentSiteName;
}

/*!
 @name Instantiation
 */

/*! 
 Factory method used to create a new VVCMSAPI singlton.
 */
+ (VVCMSAPI *)vvCMSAPI;

/*!
 @name Initialization
 */
/*! 
 Set Delegate
 @param	delegate The delegate object that implements the handlers for the VVCMSAPIDelegate protocol
 @param error By-Reference error pointer for error handling
 */
- (void)setDelegate:(id<VVCMSAPIDelegate>)delegate error:(NSError **)error;

/*!
 The delegate upon which the completion methods will be called.
 */
@property (assign) id<VVCMSAPIDelegate> delegate;

/*!
 A string representing the domain for the current site and user.  nil will default to vcloud.volarvide.com.
 */
@property (nonatomic, strong) NSString *apiURL;

/*!
 @name Authentication
 */

/*!
 Authenticates with username and password and initiates VVCMSAPI
 @param url The domain for API further API calls.
 @param username Username for authenticating. Pass nil for public access.
 @param password Password for authenticating. Pass nil for public access.
 @discussion This method retrieves the broadcast metadata endpoints is to be used after setting the domain and site and is required before requesting broadcast information.
 */
- (void)authenticationRequestForDomain:(NSString *)url username:(NSString *)username andPassword:(NSString *)password;

/*!
 @name Queary for broadcasts objects
 */
/*! 
 Request VVCMSBroadcast objects for the current domain, site, and user.
 @param status Used to filter results by the broadcast status.  One of the following VVCMSBroadcastsStatus values:
 
    VVCMSBroadcastStatusUnknown,
    VVCMSBroadcastStatusScheduled,
    VVCMSBroadcastStatusStreaming,
    VVCMSBroadcastStatusArchived,
    VVCMSBroadcastStatusAll

 @param page The pagenation page
 @param items The number of results per page (for pagenation)
 */
- (void) requestBroadcastsWithStatus:(VVCMSBroadcastStatus)status page:(int)page resultsPerPage:(int)items;

/*!
 @name Logout
 */
/*!
 End authenticated session
 */
- (void)logout;

/*!
 @name Utilities
 */
/*!
 Reachability status of VolarVideo CMS domain and site
 */
-(BOOL) isReachable;

/*!
 Last known reachability result
 */
- (BOOL) latestReachabilityResult;

/*!
 Longform of sitename, useful if multiple sites are to be managed.
 */
-(NSString*) siteName;


@end
