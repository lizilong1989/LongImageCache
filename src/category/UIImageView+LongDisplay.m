//
//  UIImageView+LongDisplay.m
//  Pods
//
//  Created by zilong.li on 2017/11/17.
//

#import "UIImageView+LongDisplay.h"

@implementation UIImageView (LongDisplay)

-(void)drawRadius:(CGFloat)aRadius
             size:(CGSize)aSizetoFit
{
    
    CGRect rect = CGRectMake(0, 0, aSizetoFit.width, aSizetoFit.height);
    UIGraphicsBeginImageContextWithOptions(rect.size,false,[UIScreen mainScreen].scale);
    
    CGContextAddPath(UIGraphicsGetCurrentContext(),[UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(aRadius, aRadius)].CGPath);
    
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [self.image drawInRect:rect];
    
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.image = output;
}

@end
