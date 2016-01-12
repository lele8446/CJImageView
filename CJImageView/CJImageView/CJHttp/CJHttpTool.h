//
//  CJHttpTool.h
//  CJImageView
//
//  Created by C.K.Lian on 15/12/31.
//  Copyright © 2015年 C.K.Lian. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HTTP_DEFAULT_TIMEOUT    20

typedef NS_ENUM(NSUInteger, CJRequestCachePolicy)
{
    /**
     *  忽略缓存，重新请求
     */
    CJRequestIgnoringLocalCacheData  = NSURLRequestReloadIgnoringCacheData,
    /**
     *  有缓存就用缓存，没有缓存就重新请求
     */
    CJRequestReturnCacheDataElseLoad = NSURLRequestReturnCacheDataElseLoad,
    /**
     *  有缓存就用缓存，没有缓存就不发请求，当做请求出错处理（用于离线模式）
     */
    CJRequestReturnCacheDataDontLoad = NSURLRequestReturnCacheDataDontLoad,
};

/**
 *  获取NSURLRequest
 *
 *  @param urlPath    请求url
 *  @param method     请求类型（默认GET）
 *  @param parameters 请求参数
 *  @param timeout    超时时间
 *  @param encoding   是否编码
 *  @param cachPolicy 缓存方式
 *
 *  @return NSMutableURLRequest
 */
NSMutableURLRequest *CJRequestWithURL(NSString *urlPath,NSString *method,id parameters,NSTimeInterval timeout, BOOL encoding, CJRequestCachePolicy cachPolicy);

@interface CJHttpTool : NSObject

@end


