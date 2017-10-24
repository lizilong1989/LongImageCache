//
//  LongGifImage.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/10/19.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "LongGifImage.h"

@implementation UIImage (LongGif)

+ (float)frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
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

@end

@interface LongImageSourceArray : NSArray

@property (nonatomic, readonly) CGImageSourceRef imageSource;

- (void)updateCount;

+ (instancetype)arrayWithImageSource:(CGImageSourceRef)imageSource;
+ (instancetype)arrayWithImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale;

@end

@interface LongGifImage ()

@property (nonatomic, readwrite) NSTimeInterval *frameDurations;
@property (nonatomic, readwrite) NSTimeInterval totalDuration;
@property (nonatomic, readwrite) NSUInteger loopCount;
@property (nonatomic, readwrite) LongImageSourceArray *imageSourceArray;

@end

@implementation LongGifImage

+ (instancetype)imageNamed:(NSString*)name
{
    if (name.length == 0) {
        return nil;
    }
    CGFloat scale = [UIScreen mainScreen].scale;
    
    LongGifImage *image = nil;
    if (scale > 1.0f) {
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];
        NSData *data = [NSData dataWithContentsOfFile:retinaPath];
        if (data.length == 0) {
            NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
             data = [NSData dataWithContentsOfFile:path];
        }
        
        if (data.length > 0) {
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
            image = [[LongGifImage alloc] initWithCGImageSource:imageSource];
            CFRelease(imageSource);
        }
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data.length > 0) {
            CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)(data), NULL);
            image = [[LongGifImage alloc] initWithCGImageSource:imageSource];
            CFRelease(imageSource);
        }
    }
    

    return image;
}

- (id)initWithCGImageSource:(CGImageSourceRef)imageSource
{
    return [self initWithCGImageSource:imageSource scale:1.0f];
}

- (id)initWithCGImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale
{
    self = [super init];
    if (!imageSource || !self) {
        return nil;
    }
    
    NSUInteger numberOfFrames = CGImageSourceGetCount(imageSource);
    
    NSDictionary *imageProperties = CFBridgingRelease(CGImageSourceCopyProperties(imageSource, NULL));
    NSDictionary *gifProperties = [imageProperties objectForKey:(NSString *)kCGImagePropertyGIFDictionary];
    
    self.frameDurations = (NSTimeInterval *)malloc(numberOfFrames  * sizeof(NSTimeInterval));
    self.loopCount = [gifProperties[(NSString *)kCGImagePropertyGIFLoopCount] unsignedIntegerValue];
    for (NSUInteger i = 0; i < numberOfFrames; ++i) {
        NSTimeInterval frameDuration = [UIImage frameDurationAtIndex:i source:imageSource];
        self.frameDurations[i] = frameDuration;
        self.totalDuration += frameDuration;
    }
    self.imageSourceArray = [LongImageSourceArray arrayWithImageSource:imageSource scale:scale];
    
    return self;
}

#pragma mark - Compatibility methods

- (NSArray *)images
{
    return self.imageSourceArray;
}

- (CGSize)size
{
    if (self.images.count) {
        return [(UIImage *)self.images.firstObject size];
    }
    return [super size];
}

- (CGImageRef)CGImage
{
    if (self.images.count) {
        return [(UIImage *)self.images.firstObject CGImage];
    } else {
        return [super CGImage];
    }
}

- (UIImageOrientation)imageOrientation
{
    if (self.images.count) {
        return [(UIImage *)self.images.firstObject imageOrientation];
    } else {
        return [super imageOrientation];
    }
}

- (CGFloat)scale
{
    if (self.images.count) {
        return [(UIImage *)self.images.firstObject scale];
    } else {
        return [super scale];
    }
}

- (NSTimeInterval)duration
{
    return self.images ? self.totalDuration : [super duration];
}

- (void)dealloc {
    free(_frameDurations);
}

@end

@interface LongImageSourceArray ()

@property (nonatomic, readonly) NSCache *frameCache;
@property (nonatomic) NSUInteger frameCount;
@property (nonatomic, readonly) CGFloat scale;

@end

@implementation LongImageSourceArray

+ (instancetype)arrayWithImageSource:(CGImageSourceRef)imageSource
{
    return [self arrayWithImageSource:imageSource scale:1.0f];
}

+ (instancetype)arrayWithImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale
{
    if (!imageSource) {
        return nil;
    }
    return [[self alloc] initWithImageSource:imageSource scale:scale];
}

- (instancetype)initWithImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale
{
    self = [super init];
    if (self) {
        CFRetain(imageSource);
        _imageSource = imageSource;
        _frameCache = [NSCache new];
        [_frameCache setCountLimit:10];
        _frameCount = 0;
        _scale = scale;
        [self updateCount];
    }
    return self;
}

- (NSUInteger)count
{
    return self.frameCount;
}

- (id)objectAtIndex:(NSUInteger)idx
{
    id object = [self.frameCache objectForKey:@(idx)];
    if (!object) {
        object = [self _objectAtIndex:idx];
    }
    return object;
}

- (BOOL)containsObject:(id)anObject
{
    return [[(id)self.frameCache allObjects] containsObject:anObject];
}

- (id)_objectAtIndex:(NSUInteger)idx
{
    CGImageRef frameImageRef = CGImageSourceCreateImageAtIndex(self.imageSource, idx, NULL);
    UIImage *image = [UIImage imageWithCGImage:frameImageRef scale:self.scale orientation:UIImageOrientationUp];
    CGImageRelease(frameImageRef);
    if (image) {
        [self.frameCache setObject:image forKey:@(idx)];
    }
    return image;
}

- (void)updateCount
{
    NSInteger count = CGImageSourceGetCount(self.imageSource);
    if (CGImageSourceGetStatus(self.imageSource) != kCGImageStatusComplete) {
        count -=2;
    }
    self.frameCount = MAX(0, count);
    NSUInteger cacheLimit = self.frameCache.countLimit;
    if (self.frameCount > 0) {
        cacheLimit = MIN(self.frameCount, 10);
    }
    [self.frameCache setCountLimit:cacheLimit];
}

- (void)dealloc
{
    CFRelease(_imageSource);
}

@end
