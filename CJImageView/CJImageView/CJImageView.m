//
//  CJImageView.m
//  CJImageView
//
//  Created by C.J.Lian on 2021/7/2.
//  Copyright © 2021 cjl. All rights reserved.
//

#import "CJImageView.h"

#define PointValue(a)  ((a)<0?0:(a))
typedef void(^CropImageBlock)(UIImage *image);

@interface CJImageContentView : UIView
@property (nonatomic, assign) CJImageViewContentMode cjContentMode;

@end
@implementation CJImageContentView

- (void)flushWithImage:(UIImage *)originalImage {
    [self cropImage:originalImage completion:^(UIImage *image) {
        self.layer.contents = (__bridge id)image.CGImage;
    }];
}

- (void)cropImage:(UIImage *)image completion:(CropImageBlock)completion {
    if (image) {
        @autoreleasepool {
            CGImageRef cgImage = image.CGImage;
            size_t imageW = CGImageGetWidth(cgImage);
            size_t imageH = CGImageGetHeight(cgImage);
            
            CGFloat scale = image.scale;
            CGFloat imageViewW = CGRectGetWidth(self.frame)*scale;
            CGFloat imageViewH = CGRectGetHeight(self.frame)*scale;
            
            CGFloat x = 0,y = 0;
            CGFloat resultImageW = imageViewW;
            CGFloat resultImageH = imageViewH;
            UIImage *resultImage = nil;
            
            if (imageW > imageViewW && imageH > imageViewH) {
                if (imageW/imageViewW > imageH/imageViewH) {
                    resultImageH = imageH;
                    resultImageW = (resultImageH * imageViewW)/imageViewH;
                }else{
                    resultImageW = imageW;
                    resultImageH = (resultImageW * imageViewH)/imageViewW;
                }
            }
            else if (imageW > imageViewW && imageH < imageViewH) {
                resultImageH = imageH;
                resultImageW = imageViewW;
            }
            else if (imageW < imageViewW && imageH > imageViewH) {
                resultImageH = imageViewH;
                resultImageW = imageW;
            }else{
                resultImage = image;
            }
            
            CGFloat x1 = self.bounds.size.width - resultImage.size.width;
            CGFloat y1 = self.bounds.size.height - resultImage.size.height;
            CGPoint point = CGPointZero;
            if (self.cjContentMode == CJContentModeScaleAspectCenter) {
                x = PointValue((imageW-resultImageW)/2);
                y = PointValue((imageH-resultImageH)/2);
                point = CGPointMake(x1/2, y1/2);
            }
            else if (self.cjContentMode == CJContentModeScaleAspectTop) {
                x = PointValue((imageW-resultImageW)/2);
                y = 0;
                point = CGPointMake(x1/2, 0);
            }
            else if (self.cjContentMode == CJContentModeScaleAspectBottom) {
                x = PointValue((imageW-resultImageW)/2);
                y = PointValue((imageH-resultImageH));
                point = CGPointMake(x1/2, y1);
            }
            else if (self.cjContentMode == CJContentModeScaleAspectLeft) {
                x = 0;
                y = PointValue((imageH-resultImageH)/2);
                point = CGPointMake(0, y1/2);
            }
            else if (self.cjContentMode == CJContentModeScaleAspectRight) {
                x = PointValue((imageW-resultImageW));
                y = PointValue((imageH-resultImageH)/2);
                point = CGPointMake(x1, y1/2);
            }
            else if (self.cjContentMode == CJContentModeScaleAspectTopLeft) {
                x = 0;
                y = 0;
                point = CGPointMake(0, 0);
            }
            else if (self.cjContentMode == CJContentModeScaleAspectTopRight) {
                x = PointValue((imageW-resultImageW));
                y = 0;
                point = CGPointMake(x1, 0);
            }
            else if (self.cjContentMode == CJContentModeScaleAspectBottomLeft) {
                x = 0;
                y = PointValue((imageH-resultImageH));
                point = CGPointMake(0, y1);
            }
            else if (self.cjContentMode == CJContentModeScaleAspectBottomRight) {
                x = PointValue((imageW-resultImageW));
                y = PointValue((imageH-resultImageH));
                point = CGPointMake(x1, y1);
            }
            
            if (!resultImage) {
                cgImage = CGImageCreateWithImageInRect(cgImage, CGRectMake(x, y, resultImageW, resultImageH));
                resultImage = [UIImage imageWithCGImage:cgImage];
                CGImageRelease(cgImage);
            }else{
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
                [resultImage drawAtPoint:point];
                resultImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            
            if (completion) {
                completion(resultImage);
            }
        }
    }
}
@end


@interface CJImageView ()
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) CJImageContentView *imageContentView;
@property (nonatomic, assign) CGRect oldBounds;
@end

