//
//  ViewController.m
//  QRcode
//
//  Created by Tommy on 2017/3/7.
//  Copyright © 2017年 Tommy. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageview;
@property (strong, nonatomic) IBOutlet UILabel *Timeview;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     NSString *dataString = @"这是一个二维码的生成结果";
    
    [self startGCDTimer];
}




-(void)creatQRcode:(NSString*)datastring{

    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 2.恢复滤镜的默认属性
    [filter setDefaults];
    
    
    // 3.给过滤器添加数据
    
    NSData *data = [datastring dataUsingEncoding:NSUTF8StringEncoding];
    
    [filter setValue:data forKey:@"inputMessage"];
    
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    
    // 5.显示二维码

    _imageview.image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:230];
    
    [self.view addSubview:_imageview];    // Do any additional setup after loading the view, typically from a nib.

}
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

-(void) startGCDTimer{
    
    // GCD定时器
    static dispatch_source_t _timer;
    NSTimeInterval period = 3600.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
    // 事件回调
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            //时间戳+ID
            NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
            NSTimeInterval a=[dat timeIntervalSince1970];
            NSString * timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
            NSString * seatID = @"1";
            NSString * QRcodeString = [NSString stringWithFormat:@"%@,%@",timeString,seatID];
            [self creatQRcode:QRcodeString];
            //刷新时间
            NSDate *currentDate = [NSDate date];
            // 实例化日期格式
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            //设置日期格式
            [dateFormatter setDateFormat:@"YYYY年MM月dd日HH:mm"]; //YYYY表示年 MM表示月份 dd表示日 还有HH表示小时  mm表示分钟 ss表示秒，可以按照需求更改格式
            //将日期转换成字符串输出
            NSString *currentDateStr = [dateFormatter   stringFromDate:currentDate];
            
            _Timeview.text = currentDateStr;

        });
    });
    
    // 开启定时器
    dispatch_resume(_timer);
    
    // 关闭定时器
    // dispatch_source_cancel(_timer);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
