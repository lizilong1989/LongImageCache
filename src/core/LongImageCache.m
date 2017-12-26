//
//  LongImageCache.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/10/12.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "LongImageCache.h"

#import "LongCache.h"
#import "NSString+LongMD5.h"
#import "LongGifImage.h"
#import "LongWebPImage.h"

#import <pthread.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

#define kLongDefaultSize 256

static LongImageCache *instance = nil;

@interface LongImageCache()
{
    NSMutableDictionary *_imageDic;
    NSMutableArray *_imageArray;
    
    pthread_mutex_t _mutex;
}

@end

@implementation LongImageCache

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LongImageCache alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageDic = [NSMutableDictionary dictionary];
        _imageArray = [NSMutableArray array];
        pthread_mutex_init(&_mutex, NULL);
    }
    return self;
}

- (void)setCacheWithData:(NSData *)aData
                     key:(NSString*)aKey
                  toDisk:(BOOL)aToDisk
{
    if (aKey.length > 0 && aData.length > 0) {
        UIImage *image = nil;
        
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(aData), NULL);
        NSString *imageContentType = [LongImageCache contentTypeForImageData:aData];
        if ([imageContentType isEqualToString:@"image/gif"] || [LongImageCache CGImageSourceContainsAnimatedGif:imageSource]) {
            image = [[LongGifImage alloc] initWithCGImageSource:imageSource scale:1.0f];
        }
#ifdef LONG_WEBP
        else if ([imageContentType isEqualToString:@"image/webp"]) {
            image = [[LongWebPImage alloc] initWithData:aData];
        }
#endif
        else {
            image = [UIImage imageWithData:aData];
        }
        [self _setImage:image key:aKey];
        
        [[LongCache sharedInstance] storeCacheWithData:aData
                                                forKey:aKey
                                                toDisk:aToDisk];
        
        if (imageSource) {
            CFRelease(imageSource);
        }
    }
}

- (UIImage*)getImageFromCacheWithKey:(NSString *)aKey
{
    if (aKey.length == 0) {
        return nil;
    }
    UIImage *image = [self _getImageWithKey:aKey];
    if (image == nil) {
        NSData *cacheData = [[LongCache sharedInstance] getCacheWithKey:aKey];
        if (cacheData) {
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(cacheData), NULL);
            NSString *imageContentType = [LongImageCache contentTypeForImageData:cacheData];
            if ([imageContentType isEqualToString:@"image/gif"] || [LongImageCache CGImageSourceContainsAnimatedGif:imageSource]) {
                image = [[LongGifImage alloc] initWithCGImageSource:imageSource scale:1.0f];
            }
#ifdef LONG_WEBP
            else if ([imageContentType isEqualToString:@"image/webp"]) {
                image = [[LongWebPImage alloc] initWithData:cacheData];
            }
#endif
            else {
                image = [UIImage imageWithData:cacheData];
            }
            [self _setImage:image key:aKey];
            
            if (imageSource) {
                CFRelease(imageSource);
            }
        }
    }
    return image;
}

- (void)clearImageCache
{
    [_imageDic removeAllObjects];
}

#pragma mark - private
- (void)_setImage:(UIImage*)aImage key:(NSString*)aKey
{
    if (aImage == nil || aKey.length == 0) {
        return;
    }
    pthread_mutex_lock(&_mutex);
    if ([_imageArray count] > kLongDefaultSize) {
        NSString *key = [_imageArray lastObject];
        [_imageDic removeObjectForKey:key];
        [_imageArray removeLastObject];

        [_imageDic setObject:aImage forKey:[aKey md5String]];
        [_imageArray insertObject:[aKey md5String] atIndex:0];
    } else {
        if ([_imageDic objectForKey:[aKey md5String]]) {
            [_imageArray removeObject:[aKey md5String]];
        }

        [_imageDic setObject:aImage forKey:[aKey md5String]];
        [_imageArray insertObject:[aKey md5String] atIndex:0];
    }
    pthread_mutex_unlock(&_mutex);
}

- (UIImage*)_getImageWithKey:(NSString*)aKey
{
    pthread_mutex_lock(&_mutex);
    UIImage *image = [_imageDic objectForKey:[aKey md5String]];
    pthread_mutex_unlock(&_mutex);
    return image;
}

+ (BOOL)isGif:(NSData *)aData
{
    BOOL ret = NO;
    if (aData.length > 0 ) {
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(aData), NULL);
        NSString *imageContentType = [LongImageCache contentTypeForImageData:aData];
        ret = [imageContentType isEqualToString:@"image/gif"] || [LongImageCache CGImageSourceContainsAnimatedGif:imageSource];
        CFRelease(imageSource);
    }
    return ret;
}

+ (BOOL)isWebP:(NSData*)aData
{
    BOOL ret = NO;
    if (aData.length > 0 ) {
        NSString *imageContentType = [LongImageCache contentTypeForImageData:aData];
        ret = [imageContentType isEqualToString:@"image/webp"];
    }
    return ret;
}

+ (BOOL)CGImageSourceContainsAnimatedGif:(CGImageSourceRef)imageSource
{
    return imageSource && UTTypeConformsTo(CGImageSourceGetType(imageSource), kUTTypeGIF) && CGImageSourceGetCount(imageSource) > 1;
}

+ (NSString *)contentTypeForImageData:(NSData *)data {
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return nil;
            }
            
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return @"image/webp";
            }
            
            return nil;
    }
    return nil;
}

@end