@implementation CJImageView
@dynamic image;

- (CJImageContentView *)imageContentView {
    if (!_imageContentView) {
        _imageContentView = [[CJImageContentView alloc]initWithFrame:CGRectMake(0, 0, 30, 20)];
        _imageContentView.backgroundColor = [UIColor clearColor];
        [_imageContentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:_imageContentView];
        [self equalLayoutConstraintItem:_imageContentView toItem:self attribute:NSLayoutAttributeLeft];
        [self equalLayoutConstraintItem:_imageContentView toItem:self attribute:NSLayoutAttributeRight];
        [self equalLayoutConstraintItem:_imageContentView toItem:self attribute:NSLayoutAttributeTop];
        [self equalLayoutConstraintItem:_imageContentView toItem:self attribute:NSLayoutAttributeBottom];
        _imageContentView.hidden = YES;
    }
    return _imageContentView;
}

- (void)equalLayoutConstraintItem:(id)view1 toItem:(id)view2 attribute:(NSLayoutAttribute)attr {
    [NSLayoutConstraint constraintWithItem:view1
                                 attribute:attr
                                 relatedBy:NSLayoutRelationEqual
                                    toItem:view2
                                 attribute:attr
                                multiplier:1.0f
                                  constant:0.0f].active = YES;
}

- (void)setImage:(UIImage *)image {
    self.originalImage = image;
    [self flush];
}

/* Return nil, bacause UIImageView will automatically refreshes image according to the contentMode value when it resign active, instead of displaying the current image.
 *
 * Get image, use [self cjImage] instead.
 */
- (UIImage *)image {
    return nil;
}
- (UIImage *)cjImage {
    return self.originalImage;
}

- (void)setCjContentMode:(CJImageViewContentMode)CJContentMode {
    _cjContentMode = CJContentMode;
    self.imageContentView.cjContentMode = CJContentMode;
    
    if (!(self.cjContentMode >= CJContentModeScaleAspectCenter &&
        self.cjContentMode <= CJContentModeScaleAspectBottomRight)) {
        self.contentMode = (UIViewContentMode)CJContentMode;
    }
    
    [self flush];
}

- (void)setContentMode:(UIViewContentMode)contentMode {
    [super setContentMode:contentMode];
    _cjContentMode = 0;
    self.imageContentView.cjContentMode = 0;
    [self flush];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectEqualToRect(self.bounds, self.oldBounds)) {
        self.oldBounds = self.bounds;
        [self flush];
    }
}

- (void)flush {
    if (self.cjContentMode >= CJContentModeScaleAspectCenter &&
        self.cjContentMode <= CJContentModeScaleAspectBottomRight) {
        [super setImage:nil];
        self.layer.contents = nil;
        self.imageContentView.hidden = NO;
        [self.imageContentView flushWithImage:self.originalImage];
    }
    else{
        [super setImage:self.originalImage];
        self.imageContentView.hidden = YES;
        self.imageContentView.layer.contents = nil;
    }
}

@end
