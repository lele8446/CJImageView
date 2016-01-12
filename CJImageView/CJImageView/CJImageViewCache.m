//
//  CJImageViewCache.m
//  CJImageView
//
//  Created by C.K.Lian on 16/1/11.
//  Copyright © 2016年 C.K.Lian. All rights reserved.
//

#import "CJImageViewCache.h"
#import <CommonCrypto/CommonDigest.h>

// PNG signature bytes and data (below)
static unsigned char kPNGSignatureBytes[8] = {0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A};
static NSData *kPNGSignatureData = nil;

BOOL ImageDataHasPNGPreffix(NSData *data);

BOOL ImageDataHasPNGPreffix(NSData *data) {
    NSUInteger pngSignatureLength = [kPNGSignatureData length];
    if ([data length] >= pngSignatureLength) {
        if ([[data subdataWithRange:NSMakeRange(0, pngSignatureLength)] isEqualToData:kPNGSignatureData]) {
            return YES;
        }
    }
    
    return NO;
}

@interface CJImageViewCache ()
@property (strong, nonatomic) NSCache *memCache;//默认是线程安全的
@property (strong, nonatomic) NSString *diskCachePath;
@property (strong, nonatomic) dispatch_queue_t ioQueue;
@end

@implementation CJImageViewCache
{
    NSFileManager *_fileManager;
}

+ (CJImageViewCache *)sharedImageCache
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [[CJImageViewCache alloc] init];
        kPNGSignatureData = [NSData dataWithBytes:kPNGSignatureBytes length:8];
    });
    return instance;
}

- (id)init
{
    return [self initWithNameSpace:@"CJImageViewCache"];
}

