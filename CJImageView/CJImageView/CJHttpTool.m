//
//  CJHttpTool.m
//  CJImageView
//
//  Created by C.K.Lian on 15/12/31.
//  Copyright © 2015年 C.K.Lian. All rights reserved.
//

#import "CJHttpTool.h"

@implementation CJHttpTool

@end

#define HTTP_MULTIPART_BOUNDARY @"CJHTTPMULTIPARTBOUNDARY"

#pragma mark -
#pragma mark CJURLEncodedStringFromStringWithEncoding
NSString * CJURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding);
NSString * CJURLEncodedStringFromStringWithEncoding(NSString *string, NSStringEncoding encoding) {
    //    static NSString * const kCJLegalCharactersToBeEscaped = @"?!@#$^&%*+=,:;'\"`<>()[]{}/\\|~ ";
    //    return CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
    //                                                                     (CFStringRef)string,
    //                                                                     NULL,
    //                                                                     (CFStringRef)kCJLegalCharactersToBeEscaped,
    //                                                                     CFStringConvertNSStringEncodingToEncoding(encoding)));
    
    return [string stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

#pragma mark CJQueryStringComponent
@interface CJQueryStringComponent : NSObject {
@private
    NSString *_key;
    NSString *_value;
}

@property (readwrite, nonatomic, retain) id key;
@property (readwrite, nonatomic, retain) id value;

- (id)initWithKey:(id)key value:(id)value;
- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding;

@end

@implementation CJQueryStringComponent
@synthesize key = _key;
@synthesize value = _value;

- (id)initWithKey:(id)key value:(id)value {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.key = key;
    self.value = value;
    
    return self;
}

- (void)dealloc {
    self.key = nil;
    self.value = nil;
    
}

- (NSString *)URLEncodedStringValueWithEncoding:(NSStringEncoding)stringEncoding {
    return [NSString stringWithFormat:@"%@=%@", self.key, CJURLEncodedStringFromStringWithEncoding([self.value description], stringEncoding)];
}
@end

#pragma mark -
#pragma mark  CJQueryStringComponents
NSArray * CJQueryStringComponentsFromKeyAndValue(NSString *key, id value);
NSArray * CJQueryStringComponentsFromKeyAndDictionaryValue(NSString *key, NSDictionary *value);
NSArray * CJQueryStringComponentsFromKeyAndArrayValue(NSString *key, NSArray *value);
NSString * CJQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding);

NSString * CJQueryStringFromParametersWithEncoding(NSDictionary *parameters, NSStringEncoding stringEncoding) {
    NSMutableArray *mutableComponents = [NSMutableArray array];
    for (CJQueryStringComponent *component in CJQueryStringComponentsFromKeyAndValue(nil, parameters)) {
        [mutableComponents addObject:[component URLEncodedStringValueWithEncoding:stringEncoding]];
    }
    
    return [mutableComponents componentsJoinedByString:@"&"];
}

NSArray * CJQueryStringComponentsFromKeyAndValue(NSString *key, id value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    if([value isKindOfClass:[NSDictionary class]]) {
        [mutableQueryStringComponents addObjectsFromArray:CJQueryStringComponentsFromKeyAndDictionaryValue(key, value)];
    } else if([value isKindOfClass:[NSArray class]]) {
        [mutableQueryStringComponents addObjectsFromArray:CJQueryStringComponentsFromKeyAndArrayValue(key, value)];
    } else {
        [mutableQueryStringComponents addObject:[[CJQueryStringComponent alloc] initWithKey:key value:value]];
    }
    
    return mutableQueryStringComponents;
}

NSArray * CJQueryStringComponentsFromKeyAndDictionaryValue(NSString *key, NSDictionary *value){
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    [value enumerateKeysAndObjectsUsingBlock:^(id nestedKey, id nestedValue, BOOL *stop) {
        [mutableQueryStringComponents addObjectsFromArray:CJQueryStringComponentsFromKeyAndValue((key ? [NSString stringWithFormat:@"%@[%@]", key, nestedKey] : nestedKey), nestedValue)];
    }];
    
    return mutableQueryStringComponents;
}

NSArray * CJQueryStringComponentsFromKeyAndArrayValue(NSString *key, NSArray *value) {
    NSMutableArray *mutableQueryStringComponents = [NSMutableArray array];
    
    [value enumerateObjectsUsingBlock:^(id nestedValue, NSUInteger idx, BOOL *stop) {
        [mutableQueryStringComponents addObjectsFromArray:CJQueryStringComponentsFromKeyAndValue([NSString stringWithFormat:@"%@[]", key], nestedValue)];
    }];
    
    return mutableQueryStringComponents;
}

NSMutableURLRequest *CJRequestWithURL(NSString *urlPath,NSString *method,id parameters,NSTimeInterval timeout, BOOL encoding, CJRequestCachePolicy cachPolicy)
{
    
    if (urlPath == nil || [urlPath isEqual:[NSNull null]] || [urlPath rangeOfString:@"http"].location == NSNotFound) {
        return nil;
    }
    
    NSString *_method = method;
    if (_method == nil) {
        _method = @"GET";
    }else{
        _method = [_method uppercaseString];
    }
    if (encoding) {
        urlPath = [urlPath stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    NSURL *url = [NSURL URLWithString:urlPath];
    
    if (url == nil) {
        return nil;
    }
    
    NSTimeInterval httpTimeout = (timeout && timeout!=0)?timeout:HTTP_DEFAULT_TIMEOUT;
    NSURLRequestCachePolicy httpCachPolicy = (NSURLRequestCachePolicy)cachPolicy;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:httpCachPolicy timeoutInterval:httpTimeout];
    [request setHTTPMethod:_method];
    [request setValue:@"CJ Mobile App" forHTTPHeaderField:@"User-Agent"];
    
    if (parameters && [parameters isKindOfClass:[NSDictionary class]]) {
        if ([_method isEqualToString:@"GET"] || [_method isEqualToString:@"HEAD"] || [_method isEqualToString:@"DELETE"]) {
            url = [NSURL URLWithString:[[url absoluteString] stringByAppendingFormat:[urlPath rangeOfString:@"?"].location == NSNotFound ? @"?%@" : @"&%@", CJQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding)]];
            [request setURL:url];
        } else {
            NSString *charset = (NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
            if(![request valueForHTTPHeaderField:@"Content-Type"]){
                [request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset] forHTTPHeaderField:@"Content-Type"];
            }
            
            [request setHTTPBody:[CJQueryStringFromParametersWithEncoding(parameters, NSUTF8StringEncoding) dataUsingEncoding:NSUTF8StringEncoding]];
            
        }
    }else if(parameters && [parameters isKindOfClass:[NSData class]]){
        
        if(![request valueForHTTPHeaderField:@"Content-Type"]){
            [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", HTTP_MULTIPART_BOUNDARY]  forHTTPHeaderField:@"Content-Type"];
        }
        [request setHTTPBody:parameters];
    }
    
    return request;
}

