//
//  WxImagePickerController.swift
//  PhotoPicker
//
//  Created by wxj on 2017/12/7.
//  Copyright © 2017年 wxj. All rights reserved.
//

import UIKit
import Photos

let  minLineSpace : CGFloat = 3.0

let  ScreenWidth = UIScreen.main.bounds.size.width
let  ScreenHeight = UIScreen.main.bounds.size.height
let  Identifier  = "cell"

class WXImagePickerController: UIViewController,UICollectionViewDelegate,ImagePickerBottomVieDelegate,UICollectionViewDataSource,PHPhotoLibraryChangeObserver {
    
    private var collectionView :       UICollectionView?
    private var bottomView :           WXImagePickerBottomView?
    private var imageManager :         PHImageManager? //图像管理器
    private var imageRequestOption :   PHImageRequestOptions?
    private var selectOriginal       = false
    private var currentSelectArray :   NSMutableArray?
    private var currentSelectassetArray :   NSMutableArray?
    var assetList :                    PHFetchResult<PHAsset>?
    
    //计算图片排列的大小
    let itemSize = CGSize(width: (ScreenWidth - minLineSpace*5)/4.0, height: (ScreenWidth - minLineSpace*5)/4.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "所有照片"
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 30/255.0, green: 30/255.0, blue: 30/255.0, alpha: 0.5)
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        self.view.backgroundColor = .white
        // Do any additional setup after loading the view.
        self.getAllPhotos()
        self.setUpNavigationItems()
        self.setUpSubViews()
        self.setupBottomView()
        self.currentSelectArray = NSMutableArray()
        self.currentSelectassetArray = NSMutableArray()
    }
    
    func getAllPhotos(){
        
        PHPhotoLibrary.shared().register(self as PHPhotoLibraryChangeObserver)
        //  获取所有系统图片信息集合体
        let allOptions = PHFetchOptions()
        //  对内部元素排序，按照时间由远到近排序
        allOptions.sortDescriptors = [NSSortDescriptor.init(key: "creationDate", ascending: false)]
        //  将元素集合拆解开，此时 allResults 内部是一个个的PHAsset单元
        let allResults = PHAsset.fetchAssets(with: .image, options: allOptions)
        print(allResults.count)
        
        self.assetList = allResults
        
        // 新建一个默认类型的图像管理器imageManager
         imageManager = PHImageManager.default()
        
        // 新建一个PHImageRequestOptions对象
         imageRequestOption = PHImageRequestOptions()
        
        // PHImageRequestOptions是否有效
        imageRequestOption?.isSynchronous = true
        
        // 缩略图的压缩模式设置为无
        imageRequestOption?.resizeMode = .fast
        // 缩略图的质量
        imageRequestOption?.deliveryMode = .fastFormat//.highQualityFormat

    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        getAllPhotos()
    }
    
    //加载collectionView
    func setUpSubViews() {
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = minLineSpace
        layout.minimumInteritemSpacing = minLineSpace
        layout.itemSize = itemSize
        layout.sectionInset = UIEdgeInsetsMake(minLineSpace, minLineSpace, minLineSpace, minLineSpace)
        collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView?.backgroundColor = .white
        collectionView?.translatesAutoresizingMaskIntoConstraints = false
        collectionView?.delegate = self;
        collectionView?.dataSource = self;
        if #available(iOS 11.0, *) {
            collectionView?.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
        self.view.addSubview(collectionView!)
        
        collectionView?.register(WXCollectionViewCell.self, forCellWithReuseIdentifier: Identifier)
        
        let viewsLayoutConstraint = ["collectionView": collectionView as Any]
        
        let horizonalConstraint =  NSLayoutConstraint.constraints(withVisualFormat: "H:|[collectionView]|",
                                                                  options: [], metrics: nil,
                                                                  views: viewsLayoutConstraint)
        let verticalConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-64-[collectionView]-44-|",
                                                                options: [], metrics: nil,
                                                                views: viewsLayoutConstraint)
        
        self.view.addConstraints(horizonalConstraint)
        self.view.addConstraints(verticalConstraint)
    }
    
    //加载底部图片预览发送view
    func setupBottomView()
    {
        bottomView = WXImagePickerBottomView(frame: .zero, existImages: false)
        bottomView?.backgroundColor = UIColor(red: 40/255.0, green: 45/255.0, blue: 55/255.0, alpha: 1.0)
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
    //设置导航栏
    func setUpNavigationItems() {
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(goBack))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancelSelectImage))
    }
    
    //返回
    @objc func goBack() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //取消
    @objc func cancelSelectImage() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //Mark: TableviewDatasource
    func numberOfItems(inSection section: Int) -> Int{
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.assetList!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Identifier, for: indexPath) as! WXCollectionViewCell
        
        let asset = self.assetList![indexPath.row] as PHAsset
        let image = self.getImageWithPHAsset(asset)
        cell.thumbnailImageView?.image = image
        cell.index_path = indexPath as NSIndexPath
        cell.selectImageWithIndex = { (_ index : NSIndexPath,_ isSelected : Bool) -> Void in
            
            if isSelected{
                
                if !(self.currentSelectArray?.contains(index))!
                {
                    self.currentSelectArray?.add(index)
                    let assetObj = self.assetList![index.row] as PHAsset
                    self.currentSelectassetArray?.add(assetObj)
                }
                
            }else{
                if (self.currentSelectArray?.contains(index))!{
                    self.currentSelectArray?.remove(index)
                    let assetObj = self.assetList![index.row] as PHAsset
                    self.currentSelectassetArray?.remove(assetObj)
                }
            }
            self.bottomView?.selectCount = (self.currentSelectArray?.count)!
            
            if self.currentSelectArray!.count > 0 {
                for arrIndex in 0...(self.currentSelectArray!.count - 1)
                {
                    let index_path = self.currentSelectArray![arrIndex]

                    let selectCell = self.collectionView?.cellForItem(at: index_path as! IndexPath) as! WXCollectionViewCell
                    DispatchQueue.main.async {
                       selectCell.selectBtn?.setTitle("\(arrIndex + 1)", for: .selected)
                    }
                }

            }else{

            }
        }
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let previewVc = WXImagePreviewController()
        previewVc.assetPhotoList = self.assetList
        previewVc.currentIndex = indexPath.row
        self.navigationController?.pushViewController(previewVc, animated: true)
    }
    
    func getImageWithPHAsset(_ asset: PHAsset) -> UIImage
    {
        var photoImage : UIImage?
        imageRequestOption?.deliveryMode = .fastFormat
        self.imageManager?.requestImage(for: asset, targetSize: self.itemSize, contentMode: .aspectFill, options: self.imageRequestOption, resultHandler: {
            (result, _) -> Void in
            photoImage = result
        })
        return photoImage!
    }
    
    // MARK:ImagePickerBottomVieDelegate
    
    //图片预览
    func previewSelectImages(_ pickerBottomView : WXImagePickerBottomView)
    {
        print("previewSelectImages")
        let previewVc = WXImagePreviewController()
        previewVc.selectImages = self.currentSelectassetArray
        previewVc.currentIndex = 0
        self.navigationController?.pushViewController(previewVc, animated: true)
    }
        
    //图片原图选择
    func selectTheImageQualityType (_ pickerBottomView : WXImagePickerBottomView,_ isHigh : Bool)
    {
        print("selectTheImageQualityType")
        self.selectOriginal = isHigh
    }
    
    //图片发送
    func sendSelectedImages(_ pickerBottomView : WXImagePickerBottomView)
    {
        print("sendSelectedImages")
        
        let imagesArray = self.getHighQualityImageWithSelectImages()
        
        print(imagesArray)
        
    }
    
    //获取已选图片
    func getHighQualityImageWithSelectImages() -> NSMutableArray
    {


        if self.currentSelectArray!.count > 0 {

            let resultArray = NSMutableArray()
            self.imageRequestOption?.deliveryMode = self.selectOriginal ? .highQualityFormat : .fastFormat
            self.imageRequestOption?.resizeMode = self.selectOriginal ? .none : .fast
            for index in 0...(self.currentSelectArray!.count - 1) {
                autoreleasepool{
                    let indexPath = self.currentSelectArray![index] as! IndexPath
                    let asset = self.assetList![indexPath.row] as PHAsset

                    self.imageManager?.requestImageData(for: asset, options: self.imageRequestOption, resultHandler: { (result,_,_,_)  -> Void in

                        print(result!)

                        let image : UIImage = self.selectOriginal ? UIImage(data: result!)! : UIImage(data: result!, scale: 1.5)!
                        print(image.size)
                        resultArray.add(image)

                    })
                }
            }

           return resultArray
        }

           return NSMutableArray()

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