- (id)initWithNameSpace:(NSString *)ns
{
    if ((self = [super init])) {
        NSString *fullNamespace = ns;
        
        // Init the memory cache
        _memCache = [[NSCache alloc] init];
        _memCache.totalCostLimit = 1024*1024*10;//设置10兆的内存缓存作为二级缓存，先读内存，内存没有再读文件
        _memCache.name = fullNamespace;
        
        _ioQueue = dispatch_queue_create("CJ.CJImageViewCache", DISPATCH_QUEUE_SERIAL);
        
        // Init the disk cache
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        _diskCachePath = [paths[0] stringByAppendingPathComponent:fullNamespace];
        
        dispatch_sync(_ioQueue, ^{
            _fileManager = [NSFileManager defaultManager];
        });
        
        // Subscribe to app events
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)clearMemory
{
    [self.memCache removeAllObjects];
}

- (void)clearAllCache
{
    BOOL exists = [_fileManager fileExistsAtPath:_diskCachePath];
    if (exists) {
        [_fileManager removeItemAtPath:_diskCachePath error:nil];
    }
    [self clearMemory];
}

//清除指定缓存
- (void)clearWithUri:(NSString *)uri
{
    __weak typeof (self) wSelf = self;
    dispatch_async(self.ioQueue, ^{
        //清除文件缓存
        [wSelf clearDiskWithUri:uri];
        //清除内存缓存
        [wSelf clearMemoryWithUri:uri];
    });
}

- (void)clearDiskWithUri:(NSString *)uri
{
    BOOL exists = [_fileManager fileExistsAtPath:[self cachePath:uri]];
    if (exists) {
        @synchronized(_fileManager) {
            [_fileManager removeItemAtPath:[self cachePath:uri] error:nil];
            NSString *upperPath = [[self cachePath:uri] stringByDeletingLastPathComponent];
            if ([[_fileManager contentsOfDirectoryAtPath:upperPath error:nil] count] == 0) {
                [_fileManager removeItemAtPath:upperPath error:nil];
            }
        }
    }
}

- (void)clearMemoryWithUri:(NSString *)uri
{
    [[CJImageViewCache sharedImageCache].memCache removeObjectForKey:uri];//清除对应的内存缓存，如果有的话
}

- (NSString *)cachePath:(NSString *)relaPath
{
    // nil 安全判断
    if (relaPath != nil && relaPath.length > 0) {
        const char *str = [relaPath UTF8String];
        if (str == NULL) {
            str = "";
        }
        unsigned char r[16];
        CC_MD5(str, (CC_LONG)strlen(str), r);
        NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                              r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
        return [_diskCachePath stringByAppendingPathComponent:filename];
    }
    return nil;
}

- (void)saveCache:(NSData *)data uri:(NSString *)uri decoded:(BOOL)decoded
{
    __weak typeof (self) wSelf = self;
    dispatch_async(self.ioQueue, ^{
        [wSelf saveMemoryCache:data uri:uri decoded:decoded];
        [wSelf saveDiskCache:data uri:uri];
    });
}

//将数据写入内存缓存
- (void)saveMemoryCache:(NSData *)data uri:(NSString *)uri decoded:(BOOL)decoded
{
    if (data==nil ||uri==nil){
        return;
    }
    if (data.length >1024*1024*1){//大于一兆的数据就不要放进内存缓存了,不然内存紧张会崩溃)
        return;
    }
    
    //对于jpg,png图片，将data转为UIImage再存到内存缓存，不用每次获时再执行imageWithData这个非常耗时的操作。
    if (data!=nil){
        @try {
            UIImage *image=[UIImage imageWithData:data];
            //png图片不执行decoded
            if (decoded && ![CJImageViewCache isPNGImage:data]) {
                image = [CJImageViewCache decodedImageWithImage:image];
            }if (nil == image) {
                image=[UIImage imageWithData:data];
            }
            NSInteger dataSize= image.size.width * image.size.height * image.scale;
            [_memCache setObject:image forKey:uri cost:dataSize];
        }
        @catch (NSException *exception) {
            NSLog(@"exception=%@",exception);
        }
    }
}

//将数据写入硬盘缓存
- (void)saveDiskCache:(NSData *)imageData uri:(NSString *)uri
{
    UIImage *image = [UIImage imageWithData:imageData];
    NSData *data = imageData;
    // We need to determine if the image is a PNG or a JPEG
    // PNGs are easier to detect because they have a unique signature (http://www.w3.org/TR/PNG-Structure.html)
    // The first eight bytes of a PNG file always contain the following (decimal) values:
    // 137 80 78 71 13 10 26 10
    
    // We assume the image is PNG, in case the imageData is nil (i.e. if trying to save a UIImage directly),
    // we will consider it PNG to avoid loosing the transparency
    int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    BOOL imageIsPng = hasAlpha;
    
    // But if we have an image data, we will look at the preffix
    if ([imageData length] >= [kPNGSignatureData length]) {
        imageIsPng = ImageDataHasPNGPreffix(imageData);
    }
    
    if (imageIsPng) {
        data = UIImagePNGRepresentation(image);
    }
    else {
        data = UIImageJPEGRepresentation(image, (CGFloat)1.0);
    }
    
    if (data) {
        @synchronized(_fileManager) {
            if (![_fileManager fileExistsAtPath:_diskCachePath]) {
                [_fileManager createDirectoryAtPath:_diskCachePath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            if ([_fileManager fileExistsAtPath:[self cachePath:uri]]) {
                [_fileManager removeItemAtPath:[self cachePath:uri] error:nil];
            }
            [_fileManager createFileAtPath:[self cachePath:uri] contents:data attributes:nil];
            //                NSLog(@"_diskCachePath = %@",_diskCachePath);
        }
    }
}

- (UIImage *)getImageFromCache:(NSString *)uri decoded:(BOOL)decoded
{
    UIImage *image = nil;
    image = [self getImageFromMemoryCache:uri];
    if (image) {
        return image;
    }else{
        image = [self getImageFromDiskCache:uri decoded:decoded];
    }
    return image;
}

- (UIImage *)getImageFromMemoryCache:(NSString *)uri
{
    UIImage *result = nil;
    result = [_memCache objectForKey:uri];
    return result;
}

- (UIImage *)getImageFromDiskCache:(NSString *)uri decoded:(BOOL)decoded
{
    UIImage *image = nil;
    NSData *data = [NSData dataWithContentsOfFile:[self cachePath:uri]];
    if (data) {
        image = [UIImage imageWithData:data];
        //png图片不执行decoded
        if (decoded && ![CJImageViewCache isPNGImage:data]) {
            image = [CJImageViewCache decodedImageWithImage:image];
        }
        if (image) {
            CGFloat cost = image.size.height * image.size.width * image.scale;
            [self.memCache setObject:image forKey:uri cost:cost];
        }
    }
    return image;
}

- (double)getCacheCapacity
{
    __block double size = 0.00;
    __weak typeof(self) wSelf = self;
    dispatch_sync(self.ioQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [_fileManager enumeratorAtPath:wSelf.diskCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [wSelf.diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    double Msize = 1024.0*1024.0;
    size = size/Msize;
//    return ceil(size*100) / 100;
    return (double)(round(size*100)/100.0);
}

+ (BOOL)isPNGImage:(NSData *)imageData
{
    UIImage *image = [UIImage imageWithData:imageData];
    // We need to determine if the image is a PNG or a JPEG
    // PNGs are easier to detect because they have a unique signature (http://www.w3.org/TR/PNG-Structure.html)
    // The first eight bytes of a PNG file always contain the following (decimal) values:
    // 137 80 78 71 13 10 26 10
    
    // We assume the image is PNG, in case the imageData is nil (i.e. if trying to save a UIImage directly),
    // we will consider it PNG to avoid loosing the transparency
    int alphaInfo = CGImageGetAlphaInfo(image.CGImage);
    BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                      alphaInfo == kCGImageAlphaNoneSkipFirst ||
                      alphaInfo == kCGImageAlphaNoneSkipLast);
    BOOL imageIsPng = hasAlpha;
    
    // But if we have an image data, we will look at the preffix
    if ([imageData length] >= [kPNGSignatureData length]) {
        imageIsPng = ImageDataHasPNGPreffix(imageData);
    }
    return imageIsPng;
}

+ (UIImage *)decodedImageWithImage:(UIImage *)image
{
    if (image.images) {
        // Do not decode animated images
        return image;
    }
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3) {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    // If failed, return undecompressed image
    if (!context) return image;
    
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;

}
    
@end
