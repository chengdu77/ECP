//
//  MyPhotographViewController.m
//  JCDB
//
//  Created by WangJincai on 16/1/16.
//  Copyright © 2016年 WJC.com. All rights reserved.
//

#import "MyPhotographViewController.h"


@interface MyPhotographViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>


@property (nonatomic,copy) GetImageBlock block;
@property (nonatomic,strong) UIViewController *viewController;

@end


static MyPhotographViewController   *photographViewController;

@implementation MyPhotographViewController



+(MyPhotographViewController *)shareInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photographViewController = [[MyPhotographViewController alloc] init];
    });
    return photographViewController;
}

- (void)viewController:(UIViewController*)viewController withBlock:(GetImageBlock) block{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    
    [actionSheet showInView:viewController.view];
    
    
   
    
    self.viewController = viewController;
    self.block = block;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == actionSheet.cancelButtonIndex){
        return;
    }
    
    switch (buttonIndex){
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
        case 1:  //打开本地相册
            [self localPhotoList];
            break;
    }
}


- (void)takePhoto{
    
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;

//        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self.viewController presentViewController:picker animated:YES completion:nil];
    }
}

//打开本地相册
- (void)localPhotoList{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self.viewController presentViewController:picker animated:YES completion:nil];
}

//当选择一张图片后进入这里
- (void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]){
        //先把图片转成NSData
        UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        self.block(image);
    }else{
        self.block(nil);
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
