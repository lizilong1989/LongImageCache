//
//  LongCache.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/5.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#define kDefaultMaxCacheSize 256 * 256

#define kDefaultMaxCacheDataSize 1024 * 1024 * 128

#import "LongCache.h"

#import "LongNode.h"
#import "NSString+LongMD5.h"

#import <pthread.h>

#define kDefaultLongCachePath @"/Documents/LongCache"

@interface LongCache ()
{
    LongNodeList *_nodeList;
    CFMutableDictionaryRef _dicRef;
    pthread_mutex_t _mutex;
    
    dispatch_queue_t _cacheQueue;
    dispatch_queue_t _cacheQueues[10];
    
    NSString *_diskCachePath;
    NSUInteger _totalSize; //实际cache文件大小
    NSUInteger _maxTotalSize; //cache限制的文件大小
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
        _dicRef = CFDictionaryCreateMutable(0, kDefaultMaxCacheSize, NULL, NULL);
        pthread_mutex_init(&_mutex, NULL);
        _cacheQueue = dispatch_queue_create("com.longcache.queue", DISPATCH_QUEUE_SERIAL);
        
        for (int i = 0; i < 10; i ++) {
            NSString *name = [NSString stringWithFormat:@"com.longcache.queue.%d",i];
            _cacheQueues[i] = dispatch_queue_create([name UTF8String], DISPATCH_QUEUE_SERIAL);
        }
        
        dispatch_set_target_queue(_cacheQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        _diskCachePath = [NSString stringWithFormat:@"%@%@",NSHomeDirectory(),kDefaultLongCachePath];
        _maxTotalSize = kDefaultMaxCacheDataSize;
    }
    return self;
}

- (void)dealloc
{
    CFRelease(_dicRef);
    pthread_mutex_destroy(&_mutex);
#if !OS_OBJECT_USE_OBJC
    dispatch_release(_cacheQueue);
    _cacheQueue = nil;
#endif
}

- (void)setCacheMaxFileSize:(NSInteger)aFileSize
{
    _maxTotalSize = aFileSize;
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
    if (CFDictionaryContainsKey(_dicRef, (__bridge const void *)aKey)) {
    } else {
        BOOL overflow = _totalSize > _maxTotalSize;
        do {
            CFIndex count = [_nodeList count];
            if (count >= kDefaultMaxCacheSize || overflow) {
                [_nodeList removeNodeWithKey:aKey];
                [self _removeDataWithKey:aKey];
            }
            overflow = _totalSize > _maxTotalSize;
        } while(overflow);
        
        _totalSize += aData.length;
        [self _insertNodeWithKey:aKey];
        CFDictionarySetValue(_dicRef, (__bridge const void *)aKey,CFDataCreate(0, aData.bytes, aData.length));
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
    if (CFDictionaryContainsKey(_dicRef, (__bridge const void *)aKey)) {
        obj = (__bridge NSData*)CFDictionaryGetValue(_dicRef, (__bridge const void *)aKey);
    }
    if (!obj) {
        NSString *md5Key = [aKey md5String];
        obj = [self _getCacheFromDiskWithKey:md5Key];
    }
    pthread_mutex_unlock(&_mutex);
    return obj;
}

- (void)clearCacheWithKey:(NSString *)aKey
{
    [self clearCacheWithKey:aKey toDisk:NO];
}

- (void)clearCacheWithKey:(NSString *)aKey toDisk:(BOOL)aToDisk
{
    pthread_mutex_lock(&_mutex);
    if (aToDisk) {
        [self _removeCacheFromDiskWithKey:aKey];
    }
    [self _removeDataWithKey:aKey];
    [_nodeList removeNodeWithKey:aKey];
    pthread_mutex_unlock(&_mutex);
}

- (void)clearAllCache
{
    pthread_mutex_lock(&_mutex);
    [_nodeList removeAllObjects];
    CFDictionaryRemoveAllValues(_dicRef);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_diskCachePath]) {
        [fileManager removeItemAtPath:_diskCachePath error:nil];
    }
    _totalSize = 0;
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

- (NSUInteger)getDiskSize
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

- (void)_removeDataWithKey:(NSString*)aKey
{
    if (aKey == nil || aKey.length == 0) {
        return;
    }
    CFDataRef dataRef = CFDictionaryGetValue(_dicRef, (__bridge const void *)(aKey));
    if (dataRef) {
        _totalSize -= CFDataGetLength(dataRef);
        CFRelease(dataRef);
    }
    CFDictionaryRemoveValue(_dicRef, (__bridge const void *)(aKey));
}

- (void)_saveCacheFromDiskWithData:(NSData *)aData forKey:(NSString*)aKey
{
    if (![aData isKindOfClass:[NSData class]] || ![aKey isKindOfClass:[NSString class]]) {
        return;
    }
    
    if (aData.length == 0 || aKey.length == 0) {
        return;
    }
    
    NSInteger threadCount = [aKey hash] % 10;
    
    dispatch_async(_cacheQueues[threadCount], ^{
        NSString *md5Key = [aKey md5String]; //这是一个较为耗时的操作
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:_diskCachePath]) {
            [fileManager createDirectoryAtPath:_diskCachePath
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:nil];
        }
        [aData writeToFile:[_diskCachePath stringByAppendingString:[self _cacheNameWithKey:md5Key]]
                atomically:NO];
    });
}

- (void)_removeCacheFromDiskWithKey:(NSString*)aKey
{
    if (![aKey isKindOfClass:[NSString class]] || aKey.length == 0) {
        return;
    }
    
    NSInteger threadCount = [aKey hash] % 10;
    
    dispatch_async(_cacheQueues[threadCount], ^{
        NSString *md5Key = [aKey md5String]; //这是一个较为耗时的操作
        NSString *path = [NSString stringWithFormat:@"%@%@",_diskCachePath ,[self _cacheNameWithKey:md5Key]];
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
            BOOL overflow = _totalSize > _maxTotalSize;
            do {
                CFIndex count = [_nodeList count];
                if (count >= kDefaultMaxCacheSize || overflow) {
                    [_nodeList removeNodeWithKey:aKey];
                    [self _removeDataWithKey:aKey];
                }
                overflow = _totalSize > _maxTotalSize;
            } while(overflow);
            
            _totalSize += ret.length;
            [self _insertNodeWithKey:aKey];
            CFDictionarySetValue(_dicRef, (__bridge const void *)(aKey), CFDataCreate(0, ret.bytes, ret.length));
        }
    }
    return ret;
}

- (NSString*)_cacheNameWithKey:(NSString*)aKey
{
    return [NSString stringWithFormat:@"/%@_longcache",aKey];
}

- (void)_insertNodeWithKey:(NSString*)aKey
{
    if (_nodeList == nil) {
        LongNode *node = [[LongNode alloc] init];
        node.key = aKey;
        _nodeList = [[LongNodeList alloc] initWithNode:node];
    } else {
        LongNode *node = [[LongNode alloc] init];
        node.key = aKey;
        [_nodeList insertNode:node];
    }
}

@end
