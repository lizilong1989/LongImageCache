//
//  LongGifImage.h
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/10/19.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LongGifImage : UIImage

- (id)initWithCGImageSource:(CGImageSourceRef)imageSource;

- (id)initWithCGImageSource:(CGImageSourceRef)imageSource scale:(CGFloat)scale;

@end
