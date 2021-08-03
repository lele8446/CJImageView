//
//  ViewController.m
//  CJImageView
//
//  Created by C.K.Lian on 2021/8/1.
//  Copyright © 2021 C.K.Lian. All rights reserved.
//

#import "ViewController.h"
#import "CJImageView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet CJImageView *imageView;
@property (assign, nonatomic) BOOL selectWin;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.selectWin = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = [UIImage imageNamed:@"common_ic_result_win"];
    self.imageView.cjContentMode = CJContentModeScaleAspectTop;
}

- (IBAction)selectImage:(id)sender {
    self.selectWin = !self.selectWin;
    NSString *name = self.selectWin ? @"common_ic_result_win" : @"common_ic_comment_sel";
    self.imageView.image = [UIImage imageNamed:name];
}

- (IBAction)loadImage:(id)sender {
    NSURL *url = [[NSURL alloc]initWithString:@"https://img2.baidu.com/it/u=705858528,3543125423&fm=11&fmt=auto&gp=0.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [[UIImage alloc]initWithData:data];
    self.imageView.image = image;
}

- (IBAction)selectLaunchImage:(id)sender {
    self.imageView.image = [UIImage imageNamed:@"launch_image_1"];
}

- (IBAction)changeContentMode:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"ContentMode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [actionSheet addAction:action];
    
    [self addContentMode:UIViewContentModeScaleToFill title:@"UIScaleToFill" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeScaleAspectFit title:@"UIScaleAspectFit" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeScaleAspectFill title:@"UIScaleAspectFill" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeRedraw title:@"UIModeRedraw" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeCenter title:@"UIModeCenter" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeTop title:@"UIModeTop" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeBottom title:@"UIModeBottom" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeLeft title:@"UIModeLeft" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeRight title:@"UIModeRight" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeTopLeft title:@"UIModeTopLeft" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeTopRight title:@"UIModeTopRight" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeBottomLeft title:@"UIModeBottomLeft" actionSheet:actionSheet];
    [self addContentMode:UIViewContentModeBottomRight title:@"UIModeBottomRight" actionSheet:actionSheet];
    
    [self presentViewController:actionSheet animated:YES completion:^{
        
    }];

}

- (IBAction)changeCJContentMode:(id)sender {
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"CJContentMode" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    [actionSheet addAction:action];
    
    [self addCJContentMode:CJContentModeScaleAspectCenter title:@"Center" actionSheet:actionSheet];
    [self addCJContentMode:CJContentModeScaleAspectTop title:@"Top" actionSheet:actionSheet];
    [self addCJContentMode:CJContentModeScaleAspectBottom title:@"Bottom" actionSheet:actionSheet];
    [self addCJContentMode:CJContentModeScaleAspectLeft title:@"Left" actionSheet:actionSheet];
    [self addCJContentMode:CJContentModeScaleAspectRight title:@"Right" actionSheet:actionSheet];
    [self addCJContentMode:CJContentModeScaleAspectTopLeft title:@"TopLeft" actionSheet:actionSheet];
    [self addCJContentMode:CJContentModeScaleAspectTopRight title:@"TopRight" actionSheet:actionSheet];
    [self addCJContentMode:CJContentModeScaleAspectBottomLeft title:@"BottomLeft" actionSheet:actionSheet];
    [self addCJContentMode:CJContentModeScaleAspectBottomRight title:@"BottomRight" actionSheet:actionSheet];
    
    [self presentViewController:actionSheet animated:YES completion:^{
        
    }];
}

- (void)addCJContentMode:(CJImageViewContentMode)cjContentMode title:(NSString *)title actionSheet:(UIAlertController *)actionSheet {
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imageView.cjContentMode = cjContentMode;
    }];
    [actionSheet addAction:action1];
}

- (void)addContentMode:(UIViewContentMode)contentMode title:(NSString *)title actionSheet:(UIAlertController *)actionSheet {
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.imageView.contentMode = contentMode;
    }];
    [actionSheet addAction:action1];
}

- (BOOL)shouldAutorotate {
      return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
     return UIInterfaceOrientationMaskAll;
}

//3.返回进入界面默认显示方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
     return UIInterfaceOrientationPortrait;
}


@end
