//
//  LongCacheDownloadTask.h
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/22.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LongCacheDownloadTask : NSObject

+ (instancetype)sharedInstance;

- (void)cancelDownloadTaskWithUrl:(NSString*)aUrl;

- (void)downloadWithUrl:(NSString*)aUrl
               progress:(void (^)(int progress))aProgressBlock
             completion:(void (^)(NSData *aData, NSError *aError))aCompletionBlock;

@end
