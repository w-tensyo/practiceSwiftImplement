//
//  OkashiTableViewCell.swift
//  okashiToriko
//
//  Created by 渡邉天彰 on 2020/05/29.
//  Copyright © 2020 takaaki watanabe. All rights reserved.
//

import UIKit

class OkashiTableViewCell: UITableViewCell {

    
    @IBOutlet weak var okashiNameLabel: UILabel!
    
    @IBOutlet weak var makerNameLabel: UILabel!
    
    @IBOutlet weak var sellAreaIcon: UIImageView!
    
    @IBOutlet weak var okashiImageView: UIImageView!
    
    @IBOutlet weak var okashiPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        okashiImageView.frame = CGRect(x: 0, y: 80, width: frame.size.width, height: 80)
        // Configure the view for the selected state
    }
    
    func setContent(okashiItems: OkashiItems){
        self.okashiNameLabel.text = okashiItems.okashiName
        self.makerNameLabel.text = okashiItems.okashiMaker
        
        
        self.okashiImageView.image = getImageByUrl(url: okashiItems.okashiImage!)
        
        if okashiItems.okashiPrice == nil{
            self.okashiPriceLabel.text = "価格不明"
        }else{
            self.okashiPriceLabel.text = "\(okashiItems.okashiPrice!) 円"
        }
        if okashiItems.okashiArea != nil{
            self.sellAreaIcon.image = UIImage(named: "area")
        }
    
        
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

