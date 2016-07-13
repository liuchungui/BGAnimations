//
//  ViewController.m
//  Bezier
//
//  Created by 刘春桂 on 16/6/26.
//  Copyright © 2016年 liuchungui. All rights reserved.
//

#import "ViewController.h"

#define kMainScrrenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScrrenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
//顶部的点y坐标
@property (nonatomic, assign) CGPoint topY;
//上面的半径
@property (nonatomic, assign) CGFloat topRadius;
//中间的点y坐标
@property (nonatomic, assign) CGPoint centerY;
//中间点的位置
@property (nonatomic, assign) CGFloat centerRadius;
//底部的点y坐标
//@property (nonatomic, assign) CGPoint bottomY;
//底部的半径
@property (nonatomic, assign) CGPoint bottomRadius;
@property (weak, nonatomic) IBOutlet UISlider *topYSlider;
@property (weak, nonatomic) IBOutlet UISlider *topRadiusSlider;
@property (weak, nonatomic) IBOutlet UISlider *centerYSlider;
@property (weak, nonatomic) IBOutlet UISlider *centerRadiustSlider;
@property (weak, nonatomic) IBOutlet UISlider *bottomRadiustSlider;
@property (weak, nonatomic) IBOutlet UILabel *topYLabel;
@property (weak, nonatomic) IBOutlet UILabel *topRadiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerYLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerRadiusLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomRadiusLabel;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //set up
    [self.topYSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.topRadiusSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.centerYSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.centerRadiustSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.bottomRadiustSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    [self.view.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
    
    //显示图形
    [self sliderAction:nil];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)sliderAction:(UISlider *)slider {
    NSInteger value = slider.value;
    if(slider == self.topYSlider) {
        self.topYLabel.text = [NSString stringWithFormat:@"topY: %zd", value];
    }
    else if(slider == self.topRadiusSlider) {
        self.topRadiusLabel.text = [NSString stringWithFormat:@"topRadius: %zd", value];
    }
    else if(slider == self.centerYSlider) {
        self.centerYLabel.text = [NSString stringWithFormat:@"centerY: %zd", value];
    }
    else if(slider == self.centerRadiustSlider) {
        self.centerRadiusLabel.text = [NSString stringWithFormat:@"centerRadius: %zd", value];
    }
    else if(slider == self.bottomRadiustSlider) {
        self.bottomRadiusLabel.text = [NSString stringWithFormat:@"bottomRadius: %zd", value];
    }
    
    //给path
    UIBezierPath *path = [self waterPathWithTopPoint:CGPointMake(kMainScrrenWidth/2.0, self.topYSlider.value) topRadius:self.topRadiusSlider.value centerPoint:CGPointMake(kMainScrrenWidth/2.0, self.centerYSlider.value) centerRadius:self.centerRadiustSlider.value bottomPoint:CGPointMake(kMainScrrenWidth/2.0, 350) bottomRadius:self.bottomRadiustSlider.value];
    self.shapeLayer.path = [path CGPath];
}

- (UIBezierPath *)waterPathWithTopPoint:(CGPoint)topPoint topRadius:(CGFloat)topRadius centerPoint:(CGPoint)centerPoint centerRadius:(CGFloat)centerRadius bottomPoint:(CGPoint)bottomPoint bottomRadius:(CGFloat)bottomRadius {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(topPoint.x-topRadius, topPoint.y)];
    [path addArcWithCenter:topPoint radius:topRadius startAngle:M_PI endAngle:2*M_PI clockwise:YES];
//    [path addCurveToPoint:CGPointMake(bottomPoint.x+bottomRadius, bottomPoint.y) controlPoint1:CGPointMake(centerPoint.x+centerRadius+40, centerPoint.y) controlPoint2:CGPointMake(bottomPoint.x-bottomRadius/5.0, bottomPoint.y-50)];
    [path addQuadCurveToPoint:CGPointMake(bottomPoint.x+bottomRadius, bottomPoint.y) controlPoint:CGPointMake(centerPoint.x+centerRadius+50, centerPoint.y)];
    [path addLineToPoint:CGPointMake(kMainScrrenWidth, bottomPoint.y)];
    [path addLineToPoint:CGPointMake(0, bottomPoint.y)];
    [path addLineToPoint:CGPointMake(bottomPoint.x-bottomRadius, bottomPoint.y)];
    [path addQuadCurveToPoint:CGPointMake(topPoint.x-topRadius, topPoint.y) controlPoint:CGPointMake(centerPoint.x-centerRadius, centerPoint.y)];
    return path;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
