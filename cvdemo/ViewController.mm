//
//  ViewController.m
//  orbslamios
//
//  Created by Ying Gaoxuan on 16/11/1.
//  Copyright © 2016年 Ying Gaoxuan. All rights reserved.
//

#import "ViewController.h"
#import <UIKit/UIImagePickerController.h>

//#import "UIImagePickerController.h"

#include "Masonry.h"

#import "cvUtiil.hpp"
#import <AssetsLibrary/AssetsLibrary.h>



@interface ViewController ()<CvVideoCameraDelegate>
{
    CvVideoCamera* videoCamera;
    UIImageView* imgView;
    UIButton* startBtn;
    UIButton* resetBtn;
    cvUtil* calMatrix;
    int state;
    int method;
}

@end

@implementation ViewController

//@synthesize videoCamera = _videoCamera;



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    imgView = [[UIImageView alloc] initWithImage:[UIImage new]];
    [self.view addSubview:imgView];
    
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).with.offset(54);
        //make.bottom.equalTo(self.view).with.offset(-100);
        make.bottom.equalTo(self.view);
    }];
    
    startBtn = [[UIButton alloc] init];
    [startBtn addTarget:self action:@selector(startButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [startBtn setTitle:@"Start" forState:UIControlStateNormal];
    [startBtn setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:startBtn];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(imgView);
        //make.top.equalTo(imgView.mas_bottom);
        make.top.equalTo(imgView.mas_bottom).with.offset(-100);
        make.bottom.equalTo(self.view).with.offset(-50);
        
    }];
    
    resetBtn = [[UIButton alloc] init];
    [resetBtn addTarget:self action:@selector(resetButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [resetBtn setTitle:@"Reset" forState:UIControlStateNormal];
    [resetBtn setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:resetBtn];
    [resetBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(imgView);
        //make.top.equalTo(imgView.mas_bottom).with.offset(50);
        make.top.equalTo(imgView.mas_bottom).with.offset(-50);
        make.bottom.equalTo(self.view);
        
    }];
    
    videoCamera = [[CvVideoCamera alloc] initWithParentView:imgView];
    videoCamera.delegate = self;
    videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    //videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    //videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset1280x720;
    videoCamera.defaultFPS = 30;
    videoCamera.grayscaleMode = NO;
    
    state=0;
    method=1;
//    calMatrix=new cvUtil();
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [videoCamera start];
    NSLog(@"DemoType = %d",self.demoType);
}


- (void)startButtonPressed:(id)sender
{
    //[videoCamera start];
    state=1;
    calMatrix=new cvUtil();
}

- (void)resetButtonPressed:(id)sender
{
    //[videoCamera start];
    state=0;
}

