//
//  ViewController.swift
//  JustTest
//
//  Created by 王波 on 2018/6/11.
//  Copyright © 2018年 wangbo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var dataArr = [CellModel]()
    var imageDic = [String:Data]()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "首页"
        requestData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}

extension ViewController{
    func gotoVCA() {
        let vc = ControllerA()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func gotoVCB() {
        let vc = ControllerB()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func requestData(){
        let url = URL(string: "http://static.youshikoudai.com/mockapi/data")
        
        let request = URLRequest(url: url!)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil,data != nil {
                let arr = try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                print(arr ?? "empty")
                if let a = arr as? Array<Dictionary<String, String>> {
                    self.dealDataArr(arr: a)
                }
            }
        }
        
        task.resume()
    }
    
    func dealDataArr(arr:Array<Dictionary<String, String>>){
        var newArr = [CellModel]()
        for dic in arr{
            let model = CellModel()
            if let url = dic["image"]{
                model.imageUrl = url
            }
            if let t = dic["text"]{
                model.title = t
            }
            newArr.append(model)
        }
        self.dataArr = newArr
        DispatchQueue.main.async{
            self.tableView.reloadData()
        }
    }
}

extension ViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "tablecell") as! tableCell
        if dataArr.count > indexPath.row{
            let model = dataArr[indexPath.row]
            cell.setModel(model: model)
        }
        
        cell.touchABlock = {[weak self] in
            self?.gotoVCA()
        }
        cell.touchBBlock = {[weak self] in
            self?.gotoVCB()
        }
        return cell
        
    }
}

class tableCell: UITableViewCell {
    
    static let reuseID = "tablecell"
    @IBOutlet weak var imageV: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var touchABlock:(()->Void)?
    var touchBBlock:(()->Void)?
    
    @IBAction func touchA(_ sender: UIButton) {
        if touchABlock != nil {
            touchABlock!()
        }else{
            print("没有实现A的点击事件")
        }
    }
    
    @IBAction func touchB(_ sender: UIButton) {
        if touchBBlock != nil {
            touchBBlock!()
        }else{
            print("没有实现B的点击事件")
        }
    }
    
    func setModel(model:CellModel) {
        if let t = model.title {
            label.text = t
        }
        
        if let i = model.imageUrl {
            DispatchQueue(label: "test").async {
                //这里应该做缓存的。。。
                if  let data = NSData(contentsOf: URL(string: i)!){
                    let image = UIImage(data: data as Data)
                    DispatchQueue.main.async{
                        self.imageV.image = image
                    }
                }
            }
          
        }
    }
}

class CellModel: NSObject {
    var imageUrl:String?
    var title:String?
    
    init(title:String) {
        self.title = title
    }
    
    override init() {
        super.init()
    }
}

class ControllerA: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = UIColor.red
    }
}

class ControllerB: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = UIColor.blue
    }
}
