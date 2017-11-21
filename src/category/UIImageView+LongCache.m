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
#import "LongGifImage.h"
#import "LongWebPImage.h"
#import "LongCacheDownloadTask.h"

static const void *LongCacheIndexKey = &LongCacheIndexKey;
static const void *LongCacheUrlKey = &LongCacheUrlKey;
static const void *LongCacheindicatorViewKey = &LongCacheindicatorViewKey;
static const void *LongCacheDisplayLinkViewKey = &LongCacheDisplayLinkViewKey;
static const void *LongCacheTimeDurationKey = &LongCacheTimeDurationKey;
static const void *LongCacheImageSourceRefKey = &LongCacheImageSourceRefKey;
static const void *LongCacheImageNamesKey = &LongCacheImageNamesKey;
static const void *LongCacheRepeatCountKey = &LongCacheRepeatCountKey;

@interface UIImageView (LongCachePrivate)

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSNumber *longIndex;
@property (nonatomic, strong) NSNumber *timeDuration;
@property (nonatomic, strong) NSString *urlKey;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGImageSourceRef imageSourceRef;
@property (nonatomic, strong) NSArray *names;
@property (nonatomic, strong) NSNumber *repeatCount;

- (void)long_playGif;

- (void)long_playImage;

@end

@implementation UIImageView (LongCachePrivate)

@dynamic indicatorView;
@dynamic longIndex;
@dynamic urlKey;
@dynamic displayLink;
@dynamic timeDuration;
@dynamic imageSourceRef;
@dynamic names;
@dynamic repeatCount;

+ (void)load
{
    Method originalStartMethod = class_getInstanceMethod([UIImageView class], @selector(startAnimating));
    Method swizzleStartMethod = class_getInstanceMethod([UIImageView class], @selector(long_startAnimating));
    method_exchangeImplementations(originalStartMethod, swizzleStartMethod);
    
    Method originalStopMethod = class_getInstanceMethod([UIImageView class], @selector(stopAnimating));
    Method swizzleStopMethod = class_getInstanceMethod([UIImageView class], @selector(long_stopAnimating));
    method_exchangeImplementations(originalStopMethod, swizzleStopMethod);
    
    Method originalIsAnimatingMethod = class_getInstanceMethod([UIImageView class], @selector(isAnimating));
    Method swizzleIsAnimatingMethod = class_getInstanceMethod([UIImageView class], @selector(long_isAnimating));
    method_exchangeImplementations(originalIsAnimatingMethod, swizzleIsAnimatingMethod);
    
    SEL dealloc = NSSelectorFromString(@"dealloc");
    Method originalDeallocMethod = class_getInstanceMethod([UIImageView class], dealloc);
    Method swizzleDeallocMethod = class_getInstanceMethod([UIImageView class], @selector(long_dealloc));
    method_exchangeImplementations(originalDeallocMethod, swizzleDeallocMethod);
}

