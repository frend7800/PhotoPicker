//
//  WXImagePreviewController.swift
//  PhotoPicker
//
//  Created by wxj on 2017/12/8.
//  Copyright © 2017年 wxj. All rights reserved.
//

import UIKit
import Photos

class WXImagePreviewController: UIViewController,UIScrollViewDelegate,ImagePickerBottomVieDelegate,ImagePickerNavigationViewDelegate {

    var scrollView :          UIScrollView?
    var assetPhotoList :      PHFetchResult<PHAsset>?
    var imageManager :        PHImageManager?
    var imageRequestOption :  PHImageRequestOptions?
    var selectImages :        NSMutableArray?
    var currentIndex :        Int!
    var bottomView :          WXImagePickerBottomView?
    var navigationView :      WXImagePickerNavigationView?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    //隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //self.title = "照片预览"
        self.view.backgroundColor = .black
        self.setUpImageManager()
        self.setUpSubViews()
        self.createNavigationView()
        self.createBottomBarView()
        // Do any additional setup after loading the view.
       
    }

    func setUpImageManager() {
        // 新建一个默认类型的图像管理器imageManager
        imageManager = PHImageManager.default()
        
        // 新建一个PHImageRequestOptions对象
        imageRequestOption = PHImageRequestOptions()
        
        // PHImageRequestOptions是否有效
        imageRequestOption?.isSynchronous = true
        
        // 缩略图的压缩模式设置为无
        imageRequestOption?.resizeMode = .none
        // 缩略图的质量
        imageRequestOption?.deliveryMode = .highQualityFormat
    }
    
    func setUpSubViews(){
        
        scrollView = UIScrollView()
        scrollView?.frame = CGRect(x: -10, y:0, width: ScreenWidth + 10, height: ScreenHeight)
        scrollView?.backgroundColor = .clear
        scrollView?.isPagingEnabled = true
        scrollView?.bounces = false
        scrollView?.showsVerticalScrollIndicator = false
        scrollView?.showsHorizontalScrollIndicator = false
        scrollView?.delegate = self
        scrollView?.alwaysBounceHorizontal = true
        self.view.addSubview(scrollView!)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(scrollViewClick))
        scrollView?.addGestureRecognizer(gesture)
        
        if self.selectImages != nil {
            scrollView?.contentSize = CGSize(width: (ScreenWidth + 10) * CGFloat((self.selectImages?.count)!), height: ScreenHeight)
            self.loadSelectedImages()
        }else
        {
            scrollView?.contentSize = CGSize(width: (ScreenWidth + 10) * CGFloat((self.assetPhotoList?.count)!), height: ScreenHeight)
           self.loadPhotoAlbumImages()
        }
        
    
        scrollView?.setContentOffset(CGPoint(x: Int(ScreenWidth + 10) * self.currentIndex, y: 0), animated: false)

    }
    
    func createNavigationView() {
        
        navigationView = WXImagePickerNavigationView(frame: .zero)
        navigationView?.backgroundColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
        navigationView?.translatesAutoresizingMaskIntoConstraints = false
        navigationView?.delegate = self
        navigationView?.isHidden = false
        self.view.addSubview(navigationView!)
        
        let viewsLayoutConstraint = ["navigationView": navigationView as Any]
        
        let horizonalConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|[navigationView]|",
                                                                  options: [], metrics: nil,
                                                                  views: viewsLayoutConstraint)
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|[navigationView(60)]",
                                                                options: [], metrics: nil,
                                                                views: viewsLayoutConstraint)
        
        self.view.addConstraints(horizonalConstraint)
        self.view.addConstraints(verticalConstraint)
    }
    
    func createBottomBarView()
    {
        bottomView = WXImagePickerBottomView(frame: .zero, existImages: true)
        bottomView?.backgroundColor = UIColor(red: 33/255.0, green: 33/255.0, blue: 33/255.0, alpha: 1.0)
        bottomView?.translatesAutoresizingMaskIntoConstraints = false
        bottomView?.delegate = self
        bottomView?.isHidden = false
        self.view.addSubview(bottomView!)
        
        let viewsLayoutConstraint = ["bottomView": bottomView as Any]
        
        let horizonalConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|[bottomView]|",
                                                                  options: [], metrics: nil,
                                                                  views: viewsLayoutConstraint)
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[bottomView(44)]|",
                                                                options: [], metrics: nil,
                                                                views: viewsLayoutConstraint)
        
        self.view.addConstraints(horizonalConstraint)
        self.view.addConstraints(verticalConstraint)
        
    }
    
    func loadPhotoAlbumImages()
    {
        for index in 0...Int((self.assetPhotoList?.count)! - 1) {
            autoreleasepool {
                let backView = UIView(frame: CGRect(x: (ScreenWidth + 10) * CGFloat(index), y: 0, width: ScreenWidth + 10, height: ScreenHeight))
                backView.backgroundColor = .clear
                scrollView?.addSubview(backView)
                
                let imageView = UIImageView()
                imageView.frame = CGRect(x: 10, y: 0, width: ScreenWidth, height: ScreenHeight)
                imageView.backgroundColor = .clear
                
                let asset = self.assetPhotoList![index] as PHAsset
                let image = self.getHighQualityImageWithPHAsset(asset)
                imageView.image = image
                imageView.contentMode = .scaleAspectFit
                imageView.tag = 100 + index
                backView.addSubview(imageView)
                
            }
        }
        
    }
    
    func loadSelectedImages()
    {
        for index in 0...Int((self.selectImages?.count)! - 1) {
            autoreleasepool {
                let backView = UIView(frame: CGRect(x: (ScreenWidth + 10) * CGFloat(index), y: 0, width: ScreenWidth + 10, height: ScreenHeight))
                backView.backgroundColor = .clear
                scrollView?.addSubview(backView)
                
                let imageView = UIImageView()
                imageView.frame = CGRect(x: 10, y: 0, width: ScreenWidth, height: ScreenHeight)
                imageView.backgroundColor = .clear
                
                let asset = self.selectImages?[index] as! PHAsset
                let image = self.getHighQualityImageWithPHAsset(asset)
                imageView.image = image
                imageView.contentMode = .scaleAspectFit
                imageView.tag = 100 + index
                backView.addSubview(imageView)
                
            }
        }
    }
    
    func getHighQualityImageWithPHAsset(_ asset: PHAsset) -> UIImage
    {
        var photoImage : UIImage?
        self.imageManager?.requestImage(for: asset, targetSize: self.view.bounds.size, contentMode: .aspectFit, options: self.imageRequestOption, resultHandler: {
            (result, _) -> Void in
            photoImage = result
        })
        return photoImage!
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offset = scrollView.contentOffset
        if offset.x <= 0 {
            offset.x = 0
            scrollView.contentOffset = offset
        }
        
        currentIndex = Int(roundf(Float(offset.x / (ScreenWidth + 10))))
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
          self.scrollView?.setContentOffset(CGPoint(x: Int(ScreenWidth + 10) * self.currentIndex, y: 0), animated: false)
        
    }
    
   @objc func scrollViewClick() {
        
        //self.dismiss(animated: true, completion: nil)
       self.bottomView!.isHidden = !self.bottomView!.isHidden
       self.navigationView?.isHidden = !self.navigationView!.isHidden
    
    }
    
    // MARK:ImagePickerBottomVieDelegate
    
    //图片编辑
    func editSelectImages(_ pickerBottomView : WXImagePickerBottomView)
    {
        print("editSelectImages")
    }
    
    //图片原图选择
    func selectTheImageQualityType (_ pickerBottomView : WXImagePickerBottomView,_ isHigh : Bool)
    {
        print("selectTheImageQualityType")
    }
    
    //图片发送
    func sendSelectedImages(_ pickerBottomView : WXImagePickerBottomView)
    {
        print("sendSelectedImages")
        
    }
    
    //MARK: ImagePickerNavigationViewDelegate
    func goBack(_ navigationView: WXImagePickerNavigationView) {
       
        self.navigationController?.popViewController(animated: true)
    }
    
    func selectedImage(_ navigationView: WXImagePickerNavigationView) {
        
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
