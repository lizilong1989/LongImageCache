//
//  UIImageView+LongCache.h
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/22.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (LongCache)

- (void)setImageWithUrl:(NSString*)aUrl;

- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage;

- (void)setImageWithUrl:(NSString*)aUrl
       placeholderImage:(UIImage*)aImage
                 toDisk:(BOOL)aToDisk;

@end
