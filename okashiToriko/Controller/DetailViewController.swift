//
//  DetailViewController.swift
//  okashiToriko
//
//  Created by 渡邉天彰 on 2020/06/07.
//  Copyright © 2020 takaaki watanabe. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var okashiName: UILabel!
    
    @IBOutlet weak var okashiMakerName: UILabel!
    
    @IBOutlet weak var okashiSellArea: UILabel!
    
    @IBOutlet weak var okashiImage: UIImageView!
    
    @IBOutlet weak var okashiPrice: UILabel!
    
    @IBOutlet weak var okashiDetail: UITextView!
    
    var nameString:String = ""
    var makerString:String = ""
    var sellArea:String = ""
    var image:String = ""
    var price:String = ""
    var commentString:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        okashiName.text = nameString
        okashiMakerName.text = makerString
        print(sellArea)
        if sellArea == "0" {
            okashiSellArea.text = ""
        }else{
            okashiSellArea.text = "地域限定"
        }
        okashiDetail.text = commentString
        okashiImage.image = getImageByUrl(url:image)
        
        okashiPrice.text = "\(price) 円"
        
    }
    
    //URLから画像を拾う記述
    func getImageByUrl(url: String) -> UIImage{
        let url = URL(string: url)
        
        do {
            let data = try Data(contentsOf: url!)
            return UIImage(data: data)!
        }catch let error{
            print("Error: \(error.localizedDescription)")
        }
        return UIImage()
    }
    

}
