//
//  CJImageViewCache.h
//  CJImageView
//
//  Created by C.K.Lian on 16/1/11.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CJImageViewCache : NSObject
/**
 *  缓存单例
 *
 *  @return
 */
+ (CJImageViewCache *)sharedImageCache;

/**
 *  清除所有缓存
 */
- (void)clearAllCache;

/**
 *  清除指定缓存
 *
 *  @param uri
 */
- (void)clearWithUri:(NSString *)uri;

/**
 *  保存缓存
 *
 *  @param data imageData
 *  @param uri
 *  @param decoded 是否decoded
 */
- (void)saveCache:(NSData *)data uri:(NSString *)uri decoded:(BOOL)decoded;

/**
 *  获取缓存
 *
 *  @param uri
 *  @param decoded 是否decoded
 *
 *  @return 
 */
- (UIImage *)getImageFromCache:(NSString *)uri decoded:(BOOL)decoded;

/**
 *  获取缓存大小
 *
 *  @return 单位M，保留两位小数
 */
- (double)getCacheCapacity;

/**
 *  decoded UIImage
 *
 *  @param image
 *
 *  @return 
 */
+ (UIImage *)decodedImageWithImage:(UIImage *)image;

/**
 *  是否PNG图片
 *
 *  @param imageData
 *
 *  @return 
 */
+ (BOOL)isPNGImage:(NSData *)imageData;
@end
