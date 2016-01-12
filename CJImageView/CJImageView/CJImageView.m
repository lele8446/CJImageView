//
//  CJImageView.m
//  CJImageView
//
//  Created by C.K.Lian on 15/12/30.
//  Copyright © 2015年 C.K.Lian. All rights reserved.
//

#import "CJImageView.h"
#import "CJHttpClient.h"
#import "CJImageViewCache.h"

@interface CJImageView ()
@property (nonatomic, retain) UIActivityIndicatorView *loadingInducator;
/**
 *  加载图片url
 */
@property (nonatomic, copy, readwrite) NSString *url;

@property (nonatomic) BOOL decoded;
@end

@implementation CJImageView

- (void)setDecoded:(BOOL)decoded
{
    _decoded = decoded;
}
- (BOOL)getDecoded
{
    if (_decoded) {
        return _decoded;
    }else{
        return NO;
    }
}

- (void)setShowIndicator:(BOOL)showIndicator
{
    _showIndicator = showIndicator;
}
- (BOOL)getShowIndicator
{
    if (_showIndicator) {
        return _showIndicator;
    }else{
        return NO;
    }
}

- (void)setStyle:(UIActivityIndicatorViewStyle)style
{
    _style = style;
}
- (UIActivityIndicatorViewStyle)getStyle
{
    if (_style) {
        return _style;
    }else{
        return UIActivityIndicatorViewStyleGray;
    }
}


- (void)setUri:(NSString *)uri
{
    [self setUri:uri defaultImage:nil];
}

- (void)setUri:(NSString *)uri showIndicator:(BOOL)showIndicator
{
    self.showIndicator = showIndicator;
    [self setUri:uri defaultImage:nil showIndicator:self.showIndicator style:self.style decoded:self.decoded];
}

- (void)setUri:(NSString *)uri defaultImage:(UIImage *)image
{
    [self setUri:uri defaultImage:image showIndicator:self.showIndicator decoded:self.decoded];
}

- (void)setUri:(NSString *)uri defaultImage:(UIImage *)image showIndicator:(BOOL)showIndicator decoded:(BOOL)decoded
{
    self.showIndicator = showIndicator;
    self.decoded = decoded;
    [self setUri:uri defaultImage:image showIndicator:self.showIndicator style:self.style decoded:self.decoded];
}

- (void)setUri:(NSString *)uri defaultImage:(UIImage *)image showIndicator:(BOOL)showIndicator style:(UIActivityIndicatorViewStyle)style decoded:(BOOL)decoded
{
    self.url = uri;
    __weak typeof(self) wSelf = self;
    dispatch_async([self getImageOperatorQueue], ^(){
        UIImage * resultImage = [[CJImageViewCache sharedImageCache]getImageFromCache:uri decoded:decoded];
        if (resultImage != nil) {
            dispatch_async_main_queue(^{
                wSelf.image = resultImage;
            });
        }else{
            //获取缓存失败，请求网络
            [wSelf loadImageData:uri defaultImage:image showIndicator:showIndicator style:style decoded:decoded];
        }
        
    });
}

- (void)loadImageData:(NSString *)uri defaultImage:(UIImage *)image showIndicator:(BOOL)showIndicator style:(UIActivityIndicatorViewStyle)style decoded:(BOOL)decoded
{
    self.style = style;
    self.url = uri;
    //先显示默认图片
    dispatch_async_main_queue(^{
        self.image = image;
    });
    __weak typeof(self) wSelf = self;
    if (showIndicator) {
        if (!_loadingInducator) {
            UIActivityIndicatorView *tempIndicator =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.style];
            self.loadingInducator = tempIndicator;
            
            CGFloat minFloat = MIN(self.frame.size.width, self.frame.size.height);
            CGFloat inducatorMaxFloat = MAX(tempIndicator.frame.size.width, tempIndicator.frame.size.height);
            if (minFloat/inducatorMaxFloat < 2) {
                self.loadingInducator.transform = CGAffineTransformScale(self.loadingInducator.transform, 0.6, 0.6);
            }
        }
        self.loadingInducator.activityIndicatorViewStyle = self.style;
        self.loadingInducator.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        dispatch_async_main_queue(^{
            [self addSubview:self.loadingInducator];
            [self bringSubviewToFront:self.loadingInducator];
            [self.loadingInducator startAnimating];
        });
    }
    
    [CJHttpClient getUrl:uri parameters:nil timeoutInterval:HTTP_DEFAULT_TIMEOUT cachPolicy:CJRequestIgnoringLocalCacheData completionHandler:^(NSData *data, NSURLResponse *response){
        //保存缓存
        [[CJImageViewCache sharedImageCache] saveCache:data uri:uri decoded:decoded];
        dispatch_async([self getImageOperatorQueue], ^(){
            if ([[response.URL absoluteString] isEqualToString:self.url]) {
                UIImage * dataImage = [UIImage imageWithData:data];
                UIImage * resultImage = nil;
                if (decoded && ![CJImageViewCache isPNGImage:data]) {
                    resultImage = [CJImageViewCache decodedImageWithImage:dataImage];
                }
                dispatch_async_main_queue(^{
                    wSelf.image = resultImage != nil?resultImage:(dataImage != nil?dataImage:image);
                    [wSelf.loadingInducator stopAnimating];
                    [wSelf sendSubviewToBack:wSelf.loadingInducator];
                });
            }
        });
    }errorHandler:^(NSError *error){
        dispatch_async_main_queue(^{
            wSelf.image = image;
            [wSelf.loadingInducator stopAnimating];
            [wSelf sendSubviewToBack:wSelf.loadingInducator];
        });
    }];
}

- (dispatch_queue_t )getImageOperatorQueue{
    static dispatch_queue_t  _imageOperatorQueue;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _imageOperatorQueue = dispatch_queue_create([@"CJ.imageOperatorQueue" UTF8String], NULL);
    });
    return _imageOperatorQueue;
}
@end
