# CJImageView
A custom UIImageView that supports contentMode attribute expansion.  

If image' size larger than CJImageView' size,  contents scaled to fill with fixed aspect and adjust position,  some portion of content may be clipped.  Otherwise just adjust the position.

![CJImageView](https://lele8446infoq.oss-cn-shenzhen.aliyuncs.com/CJImageView/CJImageView01.jpg)

Note that **self.image** or **[self image]** always return nil. Use **[self cjImage]、self.cjImage()** instead.

### Installation

To integrate CJImageView into your Xcode project using CocoaPods, specify it in your Podfile:

```sh
// Objective-C
pod 'CJImageView', '1.0.0'

// Swift
pod 'CJImageViewSwift', '1.0.4'
```



### Usage

* Objective-C

  ```objective-c
  #import <CJImageView.h>
  
  self.imageView.image = [UIImage imageNamed:@"xxx"];
  self.imageView.cjContentMode = CJContentModeScaleAspectTop;
  ```

* Swift

  ```swift
  import CJImageView
  
  self.imageView.image = UIImage.init(named: "common_ic_result_win")
  self.imageView.cjContentMode = .scaleAspectTop
  ```