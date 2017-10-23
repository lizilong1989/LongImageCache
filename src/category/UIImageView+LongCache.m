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
#import "LongImageCache.h"
#import "LongCacheDownloadTask.h"

static const void *LongCacheGifDataKey = &LongCacheGifDataKey;
static const void *LongCacheIndexKey = &LongCacheIndexKey;
static const void *LongCacheUrlKey = &LongCacheUrlKey;
static const void *LongCacheindicatorViewKey = &LongCacheindicatorViewKey;

@interface UIImageView (LongCachePrivate)
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSData *longGifData;
@property (nonatomic, strong) NSNumber *longIndex;
@property (nonatomic, strong) NSString *urlKey;

- (void)playGif;

@end

@implementation UIImageView (LongCachePrivate)

@dynamic indicatorView;
@dynamic longGifData;
@dynamic longIndex;
@dynamic urlKey;


- (UIActivityIndicatorView *)indicatorView
{
    UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, LongCacheindicatorViewKey);
    if (indicatorView == nil) {
        indicatorView = [[UIActivityIndicatorView alloc] init];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        objc_setAssociatedObject(self, LongCacheindicatorViewKey, indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return indicatorView;
}

- (NSData*)longGifData
{
    NSData *gifData = objc_getAssociatedObject(self, LongCacheGifDataKey);
    return gifData;
}

- (void)setLongGifData:(NSData*)aGifData
{
    objc_setAssociatedObject(self, LongCacheGifDataKey, aGifData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)longIndex
{
    return objc_getAssociatedObject(self, LongCacheIndexKey);
}

- (void)setLongIndex:(NSNumber*)aIndex
{
    objc_setAssociatedObject(self, LongCacheIndexKey, aIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)urlKey
{
    return objc_getAssociatedObject(self, LongCacheUrlKey);
}

- (void)setUrlKey:(NSString *)urlKey
{
    objc_setAssociatedObject(self, LongCacheUrlKey, urlKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - gif

- (void)playGif
{
    NSData *gifData = self.longGifData;
    if (gifData == nil) {
        return;
    }
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(gifData), NULL);
    NSUInteger numberOfFrames = CGImageSourceGetCount(imageSource);
    NSInteger index = self.longIndex.integerValue;
    if (index >= numberOfFrames) {
        index = 0;
    }
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(imageSource, index, NULL);
    self.layer.contents = (__bridge id)(imageRef);
    CFRelease(imageRef);
    CFRelease(imageSource);
    [self setLongIndex:@(++index)];
}

@end

@interface LongGifManager : NSObject

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) NSHashTable *gifViewHashTable;
@property (nonatomic, strong) NSMapTable *gifSourceRefMapTable;

+ (LongGifManager *)shared;

- (void)stopGifView:(UIImageView *)view;

@end
@implementation LongGifManager

+ (LongGifManager *)shared{
    static LongGifManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LongGifManager alloc] init];
    });
    return _sharedInstance;
}

-(id)init
{
    self = [super init];
    if (self) {
        _gifViewHashTable = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        _gifSourceRefMapTable = [NSMapTable mapTableWithKeyOptions:NSMapTableWeakMemory valueOptions:NSMapTableWeakMemory];
    }
    return self;
}

- (void)play{
    for (UIImageView *imageView in _gifViewHashTable) {
        [imageView performSelector:@selector(playGif)];
    }
}

- (void)stopDisplayLink
{
    if (self.displayLink) {
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (void)stopGifView:(UIImageView *)view
{
    CGImageSourceRef ref = (__bridge CGImageSourceRef)([[LongGifManager shared].gifSourceRefMapTable objectForKey:view]);
    if (ref) {
        [_gifSourceRefMapTable removeObjectForKey:view];
        CFRelease(ref);
    }
    [_gifViewHashTable removeObject:view];
    if (_gifViewHashTable.count<1 && !_displayLink) {
        [self stopDisplayLink];
    }
}

@end

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
    [self setUrlKey:[aUrl copy]];
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

#pragma mark - private

- (void)_setImageWithImage:(UIImage*)image data:(NSData*)aData
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        if (image) {
            weakSelf.image = nil;
            if ([image.images count] > 0) {
                weakSelf.image = [image.images objectAtIndex:0];
                NSData *gifData = [[LongCache sharedInstance] getCacheWithKey:weakSelf.urlKey];
                [weakSelf setLongGifData:gifData];
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [[LongGifManager shared].gifViewHashTable addObject:weakSelf];
                });
                
                if (![LongGifManager shared].displayLink) {
                    [LongGifManager shared].displayLink = [CADisplayLink displayLinkWithTarget:[LongGifManager shared] selector:@selector(play)];
                    [[LongGifManager shared].displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
                }
                
            } else {
                [[LongGifManager shared] stopGifView:weakSelf];
                weakSelf.image = image;
            }
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
        UIActivityIndicatorView *indicatorView = weakSelf.indicatorView;
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
        UIActivityIndicatorView *indicatorView = weakSelf.indicatorView;
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
