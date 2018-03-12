//
//  WXCollectionViewCell.swift
//  PhotoPicker
//
//  Created by wxj on 2017/12/7.
//  Copyright © 2017年 wxj. All rights reserved.
//

import UIKit

class WXCollectionViewCell: UICollectionViewCell {
    
    var thumbnailImageView: UIImageView?
    var selectBtn:          UIButton?
    var index_path :        NSIndexPath?
    typealias selectBlock = (_ index : NSIndexPath,_ isSelected : Bool) -> Void
    var selectImageWithIndex:selectBlock?
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        self.setUpSubViews()
    }
    
    func setUpSubViews() {
        
        thumbnailImageView = UIImageView(frame: self.bounds)
        thumbnailImageView?.backgroundColor = .clear
        thumbnailImageView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(thumbnailImageView!)
        
        selectBtn = UIButton(type: .custom)
        selectBtn?.backgroundColor = .clear
        selectBtn?.translatesAutoresizingMaskIntoConstraints = false
        selectBtn?.setBackgroundImage(UIImage(named: "photo_def_previewVc"), for: .normal)
        selectBtn?.setBackgroundImage(UIImage(named: "preview_number_icon"), for: .selected)
        selectBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 12.0)
        selectBtn?.setTitleColor(.white, for: .selected)
        selectBtn?.setTitle("", for: .normal)
        selectBtn?.addTarget(self, action: #selector(didSelectImage), for: .touchUpInside)
        self.addSubview(selectBtn!)
        
        let imageViewLayout = ["thumbnailImageView": thumbnailImageView as Any]
        let imgHorizonalConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|[thumbnailImageView]|", options: [], metrics: nil, views: imageViewLayout)
        let imgVerticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[thumbnailImageView]|", options: [], metrics: nil, views: imageViewLayout)
        
        self.addConstraints(imgHorizonalConstraint)
        self.addConstraints(imgVerticalConstraint)
        
        let btnViewLayout = ["selectBtn": selectBtn as Any]
        
        let btnHorizonalConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:[selectBtn(28)]-2-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnViewLayout)
        let btnVerticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-2-[selectBtn(28)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: btnViewLayout)
        
        self.addConstraints(btnHorizonalConstraint)
        self.addConstraints(btnVerticalConstraint)
        
    }
    
    @objc func didSelectImage() {
        
        self.selectBtn?.isSelected = !(self.selectBtn?.isSelected)!
        
        if self.selectImageWithIndex != nil {
           self.selectImageWithIndex!((self.index_path)!,(self.selectBtn?.isSelected)!)
        }
    
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
