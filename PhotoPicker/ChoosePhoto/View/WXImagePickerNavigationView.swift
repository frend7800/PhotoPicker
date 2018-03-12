//
//  WXImagePickerNavigationView.swift
//  PhotoPicker
//
//  Created by 魏新杰 on 2018/3/11.
//  Copyright © 2018年 wxj. All rights reserved.
//

import UIKit

protocol ImagePickerNavigationViewDelegate : NSObjectProtocol {
    
    func goBack(_ navigationView : WXImagePickerNavigationView)
    
    func selectedImage(_ navigationView : WXImagePickerNavigationView)
    
}

class WXImagePickerNavigationView: UIView {

    var backButton        : UIButton?
    var selectButton      : UIButton?
    var delegate          : ImagePickerNavigationViewDelegate?
    var selectState       : Bool?
    var isSelected        : Bool{
        
        set{
            selectState = newValue
            if newValue {
                
                selectButton?.setImage(UIImage(named: "preview_number_icon"), for: .normal)
            }else{
                
               selectButton?.setImage(UIImage(named: "photo_def_previewVc"), for: .normal)
            }
            
        }
        get{
            
            return selectState!
        }
        
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.createSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createSubViews(){
        
        backButton = UIButton(type: .custom)
        backButton?.backgroundColor = .clear
        backButton?.setImage(UIImage(named: "back"), for: .normal)
        backButton?.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        backButton?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(backButton!)
        
        selectButton = UIButton(type: .custom)
        selectButton?.backgroundColor = .clear
        selectButton?.setImage(UIImage(named: "photo_def_previewVc"), for: .normal)
        selectButton?.addTarget(self, action: #selector(selectButtonClick), for: .touchUpInside)
        selectButton?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(selectButton!)
        
        let subviewsConstraint = ["leftBtn": self.backButton as Any,"rightBtn": self.selectButton as Any]
        
        let backBtnHorConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[leftBtn(30)]",
                                                                    options: [], metrics: nil,
                                                                    views: subviewsConstraint)
        let backBtnVerConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[leftBtn]-15-|",
                                                                   options: [], metrics: nil,
                                                                   views: subviewsConstraint)
        
        let selectBtnHorConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:[rightBtn(30)]-15-|",
                                                                      options: [], metrics: nil,
                                                                      views: subviewsConstraint)
        let selectBtnVerConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-15-[rightBtn]-15-|",
                                                                     options: [], metrics: nil,
                                                                     views: subviewsConstraint)
      
        
        self.addConstraints(backBtnHorConstraint)
        self.addConstraints(backBtnVerConstraint)
        
        self.addConstraints(selectBtnHorConstraint)
        self.addConstraints(selectBtnVerConstraint)
        
    }
    
    @objc func backButtonClick()
    {
        self.delegate?.goBack(self)
    }
    
    @objc func selectButtonClick()
    {
        self.delegate?.selectedImage(self)
    }
    

}
