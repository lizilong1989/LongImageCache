//
//  LongCache.m
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/9/5.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#define kDefaultMaxCacheSize 128

#import "LongCache.h"

#import <pthread.h>

#define kDefaultLongCachePath @"/Documents/LongCache"

@interface LongCache ()
{
    CFMutableArrayRef _arrayRef;
    CFMutableDictionaryRef _dicRef;
    pthread_mutex_t _mutex;
    
    dispatch_queue_t _cacheQueue;
}

@end

@implementation LongCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        _arrayRef = CFArrayCreateMutable(0, kDefaultMaxCacheSize, NULL);
        _dicRef = CFDictionaryCreateMutable(0, kDefaultMaxCacheSize, NULL, NULL);
        pthread_mutex_init(&_mutex, NULL);
        _cacheQueue = dispatch_queue_create("com.longcache.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_cacheQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0));
        
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_arrayRef);
    CFRelease(_dicRef);
    pthread_mutex_destroy(&_mutex);
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_cacheQueue);
    _cacheQueue = nil;
#endif
}

#pragma mark - public

- (void)storeCacheWithData:(NSData *)aData
                    forKey:(NSString*)aKey
                    toDisk:(BOOL)aToDisk
{
    if (![aData isKindOfClass:[NSData class]] || ![aKey isKindOfClass:[NSString class]]) {
        return;
    }
    
    if (aData.length == 0 || aKey.length == 0) {
        return;
    }
    
    pthread_mutex_lock(&_mutex);
    id obj = (__bridge id)CFDictionaryGetValue(_dicRef, (__bridge const void *)(aKey));
    if (obj) {
        [self _removeWithKey:aKey];
        CFArrayInsertValueAtIndex(_arrayRef, 0, (__bridge const void *)(aKey));
        CFDictionarySetValue(_dicRef, (__bridge const void *)(aKey), CFDataCreate(nil, aData.bytes, aData.length));
        CFRelease((__bridge CFTypeRef)(obj));
    } else {
        CFIndex count = CFDictionaryGetCount(_dicRef);
        if (count >= kDefaultMaxCacheSize) {
            const void *key = CFArrayGetValueAtIndex(_arrayRef, count - 1);
            CFArrayRemoveValueAtIndex(_arrayRef, count - 1);
            CFDictionaryRemoveValue(_dicRef, key);
        }
        CFArrayInsertValueAtIndex(_arrayRef, 0, (__bridge const void *)(aKey));
        CFDictionarySetValue(_dicRef, (__bridge const void *)(aKey),(__bridge CFTypeRef)aData);
    }
    if (aToDisk) {
        [self _saveCacheFromDiskWithData:aData forKey:aKey];
    }
    pthread_mutex_unlock(&_mutex);
}

- (void)storeCacheWithData:(NSData *)aData
                    forKey:(NSString*)aKey
{
    [self storeCacheWithData:aData
                      forKey:aKey
                      toDisk:NO];
}

- (NSData*)getCacheWithKey:(NSString*)aKey
{
    NSData *obj = nil;
    if (![aKey isKindOfClass:[NSString class]] || aKey.length == 0) {
        return obj;
    }
    pthread_mutex_lock(&_mutex);
    obj = (__bridge NSData*)CFDictionaryGetValue(_dicRef, (__bridge const void *)(aKey));
    if (!obj) {
        obj = [self _getCacheFromDiskWithKey:aKey];
    }
    pthread_mutex_unlock(&_mutex);
    return obj;
}

- (void)clearCacheWithKey:(NSString *)aKey
{
    pthread_mutex_lock(&_mutex);
    [self _removeWithKey:aKey];
    [self _removeCacheFromDiskWithKey:aKey];
    CFDictionaryRemoveValue(_dicRef, (__bridge const void *)(aKey));
    pthread_mutex_unlock(&_mutex);
}

- (void)clearAllCache
{
    pthread_mutex_lock(&_mutex);
    CFArrayRemoveAllValues(_arrayRef);
    CFDictionaryRemoveAllValues(_dicRef);
    NSString *path = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),kDefaultLongCachePath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    pthread_mutex_unlock(&_mutex);
}

#pragma mark - private

- (void)_removeWithKey:(NSString*)aKey
{
    CFIndex count = CFArrayGetCount(_arrayRef);
    CFIndex index = CFArrayGetCountOfValue(_arrayRef, CFRangeMake(0, count - 1), (__bridge const void *)(aKey));
    CFArrayRemoveValueAtIndex(_arrayRef, index);
}

- (void)_saveCacheFromDiskWithData:(NSData *)aData forKey:(NSString*)aKey
{
    if (![aData isKindOfClass:[NSData class]] || ![aKey isKindOfClass:[NSString class]]) {
        return;
    }
    
    if (aData.length == 0 || aKey.length == 0) {
        return;
    }
    
    dispatch_async(_cacheQueue, ^{
        @autoreleasepool {
            NSString *path = NSHomeDirectory();
            path = [path stringByAppendingString:kDefaultLongCachePath];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if (![fileManager fileExistsAtPath:path]) {
                [fileManager createDirectoryAtPath:path
                       withIntermediateDirectories:YES
                                        attributes:nil
                                             error:nil];
            }
            [aData writeToFile:[path stringByAppendingString:[self _cacheNameWithKey:aKey]]
                    atomically:NO];
        }
    });
}

- (void)_removeCacheFromDiskWithKey:(NSString*)aKey
{
    if (![aKey isKindOfClass:[NSString class]] || aKey.length == 0) {
        return;
    }
    
    dispatch_async(_cacheQueue, ^{
        NSString *path = [NSString stringWithFormat:@"%@%@%@",NSHomeDirectory(),kDefaultLongCachePath,[self _cacheNameWithKey:aKey]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            [fileManager removeItemAtPath:path error:nil];
        }
    });
}

- (NSData*)_getCacheFromDiskWithKey:(NSString*)aKey
{
    NSData *ret = nil;
    if (![aKey isKindOfClass:[NSString class]] || aKey.length == 0) {
        return ret;
    }

    NSString *path = [NSString stringWithFormat:@"%@%@%@",NSHomeDirectory(), kDefaultLongCachePath,[self _cacheNameWithKey:aKey]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        ret = [NSData dataWithContentsOfFile:path];
        if (ret) {
            CFIndex count = CFDictionaryGetCount(_dicRef);
            if (count >= kDefaultMaxCacheSize) {
                const void *key = CFArrayGetValueAtIndex(_arrayRef, count - 1);
                CFArrayRemoveValueAtIndex(_arrayRef, count - 1);
                CFDictionaryRemoveValue(_dicRef, key);
            }
            CFArrayInsertValueAtIndex(_arrayRef, 0, (__bridge const void *)(aKey));
            CFDictionaryAddValue(_dicRef, (__bridge const void *)(aKey), (__bridge CFTypeRef)ret);
        }
    }
    return ret;
}

- (NSString*)_cacheNameWithKey:(NSString*)aKey
{
    return [NSString stringWithFormat:@"/%@_longcache",aKey];
}

@end
