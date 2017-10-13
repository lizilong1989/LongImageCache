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
static const void *LongCacheindicatorViewKey = &LongCacheindicatorViewKey;

@implementation UIImageView (LongCache)

- (UIActivityIndicatorView *)getIndicatorView
{
    UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, LongCacheindicatorViewKey);
    if (indicatorView == nil) {
        indicatorView = [[UIActivityIndicatorView alloc] init];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        objc_setAssociatedObject(self, LongCacheindicatorViewKey, indicatorView, OBJC_ASSOCIATION_RETAIN);
    }
    return indicatorView;
}

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
    [self setImageWithUrl:aUrl placeholderImage:aImage toDisk:aToDisk showActivityView:NO];
}

- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk
       showActivityView:(BOOL)aShowActivityView
{
    [self setImageWithUrl:aUrl placeholderImage:aImage toDisk:aToDisk showActivityView:aShowActivityView progress:NULL];
}

- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk
       showActivityView:(BOOL)aShowActivityView
               progress:(void (^)(int progress))aProgressBlock
{
    [self setImageWithUrl:aUrl placeholderImage:aImage toDisk:aToDisk showActivityView:aShowActivityView progress:aProgressBlock completion:NULL];
}

- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk
       showActivityView:(BOOL)aShowActivityView
               progress:(void (^)(int progress))aProgressBlock
             completion:(void (^)(UIImage *aImage, NSError *aError))aCompletionBlock
{
    UIImage *image = [[LongImageCache sharedInstance] getImageFromCacheWithKey:aUrl];
    if (image) {
        [self _setImageWithImage:image data:nil];
        return;
    } else {
        [self _setImageWithImage:aImage data:nil];
    }
    
    [[LongCacheDownloadTask sharedInstance] cancelDownloadTaskWithUrl:aUrl];
    
    if (aShowActivityView) {
        [self _showActivityIndicatorView];
    }
    
    __weak typeof(self) weakSelf = self;
    __block NSString *_blockUrl = aUrl;
    [[LongCacheDownloadTask sharedInstance] downloadWithUrl:aUrl
                                                   progress:^(int progress) {
                                                       if (aProgressBlock) {
                                                           aProgressBlock(progress);
                                                       }
                                                   }
                                                 completion:^(NSData *aData, NSError *aError) {
                                                     if (aCompletionBlock) {
                                                         UIImage *image = [UIImage imageWithData:aData];
                                                         if (!aError) {
                                                             [[LongImageCache sharedInstance] setCacheWithData:aData key:_blockUrl toDisk:aToDisk];
                                                         }
                                                         aCompletionBlock(image, aError);
                                                     } else {
                                                         if (!aError) {
                                                             [weakSelf _setImageWithImage:nil data:aData];
                                                             [[LongImageCache sharedInstance] setCacheWithData:aData key:_blockUrl toDisk:aToDisk];
                                                         }
                                                     }
                                                     if (aShowActivityView) {
                                                         [weakSelf _hideActivityIndicatorView];
                                                     }
                                                 }];
}

- (void)_setImageWithImage:(UIImage*)image data:(NSData*)aData
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
    [self _executeOnMainThread:block];
}

- (void)_showActivityIndicatorView
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        UIActivityIndicatorView *indicatorView = [weakSelf getIndicatorView];
        indicatorView.translatesAutoresizingMaskIntoConstraints = NO;
        [weakSelf addSubview:indicatorView];
        
        [weakSelf addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView
                                                         attribute:NSLayoutAttributeCenterX
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:weakSelf
                                                         attribute:NSLayoutAttributeCenterX
                                                        multiplier:1.0
                                                          constant:0.0]];
        
        [weakSelf addConstraint:[NSLayoutConstraint constraintWithItem:indicatorView
                                                         attribute:NSLayoutAttributeCenterY
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:weakSelf
                                                         attribute:NSLayoutAttributeCenterY
                                                        multiplier:1.0
                                                          constant:0.0]];
        [indicatorView startAnimating];
    };
    [self _executeOnMainThread:block];
}

- (void)_hideActivityIndicatorView
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        UIActivityIndicatorView *indicatorView = [weakSelf getIndicatorView];
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
    };
    [self _executeOnMainThread:block];
}

- (void)_executeOnMainThread:(dispatch_block_t)block
{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

@end
