//
//  RBTree.m
//  redAndBlackTree
//
//  Created by you&me on 2019/11/27.
//  Copyright © 2019 you&me. All rights reserved.
//

#import "RBTree.h"
static RBTree *sharedRBTree = nil;
@implementation RBTree
{
    RBTreeNode *mRootTreeNode;
}
///全局对象
+(instancetype)shardRBTree{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (sharedRBTree == nil) {
            sharedRBTree = [RBTree new];
        }
    });
    return sharedRBTree;
}

-(RBTreeNode *)getRootTreeNode{
    return mRootTreeNode;
}

+(BOOL)isBrotherHaveTheRightChild:(RBTreeNode *)treeNode{
    BOOL isResult = NO;
    RBTreeNode *parentNode = treeNode.getParentNode;
    if(parentNode != nil && parentNode.getLeftNode && parentNode.getLeftNode.getRightNode){
        isResult = YES;
    }
    return isResult;
}
+ (BOOL) isBrotherHaveTheLeftChild:(RBTreeNode*)treeNode
{
    BOOL isResult = NO;
    RBTreeNode *parentNode = treeNode.getParentNode;
    if(parentNode != nil){
        RBTreeNode *brother = parentNode.getRightNode;
        if(brother != nil){
            if(brother.getLeftNode != nil){
                isResult = YES;
            }
        }
    }
    return isResult;
}

///获取树高度
-(int) getTreeHeight{
    int height = 0;
    if (mRootTreeNode == nil) {
        return height;
    }
    height = [self gettreeHeightWithNode:mRootTreeNode withHeightValue:height];
    return height;
}


///获取某个节点的右子树高度
-(int)getTreeNodeRightHeight:(RBTreeNode *)treeNode{
    int height = 0;
    if (treeNode == nil) {
        return height;
    }
    height = [self getTreeNodeRightHeight:treeNode withHeightValue:height];
    return height;
}

-(int) getTreeNodeRightHeight:(RBTreeNode *)treeNode withHeightValue:(int)heightValue
{
    if (treeNode == nil) {
        return  heightValue;
    }
    heightValue = [self getTreeNodeRightHeight:treeNode.getRightNode withHeightValue:heightValue];
    return heightValue;
}

///获取某个节点的左子树高度
-(int)getTreeNodeLeftHeight:(RBTreeNode *)treeNode{
    int height = 0;
    if (treeNode == nil) {
        return 0;
    }
    height = [self getTreeNodeLeftHeight:treeNode.getLeftNode withHeightValue:height];
    return height;
}

-(int) getTreeNodeLeftHeight:(RBTreeNode *)treeNode withHeightValue:(int)heightValue
{
    if (treeNode == nil) {
        return  heightValue;
    }
    heightValue = [self getTreeNodeRightHeight:treeNode.getLeftNode withHeightValue:heightValue];
    return heightValue;
}


-(int)gettreeHeightWithNode:(RBTreeNode*)treeNode withHeightValue:(int)heightValue
{
    if (treeNode == nil) {
        return heightValue;
    }
    heightValue += 1;
    int leftHeight = heightValue;
    int rightHeight = heightValue;
    if (treeNode.getLeftNode != nil) {
        leftHeight = [self gettreeHeightWithNode:treeNode.getLeftNode withHeightValue:heightValue];
    }
    if(treeNode.getRightNode){
        rightHeight = [self gettreeHeightWithNode:treeNode.getRightNode withHeightValue:heightValue];
    }
    return (leftHeight > rightHeight) ? leftHeight : rightHeight;
}

///节点旋转 - 向右旋转
-(void)nodeRotate_toRight:(RBTreeNode*)treeNode{
    RBTreeNode *leftChildTreeNode = [treeNode getLeftNode];
    RBTreeNode *parentTreeNode = [treeNode getParentNode];
    if (parentTreeNode != nil && treeNode != mRootTreeNode) {

    }
}

///节点旋转 - 向左旋转
-(void)nodeRotate_toLeft:(RBTreeNode*)treeNode{
    RBTreeNode *rightChildTreeNode = [treeNode getRightNode];
    RBTreeNode *parentTreeNode = [treeNode getParentNode];
    if (parentTreeNode && treeNode != mRootTreeNode) {
        if (parentTreeNode.getLeftNode == treeNode) {
            [parentTreeNode setLeftNode:rightChildTreeNode];
        }else{
            [parentTreeNode setRightNode:rightChildTreeNode];
        }
    }else{
        ///根节点
        RBTreeNode *leftForChildTree = [rightChildTreeNode getLeftNode];//右节点的左节点
        [treeNode setRightNode:leftForChildTree];
        [rightChildTreeNode setLeftNode:treeNode];
    }

}
@end
