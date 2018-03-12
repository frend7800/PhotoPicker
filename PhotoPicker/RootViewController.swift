//
//  RootViewController.swift
//  PhotoPicker
//
//  Created by wxj on 2017/12/7.
//  Copyright © 2017年 wxj. All rights reserved.
//

import UIKit

class RootViewController: UIViewController,UITextViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .white
        
        let button = UIButton(type: .custom)
        button.setTitle("选择照片", for: .normal)
        button.backgroundColor =  .red;
        button.frame = CGRect(x: 100, y: 200, width: 100, height: 60)
        button.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        self.view.addSubview(button)
        
    
        
    }
    

    @objc func buttonClick() {
        
        let  imagePickerVc = WXImagePickerController()
        let  nav = UINavigationController(rootViewController: imagePickerVc)
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
