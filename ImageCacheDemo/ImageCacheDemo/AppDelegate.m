//
//  AppDelegate.m
//  ImageCacheDemo
//
//  Created by EaseMob on 2017/9/5.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "AppDelegate.h"

#import "LongCache.h"

@interface AppDelegate ()
{
    LongCache *_cache;
    NSCache *_nscache;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    _cache = [[LongCache alloc] init];
    _nscache = [[NSCache alloc] init];
    BOOL type = YES;
    
    for (int j = 0; j < 5; j ++) {
        for (int i = 0; i < 1000; i ++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                @autoreleasepool {
                    NSData *date = [[NSString stringWithFormat:@"%d",i] dataUsingEncoding:NSUTF8StringEncoding];
                    if (type) {
                        [_cache storeCacheWithData:date
                                            forKey:[NSString stringWithFormat:@"%d",i]
                                            toDisk:YES];
                    } else {
                        [_nscache setObject:date forKey:[NSString stringWithFormat:@"%d",i]];
                    }
                }
            });
        }
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        for (int i = 0; i < 1000; i ++) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                @autoreleasepool {
                    NSData *date = nil;
                    if (type) {
                        date = (NSData*)[_cache getCacheWithKey:[NSString stringWithFormat:@"%d",i]];
                    } else {
                        date = (NSData*)[_nscache objectForKey:[NSString stringWithFormat:@"%d",i]];
                    }
                    NSLog(@"%@",[[NSString alloc] initWithData:date encoding:NSUTF8StringEncoding]);
                    if (i == 999) {
                        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
                        NSLog(@"time - %f", endTime - startTime);
                        if (type) {
                            [_cache clearAllCache];
                        } else {
                            [_nscache removeAllObjects];
                        }
                    }
                }
            });
        }
    });
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
