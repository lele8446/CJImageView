//
//  CJImageView.h
//  CJImageView
//
//  Created by C.J.Lian on 2021/7/2.
//  Copyright © 2021 cjl. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CJImageViewContentMode) {
    CJContentModeScaleAspectCenter        = 1003,
    CJContentModeScaleAspectTop           = 1004,
    CJContentModeScaleAspectBottom        = 1005,
    CJContentModeScaleAspectLeft          = 1006,
    CJContentModeScaleAspectRight         = 1007,
    CJContentModeScaleAspectTopLeft       = 1008,
    CJContentModeScaleAspectTopRight      = 1009,
    CJContentModeScaleAspectBottomLeft    = 1010,
    CJContentModeScaleAspectBottomRight   = 1011,
};

IB_DESIGNABLE
/// A custom UIImageView that supports contentMode attribute expansion
@interface CJImageView : UIImageView

/// UIView contentMode attribute expansion. If image' size larger than CJImageView' size, contents scaled to fill with fixed aspect and adjust position, some portion of content may be clipped. Otherwise just adjust the position.
@property (nonatomic, assign) CJImageViewContentMode cjContentMode;

/// self.image or [self image] always return nil. Use [self cjImage] instead.
@property (nonatomic, strong, setter=setImage:, getter=image) UIImage *image;
- (UIImage *)cjImage;
@end
