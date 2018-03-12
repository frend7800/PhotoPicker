//
//  WXImagePickerBottomView.swift
//  PhotoPicker
//
//  Created by 魏新杰 on 2018/3/10.
//  Copyright © 2018年 wxj. All rights reserved.
//

import UIKit

@objc
protocol ImagePickerBottomVieDelegate : NSObjectProtocol {
    
     @objc optional   func previewSelectImages(_ pickerBottomView : WXImagePickerBottomView)
   
     @objc optional  func editSelectImages(_ pickerBottomView : WXImagePickerBottomView)
    
     func selectTheImageQualityType (_ pickerBottomView : WXImagePickerBottomView,_ isHigh : Bool)
    
     func sendSelectedImages(_ pickerBottomView : WXImagePickerBottomView)
}

class WXImagePickerBottomView: UIView,UIScrollViewDelegate {

    private var bottomSelectView :     UIView?
    private var sendButton :           UIButton?
    private var originImageButton :    UIButton?
    private var previewBtn :           UIButton?
    private var scrollView:            UIScrollView?
    private var canEdit:               Bool = false
    var selectOriginalImage :          Bool = false
    var count :                        Int?
    var selectCount :                  Int
    {
        set{
           count = newValue
            print("-----------\(newValue)")
            if newValue > 0 {
                let str : String = "发送" + "(\(String(describing: newValue)))"
                self.sendButton?.setTitle(str, for: .normal)
                self.previewBtn?.setTitleColor(UIColor.white, for: .normal)
                self.previewBtn?.isUserInteractionEnabled = true
            }else
            {
                self.sendButton?.setTitle("发送", for: .normal)
                self.previewBtn?.setTitleColor(UIColor.lightGray, for: .normal)
                self.previewBtn?.isUserInteractionEnabled = false
            }
        }
        
        get{
          return count!
        }
        
    }
    
    
    var delegate : ImagePickerBottomVieDelegate?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, existImages :Bool)
    {
        super.init(frame: frame)
        //self.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
        self.setupBottomView()
        if existImages {
            self.canEdit = true
            self.createsSelectImagesthumb()
            self.previewBtn?.setTitle("编辑", for: .normal)
        }
    
    }
    
    
    func setupBottomView() {
        bottomSelectView = UIView();
       // bottomSelectView?.backgroundColor = UIColor(red: 40/255.0, green: 45/255.0, blue: 55/255.0, alpha: 1.0)
        bottomSelectView?.backgroundColor = .clear
        bottomSelectView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(bottomSelectView!)
        
        let bottomViewConstraint = ["bottomSelectView": bottomSelectView as Any]
        
        let bottomViewHorConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomSelectView]|",
                                                                      options: [], metrics: nil,
                                                                      views: bottomViewConstraint)
        let bottomViewVerConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomSelectView(44)]|",
                                                                     options: [], metrics: nil,
                                                                     views: bottomViewConstraint)
        
        self.addConstraints(bottomViewHorConstraint)
        self.addConstraints(bottomViewVerConstraint)
        
        previewBtn = UIButton(type: .custom)
        previewBtn?.backgroundColor = .clear
        previewBtn?.setTitle("预览", for: .normal)
        previewBtn?.setTitleColor(UIColor.lightGray, for: .normal)
        previewBtn?.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        previewBtn?.addTarget(self, action: #selector(clickToPreviewImage), for: .touchUpInside)
        previewBtn?.translatesAutoresizingMaskIntoConstraints = false
        previewBtn?.isUserInteractionEnabled = false
        bottomSelectView?.addSubview(previewBtn!)
        
        originImageButton = UIButton(type: .custom)
        originImageButton?.backgroundColor = .clear
        originImageButton?.setTitle("原图", for: .normal)
        originImageButton?.setTitleColor(.white, for: .normal)
        originImageButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        originImageButton?.setImage(UIImage(named: "photo_original_def"), for: .normal)
        originImageButton?.addTarget(self, action: #selector(selectTheImageQuality), for: .touchUpInside)
        originImageButton?.translatesAutoresizingMaskIntoConstraints = false
        bottomSelectView?.addSubview(originImageButton!)
        
        sendButton = UIButton(type: .custom)
        sendButton?.backgroundColor = UIColor(red: 26/255.0, green: 170/255.0, blue: 26/255.0, alpha: 1.0)
        sendButton?.setTitle("发送", for: .normal)
        sendButton?.setTitleColor(.white, for: .normal)
        sendButton?.titleLabel?.font = UIFont.systemFont(ofSize: 14.0)
        sendButton?.layer.cornerRadius = 5.0;
        sendButton?.layer.masksToBounds = true
        sendButton?.addTarget(self, action: #selector(clickToSendSelectedImages), for: .touchUpInside)
        sendButton?.translatesAutoresizingMaskIntoConstraints = false
        bottomSelectView?.addSubview(sendButton!)
        
        
        let subviewsConstraint = ["leftView": previewBtn as Any,"centerView": originImageButton as Any,"rightView": sendButton as Any]
        
        let leftViewHorConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[leftView(60)]",
                                                                    options: [], metrics: nil,
                                                                    views: subviewsConstraint)
        let leftViewVerConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[leftView]-10-|",
                                                                   options: [], metrics: nil,
                                                                   views: subviewsConstraint)
        
        let centerViewHorConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:[centerView(80)]",
                                                                      options: [], metrics: nil,
                                                                      views: subviewsConstraint)
        let centerViewVerConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[centerView]-10-|",
                                                                     options: [], metrics: nil,
                                                                     views: subviewsConstraint)
        let centerViewCenterConstraint = NSLayoutConstraint.init(item: originImageButton!,
                                                                 attribute: NSLayoutAttribute.centerX,
                                                                 relatedBy: NSLayoutRelation.equal,
                                                                 toItem: bottomSelectView!,
                                                                 attribute: NSLayoutAttribute.centerX,
                                                                 multiplier: 1.0, constant: 0)
        
        let rightViewHorConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:[rightView(60)]-10-|",
                                                                     options: [], metrics: nil,
                                                                     views: subviewsConstraint)
        let rightViewVerConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-8-[rightView]-8-|",
                                                                    options: [], metrics: nil,
                                                                    views: subviewsConstraint)
        
        bottomSelectView?.addConstraints(leftViewHorConstraint)
        bottomSelectView?.addConstraints(leftViewVerConstraint)
        
        bottomSelectView?.addConstraints(centerViewHorConstraint)
        bottomSelectView?.addConstraints(centerViewVerConstraint)
        bottomSelectView?.addConstraint(centerViewCenterConstraint)
        
        bottomSelectView?.addConstraints(rightViewHorConstraint)
        bottomSelectView?.addConstraints(rightViewVerConstraint)
        
    }
    
    func createsSelectImagesthumb()
    {
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor(white: 0.0, alpha: 0.1)
        lineView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lineView)
        
        scrollView = UIScrollView()
        scrollView?.backgroundColor = .clear
        scrollView?.bounces = false
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.delegate = self
        scrollView?.alwaysBounceHorizontal = true
        scrollView?.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(scrollView!)
        
        
        let scrollConstraint = ["lineView": lineView as Any,"scrollView": scrollView as Any]
        
        let lineViewHConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|",
                                                                    options: [], metrics: nil,
                                                                    views: scrollConstraint)
        let lineViewVConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(0.5)]-44-|",
                                                                   options: [], metrics: nil,
                                                                   views: scrollConstraint)
        
        let scrollViewHConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|[scrollView]|",
                                                                  options: [], metrics: nil,
                                                                  views: scrollConstraint)
        let scrollViewVConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[scrollView(80)]-44.5-|",
                                                                 options: [], metrics: nil,
                                                                 views: scrollConstraint)
        self.addConstraints(lineViewHConstraint)
        self.addConstraints(lineViewVConstraint)
        self.addConstraints(scrollViewHConstraint)
        self.addConstraints(scrollViewVConstraint)
    }
    
    /*
     *选择的图片预览
     */
    @objc func clickToPreviewImage()
    {
       
        
        if self.canEdit {
            
            self.delegate?.editSelectImages!(self)
        }else{
        
            self.delegate?.previewSelectImages!(self)
        }
    }
    /*
     *选择的图片质量(原图)
     */
    @objc func selectTheImageQuality()
    {
        self.selectOriginalImage = !self.selectOriginalImage;
        if self.selectOriginalImage {
            self.originImageButton?.setImage(UIImage(named: "photo_original_sel"), for: .normal)
        }else{
            self.originImageButton?.setImage(UIImage(named: "photo_original_def"), for: .normal)
        }
        self.delegate?.selectTheImageQualityType(self, self.selectOriginalImage)
    }
    
    /*
     *发送选择的图片
     */
    @objc func clickToSendSelectedImages()
    {
        self.delegate?.sendSelectedImages(self)
    }
    
    
}
