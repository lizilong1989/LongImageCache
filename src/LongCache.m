//
//  LongCache.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/5.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#define kDefaultMaxCacheSize 256

#import "LongCache.h"

#import "NSString+LongMD5.h"

#import <pthread.h>

#define kDefaultLongCachePath @"/Documents/LongCache"

@interface LongCache ()
{
    CFMutableArrayRef _arrayRef;
    CFMutableDictionaryRef _dicRef;
    pthread_mutex_t _mutex;
    
    dispatch_queue_t _cacheQueue;
    
    NSString *_diskCachePath;
}

@end

static LongCache *instance = nil;

@implementation LongCache

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LongCache alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _arrayRef = CFArrayCreateMutable(0, kDefaultMaxCacheSize, NULL);
        _dicRef = CFDictionaryCreateMutable(0, kDefaultMaxCacheSize, NULL, NULL);
        pthread_mutex_init(&_mutex, NULL);
        _cacheQueue = dispatch_queue_create("com.longcache.queue", DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(_cacheQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        _diskCachePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),kDefaultLongCachePath];
        
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
    
    NSString *md5Key = [aKey md5String];
    
    if (CFDictionaryContainsKey(_dicRef, (__bridge const void *)(md5Key))) {
        [self _removeWithKey:md5Key];
        CFArrayInsertValueAtIndex(_arrayRef, 0, (__bridge const void *)(md5Key));
        CFDictionarySetValue(_dicRef, (__bridge const void *)(md5Key), CFDataCreate(0, aData.bytes, aData.length));
    } else {
        CFIndex count = CFDictionaryGetCount(_dicRef);
        if (count >= kDefaultMaxCacheSize) {
            const void *key = CFArrayGetValueAtIndex(_arrayRef, count - 1);
            CFArrayRemoveValueAtIndex(_arrayRef, count - 1);
            CFDictionaryRemoveValue(_dicRef, key);
        }
        CFArrayInsertValueAtIndex(_arrayRef, 0, (__bridge const void *)(md5Key));
        CFDictionarySetValue(_dicRef, (__bridge const void *)(md5Key),CFDataCreate(0, aData.bytes, aData.length));
    }
    if (aToDisk) {
        [self _saveCacheFromDiskWithData:aData forKey:md5Key];
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
    
    NSString *md5Key = [aKey md5String];
    
    if (CFDictionaryContainsKey(_dicRef, (__bridge const void *)(md5Key))) {
        obj = (__bridge NSData*)CFDictionaryGetValue(_dicRef, (__bridge const void *)(md5Key));
    }
    if (!obj) {
        obj = [self _getCacheFromDiskWithKey:md5Key];
    }
    pthread_mutex_unlock(&_mutex);
    return obj;
}

- (void)clearCacheWithKey:(NSString *)aKey
{
    pthread_mutex_lock(&_mutex);
    NSString *md5Key = [aKey md5String];
    [self _removeWithKey:md5Key];
    [self _removeCacheFromDiskWithKey:md5Key];
    CFDictionaryRemoveValue(_dicRef, (__bridge const void *)(md5Key));
    pthread_mutex_unlock(&_mutex);
}

- (void)clearAllCache
{
    pthread_mutex_lock(&_mutex);
    CFArrayRemoveAllValues(_arrayRef);
    CFDictionaryRemoveAllValues(_dicRef);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_diskCachePath]) {
        [fileManager removeItemAtPath:_diskCachePath error:nil];
    }
    pthread_mutex_unlock(&_mutex);
}

- (NSUInteger)getDiskCount
{
    __block NSUInteger count = 0;
    dispatch_sync(_cacheQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:_diskCachePath];
        count = fileEnumerator.allObjects.count;
    });
    return count;
}

- (NSUInteger)getSize
{
    __block NSUInteger size = 0;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    dispatch_sync(_cacheQueue, ^{
        NSDirectoryEnumerator *fileEnumerator = [fileManager enumeratorAtPath:_diskCachePath];
        for (NSString *fileName in fileEnumerator) {
            NSString *filePath = [_diskCachePath stringByAppendingPathComponent:fileName];
            NSDictionary<NSString *, id> *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
            size += [attrs fileSize];
        }
    });
    return size;
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
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:_diskCachePath]) {
            [fileManager createDirectoryAtPath:_diskCachePath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        [aData writeToFile:[_diskCachePath stringByAppendingString:[self _cacheNameWithKey:aKey]]
                atomically:NO];
    });
}

- (void)_removeCacheFromDiskWithKey:(NSString*)aKey
{
    if (![aKey isKindOfClass:[NSString class]] || aKey.length == 0) {
        return;
    }
    
    dispatch_async(_cacheQueue, ^{
        NSString *path = [NSString stringWithFormat:@"%@%@",_diskCachePath ,[self _cacheNameWithKey:aKey]];
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

    NSString *path = [NSString stringWithFormat:@"%@%@",_diskCachePath ,[self _cacheNameWithKey:aKey]];
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
            CFDictionaryAddValue(_dicRef, (__bridge const void *)(aKey), CFDataCreate(0, ret.bytes, ret.length));
        }
    }
    return ret;
}

- (NSString*)_cacheNameWithKey:(NSString*)aKey
{
    return [NSString stringWithFormat:@"/%@_longcache",aKey];
}

@end
