//
//  B3MediaCell.h

//
//  Created by Benjamin Askren on 9/20/12.
//  Copyright (c) 2012 Benjamin Askren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

enum B3MediaCellType {
    B3MediaCellTypeVideo,
    B3MediaCellTypeBroadcast,
    B3MediaCellTypeAudio,
    B3MediaCellTypeGallery,
    B3MediaCellTypePhoto,
    B3MediaCellTypeDocument,
    B3MediaCellTypeDOC,
    B3MediaCellTypeXLS,
    B3MediaCellTypePDF,
    B3MediaCellTypeTXT,
    B3MediaCellTypeRTF,
    B3MediaCellTypeHTML,
    B3MediaCellTypeArticle,
    B3MediaCellTypeFutureBroadcast,
    B3MediaCellTypeLiveBroadcast,
    B3MediaCellTypeScheduledBroadcast
} ;


@interface B3MediaCell : UITableViewCell {
//    IBOutlet UILabel *lblDescription, *lblMeta1, *lblMeta2;
    IBOutlet UILabel *lblMeta1;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIImageView *imgPlayVideo;
//    IBOutlet UIButton *btnFavorite;
}

@property(nonatomic,assign) BOOL read, favorite,disabled;
@property(nonatomic,unsafe_unretained) NSString *title,*description, *meta1, *meta2;   //iOS 4.3 support
//@property(nonatomic,unsafe_unretained) UIImage *thumbnail;                      //iOS 4.3 support
@property(nonatomic,strong) IBOutlet UIImageView *imgThumb;
@property(nonatomic,strong) IBOutlet UIWebView *wvDescription;
@property(nonatomic,assign) enum B3MediaCellType type;

@end
