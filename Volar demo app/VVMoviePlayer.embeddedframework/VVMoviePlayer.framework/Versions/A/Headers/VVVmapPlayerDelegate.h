//
//  VVVmapPlayerDelegate.h
//  mobileapidev
//
//  Created by Benjamin Askren on 1/26/13.
//  Copyright (c) 2013 42nd Parallel. All rights reserved.
//

#ifndef mobileapidev_VVVmapPlayerDelegate_h
#define mobileapidev_VVVmapPlayerDelegate_h



@class VVBasicPlayer;

@protocol VVVmapPlayerDelgate
-(void) setContentPlayer:(VVBasicPlayer*)player;
-(void) setLoadState:(MPMovieLoadState)loadstate;
-(void) setDuration:(NSTimeInterval)d;
-(void) setNaturalSize:(CGSize)s;
-(void) playAdPlayer:(VVBasicPlayer*)player;
-(void) playContentPlayer;
-(BOOL) playing;
-(void) resume;
-(void) setAudioOnly:(BOOL)audioOnly;
-(void) showSpinner;
-(void) hideSpinner;
-(UIActivityIndicatorView*)spinner;
-(void) setMovieMediaTypes:(MPMovieMediaTypeMask)movieMediaTypes;
-(void) contentPreloadDidFinishWithError:(NSError*)error;
-(void) setReadyForDisplay:(BOOL)ready;
-(void) contentFinishedWithError:(NSError*)error;
-(void) setStartCount:(double)c;
-(void) setEndCount:(double)c;
-(void) displayMessage:(NSString*)message;
-(void) clearMessage;
-(VVBasicPlayer*)activePlayer;
-(void) updateAdCountdownTime:(NSTimeInterval)remaining;
@property(nonatomic,assign) BOOL keepPlayingContent;

-(void) setPosterImage:(UIImage *)posterImage ;
-(void) showPoster ;
-(void) hidePoster ;


@end


#endif
