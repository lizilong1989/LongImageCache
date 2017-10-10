//
//  LongCacheDownloadTask.m
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/9/22.
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
    [[LongRequestManager sharedInstance] cancelRequestWithUrl:aUrl];
}

- (void)downloadWithUrl:(NSString*)aUrl
             completion:(void (^)(NSData *aData, NSError *aError))aCompletionBlock
{
    dispatch_block_t block = ^{
        [[LongRequestManager sharedInstance] downloadWithUrl:aUrl progress:NULL completion:aCompletionBlock];
    };
    [_longDispatch addTask:block];
}

@end
