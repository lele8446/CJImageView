//
//  CJHttpClient.m
//  CJImageView
//
//  Created by C.K.Lian on 15/12/31.
//  Copyright © 2015年 C.K.Lian. All rights reserved.
//

#import "CJHttpClient.h"
#import <UIKit/UIKit.h>
#define CJ_IOS_VERSION ([[[UIDevice currentDevice] systemVersion] floatValue])

@implementation CJHttpClient
+ (void)setDefaultCapacity
{
    [CJHttpClient setMaxMemoryCapacity:4 maxDiskCapacity:20];
}

+ (void)setMaxMemoryCapacity:(NSUInteger)memoryCapacity maxDiskCapacity:(NSUInteger)diskCapacity
{
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:memoryCapacity*1024*1024 diskCapacity:diskCapacity*1024*1024 diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];
}

+ (NSUInteger)getCacheCapacity
{
//    NSUInteger cacheCapacity = [NSURLCache sharedURLCache].currentMemoryUsage + [NSURLCache sharedURLCache].currentDiskUsage;
    NSUInteger cacheCapacity = [NSURLCache sharedURLCache].currentDiskUsage;
    return cacheCapacity;
}

+ (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    @synchronized([NSURLCache sharedURLCache]) {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
    }
}

+ (void)removeAllCachedResponses
{
    @synchronized([NSURLCache sharedURLCache]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }
}

+ (void)removeCachedResponsesSinceDate:(NSDate *)date
{
    @synchronized([NSURLCache sharedURLCache]) {
        [[NSURLCache sharedURLCache] removeCachedResponsesSinceDate:date];
    }
}

+ (void) getUrl:(NSString *)uri parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval cachPolicy:(CJRequestCachePolicy)cachPolicy completionHandler:(void (^)(NSData *data, NSURLResponse *response))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    NSMutableURLRequest *request = CJRequestWithURL(uri, nil, parameters, timeoutInterval, YES, cachPolicy);
    if (request == nil || [request isEqual:[NSNull null]]) {
        dispatch_async_main_queue(^{
            NSError *error;
            errorHandler(error);
        });
        return;
    }
    NSLog(@"get url:%@", request.URL);
    
    if (cachPolicy != CJRequestIgnoringLocalCacheData) {
        NSCachedURLResponse* response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        //判断是否有缓存
        if (response != nil) {
            NSLog(@"存在缓存");
        }
    }else{
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [CJHttpClient removeCachedResponseForRequest:request];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            if ((error == nil || [error isEqual:[NSNull null]])&& data != nil) {
                                                dispatch_async_main_queue(^{
                                                    completionHandler(data,response);
                                                });
                                                if (cachPolicy == CJRequestIgnoringLocalCacheData) {
                                                    //忽略缓存，删除缓存
                                                    [CJHttpClient removeCachedResponseForRequest:request];
                                                }
                                            }else{
                                                dispatch_async_main_queue(^{
                                                    errorHandler(error);
                                                });
                                                //请求出错，删除缓存
                                                [CJHttpClient removeCachedResponseForRequest:request];
                                            }
                                        }];
    [task resume];
}

+ (void) postUrl:(NSString *)uri parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(NSData *data, NSURLResponse *response))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    NSMutableURLRequest *request = CJRequestWithURL(uri, @"POST", parameters, timeoutInterval, YES,CJRequestIgnoringLocalCacheData);
    if (request == nil || [request isEqual:[NSNull null]]) {
        dispatch_async_main_queue(^{
            NSError *error;
            errorHandler(error);
        });
        return;
    }
    NSLog(@"post url:%@", request.URL);
    //post请求不使用缓存
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            if ((error == nil || [error isEqual:[NSNull null]])&& data != nil) {
                                                dispatch_async_main_queue(^{
                                                    completionHandler(data,response);
                                                });
                                            }else{
                                                dispatch_async_main_queue(^{
                                                    errorHandler(error);
                                                });
                                                [CJHttpClient removeCachedResponseForRequest:request];
                                            }
                                        }];
    [task resume];
}

@end
