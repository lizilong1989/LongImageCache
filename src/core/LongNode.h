//
//  LongNode.h
//  Pods
//
//  Created by EaseMob on 2017/12/12.
//

#import <Foundation/Foundation.h>

@interface LongNode : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, strong) LongNode *pre;
@property (nonatomic, strong) LongNode *next;

@end


@interface LongNodeList : NSObject

@property (nonatomic, strong) LongNode *head;
@property (nonatomic, strong) LongNode *tail;

- (instancetype)initWithNode:(LongNode*)aNode;

- (void)insertNode:(LongNode*)aNode;

- (void)removeNodeWithKey:(NSString *)aKey;

- (NSInteger)count;

- (void)removeAllObjects;

@end
