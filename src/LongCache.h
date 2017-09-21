//
//  LongCache.h
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/9/5.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LongCache : NSObject

/*!
 *  获取Cache实例
 */
+ (instancetype)sharedInstance;

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
- (NSUInteger)getSize;

@end
