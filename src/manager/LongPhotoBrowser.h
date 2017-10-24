//
//  LongPhotoBrowser.h
//  Pods
//
//  Created by zilong.li on 2017/10/24.
//

#import <Foundation/Foundation.h>

@interface LongPhotoBrowser : NSObject

/*!
 *  获取PhotoBrowser实例
 */
+ (instancetype)sharedInstance;

/*!
 *  浏览图片
 *
 *  @param aImages    图片数据
 *
 */
- (void)showWithImages:(NSArray*)aImages;

/*!
 *  浏览图片
 *
 *  @param aImages    图片数据
 *  @param aIndex     索引
 *
 */
- (void)showWithImages:(NSArray*)aImages
             withIndex:(NSInteger)aIndex;

/*!
 *  浏览图片
 *
 *  @param aUrls        地址数据
 *
 */
- (void)showWithUrls:(NSArray*)aUrls;

/*!
 *  浏览图片
 *
 *  @param aUrls        地址数据
 *  @param aIndex       索引
 *
 */
- (void)showWithUrls:(NSArray*)aUrls
           withIndex:(NSInteger)aIndex;

@end
