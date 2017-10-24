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

- (void)showWithUrls:(NSArray*)aUrls;

@end
