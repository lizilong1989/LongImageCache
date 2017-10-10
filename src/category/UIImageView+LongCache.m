//
//  UIImageView+LongCache.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/22.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "UIImageView+LongCache.h"

#import <objc/runtime.h>

#import "LongCache.h"
#import "LongCacheDownloadTask.h"

static const void *LongCacheKey = &LongCacheKey;
static const void *LongCacheLoadingKey = &LongCacheLoadingKey;

@interface UIImageView (LongCache)

@property (nonatomic, copy) NSString *lastUrl;

@property (nonatomic, assign, getter=isLoading) BOOL loading;

@end

@implementation UIImageView (LongCache)

@dynamic lastUrl;
@dynamic loading;

- (void)setLastUrl:(NSString*)lastUrl
{
    objc_setAssociatedObject(self, LongCacheKey, lastUrl, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString*)getLastUrl
{
    return objc_getAssociatedObject(self, LongCacheKey);
}

- (void)setLoading:(BOOL)loading
{
    objc_setAssociatedObject(self, LongCacheLoadingKey, @(loading), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)isLoading
{
    return objc_getAssociatedObject(self, LongCacheLoadingKey);
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
    NSString *lastUrl = [self getLastUrl];
    if (lastUrl.length > 0 && ![lastUrl isEqualToString:aUrl]) {
        [self setLastUrl:aUrl];
        if (self.loading) {
            [[LongCacheDownloadTask sharedInstance] cancelDownloadTaskWithUrl:aUrl];
        }
    }
    NSData *cacheData = [[LongCache sharedInstance] getCacheWithKey:aUrl];
    if (cacheData) {
        self.image = [UIImage imageWithData:cacheData];
        return;
    }
    __weak typeof(self) weakSelf = self;
    __block NSString *_blockUrl = aUrl;
    self.loading = YES;
    [[LongCacheDownloadTask sharedInstance] downloadWithUrl:aUrl
                                                 completion:^(NSData *aData, NSError *aError) {
                                                     if (!aError) {
                                                         dispatch_async(dispatch_get_main_queue(), ^{
                                                             weakSelf.image = [UIImage imageWithData:aData];
                                                         });
                                                         if (aToDisk) {
                                                             [[LongCache sharedInstance] storeCacheWithData:aData
                                                                                                     forKey:_blockUrl
                                                                                                     toDisk:YES];
                                                         }
                                                     }
                                                     weakSelf.loading = NO;
                                                 }];
}

@end
