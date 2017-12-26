//
//  LongNode.m
//  Pods
//
//  Created by EaseMob on 2017/12/12.
//

#import "LongNode.h"

@implementation LongNode

@end

@interface LongNodeList()
{
    NSMutableDictionary *_nodeDic;
}
@end

@implementation LongNodeList

- (instancetype)initWithNode:(LongNode*)aNode
{
    self = [self init];
    if (self) {
        _nodeDic = [NSMutableDictionary dictionary];
        [_nodeDic setObject:aNode forKey:aNode.key];
        _head = aNode;
        _tail = aNode;
    }
    return self;
}

- (void)insertNode:(LongNode *)aNode
{
    if (![_nodeDic objectForKey:aNode.key]) {
        if (_head == nil) {
            _head = aNode;
            _tail = aNode;
        } else {
            [_nodeDic setObject:aNode forKey:aNode.key];
            _tail.next = aNode;
            aNode.pre = _tail;
            _tail = aNode;
        }
    } else {
        LongNode *node = [_nodeDic objectForKey:aNode.key];
        node.pre.next = node.next;
        node.next.pre = node.pre;
        node.next = _head.next;
        node.pre = nil;
        _head = node;
    }
}

- (void)removeNodeWithKey:(NSString *)aKey
{
    if ([_nodeDic objectForKey:aKey]) {
        LongNode *node = [_nodeDic objectForKey:aKey];
        if (!node.pre) {
            _head = node.next;
            node.next.pre = nil;
        } else if (!node.next) {
            _tail = node.pre;
            node.pre.next = nil;
        } else {
            LongNode *temp = node.next;
            node.pre = temp.next;
            temp.pre = node.pre;
        }
    }
}

- (NSInteger)count
{
    return [_nodeDic count];
}

- (void)removeAllObjects
{
    [_nodeDic removeAllObjects];
}

@end
