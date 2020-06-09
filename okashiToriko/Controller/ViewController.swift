//
//  ViewController.swift
//  okashiToriko
//
//  Created by 渡邉天彰 on 2020/05/29.
//  Copyright © 2020 takaaki watanabe. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, XMLParserDelegate {
    
    //画面遷移で値を渡すための変数を用意
    var name:String = ""
    var maker:String = ""
    var sellArea:String = ""
    var price:String = ""
    var comment:String = ""
    var image:String = ""
    
    var commentStringArray = [String]()
    //XMLParserのインスタンスを作成する
    var parser = XMLParser()
    //RSSのパース中の現在の要素名
    var currentElementname:String!
    var okashiItems = [OkashiItems]()
    @IBOutlet weak var okashiTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var hiddenMaskView: UIView!
    //ローディング中に表示するActiveIndicatoreViewを定義
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hiddenMaskView.isHidden = true
        // 表示位置を設定（画面中央）
        indicator.center = view.center
        // インジケーターのスタイルを指定（白色＆大きいサイズ）
        indicator.style = .large
        // インジケーターの色を設定（青色）
        indicator.color = UIColor(red: 44/255, green: 169/255, blue: 225/255, alpha: 1)
        
        indicator.isHidden = true
        // インジケーターを View に追加
        
        view.addSubview(indicator)
        startIndicator()
        //XMLパース
        let urlString = "https://www.sysbird.jp/webapi/?apikey=guest&keyword=fo&max=2&order=r"
        let url:URL = URL(string: urlString)!
        
        
        parser = XMLParser(contentsOf: url)!
        parser.delegate = self
        parser.parse()
        
        //SearchTextFieldのデリゲートメソッドを有効にする
        searchTextField.delegate = self
        
        
        //OkashiTableViewにprotocolを充てる
        okashiTableView.delegate = self
        okashiTableView.dataSource = self
        /*OkashiTableViewにOkashiTableViewCellを紐づける
        UINibには、CustomCellと紐づいたSwiftファイル名
        forCellReuseIdentifierは再利用で使うcellを指定している。今回は、使いたいOkashiTableViewCell.xibのIdentifier名を記入。*/
        okashiTableView.register(UINib(nibName: "OkashiTableViewCell", bundle: nil), forCellReuseIdentifier: "okashiTableViewCell")
        
        stopIndicator()
    }
    //キーボードの「検索」ボタンをタップした時の処理
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        startIndicator()
        okashiItems.removeAll()
        
        if indicator.isAnimating == true{
            print("インジケータ動いているはずですよ")
        }
        print("1個目のprint\(Date())")
        let entryKeyWord = searchTextField.text!
        let encodeEntryKeyWord: String = entryKeyWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlString = "https://www.sysbird.jp/webapi/?apikey=guest&keyword=\(encodeEntryKeyWord)&max=20&order=r"
        
        let url:URL = URL(string: urlString)!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            let parser: XMLParser? = XMLParser(data: data!)
            DispatchQueue.main.sync {
                parser!.delegate = self
                parser!.parse()
                self.stopIndicator()
            }
        })
        //タスク開始
        task.resume()
        searchTextField.endEditing(true)
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185
    }
    
    //表示したいセルの数。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return okashiItems.count
    }
    
    //セルの表示内容を形成する処理。
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //okashiTableViewCellを定数cellに入れる
        let cell = tableView.dequeueReusableCell(withIdentifier: "okashiTableViewCell", for: indexPath) as! OkashiTableViewCell
        
        cell.setContent(okashiItems: okashiItems[indexPath.row])
        
        return cell
    }

    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElementname = nil
    
    
        if elementName == "item"{
            commentStringArray.removeAll()
            self.okashiItems.append(OkashiItems())
        }else{
            currentElementname = elementName
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if self.okashiItems.count > 0 {
            
            let lastItem = self.okashiItems[self.okashiItems.count - 1]
            
            switch self.currentElementname{
            case "name":
                lastItem.okashiName = string
            case "maker":
                lastItem.okashiMaker = string
            case "price":
                lastItem.okashiPrice = string
            case "image":
                lastItem.okashiImage = string
            case "comment":
                if string == "<" || string == "p"{
                    
                }else if string == ">" || string == "br"{
                    
                }else if string == "/p"{

                }else{
                    commentStringArray.append(string)
                }

            case "area":
                lastItem.okashiArea = string
            default :break
            
            }

        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let joinedComment = commentStringArray.joined()
        let lastItem = self.okashiItems[self.okashiItems.count - 1]
        lastItem.okashiComment = joinedComment

        
        
        self.currentElementname = nil
        
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.okashiTableView.reloadData()
    }
    
    //セルをタップした時のアクションを実装
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexNumber = indexPath.row
        
        name = okashiItems[indexNumber].okashiName!
        maker = okashiItems[indexNumber].okashiMaker!
        if okashiItems[indexNumber].okashiArea != nil{
            sellArea = "1"
        }else{
            sellArea = "0"
        }
        if okashiItems[indexNumber].okashiPrice == nil{
            price = "---"
        }else{
            price = okashiItems[indexNumber].okashiPrice!
        }
        comment = okashiItems[indexNumber].okashiComment!
        image = okashiItems[indexNumber].okashiImage!
        
        print(sellArea)
        //画面遷移
        self.performSegue(withIdentifier: "detailOkashiSegue", sender: self)
        //タップしたセルの角パラメータをUserDefaultsに一時的に格納
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailOkashiSegue"{
            let detailOkashiVC = segue.destination as! DetailViewController
            detailOkashiVC.nameString = name
            detailOkashiVC.makerString = maker
            detailOkashiVC.price = price
            detailOkashiVC.commentString = comment
            detailOkashiVC.image = image
            detailOkashiVC.sellArea = sellArea
        }
    }

    func startIndicator(){
        indicator.isHidden = false
        hiddenMaskView.isHidden = false
        indicator.startAnimating()

        print("インジケータ表示開始")
    }
    
    func stopIndicator(){
        indicator.stopAnimating()
        indicator.isHidden = true
        hiddenMaskView.isHidden = true
        print("インジケータ表示終了！")
    }
}

