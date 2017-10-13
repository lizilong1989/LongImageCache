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

static LongImageCache *instance = nil;

@interface LongImageCache()
{
    NSMutableDictionary *_imageDic;
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
    }
    return self;
}

- (void)setCacheWithData:(NSData *)aData
                     key:(NSString*)aKey
                  toDisk:(BOOL)aToDisk
{
    if (aKey.length > 0 && aData.length > 0) {
        UIImage *image = [UIImage imageWithData:aData];
        [_imageDic setObject:image forKey:[aKey md5String]];
        
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
    UIImage *image = [_imageDic objectForKey:[aKey md5String]];
    if (image == nil) {
        NSData *cacheData = [[LongCache sharedInstance] getCacheWithKey:aKey];
        if (cacheData) {
            image = [UIImage imageWithData:cacheData];
            [_imageDic setObject:image forKey:[aKey md5String]];
        }
    }
    return image;
}

- (void)clearImageCache
{
    [_imageDic removeAllObjects];
}

@end
