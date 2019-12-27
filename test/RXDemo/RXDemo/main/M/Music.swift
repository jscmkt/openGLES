//
//  Music.swift
//  RXSwift
//
//  Created by you&me on 2019/1/29.
//  Copyright © 2019年 you&me. All rights reserved.
//

import Foundation

struct Music {
    let name:String //歌名
    let singer:String //演唱者
    init(name:String, singer:String) {
        self.name = name
        self.singer = singer
    }

}
//实现 CustomStringConvertible 协议，方便输出调试
extension Music:CustomStringConvertible{
    var description: String {
        return "name：\(name) singer：\(singer)"
    }


}
