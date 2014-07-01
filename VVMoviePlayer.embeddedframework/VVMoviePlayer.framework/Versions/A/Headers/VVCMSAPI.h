//
//  VVCMIAPI.h
//  ProductionTruckSandbox
//
//  Created by Justin Raney on 12/14/12.
//  Copyright (c) 2012 Apax Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVCMSBroadcast.h"
#import "VVCMSSite.h"
#import "VVCMSAPIDelegate.h"

#ifdef NS_ENUM
typedef NS_ENUM(NSInteger, vvCMSAPIError) {
    /** Errors returned by VVCMSAPI authenticationRequestForDomain:username:andPassword:
     */
    vvCMSAPIErrorInvalidDelegate=100,
    vvCMSAPIErrorNoDomainURL,
    vvCMSAPIErrorDomainUnreachable,
    vvCMSAPIErrorInvalidDomainURL,
    vvCMSAPIErrorNotLoggedIn,
    vvCMSAPIErrorUnknownEndpoint=999
};
#endif

// hard coded endpoints
#define kVVCMSAPILoginEP                @"api/auth/login"
#define kVVCMSAPIKeyUsername            @"email"
#define kVVCMSAPIKeyPassword            @"password"
#define kVVCMSAPIDomainInfoEP           @"api/info/domain"
#define kVVCMSAPIKeySections            @"api/client/section"
#define kVVCMSAPIKeyPlaylists           @"api/client/playlist"

// domain response keys
#define kVVCMSAPIKeySuccess             @"success"
#define kVVCMSAPIKeyError               @"error"
#define kVVCMSAPIKeyErrorCode           @"code"
#define kVVCMSAPIKeyErrorMessage        @"message"
#define kVVCMSAPIKeySites               @"sites"
#define kVVCMSAPIKeyEventId             @"id"

// pagination
#define kVVCMSAPIKeyPagination          @"pagination"
#define kVVCMSAPIKeyNumPages            @"num_pages"
#define kVVCMSAPIKeyNumItems            @"num_items"

// user name response keys
#define kVVCMSAPIKeyUser                @"user"
#define kVVCMSAPIKeyUserName            @"name"

#define kVVCMSAPIErrorDomain            @"com.vv.cmsapi"

// broadcast(s) responds keys
#define kVVCMSAPIKeyBroadcastsArray             @"broadcasts"
#define kVVCMSAPIKeyBroadcastStatus             @"status"
#define kVVCMSAPIKeyBroadcastStatusScheduled    @"scheduled"
#define kVVCMSAPIKeyBroadcastStatusStreaming    @"streaming"
#define kVVCMSAPIKeyBroadcastStatusStopped      @"stopped"
#define kVVCMSAPIKeyBroadcastStatusArchived     @"archived"
#define kVVCMSAPIKeyBroadcastID                 @"id"
#define kVVCMSAPIKeyBroadcastTitle              @"title"
#define kVVCMSAPIKeyBroadcastDescr              @"description"
#define kVVCMSAPIKeyBroadcastVMAPURL            @"vmap"
#define kVVCMSAPIKeyBroadcastThumbURL           @"thumbnail"
#define kVVCMSAPIKeyBroadcastStartDate          @"start_date"
#define kVVCMSAPIKeyBroadcastEditDate           @"edit_date"
#define kVVCMSAPIKeyBroadcastRating             @"rating"
#define kVVCMSAPIKeyBroadcastAudioOnly          @"audioOnly"
#define kVVCMSAPIKeyBroadcastProgress           @"progress"
#define kVVCMSAPIKeyBroadcastAuthorDict         @"author"
#define kVVCMSAPIKeyAuthorDictName              @"full_name"
#define kVVCMSAPIKeyBroadcastIsStreaming        @"isStreaming"


@class VVCMSAPI;

/*!
 @discussion VVCMSAPI is used to authenticate and query a VolarVideo site for the current broadcasts (additional document types will be added over time).  The following outlines the squence of usage:
 
 1. Instantiation
 2. Initialization
 3. Authentication
 4. Set Filters
 5. Query
 ...
 n. Logout
 
 
 */
#ifdef NS_ENUM
typedef NS_ENUM(NSInteger, VVCMSAPISortBy) {
    /** Specified the how the results of requestSectionsPage:resultsPerPage:,requestBroadcastsWithStatus:page:resultsPerPage:, and requestPlaylistsPage:resultsPerPage: methods are sorted.
     *
     */
    VVCMSAPISortByNone,
    VVCMSAPISortByDate,
    VVCMSAPISortByStatus,
    VVCMSAPISortById,
    VVCMSAPISortByTitle,
    VVCMSAPISortByDescription
};
#endif

#ifdef NS_ENUM
typedef NS_ENUM(NSInteger, VVCMSAPISortDirection) {
    /** Specifies the directection of sorting for requestSectionsPage:resultsPerPage:,requestBroadcastsWithStatus:page:resultsPerPage:, and requestPlaylistsPage:resultsPerPage: results.
     */
    vvCMSAPISortDescending=0,
    vvCMSAPISortAscending=1
} ;
#endif

