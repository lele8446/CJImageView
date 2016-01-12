//
//  CJImageView.h
//  CJImageView
//
//  Created by C.K.Lian on 15/12/30.
//  Copyright © 2015年 C.K.Lian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJImageView : UIImageView

/**
 *  是否显示加载菊花，默认否
 */
@property (nonatomic) BOOL showIndicator;
/**
 *  加载菊花样式，默认UIActivityIndicatorViewStyleGray
 */
@property (nonatomic) UIActivityIndicatorViewStyle style;


/**
 *  加载图片uri
 *
 *  @param uri
 */
- (void)setUri:(NSString *)uri;

/**
 *  加载图片，设置默认图
 *
 *  @param uri
 *  @param image
 */
- (void)setUri:(NSString *)uri defaultImage:(UIImage *)image;

/**
 *  加载图片，是否显示加载菊花
 *
 *  @param uri
 *  @param showIndicator
 */
- (void)setUri:(NSString *)uri showIndicator:(BOOL)showIndicator;

/**
 *  加载图片，设置默认图，是否显示加载菊花
 *
 *  @param uri
 *  @param image
 *  @param showIndicator
 *  @param decoded
 */
- (void)setUri:(NSString *)uri defaultImage:(UIImage *)image showIndicator:(BOOL)showIndicator decoded:(BOOL)decoded;

/**
 *  加载图片，设置默认图，显示加载菊花，设置加载菊花样式
 *
 *  @param uri
 *  @param image
 *  @param showIndicator
 *  @param style 默认UIActivityIndicatorViewStyleGray
 *  @param decoded 是否decoded
 */
- (void)setUri:(NSString *)uri defaultImage:(UIImage *)image showIndicator:(BOOL)showIndicator style:(UIActivityIndicatorViewStyle)style decoded:(BOOL)decoded;

@end