- (UIActivityIndicatorView *)indicatorView
{
    UIActivityIndicatorView *indicatorView = objc_getAssociatedObject(self, LongCacheindicatorViewKey);
    if (indicatorView == nil) {
        indicatorView = [[UIActivityIndicatorView alloc] init];
        [indicatorView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        objc_setAssociatedObject(self, LongCacheindicatorViewKey, indicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return indicatorView;
}

- (NSNumber*)longIndex
{
    return objc_getAssociatedObject(self, LongCacheIndexKey);
}

- (void)setLongIndex:(NSNumber*)aIndex
{
    objc_setAssociatedObject(self, LongCacheIndexKey, aIndex, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)timeDuration
{
    return objc_getAssociatedObject(self, LongCacheTimeDurationKey);
}

- (void)setTimeDuration:(NSNumber *)timeDuration
{
    objc_setAssociatedObject(self, LongCacheTimeDurationKey, timeDuration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString*)urlKey
{
    return objc_getAssociatedObject(self, LongCacheUrlKey);
}

- (void)setUrlKey:(NSString *)urlKey
{
    objc_setAssociatedObject(self, LongCacheUrlKey, urlKey, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CADisplayLink*)displayLink
{
    return objc_getAssociatedObject(self, LongCacheDisplayLinkViewKey);
}

- (void)setDisplayLink:(CADisplayLink *)displayLink
{
    objc_setAssociatedObject(self, LongCacheDisplayLinkViewKey, displayLink, OBJC_ASSOCIATION_RETAIN);
}

- (void)setImageSourceRef:(CGImageSourceRef)imageSourceRef
{
    objc_setAssociatedObject(self, LongCacheImageSourceRefKey, (__bridge id _Nullable)(imageSourceRef), OBJC_ASSOCIATION_ASSIGN);
}

- (CGImageSourceRef)imageSourceRef
{
    return (__bridge CGImageSourceRef)(objc_getAssociatedObject(self, LongCacheImageSourceRefKey));
}

- (void)setNames:(NSArray *)names
{
    objc_setAssociatedObject(self, LongCacheImageNamesKey, names, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSArray*)names
{
    return objc_getAssociatedObject(self, LongCacheImageNamesKey);
}

- (void)setRepeatCount:(NSNumber *)repeatCount
{
    objc_setAssociatedObject(self, LongCacheRepeatCountKey, repeatCount, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber*)repeatCount
{
    return objc_getAssociatedObject(self, LongCacheRepeatCountKey);
}

#pragma mark - gif

- (void)long_playGif
{
    if (!self.imageSourceRef) {
        [self stopAnimating];
        return;
    }
    
    NSUInteger numberOfFrames = CGImageSourceGetCount(self.imageSourceRef);
    NSInteger index = self.longIndex.integerValue;
    if (index >= numberOfFrames) {
        index = 0;
    }
    
    NSTimeInterval time = [self.timeDuration doubleValue];
    time += self.displayLink.duration;
    if (time <= [self _frameDurationAtIndex:index source:self.imageSourceRef]) {
        self.timeDuration = @(time);
        return;
    }
    self.timeDuration = 0;
    
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(self.imageSourceRef, index, NULL);
    self.image = [UIImage imageWithCGImage:imageRef];
    [self.layer setNeedsDisplay];
    CFRelease(imageRef);
    [self setLongIndex:@(++index)];
}

- (float)_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    }
    else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

#pragma mark - play image

- (void)long_playImage
{
    if ([self.names count] == 0) {
        [self stopAnimating];
        return;
    }
    
    NSInteger repeatCount = self.repeatCount.integerValue;
    if (self.repeatCount.integerValue == -1) {
        [self setRepeatCount:@(0)];
        [self stopAnimating];
        return;
    }
    
    NSInteger index = self.longIndex.integerValue;
    if (index >= [self.names count]) {
        index = 0;
        if (self.animationRepeatCount != 0) {
            [self setRepeatCount:@(--repeatCount)];
        }
    }
    
    NSTimeInterval time = [self.timeDuration doubleValue];
    time += self.displayLink.duration;
    if (time <= self.animationDuration) {
        self.timeDuration = @(time);
        return;
    }
    self.timeDuration = 0;
    
    NSString *name = [self.names objectAtIndex:index];
    [self setImageWithName:name];
    [self setLongIndex:@(++index)];
}

#pragma mark - private

- (void)_setImageWithData:(NSData*)aData
{
    UIImage *image = [UIImage imageWithData:aData];
    [self _setImageWithImage:image];
}

- (void)_setImageWithImage:(UIImage*)aImage
{
    self.image = aImage;
    [self.layer setNeedsDisplay];
}

- (NSData*)_getDataWithName:(NSString*)aName pathComponent:(NSString*)aPathComponent
{
    NSData *data = nil;
    CGFloat scale = [UIScreen mainScreen].scale;
    NSArray *scales;
    if (scale <= 1.0f) {
        scales = @[@"",@"@2x",@"@3x"];
    } else if (scale <= 2.0f){
        scales = @[@"@2x",@"@3x",@""];
    } else {
        scales = @[@"@3x",@"@2x",@""];
    }
    
    for(NSString *scale in scales) {
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[aName stringByAppendingString:scale] ofType:aPathComponent];
        data = [NSData dataWithContentsOfFile:retinaPath];
        if (data.length > 0) {
            break;
        }
    }
    return data;
}

- (void)_addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(long_appDidEnterBackgroundNotif:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(long_appWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)_removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidEnterBackgroundNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
}

- (void)long_appDidEnterBackgroundNotif:(NSNotification*)notif
{
    [self stopAnimating];
}

- (void)long_appWillEnterForeground:(NSNotification*)notif
{
    [self startAnimating];
}

#pragma mark - swizzle

- (void)long_startAnimating
{
    [self _addNotification];
    if (self.imageSourceRef != nil) {
        if (!self.displayLink) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(long_playGif)];
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
        self.displayLink.paused = NO;
    } if ([self.names count] > 0) {
        if (!self.displayLink) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(long_playImage)];
            [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
        if (self.animationRepeatCount != 0) {
            self.repeatCount = @(self.animationRepeatCount - 1);
        }
        self.displayLink.paused = NO;
    } else {
        [self long_startAnimating];
    }
}

- (void)long_stopAnimating
{
    if (self.displayLink != nil) {
        self.displayLink.paused = YES;
        [self.displayLink invalidate];
        self.displayLink = nil;
    } else {
        [self long_stopAnimating];
    }
}

- (BOOL)long_isAnimating
{
    BOOL isAnimating = NO;
    if (self.displayLink) {
        isAnimating = self.displayLink && !self.displayLink.isPaused;
    } else {
        isAnimating = [self long_isAnimating];
    }
    return isAnimating;
}

- (void)long_dealloc
{
    [self stopAnimating];
    [self.displayLink invalidate];
    [self _removeNotification];
}

#pragma mark - override

- (void)displayLayer:(CALayer *)layer
{
    layer.contents = (__bridge id)self.image.CGImage;
}

/*
-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGLayerRef cg = CGLayerCreateWithContext(ctx, self.frame.size, NULL);
    CGContextRef layerContext = CGLayerGetContext(cg);
    CGContextDrawImage(layerContext, self.frame, self.image.CGImage);
    CGContextDrawLayerAtPoint(ctx, CGPointMake(0, 0), cg);
}
 */

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
    
    if (aUrl.length == 0) {
        return;
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

- (void)setImageWithName:(NSString*)aName
{
    if (aName.length == 0) {
        return;
    }
    
    NSString *res = aName.stringByDeletingPathExtension;
    NSString *ext = aName.pathExtension;
    
    NSData *data = nil;
    UIImage *image = [[LongImageCache sharedInstance] getImageFromCacheWithKey:aName];
    
    if (image) {
        [self _setImageWithImage:image];
        return;
    }
    
    if (ext.length > 0) {
        data = [self _getDataWithName:res pathComponent:ext];
    } else {
        NSArray *exts =
#ifdef LONG_WEBP
        exts = @[@"png",@"jpg",@"jpeg",@"gif",@"webp",@""];
#else
        exts = @[@"png",@"jpg",@"jpeg",@"gif",@""];
#endif
        for (NSString *ext in exts) {
            data = [self _getDataWithName:aName pathComponent:ext];
            if (data.length > 0) {
                [[LongImageCache sharedInstance] setCacheWithData:data key:aName toDisk:NO];
                break;
            }
        }
    }
    
    [self _setImageWithData:data];
}

- (void)setImagesWithNames:(NSArray *)aNames
{
    self.names = aNames;
    if ([aNames count] > 0) {
        NSString *name = [self.names objectAtIndex:0];
        [self setImageWithName:name];
    }
}

#pragma mark - private

- (void)_setImageWithImage:(UIImage*)image data:(NSData*)aData
{
    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = ^{
        
        if (weakSelf.imageSourceRef) {
            CFRelease(weakSelf.imageSourceRef);
            weakSelf.imageSourceRef = nil;
        }
        
        if (image) {
            weakSelf.image = nil;
            if (image.images) {
                weakSelf.image = [image.images objectAtIndex:0];
                NSData *gifData = [[LongCache sharedInstance] getCacheWithKey:weakSelf.urlKey];
                if (gifData.length > 0 ) {
                    [weakSelf setImageSourceRef:CGImageSourceCreateWithData((__bridge CFDataRef)(gifData), NULL)];
                    [weakSelf startAnimating];
                }
            } else {
                [weakSelf _setImageWithImage:image];
                [weakSelf stopAnimating];
            }
        }
        
        if (aData) {
            if ([LongImageCache isGif:aData]) {
                weakSelf.image = [UIImage imageWithData:aData];
                [weakSelf setImageSourceRef:CGImageSourceCreateWithData((__bridge CFDataRef)(aData), NULL)];
                [weakSelf startAnimating];
            }
#ifdef LONG_WEBP
            else if ([LongImageCache isWebP:aData]) {
                [weakSelf _setImageWithImage:[[LongWebPImage alloc] initWithData:aData]];
                [weakSelf stopAnimating];
            }
#endif
            else {
                [weakSelf _setImageWithData:aData];
                [weakSelf stopAnimating];
            }
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
