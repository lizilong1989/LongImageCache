//
//  UIImageView+LongCache.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/22.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "UIImageView+LongCache.h"

#import <objc/runtime.h>

#import "LongImageCache.h"
#import "LongCacheDownloadTask.h"
#import "UIImage+LongGif.h"

static const void *LongCacheKey = &LongCacheKey;
static const void *LongCacheLoadingKey = &LongCacheLoadingKey;

@implementation UIImageView (LongCache)

- (void)setImageWithUrl:(NSString*)aUrl
{
    [self setImageWithUrl:aUrl placeholderImage:nil];
}

- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
{
    [self setImageWithUrl:aUrl placeholderImage:aImage toDisk:NO];
}

- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk
{
    [self setImageWithImage:aImage data:nil];
    [[LongCacheDownloadTask sharedInstance] cancelDownloadTaskWithUrl:aUrl];
    
    UIImage *image = [[LongImageCache sharedInstance] getImageFromCacheWithKey:aUrl];
    if (image) {
        [self setImageWithImage:image data:nil];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __block NSString *_blockUrl = aUrl;
    [[LongCacheDownloadTask sharedInstance] downloadWithUrl:aUrl
                                                 completion:^(NSData *aData, NSError *aError) {
                                                     if (!aError) {
                                                         [weakSelf setImageWithImage:nil data:aData];
                                                         [[LongImageCache sharedInstance] setCacheWithData:aData key:_blockUrl toDisk:aToDisk];
                                                     }
                                                 }];
}

- (void)setImageWithImage:(UIImage*)image data:(NSData*)aData
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        if (image) {
            weakSelf.image = image;
        }
        
        if (aData) {
            weakSelf.image = [UIImage imageWithData:aData];
        }
        
        [weakSelf setNeedsLayout];
    };
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
