//
//  AppDelegate.m
//  ImageCacheDemo
//
//  Created by zilong.li on 2017/9/5.
//  Copyright © 2017年 zilong.li. All rights reserved.
//

#import "AppDelegate.h"

#import "LongCache.h"
#import <LongCrash/LongCrashManager.h>

#import "TableViewController.h"
#import "ImageViewController.h"

@interface AppDelegate () <LongCrashDelegate>
{
    NSCache *_nscache;
}

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    /*
    _nscache = [[NSCache alloc] init];
    _nscache.countLimit = 256 * 256;
    _nscache.totalCostLimit = 1024 * 1024 * 128;
    BOOL type = NO;
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        for (int j = 0; j < 5; j ++) {
            for (int i = 0; i < 10000; i ++) {
                
                @autoreleasepool {
                    NSData *date = [[NSString stringWithFormat:@"%d",i] dataUsingEncoding:NSUTF8StringEncoding];
                    if (type) {
                        [[LongCache sharedInstance] storeCacheWithData:date
                                                                forKey:[NSString stringWithFormat:@"%d",i]
                                                                toDisk:NO];
                    } else {
                        [_nscache setObject:date forKey:[NSString stringWithFormat:@"%d",i]];
                    }
                }
            
            }
        }
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        NSLog(@"time - %f", endTime - startTime);
        dispatch_semaphore_signal(semaphore);
   });
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
        for (int i = 0; i < 10000; i ++) {
            @autoreleasepool {
                NSData *date = nil;
                if (type) {
                    date = (NSData*)[[LongCache sharedInstance] getCacheWithKey:[NSString stringWithFormat:@"%d",i]];
                } else {
                    date = (NSData*)[_nscache objectForKey:[NSString stringWithFormat:@"%d",i]];
                }
                if ([date isKindOfClass:[NSData class]]) {
//                    NSLog(@"%@",[[NSString alloc] initWithData:date encoding:NSUTF8StringEncoding]);
                }
            }
        }
        NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
        NSLog(@"time - %f", endTime - startTime);
        if (type) {
            NSLog(@"size %ld", [[LongCache sharedInstance] getDiskSize]);
            NSLog(@"count %ld", [[LongCache sharedInstance] getDiskCount]);
            [[LongCache sharedInstance] clearAllCache];
        } else {
            [_nscache removeAllObjects];
        }
    });*/
    
    
    TableViewController *table = [[TableViewController alloc] init];
    table.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Load Image"
                                                     image:nil
                                             selectedImage:nil];
    ImageViewController *image = [[ImageViewController alloc] init];
    image.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Play Image"
                                                     image:nil
                                             selectedImage:nil];
    
    UITabBarController *tabBar = [[UITabBarController alloc] init];
    [tabBar setViewControllers:@[table,image]];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:tabBar];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [[LongCrashManager sharedInstancel] addDelegate:self delegateQueue:nil];
    
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

#pragma mark - LongCrashDelegate

- (void)didCrashWithInfo:(NSString *)aInfo
{
    NSLog(@"%@" ,aInfo);
}


@end
