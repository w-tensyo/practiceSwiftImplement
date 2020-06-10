//
//  ViewController.swift
//  okashiToriko
//
//  Created by 渡邉天彰 on 2020/05/29.
//  Copyright © 2020 takaaki watanabe. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate, UITextFieldDelegate, XMLParserDelegate {

    @IBOutlet weak var sortSelectButtonLabel: UIBarButtonItem!
    
    @IBOutlet weak var serchIcon: UIImageView!
    var commentStringArray = [String]()
    //XMLParserのインスタンスを作成する
    var parser = XMLParser()
    //RSSのパース中の現在の要素名
    var currentElementname:String!
    var okashiItems = [OkashiItems]()
    @IBOutlet weak var okashiTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var hiddenMaskView: UIView!
    @IBOutlet weak var resultZeroView: UIView!
    
    //リクエスト時にアイテムソート順を指定するための変数を用意
    //初期値は古い順で呼びたいので、aに設定
    var sortItemSelecter:String = "a"
    
    //ローディング中に表示するActiveIndicatoreViewを定義
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //navigationbar右側のボタンの初期表示を指定
        
        sortSelectButtonLabel.title = "古い順"
        
        //serchIconをタップ可能にする
        serchIcon.isUserInteractionEnabled = true
        
        hiddenMaskView.isHidden = true
        // 表示位置を設定（画面中央）
        indicator.center = view.center
        // インジケーターのスタイルを指定（白色＆大きいサイズ）
        indicator.style = .large
        // インジケーターの色を設定（青色）
        indicator.color = UIColor(red: 44/255, green: 169/255, blue: 225/255, alpha: 1)
        
        resultZeroView.isHidden = true
        indicator.isHidden = true
        // インジケーターを View に追加
        
        view.addSubview(indicator)
        startIndicator()
        //XMLパース
        let urlString = "https://www.sysbird.jp/webapi/?apikey=guest&keyword=fo&max=2&order=a"
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
        okashiSearch()

        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 185
    }
    
    //表示したいセルの数。
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print(okashiItems.count)
        if okashiItems.count == 0{
            alertView(titleString: "検索結果が0件です")
            resultZeroView.isHidden = false
        }else{
            resultZeroView.isHidden = true
        }
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
                //comment内に<p><br>タグなどが混在しているため、それらを取り除くための処理
                if string == "<" || string == "p"{
                    
                }else if string == ">" || string == "br"{
                    
                }else if string == "/p"{

                }else{
                    //不要なタグ単位で分離してしまうcommentタグを一つにつなげる
                    //commentStringArray配列に、分裂したcomment一つ一つをappendする
                    commentStringArray.append(string)
                }

            case "area":
                lastItem.okashiArea = string
            default :break
            
            }

        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        //検索結果が0件だった場合を考慮して、条件分岐でハンドリング
        if self.okashiItems.count != 0{
            //分裂したcommentを格納している配列、commentStringArrayをjoinedメソッドで結合。一つのString変数に格納
            let joinedComment = commentStringArray.joined()
            let lastItem = self.okashiItems[self.okashiItems.count - 1]
            lastItem.okashiComment = joinedComment
            self.currentElementname = nil
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        self.okashiTableView.reloadData()
    }
    
    //セルをタップした時のアクションを実装
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //detailVCに遷移先のviewControllerを定義
        let detailVC = self.storyboard?.instantiateViewController(withIdentifier:  "DetailVC") as! DetailViewController
        
        //navigationControllerを継承しているので、この方法で画面遷移（つまりSegueを使わない）
        self.navigationController?.pushViewController(detailVC, animated: true)
        
        //タップした配列の番号を管理するindexPath.rowをindexNumber変数に代入
        //※長端になるのを阻止
        let indexNumber = indexPath.row
    
        
        detailVC.nameString = okashiItems[indexNumber].okashiName!
        detailVC.makerString =
            okashiItems[indexNumber].okashiMaker!
        
        //DetailViewController内で、地域限定の場合に固定文言を表示したい。
        //そのために、okashiAreaの中身がnilでなければ
        if okashiItems[indexNumber].okashiArea != nil{
            detailVC.sellArea = Bool(true)
        }else{
            detailVC.sellArea = Bool(false)
        }
        if okashiItems[indexNumber].okashiPrice == nil{
            detailVC.price = "---"
        }else{
            detailVC.price = okashiItems[indexNumber].okashiPrice!
        }
        detailVC.commentString = okashiItems[indexNumber].okashiComment!
        if okashiItems[indexNumber].okashiImage != nil{
            detailVC.image = okashiItems[indexNumber].okashiImage!
        }else{
            detailVC.image = "noimage"
        }
        
    
        
    }


    func startIndicator(){
        indicator.isHidden = false
        hiddenMaskView.isHidden = false
        indicator.startAnimating()
    }
    
    func stopIndicator(){
        indicator.stopAnimating()
        indicator.isHidden = true
        hiddenMaskView.isHidden = true
    }
    
    func alertView(titleString: String){
        
        let alert = UIAlertController(title: titleString, message: nil, preferredStyle: .alert)
        
        let cancel = UIAlertAction(title: "閉じる", style: .cancel, handler: nil)
        
        alert.addAction(cancel)
        
        present(alert,animated: true,completion: nil)
    }
    
    
    //serachIconをタップしても検索できるようにする
    @IBAction func serchButton(_ sender: Any) {
        okashiSearch()
    }
    
    //キーボードとアイコンから検索ができるように実装するため、
    //検索処理をメソッドで一つにまとめる
    func okashiSearch(){
        if searchTextField.text == ""{
            alertView(titleString: "文字を入力してください")
        }else{
        
            startIndicator()
            okashiItems.removeAll()
        
            if indicator.isAnimating == true{
            }
            let entryKeyWord = searchTextField.text!
            let encodeEntryKeyWord: String = entryKeyWord.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let urlString = "https://www.sysbird.jp/webapi/?apikey=guest&keyword=\(encodeEntryKeyWord)&max=20&order=\(sortItemSelecter)"
            print("今のURLは:\(urlString)")
        
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
            }
        searchTextField.endEditing(true)
    }


    //ソート順を指定するためのnavigationItemのボタン
    @IBAction func sortSelectButton(_ sender: Any) {
        if sortSelectButtonLabel.title == "古い順" {
            sortItemSelecter = "r"
            sortSelectButtonLabel.title = "ランダム"
        }else if sortSelectButtonLabel.title == "ランダム"{
            sortItemSelecter = "d"
            sortSelectButtonLabel.title = "新しい順"
        }else if sortSelectButtonLabel.title == "新しい順"{
            sortItemSelecter = "a"
            sortSelectButtonLabel.title = "古い順"
        }
    }
}

