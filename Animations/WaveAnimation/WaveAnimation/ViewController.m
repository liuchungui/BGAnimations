//
//  ViewController.m
//  WaveAnimation
//
//  Created by 刘春桂 on 16/6/13.
//  Copyright © 2016年 liuchungui. All rights reserved.
//

#import "ViewController.h"

#define kMainScrrenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScrrenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, assign) CGFloat amplitudeValue;
@property (nonatomic, assign) CGFloat periodWidth;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UISlider *amplitudeSlider;
@property (weak, nonatomic) IBOutlet UISlider *periodSlider;
@property (weak, nonatomic) IBOutlet UILabel *amplitudeLabel;
@property (weak, nonatomic) IBOutlet UILabel *periodLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViews];
    
//    self.shapeLayer.path = [self wavePath];
    
    UIBezierPath *squarePath = [self squarePath];
    [squarePath appendPath:[self arcPath]];
    self.shapeLayer.path = squarePath.CGPath;
    [self.view.layer addSublayer:self.shapeLayer];
    [self animationStorkeWave];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupViews {
    self.amplitudeValue = 100;
    self.periodWidth = 414;
    
    self.amplitudeSlider.minimumValue = 5;
    self.amplitudeSlider.maximumValue = 200;
    self.amplitudeSlider.value = self.amplitudeValue;
    [self.amplitudeSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    self.periodSlider.minimumValue = 5;
    self.periodSlider.maximumValue = 1000;
    self.periodSlider.value = self.periodWidth;
    [self.periodSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    
    self.amplitudeLabel.text = [NSString stringWithFormat:@"%.lf", self.amplitudeSlider.value];
    self.periodLabel.text = [NSString stringWithFormat:@"%.lf", self.periodWidth];
    
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark views action
- (void)sliderAction:(UISlider *)slider {
    if(self.amplitudeSlider == slider) {
        self.amplitudeValue = self.amplitudeSlider.value;
        self.amplitudeLabel.text = [NSString stringWithFormat:@"%.lf", self.amplitudeSlider.value];
    }
    else {
        self.periodWidth = self.periodSlider.value;
        self.periodLabel.text = [NSString stringWithFormat:@"%.lf", self.periodWidth];
    }
    self.shapeLayer.path = [self wavePath];
}

- (void)buttonAction:(UIButton *)button {
    [self animationStorkeWave];
}


#pragma mark layer method
- (void)animationStorkeWave {
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"strokeEnd";
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 5.0;
    
    [self.shapeLayer addAnimation:animation forKey:@"ShapeLayerStorekeStartAnimation"];
}

- (CAShapeLayer *)shapeLayer {
    if(_shapeLayer == nil) {
        _shapeLayer = [[CAShapeLayer alloc] init];
        _shapeLayer.strokeColor = [UIColor blueColor].CGColor;
        _shapeLayer.fillColor = [UIColor redColor].CGColor;
        //画线的连接处的形状
        //kCALineJoinMiter 连接处是斜角，角是突出来的
        //kCALineJoinRound 连接处是圆弧的
        //kCALineJoinBevel 连接处是斜面，会缺少一小块
        _shapeLayer.lineJoin = kCALineJoinMiter;
        
        //线的开始和结尾的部分
        //kCALineCapSquare 端点是正方形，角突出
        //kCALineCapButt 不带端点，开始和结尾连接时，会缺少一块
        //kCALineCapRound 端点是圆
        _shapeLayer.lineCap = kCALineCapRound;
        
        //奇偶规则的应用：两个图形相交时，相交的部分空白出来
        _shapeLayer.fillRule = kCAFillRuleEvenOdd;
        
        //当lineJoin是kCALineJoinMiter时，当斜面长度除以线宽大于miterLimit这个值时，那连接处就会表现成kCALineJoinBevel这种形式；
        //对于是直角的连接处，斜面长度除以线宽是sqrt(2)。所以我们如果设置为sqrt(2)-0.00001时，那么连接处小于等于90°时，表现形式是kCALineJoinBevel；而大于90°的则表现是kCALineJoinMiter
        _shapeLayer.miterLimit = sqrt(2)-0.00001;
        
        //lineDashPattern 传递一个数组，然后画线按照一段实现一段空白进行画线
        _shapeLayer.lineDashPattern = @[@60, @20, @240, @70];
        
        //lineDashPhase 是说在lineDashPattern里面，经过多远才开始。它决定了从哪一段开始和决定了第一段线的长度。例如当lineDashPhase为180时，它是从第三段开始处的180-80=100位置开始，也就是说它第一段画线是100，第二段画线是70，第三段画线是60，以此类推；当然如果lineDashPhase大于整个lineDashPattern的和时，因为我们是循环计算的，可以先减去lineDashPattern中和的最大倍数之后，让lineDashPhase变成一个小于lineDashPattern和的值，然后再确定是从哪一段开始，第一段画线多长。
        _shapeLayer.lineDashPhase = 180;
        
        _shapeLayer.lineWidth = 10;
    }
    return _shapeLayer;
}

- (CGPathRef)wavePath {
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(0, kMainScrrenHeight/2.0)];
    for(CGFloat x = 0; x <= kMainScrrenWidth; x++) {
        //每个周期是2*M_PI，x/self.periodWidth相当于计算经过了多少个周期
        CGFloat y = self.amplitudeValue * sinf(2*M_PI*x/self.periodWidth) + kMainScrrenHeight/2.0;
        [path addLineToPoint:CGPointMake(x, y)];
    }
//    [path addLineToPoint:CGPointMake(kMainScrrenWidth, kMainScrrenHeight)];
//    [path addLineToPoint:CGPointMake(0, kMainScrrenHeight)];
//    [path addLineToPoint:CGPointMake(0, kMainScrrenHeight/2.0)];
    
    return [path CGPath];
}

- (UIBezierPath *)squarePath {
    CGFloat gap = 30;
    UIBezierPath *path = [[UIBezierPath alloc] init];
    [path moveToPoint:CGPointMake(gap, kMainScrrenHeight/2.0)];
    [path addLineToPoint:CGPointMake(kMainScrrenWidth-gap, kMainScrrenHeight/2.0)];
    [path addLineToPoint:CGPointMake(kMainScrrenWidth-gap, kMainScrrenHeight-gap-200)];
    [path addLineToPoint:CGPointMake(kMainScrrenWidth-gap-100, kMainScrrenHeight-gap-50)];
    [path addLineToPoint:CGPointMake(gap, kMainScrrenHeight-gap)];
    [path addLineToPoint:CGPointMake(gap, kMainScrrenHeight/2.0)];
    return path;
}

- (UIBezierPath *)arcPath {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(kMainScrrenWidth/2.0, kMainScrrenHeight/2.0) radius:50 startAngle:0 endAngle:2*M_PI clockwise:YES];
    return path;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
