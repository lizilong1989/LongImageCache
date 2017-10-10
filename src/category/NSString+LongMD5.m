//
//  NSString+LongMD5.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/10/10.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "NSString+LongMD5.h"

#import <CommonCrypto/CommonDigest.h>

@implementation NSString (LongMD5)

- (NSString *)md5String
{
    if (self.length == 0) {
        return nil;
    }
    
    const char *cStr = [self UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

@end
