//
//  LongWebPImage.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/10/19.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "LongWebPImage.h"

#ifdef LONG_WEBP

#import "decode.h"

static void LongFreeImageData(void *info, const void *data, size_t size)
{
    free((void *)data);
}

@implementation LongWebPImage

- (instancetype)initWithData:(NSData *)data
{
    WebPDecoderConfig config;
    if (!WebPInitDecoderConfig(&config)) {
        return nil;
    }
    
    config.output.colorspace = MODE_rgbA;
    config.options.use_threads = 1;
    
    // Decode the WebP image data into a RGBA value array.
    if (WebPDecode(data.bytes, data.length, &config) != VP8_STATUS_OK) {
        return nil;
    }
    
    int width = config.input.width;
    int height = config.input.height;
    if (config.options.use_scaling) {
        width = config.options.scaled_width;
        height = config.options.scaled_height;
    }
    
    // Construct a UIImage from the decoded RGBA value array.
    CGDataProviderRef provider =
    CGDataProviderCreateWithData(NULL, config.output.u.RGBA.rgba, config.output.u.RGBA.size, LongFreeImageData);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    
    self = [self initWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return self;
}

@end

#endif
