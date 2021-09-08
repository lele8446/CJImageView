//
//  CJImageView.swift
//  CJImageViewSwift
//
//  Created by C.J.Lian on 2021/7/19.
//

import UIKit

public enum CJContentMode: Int {
    case scaleAspectCenter      = 1003
    case scaleAspectTop         = 1004
    case scaleAspectBottom      = 1005
    case scaleAspectLeft        = 1006
    case scaleAspectRight       = 1007
    case scaleAspectTopLeft     = 1008
    case scaleAspectTopRight    = 1009
    case scaleAspectBottomLeft  = 1010
    case scaleAspectBottomRight = 1011
    /// unknow type, use contentMode value
    case scaleAspectUnknown     = -1000
}

private typealias CropImageBlock = (_ image: UIImage)->Void
private func PointValue(a: CGFloat)->CGFloat{
    let value: CGFloat = (a)<0 ? 0 : (a)
    return value
}
private class CJImageContentView: UIView {
    public var cjContentMode: CJContentMode!
    
    public func flushWithImage(originalImage: UIImage) {
        self.cropImage(image: originalImage) { (image: UIImage) in
            self.layer.contents = image.cgImage
        }
    }
    
    private func cropImage(image: UIImage, completion: CropImageBlock) {
        autoreleasepool {
            let cgImage: CGImage = image.cgImage!
            let imageW: CGFloat = CGFloat(cgImage.width)
            let imageH: CGFloat = CGFloat(cgImage.height)
            
            let scale: CGFloat = image.scale
            let imageViewW: CGFloat = self.frame.width * scale
            let imageViewH: CGFloat = self.frame.height * scale
            
            var x: CGFloat = 0
            var y: CGFloat = 0
            
            var resultImageW: CGFloat = imageViewW
            var resultImageH: CGFloat = imageViewH
            var resultImage: UIImage!
            
            if (imageW > imageViewW && imageH > imageViewH) {
                if (imageW/imageViewW > imageH/imageViewH) {
                    resultImageH = imageH
                    resultImageW = (resultImageH * imageViewW)/imageViewH
                }else{
                    resultImageW = imageW
                    resultImageH = (resultImageW * imageViewH)/imageViewW
                }
            }
            else if (imageW > imageViewW && imageH < imageViewH) {
                resultImageH = imageH
                resultImageW = imageViewW
            }
            else if (imageW < imageViewW && imageH > imageViewH) {
                resultImageH = imageViewH
                resultImageW = imageW
            }else{
                resultImage = image
            }
            
            let resultImageWidth: CGFloat = (resultImage != nil) ? (resultImage.size.width) : 0
            let resultImageHeight: CGFloat = (resultImage != nil) ? (resultImage.size.height) : 0
            
            let x1: CGFloat = self.bounds.size.width - resultImageWidth
            let y1: CGFloat = self.bounds.size.height - resultImageHeight
            var point: CGPoint = .zero
            if (self.cjContentMode == .scaleAspectCenter) {
                x = PointValue(a: (imageW-resultImageW)/2)
                y = PointValue(a: (imageH-resultImageH)/2)
                point = CGPoint.init(x: x1/2, y: y1/2)
            }
            else if (self.cjContentMode == .scaleAspectTop) {
                x = PointValue(a:(imageW-resultImageW)/2)
                y = 0
                point = CGPoint.init(x: x1/2, y: 0)
            }
            else if (self.cjContentMode == .scaleAspectBottom) {
                x = PointValue(a:(imageW-resultImageW)/2)
                y = PointValue(a:(imageH-resultImageH))
                point = CGPoint.init(x: x1/2, y: y1)
            }
            else if (self.cjContentMode == .scaleAspectLeft) {
                x = 0;
                y = PointValue(a:(imageH-resultImageH)/2)
                point = CGPoint.init(x: 0, y: y1/2)
            }
            else if (self.cjContentMode == .scaleAspectRight) {
                x = PointValue(a:(imageW-resultImageW))
                y = PointValue(a:(imageH-resultImageH)/2)
                point = CGPoint.init(x: x1, y: y1/2)
            }
            else if (self.cjContentMode == .scaleAspectTopLeft) {
                x = 0;
                y = 0;
                point = CGPoint.init(x: 0, y: 0)
            }
            else if (self.cjContentMode == .scaleAspectTopRight) {
                x = PointValue(a:(imageW-resultImageW))
                y = 0;
                point = CGPoint.init(x: x1, y: 0)
            }
            else if (self.cjContentMode == .scaleAspectBottomLeft) {
                x = 0;
                y = PointValue(a:(imageH-resultImageH))
                point = CGPoint.init(x: 0, y: y1)
            }
            else if (self.cjContentMode == .scaleAspectBottomRight) {
                x = PointValue(a:(imageW-resultImageW))
                y = PointValue(a:(imageH-resultImageH))
                point = CGPoint.init(x: x1, y: y1)
            }
            
            if (resultImage == nil) {
                let cropRect: CGRect = CGRect.init(x: x, y: y, width: resultImageW, height: resultImageH)
                let cropImage: CGImage = cgImage.cropping(to: cropRect)!
                resultImage = UIImage.init(cgImage: cropImage)
            }else{
                UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, 0)
                resultImage!.draw(at: point)
                resultImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            
            completion(resultImage!)
        }
    }
}

