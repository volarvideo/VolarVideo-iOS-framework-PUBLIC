//
//  ZoomingScrollView.h
//  MWPhotoBrowser
//
//  Created by Michael Waterfall on 14/10/2010.
//  Copyright 2010 d3i. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MWPhotoProtocol.h"
#import "MWTapDetectingImageView.h"
#import "MWTapDetectingView.h"

@class MWPhotoBrowser, MWPhoto, MWCaptionView,MWZoomingScrollView  ;

@interface MWZoomingScrollView : UIScrollView <UIScrollViewDelegate, MWTapDetectingImageViewDelegate, MWTapDetectingViewDelegate> {
	
	MWPhotoBrowser *_photoBrowser;
    id<MWPhoto> _photo;
    UIButton *_btnFav;
    BOOL _fav;
	
    // This view references the related caption view for simplified
    // handling in photo browser
    MWCaptionView *_captionView;
    
	MWTapDetectingView *_tapView; // for background taps
	MWTapDetectingImageView *_photoImageView;
	UIActivityIndicatorView *_spinner;
	
}

@property (nonatomic, retain) MWCaptionView *captionView;
@property (nonatomic, retain) id<MWPhoto> photo;
@property (nonatomic, assign) BOOL favorite;


- (id)initWithPhotoBrowser:(MWPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)prepareForReuse;

@end
