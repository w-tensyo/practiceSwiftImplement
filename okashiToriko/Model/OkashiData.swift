//
//  OkashiData.swift
//  okashiToriko
//
//  Created by 渡邉天彰 on 2020/05/29.
//  Copyright © 2020 takaaki watanabe. All rights reserved.
//

import Foundation

class OkashiData{
    
    //プロパティの設定
    var okashiName:String = ""
    var okashiMaker:String = ""
    var okashiPrice:String = ""
    var okashiArea:String = ""
    var okashiURL:String = ""
    var okashiImage:String = ""
    
    init(okashiName: String, okashiMaker: String, okashiPrice: String,okashiArea: String,okashiURL: String,okashiImage: String) {
        self.okashiName = okashiName
        self.okashiMaker = okashiMaker
        self.okashiPrice = okashiPrice
        self.okashiArea = okashiArea
        self.okashiURL = okashiURL
        self.okashiImage = okashiImage
    }
}