/// A custom UIImageView that supports contentMode attribute expansion.
/// Note that self.image always return nil. Use self.cjImage() instead.
open class CJImageView: UIImageView {
    
    private var _cjContentMode: CJContentMode! = CJContentMode.scaleAspectUnknown
    
    /// UIView contentMode attribute expansion.
    /// If image'size larger than CJImageView'size, contents scaled to fill with fixed aspect and adjust position, some portion of content may be clipped.
    /// Otherwise just adjust the position.
    public var cjContentMode: CJContentMode! {
        set{
            _cjContentMode = (newValue != nil) ? newValue : CJContentMode.scaleAspectUnknown
            self.imageContentView.cjContentMode = _cjContentMode
            self.flush()
        }
        get{
            return _cjContentMode
        }
    }
    
    private var originalImage: UIImage?
    private var oldBounds: CGRect! = CGRect.init()
    private lazy var imageContentView: CJImageContentView = {
        let view = CJImageContentView.init(frame: CGRect.init(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        self.addSubview(view)
        self.equalLayoutConstraintItem(view1: view, view2: self, attr: .left)
        self.equalLayoutConstraintItem(view1: view, view2: self, attr: .right)
        self.equalLayoutConstraintItem(view1: view, view2: self, attr: .top)
        self.equalLayoutConstraintItem(view1: view, view2: self, attr: .bottom)
        return view
    }()
    
    public override var contentMode: UIView.ContentMode {
        set{
            super.contentMode = newValue
            self.cjContentMode = CJContentMode.scaleAspectUnknown
            self.flush()
        }
        get{
            return super.contentMode
        }
    }
    
    /// self.image always return nil. Use self.cjImage() instead.
    public override var image: UIImage? {
        set{
            self.originalImage = newValue
            self.flush()
        }
        get{
            /// Return nil, bacause UIImageView will automatically refreshes image according to the contentMode value when it resign active, instead of displaying the current image.
            return nil
        }
    }
    /// self.image always return nil. Use self.cjImage() instead.
    public func cjImage()-> UIImage? {
        return self.originalImage
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !self.bounds.equalTo(self.oldBounds) {
            self.oldBounds = self.bounds
            self.flush()
        }
    }
    
    private func equalLayoutConstraintItem(view1: Any, view2: Any, attr: NSLayoutConstraint.Attribute) -> Void {
        NSLayoutConstraint.init(item: view1, attribute: attr, relatedBy: .equal, toItem: view2, attribute: attr, multiplier: 1.0, constant: 0.0).isActive = true
    }
    
    private func flush() -> Void {
        if (self.cjContentMode.rawValue >= CJContentMode.scaleAspectCenter.rawValue && self.cjContentMode.rawValue <= CJContentMode.scaleAspectBottomRight.rawValue) {
            self.imageContentView.isHidden = false
            self.imageContentView.flushWithImage(originalImage: self.originalImage!)
            super.image = nil
            self.layer.contents = nil
        }else{
            super.image = self.originalImage ?? nil
            self.imageContentView.isHidden = true
            self.imageContentView.layer.contents = nil
        }
    }
}
