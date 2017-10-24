//
//  LongPhotoBrowser.h
//  Pods
//
//  Created by EaseMob on 2017/10/24.
//

#import <Foundation/Foundation.h>

@interface LongPhotoBrowser : NSObject

+ (instancetype)sharedInstance;

- (void)showWithImages:(NSArray*)aImages;

- (void)showWithImages:(NSArray*)aImages
             withIndex:(NSInteger)aIndex;

- (void)showWithUrls:(NSArray*)aUrls;

- (void)showWithUrls:(NSArray*)aUrls
           withIndex:(NSInteger)aIndex;

@end
