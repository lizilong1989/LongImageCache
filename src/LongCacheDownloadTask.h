//
//  LongCacheDownloadTask.h
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/9/22.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LongCacheDownloadTask : NSObject

+ (instancetype)sharedInstance;

- (void)cancelDownloadTaskWithUrl:(NSString*)aUrl;

- (void)downloadWithUrl:(NSString*)aUrl
             completion:(void (^)(NSData *aData, NSError *aError))aCompletionBlock;

@end
