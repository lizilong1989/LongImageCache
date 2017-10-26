//
//  LongCacheDownloadTask.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/22.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "LongCacheDownloadTask.h"

#import <LongRequest/LongRequestManager.h>
#import <LongDispatch/LongDispatch.h>

#define kDefaultMaxTask 5

static LongCacheDownloadTask *task = nil;

@interface LongCacheDownloadTask()
{
    LongDispatch *_longDispatch;
}
@end

@implementation LongCacheDownloadTask

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        task = [[LongCacheDownloadTask alloc] init];
    });
    return task;
}

- (instancetype)init
{
    if (self) {
        _longDispatch = [LongDispatch initWithMaxCount:kDefaultMaxTask];
    }
    return self;
}

- (void)cancelDownloadTaskWithUrl:(NSString *)aUrl
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[LongRequestManager sharedInstance] cancelRequestWithUrl:aUrl];
    });
}

- (void)downloadWithUrl:(NSString*)aUrl
               progress:(void (^)(int progress))aProgressBlock
             completion:(void (^)(NSData *aData, NSError *aError))aCompletionBlock
{
    dispatch_block_t block = ^{
        [[LongRequestManager sharedInstance] downloadWithUrl:aUrl progress:aProgressBlock completion:aCompletionBlock];
    };
    [_longDispatch addTask:block];
}

@end
