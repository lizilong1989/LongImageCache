//
//  LongImageCache.m
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/10/12.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "LongImageCache.h"

#import "LongCache.h"
#import "NSString+LongMD5.h"
#import "UIImage+LongGif.h"

#import <pthread.h>

#define kLongDefaultSize 32

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
        UIImage *image = [UIImage imageWithData:aData];
        [self _setImage:image key:aKey];
        
        [[LongCache sharedInstance] storeCacheWithData:aData
                                                forKey:aKey
                                                toDisk:aToDisk];
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
            image = [UIImage imageWithData:cacheData];
            [self _setImage:image key:aKey];
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

@end
