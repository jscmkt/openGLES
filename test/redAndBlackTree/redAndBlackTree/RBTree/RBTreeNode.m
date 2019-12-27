//
//  RBTreeNode.m
//  redAndBlackTree
//
//  Created by you&me on 2019/11/27.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "RBTreeNode.h"

@implementation RBTreeNode
+(instancetype)treeNodeWithValue:(NSNumber *)value withColor:(NodeColor)color{
    RBTreeNode *node = [RBTreeNode new];
    [node setNodeValue:value];
    [node setNodeColor:color];
    return node;
}
-(void)setLeftNode:(RBTreeNode *)LeftNode{
    if (_mLeftNode == LeftNode) {
        return;
    }
    _mLeftNode = LeftNode;
    if (_mLeftNode != nil) {
        [_mLeftNode setParentNode:self];//弱引用
    }
}
-(void)setRightNode:(RBTreeNode *)RightNode{
    if (_mRightNode == RightNode) {
        return;
    }
    _mRightNode =RightNode;
    if (_mRightNode != nil) {
        [_mRightNode setParentNode:self];
    }
}
@end
