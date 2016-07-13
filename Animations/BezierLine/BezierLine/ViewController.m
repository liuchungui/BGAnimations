//
//  ViewController.m
//  BezierLine
//
//  Created by 刘春桂 on 16/6/28.
//  Copyright © 2016年 liuchungui. All rights reserved.
//

#import "ViewController.h"

#define kMainScrrenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScrrenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITextFieldDelegate>
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (weak, nonatomic) IBOutlet UITextField *p2TextFiled;
@property (weak, nonatomic) IBOutlet UITextField *p1TextFiled;
//正在输入的输入框
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, assign) CGPoint point1;
@property (nonatomic, assign) CGPoint point2;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    shapeLayer.lineWidth = 1.0;
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    [self.view.layer addSublayer:shapeLayer];
    self.shapeLayer = shapeLayer;
    
    self.shapeLayer.path = [self waterPath].CGPath;
    [self setup];
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkEvent:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)displayLinkEvent:(CADisplayLink *)diplayLink {
//    self.shapeLayer.path = [self waterPath].CGPath;
    self.shapeLayer.path = [self circleAndLine].CGPath;
}

- (void)setup {
    self.p1TextFiled.delegate = self;
    self.p2TextFiled.delegate = self;
}

- (UIBezierPath *)waterPath {
    CGFloat radius = 50;
    CGPoint pointC = CGPointMake(kMainScrrenWidth/2.0, kMainScrrenHeight/2.0-250);
    CGPoint pointA = CGPointMake(kMainScrrenWidth/2.0-radius, pointC.y);
    CGPoint pointB = CGPointMake(kMainScrrenWidth/2.0+radius, pointC.y);
    CGPoint pointH = CGPointMake(kMainScrrenWidth/2.0-100, kMainScrrenHeight/2.0);
    CGPoint pointI = CGPointMake(kMainScrrenWidth/2.0+100, kMainScrrenHeight/2.0);
    //第一次，初始化
    if(self.point1.x == 0 && self.point1.y == 0 && self.point2.x == 0 && self.point2.y == 0) {
        self.point1 = CGPointMake(pointA.x, pointA.y-30);
        self.point2 = CGPointMake(kMainScrrenWidth/2.0, kMainScrrenHeight/2.0-100);
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointB];
    [path addArcWithCenter:pointC radius:radius startAngle:2*M_PI endAngle:M_PI clockwise:NO];
    [path addCurveToPoint:pointH controlPoint1:self.point1 controlPoint2:self.point2];
    [path addLineToPoint:pointI];
    [path addCurveToPoint:pointB controlPoint1:CGPointMake(kMainScrrenWidth-self.point2.x, self.point2.y) controlPoint2:CGPointMake(kMainScrrenWidth-self.point1.x, self.point1.y)];
    return path;
}

- (UIBezierPath *)circleAndLine {
    CGFloat radius = 50;
    CGFloat angle = (M_PI - M_PI_2) / 2.0;
    CGPoint centerPoint = CGPointMake(kMainScrrenWidth/2.0, kMainScrrenHeight/2.0);
    CGPoint pointA = CGPointMake(centerPoint.x - radius*cos(angle), centerPoint.y - radius*sin(angle));
    CGPoint pointB = CGPointMake(centerPoint.x + radius*cos(angle), pointA.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:centerPoint];
    [path addLineToPoint:pointA];
    [path addArcWithCenter:centerPoint radius:radius startAngle:M_PI+angle endAngle:M_PI*2-angle clockwise:YES];
    [path moveToPoint:pointB];
//    [path addLineToPoint:CGPointMake(kMainScrrenWidth/2.0 + 50*sqrt(2.0), kMainScrrenHeight/2.0)];
    [path addCurveToPoint:CGPointMake(kMainScrrenWidth/2.0, kMainScrrenHeight/2.0) controlPoint1:self.point1 controlPoint2:self.point2];
    [path addLineToPoint:centerPoint];
    return path;
}

#pragma mark - touch
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self moveAndUpdateUI:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self moveAndUpdateUI:touches];
}

- (void)moveAndUpdateUI:(NSSet *)touches {
    //移动点，将输入的值存入输入框
    UITouch *touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self.view];
    [self showPoint:point];
    if(self.inputTextField == self.p1TextFiled) {
//        point.x = kMainScrrenWidth/2.0-50;
        self.point1 = point;
    }
    else if(self.inputTextField == self.p2TextFiled) {
        self.point2 = point;
    }
    self.point1 = CGPointMake(kMainScrrenWidth/2.0 + 50*sqrt(2.0), kMainScrrenHeight/2.0);
//    self.shapeLayer.path = [self waterPath].CGPath;
    self.shapeLayer.path = [self circleAndLine].CGPath;
}

- (void)showPoint:(CGPoint)point {
    self.inputTextField.text = [NSString stringWithFormat:@"%.0lf, %.0lf", point.x, point.y];
}

- (CGPoint)transformToPoint:(NSString *)str {
    NSArray *array = [str componentsSeparatedByString:@","];
    if(array.count < 2) {
        array = [str componentsSeparatedByString:@" "];
    }
    if(array.count < 2) {
        return CGPointMake(0, 0);
    }
    return CGPointMake([array[0] floatValue], [array[1] floatValue]);
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.inputTextField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    //转换为点
    if(textField == self.p1TextFiled) {
        self.point1 = [self transformToPoint:textField.text];
    }
    else {
        self.point2 = [self transformToPoint:textField.text];
    }
    //更新图形
    self.shapeLayer.path = [self waterPath].CGPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