@interface VVCMSAPI : NSObject {
    int _currentSiteIndex;//_currentSectionId,_currentPlaylistId;
    NSDictionary *_endpointDict;
    BOOL _loggedIn,_authenticated;
    NSString* _apiURL;
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
 @name Authentication
 */

/*!
 Authenticates with username and password and initiates VVCMSAPI
 @param domain The domain for further API calls.  Site can be appended onto domain.  Ex: @"vcloud.volarvideo.com/test-site"
 @param username Username for authenticating. Pass nil for public access.
 @param password Password for authenticating. Pass nil for public access.
 @discussion This method retrieves the broadcast metadata endpoints is to be used after setting the domain and site and is required before requesting broadcast information.
 */
- (void)authenticationRequestForDomain:(NSString *)domain username:(NSString *)username andPassword:(NSString *)password;

/*! 
 Authenticates with username and password and initiates VVCMSAPI
 @param domain The domain for further API calls.
 @param siteSlug The site slug for further API calls.
 @param username Username for authenticating. Pass nil for public access.
 @param password Password for authenticating. Pass nil for public access.
 @discussion This method retrieves the broadcast metadata endpoints is to be used after setting the domain and site and is required before requesting broadcast information.
 */
- (void)authenticationRequestForDomain:(NSString *)domain siteSlug:(NSString*)siteSlug username:(NSString *)username andPassword:(NSString *)password;

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
 @name Enumerate the available site sections
 */
/*!
 Request an array of all the sections available for the current site
 @param page The pagenation page
 @param items The number of results per page (for pagenation)
 */
- (void) requestSectionsPage:(int)page resultsPerPage:(int)items;

/*!
 @name Set the section id filter
 */
/*!
 @discussion Set the section id used to filter requestBroadcastsWithStatus:page:resultsPerPage: results.  Section id values can be obtained as a key value in the dictionaries returned by the return delegate for requestSectionsPage:resultsPerPage: method.  Set to nil to not filter.  Default value is nil.
 */
@property(nonatomic,strong) NSString *section_id;

/*!
 @name Enumerate the available site sections
 */
/*!
 Request an array of all the playlists available for the current site
 @param page The pagenation page
 @param items The number of results per page (for pagenation)
 */
- (void) requestPlaylistsPage:(int)page resultsPerPage:(int)items;

/*!
 @name The playlist id that will be used to filter requestBroadcastsWithStatus:page:resultsPerPage: results.  Set to nil to not filter.  Default value is nil.
 */
@property(nonatomic,strong) NSString *playlist_id;

/*!
 @name List broadcasts that occur before specified date. 
 */
/*!
 @discussion Limit broadcasts results to broadcasts that occur before this date.  Used by requestBroadcastsWithStatus:page:resultsPerPage: to limit the returned results.
 */
@property(nonatomic,strong) NSDate *beforeDate;

/*!
 @name List broadcasts that occur after specificed date.
 */
/*!
 @discussion Limit broadcasts results to broadcasts that occur after this date.  Used by requestBroadcastsWithStatus:page:resultsPerPage: to limit the returned results.
 */
@property(nonatomic,strong) NSDate *afterDate;

/*!
 @name Set broadcast property for sorting.
 */
/*!
 @discussion Used to change which broadcast property by which results returned by requestBroadcastsWithStatus:page:resultsPerPage: are sorted.
 */
@property(nonatomic,assign) VVCMSAPISortBy sortBy;

/*!
 @name Set sort direction for  requestBroadcastsWithStatus:page:resultsPerPage: results.
 */
/*!
 @discussion Used to set direction (ascending, descending) in which results returned by requestBroadcastsWithStatus:page:resultsPerPage: are sorted.
 */
@property(nonatomic,assign) VVCMSAPISortDirection sortDir;

/*!
 @name Set search title broadcast(s) 
 */
/*!
 
 @discussion Useful for searches, as this accepts incomplete titles and returns all matches.   Used in searching the result of the following methods:
 
 - requestBroadcastsWithStatus:page:resultsPerPage:
 - requestSectionsPage:(resultsPerPage:
 - requestPlaylistsPage:resultsPerPage:
 
 */
@property(nonatomic,strong) NSString *searchTitle;



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
 Array of VVCMSSite objects
 */
@property(nonatomic,readonly) NSArray *sites;

/*!
 Set the index of the current
 */
- (void)setCurrentSiteIndex:(NSInteger)index;

/*!
  Current site slug.  Note that this value can be supplimented by siteSlugs passed to setSiteSlugs:
 */
- (VVCMSSite*) currentSite;

/*!
 List of siteSlugs used for multi-site queries for broadcasts, playlists and sections.
 */
@property(nonatomic,strong) NSArray *siteNames;

@end
