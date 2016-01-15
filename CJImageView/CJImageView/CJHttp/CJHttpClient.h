//
//  CJHttpClient.h
//  CJImageView
//
//  Created by C.K.Lian on 15/12/31.
//  Copyright © 2015年 C.K.Lian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CJHttpTool.h"

#define dispatch_async_main_queue(block)\
          if ([NSThread isMainThread]) {\
              block();\
          } else {\
              dispatch_async(dispatch_get_main_queue(), block);\
          }

@interface CJHttpClient : NSObject
/**
 *  默认缓存（内存4M，硬盘20M）
 */
+ (void)setDefaultCapacity;

/**
 *  设置内存缓存与硬盘缓存大小
 *
 *  @param memoryCapacity
 *  @param diskCapacity   
 */
+ (void)setMaxMemoryCapacity:(NSUInteger)memoryCapacity maxDiskCapacity:(NSUInteger)diskCapacity;

/**
 *  获取缓存大小
 *
 *  @return
 */
+ (NSUInteger)getCacheCapacity;

/**
 *  清除指定缓存
 *
 *  @param request
 */
+ (void)removeCachedResponseForRequest:(NSURLRequest *)request;

/**
 *  清除所有缓存
 */
+ (void)removeAllCachedResponses;

/**
 *  清除指定时间之前的缓存
 *
 *  @param date
 */
+ (void)removeCachedResponsesSinceDate:(NSDate *)date;

/**
 *  get 请求
 *
 *  @param uri               请求URL
 *  @param parameters        请求参数,NSData(POST) or NSDictionary
 *  @param timeoutInterval   设置请求timeout
 *  @param cachPolicy        缓存策略
 *  @param completionHandler 请求回调
 *  @param errorHandler      error
 */
+ (void) getUrl:(NSString *)uri parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval cachPolicy:(CJRequestCachePolicy)cachPolicy completionHandler:(void (^)(NSData *data, NSURLResponse *response))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

/**
 *  post 请求
 *
 *  @param uri               请求URL
 *  @param parameters        请求参数,NSData(POST) or NSDictionary
 *  @param timeoutInterval   设置请求timeout
 *  @param completionHandler 请求回调
 *  @param errorHandler      error
 */
+ (void) postUrl:(NSString *)uri parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(NSData *data, NSURLResponse *response))completionHandler errorHandler:(void (^)(NSError *error))errorHandler;

@end
