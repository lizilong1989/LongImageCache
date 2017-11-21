//
//  UIImageView+LongCache.h
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/22.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (LongCache)

/*!
 *  设置图片url地址
 *
 *  @param aUrl     图片地址
 *
 */
- (void)setImageWithUrl:(NSString*)aUrl;

/*!
 *  设置图片url地址
 *
 *  @param aUrl     图片地址
 *  @param aImage   填充图片
 *
 */
- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage;

/*!
 *  设置图片url地址
 *
 *  @param aUrl     图片地址
 *  @param aImage   填充图片
 *  @param aToDisk  是否保存至硬盘
 *
 */
- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk;

/*!
 *  设置图片url地址
 *
 *  @param aUrl                 图片地址
 *  @param aImage               填充图片
 *  @param aToDisk              是否保存至硬盘
 *  @param aShowActivityView    是否显示加载视图
 *
 */
- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk
       showActivityView:(BOOL)aShowActivityView;

/*!
 *  设置图片url地址
 *
 *  @param aUrl                 图片地址
 *  @param aImage               填充图片
 *  @param aToDisk              是否保存至硬盘
 *  @param aShowActivityView    是否显示加载视图
 *  @param aProgressBlock       图片下载进度回调
 *
 */
- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk
       showActivityView:(BOOL)aShowActivityView
               progress:(void (^)(int progress))aProgressBlock;

/*!
 *  设置图片url地址
 *
 *  @param aUrl                 图片地址
 *  @param aImage               填充图片
 *  @param aToDisk              是否保存至硬盘
 *  @param aShowActivityView    是否显示加载视图
 *  @param aProgressBlock       图片下载进度回调
 *  @param aCompletionBlock     图片下载完成回调
 *
 */
- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk
       showActivityView:(BOOL)aShowActivityView
               progress:(void (^)(int progress))aProgressBlock
             completion:(void (^)(UIImage *aImage, NSError *aError))aCompletionBlock;

/*!
 *  设置图片根据名称
 *
 *  @param aName                图片名称
 *
 */
- (void)setImageWithName:(NSString*)aName;

/*!
 *  设置一组图片根据名称
 *
 *  @param aNames               图片名称数组
 *
 */
- (void)setImagesWithNames:(NSArray *)aNames;

@end