- (void)processImage:(cv::Mat &)image
{
    //if(state != 1) return;
    //UIImage* img = MatToUIImage(image);
    //ALAssetsLibrary * lib = [ALAssetsLibrary new];
    //[lib writeImageToSavedPhotosAlbum:img.CGImage metadata:@{} completionBlock:^(NSURL *assetURL, NSError *error) {}];
    
    int left = 640-120;
    int right = 640+300;
    int top  = 360-120;
    int buttom = 360+120;
    
    int width = 1280;
    int height = 720;
    
    
    if(state==0)
    {
        rectangle(image, cvPoint(left, top), cvPoint(right, buttom), cvScalar(1), 3);
    }
    else if(state==1)
    {
        //[lib writeImageToSavedPhotosAlbum:img.CGImage metadata:@{} completionBlock:^(NSURL *assetURL, NSError *error) {}];
        calMatrix->initialImageFeature(image);
        calMatrix->setInitialPts(left, right, top, buttom, width, height);
        state=2;
        
        cout << endl;
        cout << "img width is " << image.cols << ", img width is " << image.rows << endl;
        cout << "view height is " << self.view.frame.size.height  << ", view width is " << self.view.frame.size.width << endl;
        cout << "imgview height is " << imgView.frame.size.height  << ", imgview width is " << imgView.frame.size.width << endl;
        cout << "left is "  << left << ", right is " << right << ", top is " << top << ", buttom is " << buttom << endl;
        cout << "width is " << width << ", height is " << height << endl;
        cout << endl;
        
        //img = MatToUIImage(image);
        //[lib writeImageToSavedPhotosAlbum:img.CGImage metadata:@{} completionBlock:^(NSURL *assetURL, NSError *error) {}];
    }
    else if(state==2)
    {
        //[lib writeImageToSavedPhotosAlbum:img.CGImage metadata:@{} completionBlock:^(NSURL *assetURL, NSError *error) {}];
        Mat homo;
        
        //if(method==0)
        if(self.demoType==CVDemoTypeDefault)
        {//compare to first image
            homo=calMatrix->homoMatrixToInitial(image, cvPoint(left, top), cvPoint(right, buttom));
            
            vector<Point2d> rectPts(4), transPts(4);
            rectPts[0]=cvPoint(left+50, top+30);
            rectPts[1]=cvPoint(left+50, buttom-30);
            rectPts[2]=cvPoint(right-50, buttom-30);
            rectPts[3]=cvPoint(right-50, top+30);
            
            cv::Point points[1][4];
            perspectiveTransform(rectPts, transPts, homo);
            for(int i=0; i<4; i++)
            {
                points[0][i]=transPts[i];
            }
            
            const cv::Point* pt[1] = { points[0] };
            int npt[1] = {4};
            polylines(image, pt, npt, 1, 1, Scalar(1),3);
        }
        //else if(method==1)
        else if(self.demoType==CVDemoTypeIncremental)
        {// compare to prevous image
            //image=calMatrix->homoMatrixToPrevious(image);
            homo=calMatrix->homoMatrixToPrevious(image);
            
        }
        else if(self.demoType==CVDemoTypeCombineOne){
//            Mat homo1=calMatrix->homoMatrixToInitial(image, cvPoint(left, top), cvPoint(right, buttom));
//            Mat homo2=calMatrix->homoMatrixToPrevious(image);
//            Mat diff=homo1-homo2;
//            
//            cout << "homo 1 : " << "\n" << homo1 << "\n" << endl;
//            cout << "homo 2 : " << "\n" << homo2 << "\n" << endl;
//            
//            diff.at<double>(0,2) /= width;
//            diff.at<double>(1,2) /= height;
//            cout << "diff : " << "\n" << diff << "\n" << endl;
//            
//            cout << homo1.type() << endl;
//            int sum=0;
//            
//            for(int i=0; i<3; i++){
//                for(int j=0; j<3; j++){
//                    sum += diff.at<double>(i,j) * diff.at<double>(i,j);
//                    cout << diff.at<double>(i,j) << ", ";
//                    diff.at<Vec3b>(i,j);
//                }
//            }
//            cout << endl;
//            cout << "sum is " << sum << endl;
//            
//            homo=(homo1 + homo2)/2;
//            
//            cout << "homo : " << "\n" << homo << "\n" << endl;
            homo=calMatrix->homoMatrixCombine(image, 1);
        }
        else if(self.demoType==CVDemoTypeCombineTwo){
            homo=calMatrix->homoMatrixCombine(image, 2);
        }
        
        vector<Point2d> rectPts(4), transPts(4);
        rectPts[0]=cvPoint(left+50, top+30);
        rectPts[1]=cvPoint(left+50, buttom-30);
        rectPts[2]=cvPoint(right-50, buttom-30);
        rectPts[3]=cvPoint(right-50, top+30);
        
        cv::Point points[1][4];
        perspectiveTransform(rectPts, transPts, homo);
        for(int i=0; i<4; i++)
        {
            points[0][i]=transPts[i];
        }
        
        const cv::Point* pt[1] = { points[0] };
        int npt[1] = {4};
        polylines(image, pt, npt, 1, 1, Scalar(1),3);
        
        //img = MatToUIImage(image);
        //[lib writeImageToSavedPhotosAlbum:img.CGImage metadata:@{} completionBlock:^(NSURL *assetURL, NSError *error) {}];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
