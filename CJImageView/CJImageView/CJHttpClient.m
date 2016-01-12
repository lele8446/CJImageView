//
//  CJHttpClient.m
//  CJImageView
//
//  Created by C.K.Lian on 15/12/31.
//  Copyright © 2015年 C.K.Lian. All rights reserved.
//

#import "CJHttpClient.h"

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
    NSUInteger cacheCapacity = [NSURLCache sharedURLCache].currentMemoryUsage + [NSURLCache sharedURLCache].currentDiskUsage;
    return cacheCapacity;
}

+ (void)removeCachedResponseForRequest:(NSURLRequest *)request
{
    [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];
}

+ (void)removeAllCachedResponses
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

+ (void)removeCachedResponsesSinceDate:(NSDate *)date
{
    [[NSURLCache sharedURLCache] removeCachedResponsesSinceDate:date];
}

+ (void) getCachedForRequestUrl:(NSString *)uri successHandler:(void (^)(NSData *data, NSURLResponse *response))successHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    dispatch_async([CJHttpClient getHttpOperatorQueue], ^(){
        NSMutableURLRequest *request = CJRequestWithURL(uri, nil, nil,HTTP_DEFAULT_TIMEOUT , YES,CJRequestReturnCacheDataDontLoad);//不请求网络
        if (request == nil || [request isEqual:[NSNull null]]) {
            dispatch_async_main_queue(^{
                NSError *error;
                errorHandler(error);
            });
            //获取缓存出错，删除该缓存
            [CJHttpClient removeCachedResponseForRequest:request];
            return;
        }
        
        NSCachedURLResponse* response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        //判断是否有缓存
        if (response != nil) {
            NSLog(@"存在缓存");
        }
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                if ((error == nil || [error isEqual:[NSNull null]])&& data != nil) {
                                                    dispatch_async_main_queue(^{
                                                        successHandler(data,response);
                                                    });
                                                }else{
                                                    dispatch_async_main_queue(^{
                                                        errorHandler(error);
                                                    });
                                                    //获取缓存出错，删除该缓存
                                                    [CJHttpClient removeCachedResponseForRequest:request];
                                                }
                                            }];
        [task resume];
    });
}

+ (void) getUrl:(NSString *)uri parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval cachPolicy:(CJRequestCachePolicy)cachPolicy completionHandler:(void (^)(NSData *data, NSURLResponse *response))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    NSMutableURLRequest *request = CJRequestWithURL(uri, nil, parameters, timeoutInterval, YES, cachPolicy);
    if (request == nil || [request isEqual:[NSNull null]]) {
        NSError *error;
        errorHandler(error);
        return;
    }
    NSLog(@"get url:%@", request.URL);
    
    if (cachPolicy != CJRequestIgnoringLocalCacheData) {
        NSCachedURLResponse* response = [[NSURLCache sharedURLCache] cachedResponseForRequest:request];
        //判断是否有缓存
        if (response != nil) {
            //存在缓存，不请求网络
            [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
        }
    }else{
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
        [CJHttpClient removeCachedResponseForRequest:request];
    }
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            if ((error == nil || [error isEqual:[NSNull null]])&& data != nil) {
                                                completionHandler(data,response);
                                                if (cachPolicy == CJRequestIgnoringLocalCacheData) {
                                                    [CJHttpClient removeCachedResponseForRequest:request];
                                                }
                                            }else{
                                                errorHandler(error);
                                                [CJHttpClient removeCachedResponseForRequest:request];
                                            }
                                        }];
    [task resume];
}

+ (void) getAsyncUrl:(NSString *)uri parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval cachPolicy:(CJRequestCachePolicy)cachPolicy completionHandler:(void (^)(NSData *data, NSURLResponse *response))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    //异步线程请求
    dispatch_async([CJHttpClient getHttpOperatorQueue], ^(){
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
                //存在缓存，不请求网络
                [request setCachePolicy:NSURLRequestReturnCacheDataDontLoad];
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
                                                        if (cachPolicy == CJRequestIgnoringLocalCacheData) {
                                                            [CJHttpClient removeCachedResponseForRequest:request];
                                                        }
                                                    });
                                                }else{
                                                    dispatch_async_main_queue(^{
                                                        errorHandler(error);
                                                    });
                                                    [CJHttpClient removeCachedResponseForRequest:request];
                                                }
                                            }];
        [task resume];
    });
}

+ (void) postUrl:(NSString *)uri parameters:(id)parameters timeoutInterval:(NSTimeInterval)timeoutInterval completionHandler:(void (^)(NSData *data, NSURLResponse *response))completionHandler errorHandler:(void (^)(NSError *error))errorHandler
{
    //异步线程请求
    dispatch_async([CJHttpClient getHttpOperatorQueue], ^(){
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
    });
}

+ (dispatch_queue_t )getHttpOperatorQueue
{
    static dispatch_queue_t  _httpOperatorQueue;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _httpOperatorQueue = dispatch_queue_create([@"CJ.httpOperatorQueue" UTF8String], NULL);
    });
    return _httpOperatorQueue;
}
@end
