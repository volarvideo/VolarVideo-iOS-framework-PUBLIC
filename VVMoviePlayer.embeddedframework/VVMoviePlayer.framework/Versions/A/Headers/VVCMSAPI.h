//
//  VVCMIAPI.h
//  ProductionTruckSandbox
//
//  Created by Justin Raney on 12/14/12.
//  Copyright (c) 2012 Apax Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VVCMSBroadcast.h"
#import "VVCMSClip.h"
#import "VVCMSSection.h"
#import "VVCMSSite.h"
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
    vvCMSAPIErrorInvalidAPIKey,
    vvCMSAPIErrorUnknownEndpoint=999
};
#endif

// hard coded endpoint
#define kInfoIndex             @"api/mobile/info/index"

// pagination
#define kKeyPagination         @"pagination"
#define kKeyNumPages           @"num_pages"
#define kKeyNumItems           @"num_items"

// endpoint keys
#define kKeyEndPoints          @"endpoints"
#define kKeyDomainInfo         @"domain/info"
#define kKeySectionInfo        @"section/info"
#define kKeyBroadcastInfo      @"broadcast/all"
#define kKeyClipInfo           @"videoclip/all"

// response keys
#define kKeySuccess            @"success"
#define kKeySitesArray         @"sites"
#define kKeyBroadcastsArray    @"broadcasts"
#define kKeyClipsArray         @"clips"
#define kKeySectionsArray      @"sections"

#define kKeyErrorMessage       @"message"
#define kKeyErrorCode          @"code"
#define kKeyError              @"error"
#define kErrorDomain           @"com.vv.cmsapi"

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
};
#endif

/**
 \brief VVCMSAPI is used to query video records managed by a VolarVideo CMS.
 
 When instantiating, you must provide a valid domain and API key. Your API
 key will affect the scope of content you have access to. The same request
 could yield different results for different API keys.
 
 Every request should be provided a VVCMSAPIDelegate to handle
 responses. Work is done on another thread and delegate methods are not
 guaranteed to be called on the same thread they were requested from.
 
 It's important to call shutdown when you are finished with an
 instance of VVCMSAPI. This will prevent any unfinished requests
 from calling their delegate methods, ignore future requests, and remove
 the potential for long_lived references to memory.
 */
@interface VVCMSAPI : NSObject

/*!
 @name Life cycle
 */
/*! 
 Creates a new VVCMSAPI for the provided domain and API key
 */
- (id)initWithDomain:(NSString*)domain apiKey:(NSString*)apiKey;

/*!
 This method should be called when you are finished with an instance of
 VVCMSAPI.  This will prevent any unfinished request from calling
 their delegate methods and ignore future requests.
 */
- (void)shutdown;

/*!
 @name Request data with search parameters
 */
/*! 
 Request a list of VVCMSBroadcast objects that fit the search params
 
 @param params Parameters for searching
 @param delegate Delegate used for response callbacks
 */
- (void)requestBroadcasts:(BroadcastParams*)params usingDelegate:(id<VVCMSAPIDelegate>)delegate;

/*!
 Request a list of VVCMSClip objects that fit the search params
 
 @param params Parameters for searching
 @param delegate Delegate used for response callbacks
 */
- (void)requestClips:(ClipParams*)params usingDelegate:(id<VVCMSAPIDelegate>)delegate;

/*!
 Request a list of VVCMSSite objects that fit the search params
 
 @param params Parameters for searching
 @param delegate Delegate used for response callbacks
 */
- (void)requestSites:(SiteParams*)params usingDelegate:(id<VVCMSAPIDelegate>)delegate;

/*!
 Request a list of VVCMSSection objects that fit the search params
 
 @param params Parameters for searching
 @param delegate Delegate used for response callbacks
 */
- (void)requestSections:(SectionParams*)params usingDelegate:(id<VVCMSAPIDelegate>)delegate;

@end
