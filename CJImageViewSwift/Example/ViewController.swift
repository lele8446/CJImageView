//
//  ViewController.swift
//  CJImageViewSwift
//
//  Created by C.J.Lian on 2021/7/19.
//

import UIKit
//import CJImageView

class ViewController: UIViewController {
    @IBOutlet weak var imageView: CJImageView!
    
    var selectWin: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.launchImageAnimation()
        
        // Do any additional setup after loading the view.
    }

    func launchImageAnimation() -> Void {
        let launchViewController = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateViewController(withIdentifier: "launchImage") as UIViewController
        let view:UIView = launchViewController.view
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(view)
        
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.image = UIImage.init(named: "common_ic_result_win")
        self.imageView.cjContentMode = .scaleAspectTop
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            UIView.animate(withDuration: 1, animations: {
                view.alpha = 0
                view.layer.transform = CATransform3DScale(CATransform3DIdentity, 2.5, 2.5, 1)
            }) { (finished) in
                view.removeFromSuperview()
            }
        }
    }
    
    @IBAction func selectImage() ->Void{
        self.selectWin = !self.selectWin
        let name: String = self.selectWin ? "common_ic_result_win" : "common_ic_comment_sel"
        self.imageView.image = UIImage.init(named: name)
    }
    
    @IBAction func loadImage(_ sender: Any) {
        let url = URL.init(string: "https://img2.baidu.com/it/u=705858528,3543125423&fm=11&fmt=auto&gp=0.jpg")
        do {
            let jsonData = try Data.init(contentsOf: url!, options: Data.ReadingOptions.alwaysMapped)
            let image: UIImage = UIImage.init(data: jsonData)!
            self.imageView.image = image
        } catch {
            // 处理异常
            print(error)
        }
    }
    
    @IBAction func selectLaunchImage() ->Void{
        self.imageView.image = UIImage.init(named: "launch_image_1")
    }
    
    @IBAction func changeContentMode(_ sender: Any) {
        let alert: UIAlertController = UIAlertController.init(title: "ContentMode", message: "", preferredStyle: .actionSheet)
        let cancelItem: UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelItem)
        self.addAlertItem(mode: .scaleToFill, itemTitle: "scaleToFill", alert: alert)
        self.addAlertItem(mode: .scaleAspectFit, itemTitle: "scaleAspectFit", alert: alert)
        self.addAlertItem(mode: .scaleAspectFill, itemTitle: "scaleAspectFill", alert: alert)
        self.addAlertItem(mode: .center, itemTitle: "center", alert: alert)
        self.addAlertItem(mode: .top, itemTitle: "top", alert: alert)
        self.addAlertItem(mode: .bottom, itemTitle: "bottom", alert: alert)
        self.addAlertItem(mode: .left, itemTitle: "left", alert: alert)
        self.addAlertItem(mode: .right, itemTitle: "right", alert: alert)
        self.addAlertItem(mode: .topLeft, itemTitle: "topLeft", alert: alert)
        self.addAlertItem(mode: .topRight, itemTitle: "topRight", alert: alert)
        self.addAlertItem(mode: .bottomLeft, itemTitle: "bottomLeft", alert: alert)
        self.addAlertItem(mode: .bottomRight, itemTitle: "bottomRight", alert: alert)
        self.present(alert, animated: true, completion: nil)
    }
    func addAlertItem(mode: UIView.ContentMode, itemTitle: String, alert: UIAlertController) -> Void {
        let item: UIAlertAction = UIAlertAction.init(title: itemTitle, style: .default) { (action: UIAlertAction) in
            self.imageView.contentMode = mode
        }
        alert.addAction(item)
    }
    
    
    @IBAction func changeCJContentMode(_ sender: Any) {
        let alert: UIAlertController = UIAlertController.init(title: "CJContentMode", message: "", preferredStyle: .actionSheet)
        let cancelItem: UIAlertAction = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelItem)
        self.addAlertCJContentModeItem(mode: .scaleAspectCenter, itemTitle: "scaleAspectCenter", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectTop, itemTitle: "scaleAspectTop", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectBottom, itemTitle: "scaleAspectBottom", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectLeft, itemTitle: "scaleAspectLeft", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectRight, itemTitle: "scaleAspectRight", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectTopLeft, itemTitle: "scaleAspectTopLeft", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectTopRight, itemTitle: "scaleAspectTopRight", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectBottomLeft, itemTitle: "scaleAspectBottomLeft", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectBottomRight, itemTitle: "scaleAspectBottomRight", alert: alert)
        self.addAlertCJContentModeItem(mode: .scaleAspectUnknown, itemTitle: "scaleAspectUnknown", alert: alert)
        self.present(alert, animated: true, completion: nil)
    }
    func addAlertCJContentModeItem(mode: CJContentMode, itemTitle: String, alert: UIAlertController) -> Void {
        let item: UIAlertAction = UIAlertAction.init(title: itemTitle, style: .default) { (action: UIAlertAction) in
            self.imageView.cjContentMode = mode
        }
        alert.addAction(item)
    }
}
