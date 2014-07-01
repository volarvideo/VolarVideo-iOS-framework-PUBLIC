//
//  VVMediaCell.h

//
//  Created by Benjamin Askren on 9/20/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

enum VVMediaCellType {
    VVMediaCellTypeVideo,
    VVMediaCellTypeBroadcast,
    VVMediaCellTypeAudio,
    VVMediaCellTypeGallery,
    VVMediaCellTypePhoto,
    VVMediaCellTypeDocument,
    VVMediaCellTypeDOC,
    VVMediaCellTypeXLS,
    VVMediaCellTypePDF,
    VVMediaCellTypeTXT,
    VVMediaCellTypeRTF,
    VVMediaCellTypeHTML,
    VVMediaCellTypeArticle,
    VVMediaCellTypeFutureBroadcast,
    VVMediaCellTypeLiveBroadcast,
    VVMediaCellTypeScheduledBroadcast
} ;


@interface VVMediaCell : UITableViewCell {
//    IBOutlet UILabel *lblDescription, *lblMeta1, *lblMeta2;
    IBOutlet UILabel *lblMeta1;
    IBOutlet UILabel *lblMeta2;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIImageView *imgPlayVideo;
//    IBOutlet UIButton *btnFavorite;
}

@property(nonatomic,assign) BOOL read, favorite,disabled;
@property(nonatomic,unsafe_unretained) NSString *title,*description, *meta1, *meta2;   //iOS 4.3 support
//@property(nonatomic,unsafe_unretained) UIImage *thumbnail;                      //iOS 4.3 support
@property(nonatomic,strong) IBOutlet UIImageView *imgThumb;
@property(nonatomic,strong) IBOutlet UIWebView *wvDescription;
@property(nonatomic,assign) enum VVMediaCellType type;

@end
