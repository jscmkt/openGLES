//
//  RBTreeNode.h
//  redAndBlackTree
//
//  Created by you&me on 2019/11/27.
//  Copyright © 2019 you&me. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum: int{
    NodeColor_Red = 0, ///< 红色
    NodeColor_Black, ///< 黑色
}NodeColor;
///红黑树节点
@interface RBTreeNode : NSObject

///初始化对象,并复制节点值和节点颜色
+(instancetype)treeNodeWithValue:(NSNumber*)value withColor:(NodeColor)color;

///节点颜色
@property(nonatomic,assign,setter=setNodeColor:,getter=getNodeColor) NodeColor mNodeColor;

///节点值
@property(nonatomic,retain,setter=setNodeValue:,getter=getNodeValue)NSNumber *mNodeValue;

///左节点
@property(nonatomic,retain,setter=setLeftNode:,getter=getLeftNode)RBTreeNode *mLeftNode;

///右节点
@property(nonatomic,retain,setter=setRightNode:,getter=getRightNode)RBTreeNode *mRightNode;

//父节点,设置为weak避免循环引用的问题
@property(nonatomic,weak,setter=setParentNode:,getter=getParentNode)RBTreeNode *mParentNode;


@end

NS_ASSUME_NONNULL_END
