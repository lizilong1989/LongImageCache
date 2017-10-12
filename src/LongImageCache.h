//
//  LongImageCache.h
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/10/12.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LongImageCache : NSObject

/*!
 *  获取ImageCache实例
 */
+ (instancetype)sharedInstance;

/*!
 *  缓存数据图片
 *
 *  @param aData    缓存数据
 *  @param aKey     缓存key
 *  @param aToDisk  是否保存至硬盘
 *
 */
- (void)setCacheWithData:(NSData *)aData
                     key:(NSString*)aKey
                  toDisk:(BOOL)aToDisk;

/*!
 *  获取缓存数据图片
 *
 *  @param aKey     缓存key
 *
 *  @return 缓存图片
 */
- (UIImage*)getImageFromCacheWithKey:(NSString *)aKey;

/*!
 *  清空缓存图片
 */
- (void)clearImageCache;

@end
