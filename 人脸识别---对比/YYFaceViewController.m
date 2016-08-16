//
//  YYFaceViewController.m
//  人脸识别---对比
//
//  Created by 王玉翠 on 16/8/15.
//  Copyright © 2016年 王玉翠. All rights reserved.
//

#import "YYFaceViewController.h"
#import "FaceppAPI.h"


#define KWidth self.view.frame.size.width
#define KHeight self.view.frame.size.width
#define BtnBorder 40
#define ImgeBorder 20

@interface YYFaceViewController ()

//显示图片的imageView
@property (nonatomic, strong) UIImageView *firstImageView;

@property (nonatomic, strong) UIImageView *secondImageView;

//触发比较相似度的button
@property (nonatomic ,strong) UIButton *recoginizedBTN;

//五官的相似度
@property (nonatomic, copy) NSString *eye;

@property (nonatomic, copy) NSString *eyeBrow;

@property (nonatomic, copy) NSString *mouth;

@property (nonatomic, copy) NSString *nose;

@property (nonatomic, copy) NSString *similarity;

@property (nonatomic, strong) UITextView *similarityView;

//通过此标记判断选择图片要显示在哪个相框中
@property (nonatomic, assign) NSInteger imageTag;

@end


@implementation YYFaceViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self drawView];
    
}

-(void)drawView{
    
    //创建两个按钮,点击事件为选择照片
    UIButton *firstBTN = [UIButton buttonWithType:(UIButtonTypeSystem)];
    firstBTN.frame = CGRectMake(BtnBorder, 100, (KWidth - BtnBorder * 3) / 2, 30);
    
    [firstBTN setTitle:@"setFirstPhone" forState:(UIControlStateNormal)];
    [firstBTN addTarget:self action:@selector(selectFirstImage) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:firstBTN];
    
    UIButton *secondBTN = [UIButton buttonWithType:UIButtonTypeSystem];
    secondBTN.frame = CGRectMake(CGRectGetMaxX(firstBTN.frame) + BtnBorder, 100, (KWidth - BtnBorder * 3) / 2, 30);
    [secondBTN setTitle:@"setSecondPhone" forState:(UIControlStateNormal)];
    [secondBTN addTarget:secondBTN action:@selector(selectSecondPhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:secondBTN];
    
    //创建两个相框,显示图片
    UIImageView *firstImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ImgeBorder, 140, (KWidth - ImgeBorder * 3) / 2, (KWidth - ImgeBorder * 3) / 2 * KHeight)];
    firstImageView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:firstImageView];
    self.firstImageView = firstImageView;
    
    UIImageView *secondImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(firstImageView.frame) + ImgeBorder, 140, (KWidth - ImgeBorder * 3)/ 2 , (KWidth - ImgeBorder * 3) / 2 * KHeight)];
    secondImageView.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:secondImageView];
    self.secondImageView = secondImageView;
    
    
    //相似度检测按钮
    UIButton *recoginzedBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    recoginzedBtn.frame = CGRectMake(self.view.bounds.size.width /2, CGRectGetMaxY(secondImageView.frame ) + 20, (KWidth - BtnBorder * 3) / 2, 30);
    recoginzedBtn.center = CGPointMake(self.view.bounds.size.width / 2, CGRectGetMaxY(secondImageView.frame) + 20);
    [recoginzedBtn setTitle:@"相似度计算" forState:UIControlStateNormal];
    [recoginzedBtn addTarget:self action:@selector(recoginzed) forControlEvents:(UIControlEventTouchUpInside)];
    [self.view addSubview:recoginzedBtn];
    recoginzedBtn.enabled = YES;
    self.recoginizedBTN = recoginzedBtn;
    
    
    //添加输入框,显示输出信息
    UITextView *similarityView = [[UITextView alloc] initWithFrame:CGRectMake((KWidth - 300) / 2, CGRectGetMaxY(recoginzedBtn.frame) + 10, 300, 150)];
    similarityView.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:similarityView];
    self.similarityView = similarityView;
    
    
}


-(void)selectFirstImage{
    
    self.imageTag = 999;
    [self alertController];
    
    
}


-(void)selectSecondPhoto{
    
    self.imageTag = 888;
    [self alertController];
    
}


//检测相似度
-(void)recoginzed{
  //获取两张面孔的face_id
    NSString *firstFace_id;
    NSData *firstImageData = UIImageJPEGRepresentation(self.firstImageView.image, 0.6);
    FaceppResult *firstResult = [[FaceppAPI detection] detectWithURL:nil orImageData:firstImageData];
    NSArray *array1 = firstResult.content[@"face"];
    
    if (array1.count == 1) {
        firstFace_id = [firstResult content][@"face"][0][@"face_id"];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未检测到五官" delegate:self cancelButtonTitle:@"重新选择图片" otherButtonTitles:nil];
        [alert show];
        return ;
        
    }
    NSString *secondFace_id;
    NSData *secondImageData = UIImageJPEGRepresentation(self.secondImageView.image, 0.6);
    FaceppResult *secondResult = [[FaceppAPI detection] detectWithURL:nil orImageData:secondImageData];
    NSArray *array2 = secondResult.content[@"face"];
    if (array2.count == 1) {
        secondFace_id = [secondResult content][@"face"][0][@"face_id"];
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"未检测到五官" delegate:self cancelButtonTitle:@"重新选择图片" otherButtonTitles:nil];
        [alert show];
        return ;
        
    }
    
    //比较两者相似
    FaceppResult *similarResult = [[FaceppAPI recognition] compareWithFaceId1:firstFace_id andId2:secondFace_id async:NO];
    if ([similarResult success]) {
        self.eye = [similarResult content][@"component_similarity"][@"eye"];
        self.eyeBrow = [similarResult content][@"component_similarity"][@"eyebrow"];
        self.mouth = [similarResult content][@"component_similarity"][@"mouth"];
        self.nose = [similarResult content][@"component_similarity"][@"nose"];
        self.similarity = [similarResult content][@"similarity"];
        NSString *content = [NSString stringWithFormat:@"眼睛:%@\n眉毛:%@\n嘴巴:%@\n鼻子:%@\n综合:%@",self.eye,self.eyeBrow,self.mouth,self.nose,self.similarity];
        self.similarityView.text = content;
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"未检测到五官" delegate:self cancelButtonTitle:@"error" otherButtonTitles: nil];
        [alert show];
        
        return;
    }
    
}


-(void)alertController{
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //添加Button
    [alertController addAction: [UIAlertAction actionWithTitle: @"拍照" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //处理点击拍照
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            // 跳转到相机或相册页面
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = self;
            imagePickerController.allowsEditing = YES;
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"打开相机失败" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
            [alert show];
        }
        
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"从相册选取" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
        //处理点击从相册选取
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            // 跳转到相机或相册页面
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            
            imagePickerController.delegate = self;
            
            imagePickerController.allowsEditing = YES;
            
            
            [self presentViewController:imagePickerController animated:YES completion:^{}];
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"打开相机失败" delegate:self cancelButtonTitle:@"取消" otherButtonTitles: nil];
            [alert show];
        }
    }]];
    [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (self.imageTag == 999) {
        self.firstImageView.image = image;
    }
    if (self.imageTag == 888) {
        self.secondImageView.image = image;
    }
    if (self.firstImageView.image && self.secondImageView.image) {
        self.recoginizedBTN.enabled = YES;
    }
    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    
    
}

@end
