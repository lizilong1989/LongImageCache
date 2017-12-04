//
//  LongCache.h
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/5.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LongCache : NSObject

/*!
 *  获取Cache实例
 */
+ (instancetype)sharedInstance;

/*!
 *  设置缓存容量
 *
 *  @param aFileSize    缓存容量（单位KB）
 */
- (void)setCacheMaxFileSize:(NSInteger)aFileSize;

/*!
 *  缓存数据
 *
 *  @param aData    缓存数据
 *  @param aKey     缓存key
 *  @param aToDisk  是否保存至硬盘
 *
 */
- (void)storeCacheWithData:(NSData *)aData
                    forKey:(NSString*)aKey
                    toDisk:(BOOL)aToDisk;

/*!
 *  缓存数据
 *
 *  @param aData    缓存数据
 *  @param aKey     缓存key
 *
 */
- (void)storeCacheWithData:(NSData *)aData
                    forKey:(NSString*)aKey;

/*!
 *  获取缓存数据
 *
 *  @param aKey     缓存key
 *
 *  @result 缓存数据
 */
- (NSData *)getCacheWithKey:(NSString*)aKey;

/*!
 *  根据key清除缓存数据
 *
 *  @param aKey     缓存key
 */
- (void)clearCacheWithKey:(NSString*)aKey;

/*!
 *  根据key清除缓存数据
 *
 *  @param aKey     缓存key
 *  @param aToDisk  是否清除硬盘中的数据
 */
- (void)clearCacheWithKey:(NSString *)aKey
                   toDisk:(BOOL)aToDisk;

/*!
 *  清除所有缓存数据
 */
- (void)clearAllCache;

/*!
 *  获取缓存数据数
 *
 *  @result 缓存数据数
 */
- (NSUInteger)getDiskCount;

/*!
 *  获取缓存数据大小
 *
 *  @result 缓存数据大小
 */
- (NSUInteger)getDiskSize;

@end
