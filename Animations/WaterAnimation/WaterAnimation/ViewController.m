//
//  ViewController.m
//  WaterAnimation
//
//  Created by 刘春桂 on 16/6/5.
//  Copyright © 2016年 liuchungui. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Additional.h"

#define kMainScrrenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScrrenHeight [UIScreen mainScreen].bounds.size.height
#define kCircleViewRadius 20

@interface ViewController ()
//底部的layer
@property (nonatomic, strong) CAShapeLayer *bottomLayer;
//弹出水的layer
@property (nonatomic, strong) CAShapeLayer *topLayer;
//圆点
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIView *topWaterView;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CGPoint position;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (nonatomic, assign) CGPoint tmpPoint;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.position = [self originPoint];
    
    self.tmpPoint = CGPointMake(kMainScrrenWidth/2.0, 300);
    self.topLayer.path = [self waterPathWithTopPoint:self.tmpPoint].CGPath;
    
    //添加定时器
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayEvent:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    //添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.view addGestureRecognizer:pan];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)displayEvent:(CADisplayLink *)displayLink {
    //这里只能使用layer的presentationLayer的position，使用view不行
    CALayer *layer = self.circleView.layer.presentationLayer;
    
    CGFloat y = layer.position.y-kCircleViewRadius/2.0;
    CGPoint point = CGPointMake(layer.position.x, y);
    
    self.bottomLayer.path = [self pathWithTopCenterPotin:point];
//    self.topLayer.path = [self myPathWithPoint:CGPointMake(kMainScrrenWidth/2.0, 150)];
//    
//    return;
    
//    self.topLayer.path = [self waterPathWithTopPoint:point].CGPath;
//    self.topLayer.path = [self sinPathWithPoint:point].CGPath;
//    self.topLayer.path = [self cirleAndLine].CGPath;
//    self.topLayer.path = [self testCirle:point].CGPath;
    self.topLayer.path = [self resultPathWithPoint:point].CGPath;
}

- (CGPoint)originPoint {
    return CGPointMake(kMainScrrenWidth/2.0, kMainScrrenHeight/2.0);
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    static CGPoint startPoint;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            startPoint = [pan locationInView:self.view];
            break;
        case UIGestureRecognizerStateChanged: {
            CGPoint movePoint = [pan locationInView:self.view];
            self.position = CGPointMake(self.position.x + (movePoint.x - startPoint.x), self.position.y + (movePoint.y - startPoint.y));
            self.circleView.top = self.position.y;
            startPoint = movePoint;
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            NSLog(@"end: y = %f", self.position.y - kMainScrrenHeight/2.0);
            self.position = [self originPoint];
            [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.25 initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.circleView.top = self.position.y;
            } completion:^(BOOL finished) {
            }];
        }
            break;
            
        default:
            break;
    }
}

- (UIView *)circleView {
    if(_circleView == nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((kMainScrrenWidth-kCircleViewRadius)/2.0, kMainScrrenHeight/2.0, kCircleViewRadius, kCircleViewRadius)];
        view.backgroundColor = [UIColor clearColor];
        view.layer.cornerRadius = kCircleViewRadius/2.0;
        [self.view addSubview:view];
        _circleView = view;
    }
    return _circleView;
}

- (UIView *)topWaterView {
    if(_topWaterView == nil) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
        view.backgroundColor = [UIColor blueColor];
        [self.view addSubview:view];
        _topWaterView = view;
    }
    return _topWaterView;
}



- (CAShapeLayer *)bottomLayer {
    if(_bottomLayer == nil) {
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.fillColor = [UIColor clearColor].CGColor;
        shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        shapeLayer.lineWidth = 1.0;
        shapeLayer.frame = [UIScreen mainScreen].bounds;
        [self.view.layer addSublayer:shapeLayer];
        _bottomLayer = shapeLayer;
    }
    return _bottomLayer;
}

- (CAShapeLayer *)topLayer {
    if(_topLayer == nil) {
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.fillColor = [UIColor blueColor].CGColor;
        shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        shapeLayer.lineWidth = 1.0;
        shapeLayer.frame = [UIScreen mainScreen].bounds;
//        shapeLayer.fillRule = kCAFillRuleEvenOdd;
        [self.view.layer addSublayer:shapeLayer];
        _topLayer = shapeLayer;
    }
    return _topLayer;
}

- (CGPathRef)pathWithTopCenterPotin:(CGPoint)point {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, kMainScrrenHeight/2.0)];
    [path addLineToPoint:CGPointMake(0, kMainScrrenHeight)];
    [path addLineToPoint:CGPointMake(kMainScrrenWidth, kMainScrrenHeight)];
    [path addLineToPoint:CGPointMake(kMainScrrenWidth, kMainScrrenHeight/2.0)];
    [path addQuadCurveToPoint:CGPointMake(0, kMainScrrenHeight/2.0) controlPoint:point];
    return [path CGPath];
}

- (CGPathRef)topLayerWithPoint:(CGPoint)point {
    if(point.y <= kMainScrrenHeight/2.0) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(100, kMainScrrenHeight/2.0)];
        [path moveToPoint:CGPointMake(kMainScrrenWidth-100, kMainScrrenHeight/2.0)];
//        [path addLineToPoint:CGPointMake(0, kMainScrrenHeight)];
//        [path addLineToPoint:CGPointMake(kMainScrrenWidth, kMainScrrenHeight)];
//        [path addLineToPoint:CGPointMake(kMainScrrenWidth, kMainScrrenHeight/2.0)];
//        [path addQuadCurveToPoint:CGPointMake(100, kMainScrrenHeight/2.0) controlPoint:point];
        [path addCurveToPoint:CGPointMake(100, kMainScrrenHeight/2.0) controlPoint1:CGPointMake(kMainScrrenWidth-120, kMainScrrenHeight/2.0-50) controlPoint2:CGPointMake(120, kMainScrrenHeight/2.0-50)];
        return [path CGPath];
    }
    return nil;
}

- (CGPathRef)getBezierPathFromPoint1:(CGPoint)point1 radius1:(CGFloat)r1 Point2:(CGPoint)point2 radius2:(CGFloat)r2
{
    CGFloat x1 = point1.x;
    CGFloat y1 = point1.y;
    CGFloat x2 = point2.x;
    CGFloat y2 = point2.y;
    
    CGFloat distance = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
    
    CGFloat sinDegree;
    CGFloat cosDegree;
    
    if (distance == 0) {
        cosDegree = 1;
        sinDegree = 0;
    } else {
        cosDegree = (y2 - y1) / distance;
        sinDegree = (x2 - x1) / distance;
    }
    
    CGPoint pointA = CGPointMake(x1 - r1 * cosDegree, y1 + r1 * sinDegree);
    CGPoint pointB = CGPointMake(x1 + r1 * cosDegree, y1 - r1 * sinDegree);
    CGPoint pointC = CGPointMake(x2 + r2 * cosDegree, y2 - r2 * sinDegree);
    CGPoint pointD = CGPointMake(x2 - r2 * cosDegree, y2 + r2 * sinDegree);
    CGPoint pointN = CGPointMake(pointB.x + (distance / 2) * sinDegree, pointB.y + (distance / 2) * cosDegree);
    CGPoint pointM = CGPointMake(pointA.x + (distance / 2) * sinDegree, pointA.y + (distance / 2) * cosDegree);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointC controlPoint:pointN];
    [path addLineToPoint:pointD];
    [path addQuadCurveToPoint:pointA controlPoint:pointM];
    
    return [path CGPath];
    
}

- (CGPathRef)testPath {
    CGFloat radius = sqrt(2)/4.0*kMainScrrenWidth;
    CGPoint pointA = CGPointMake(0, 0);
    CGPoint pointB = CGPointMake(sqrt(2)/2.0*radius, sqrt(2)/2.0*radius);
    CGPoint pointC = CGPointMake(sqrt(2)*radius, radius);
    CGPoint pointD = CGPointMake(sqrt(2)*3/2.0*radius, sqrt(2)/2.0*radius);
    CGPoint pointE = CGPointMake(kMainScrrenWidth, 0);
    CGPoint center = CGPointMake(sqrt(2)*radius, 0);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointD controlPoint:pointC];
//    [path addArcWithCenter:center radius:radius startAngle:M_PI_4 endAngle:M_PI*3/4.0 clockwise:NO];
    [path addLineToPoint:pointE];
    
    return [path CGPath];
}

- (CGPathRef)myPathWithPoint:(CGPoint)point {
    CGFloat width = kMainScrrenWidth;
    CGFloat gap = kMainScrrenWidth - width;
    //计算角度
    float tanAngle = point.x*point.y/(point.x*point.x - point.y*point.y/4.0);
    float angle = atanf(tanAngle);
    //计算点B
    CGPoint pointB = CGPointMake(point.x-sin(angle)/2.0*point.y, (point.x-sin(angle)/2.0*point.y)*tan(angle));
    CGPoint pointC = CGPointMake(point.x+sin(angle)/2.0*point.y, pointB.y);
    
    CGFloat ex = abs(sqrt((pointB.x*pointB.x+pointB.y*pointB.y)/(1+tanAngle*tanAngle)/2.0));
    CGPoint pointE = CGPointMake(ex, tanAngle*ex);
    
    CGPoint pointF = CGPointMake(kMainScrrenWidth-gap-ex, pointE.y);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(gap, 0)];
//    [path addLineToPoint:pointB];
    [path addQuadCurveToPoint:pointB controlPoint:pointE];
    [path addArcWithCenter:CGPointMake(point.x, point.y/2.0) radius:point.y/2.0 startAngle:M_PI_2-angle endAngle:M_PI_2+angle clockwise:YES];
    [path addLineToPoint:pointC];
    [path addQuadCurveToPoint:CGPointMake(kMainScrrenWidth - gap, 0) controlPoint:pointF];
//    [path addLineToPoint:CGPointMake(kMainScrrenWidth - gap, 0)];
    return [path CGPath];
}

////抛物线 x*x = -2py
//- (CGPathRef)topWaterPathWithPoint:(CGPoint)point {
//    CGFloat width = 100;
//    CGPoint startPoint = CGPointMake(point.x - width/2.0, point.y);
//    CGPoint endPoint = CGPointMake(point.x + width/2.0, point.y);
//    CGPoint centerTopPoint = CGPointMake(point.x, point.y);
//    
//}

- (CGFloat)getPointXWithY:(CGFloat)y radius:(CGFloat)radius top:(CGPoint)point0 angle:(CGFloat)angle {
    return (y - point0.y - radius + (tan(angle/2.0))*point0.x + radius/cos(angle/2.0)) / tan(angle/2.0);
}

- (UIBezierPath *)waterPathWithTopPoint:(CGPoint)topPoint {
    CGFloat gap = (kMainScrrenHeight/2.0 - topPoint.y)*3;
    if(gap > 0) {
        NSLog(@"top: %f, gap: %f", topPoint.y, gap);
    }
    CGFloat radius = 100;
    if(gap < 3*radius) {
        radius = gap / 3.0;
    }

    CGPoint pointC = CGPointMake(kMainScrrenWidth/2.0, topPoint.y-gap+radius);
    CGPoint pointA = CGPointMake(kMainScrrenWidth/2.0-radius, pointC.y);
    CGPoint pointB = CGPointMake(kMainScrrenWidth/2.0+radius, pointC.y);
    CGPoint pointH = CGPointMake(gap, kMainScrrenHeight/2.0);
    CGPoint pointI = CGPointMake(kMainScrrenWidth-gap, kMainScrrenHeight/2.0);
    CGPoint point1 = CGPointMake(pointA.x, pointA.y + radius);
    CGPoint point2 = CGPointMake(kMainScrrenWidth/2.0, pointA.y + 2*radius);
    
    CGFloat offset = 4/3.0*radius;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    [path addCurveToPoint:pointB controlPoint1:CGPointMake(pointA.x, pointA.y-offset) controlPoint2:CGPointMake(pointB.x, pointB.y-offset)];
    [path addCurveToPoint:pointI controlPoint1:CGPointMake(kMainScrrenWidth-point1.x, point1.y) controlPoint2:CGPointMake(kMainScrrenWidth-point2.x, point2.y)];
    [path addLineToPoint:pointH];
    [path addCurveToPoint:pointA controlPoint1:point2 controlPoint2:point1];
    return path;
}

- (UIBezierPath *)sinPathWithPoint:(CGPoint)topPoint {
    CGFloat amplitude = (kMainScrrenHeight/2.0 - topPoint.y)*3;
    CGFloat periodWidth = kMainScrrenWidth;
    CGFloat offset = periodWidth/2.0/M_PI*(M_PI-2) + (kMainScrrenHeight/2.0 - topPoint.y)*2;
    CGPoint point1 = CGPointMake(0, kMainScrrenHeight/2.0);
    CGPoint point2 = CGPointMake(periodWidth/2.0, kMainScrrenHeight/2.0 - amplitude);
    CGPoint point3 = CGPointMake(offset, kMainScrrenHeight/2.0);
    CGPoint point4 = CGPointMake(point2.x-offset, kMainScrrenHeight/2.0 - amplitude);
    CGPoint point5 = CGPointMake(periodWidth, kMainScrrenHeight/2.0);
    CGPoint point6 = CGPointMake(point2.x+offset, point2.y);
    CGPoint point7 = CGPointMake(point5.x-offset, point5.y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point1];
    [path addCurveToPoint:point2 controlPoint1:point3 controlPoint2:point4];
    [path addCurveToPoint:point5 controlPoint1:point6 controlPoint2:point7];
    [path addLineToPoint:point1];
    return path;
}

- (void)buttonAction:(UIButton *)button {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
//    animation.fromValue = (id)[self sinPathWithPoint:self.tmpPoint].CGPath;
    animation.fromValue = (id)[self resultPathWithPoint:self.tmpPoint].CGPath;
    animation.toValue = (id)[self waterPathWithTopPoint:CGPointMake(kMainScrrenWidth, 350)].CGPath;
    animation.duration = 2.0;
    [self.topLayer addAnimation:animation forKey:@"PathAnimation"];
    self.topLayer.path = [self waterPathWithTopPoint:CGPointMake(kMainScrrenWidth, 350)].CGPath;
}

- (UIBezierPath *)cirleAndLine {
    //画圆
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(kMainScrrenWidth/2.0, kMainScrrenHeight/2.0) radius:100 startAngle:M_PI/3.0 endAngle:M_PI/3.0*2 clockwise:YES];
    return path;
}

//测试圆
- (UIBezierPath *)testCirle:(CGPoint)topPoint {
    CGFloat gap = (kMainScrrenHeight/2.0 - topPoint.y)*3;
    if(gap > 0) {
        //        NSLog(@"top: %f, gap: %f", topPoint.y, gap);
    }
    CGFloat radius = 100;
    if(gap < 3*radius) {
        radius = gap / 3.0;
    }
    
//    CGFloat angle = radius / 100.0 * M_PI;
    CGFloat angle = M_PI_4;
    
    CGPoint pointC = CGPointMake(kMainScrrenWidth/2.0, topPoint.y-gap+radius);
    CGPoint pointA = CGPointMake(pointC.x - radius * sin(angle/2.0), pointC.y - radius * cos(angle/2.0));
    CGPoint pointB = CGPointMake(pointC.x + radius * sin(angle/2.0), pointC.y - radius * cos(angle/2.0));
    CGPoint pointH = CGPointMake(gap, kMainScrrenHeight/2.0);
    CGPoint pointI = CGPointMake(kMainScrrenWidth-gap, kMainScrrenHeight/2.0);
    
    CGPoint point1 = CGPointMake(pointB.x, pointB.y + radius);
    CGPoint point2 = CGPointMake(kMainScrrenWidth/2.0, pointB.y + 2*radius);
    if(radius < 200) {
        point1.y = pointB.y + radius/3.0;
        CGPoint tmpTopPoint = CGPointMake(pointC.x, pointC.y-radius);
        CGFloat point1X = [self getPointXWithY:point1.y radius:radius top:tmpTopPoint angle:angle];
        CGFloat pointBX = [self getPointXWithY:pointB.y radius:radius top:tmpTopPoint angle:angle];
        CGFloat pointAX = [self getPointXWithY:pointA.y radius:radius top:tmpTopPoint angle:angle];
        point1 = CGPointMake(point1X + radius*2, point1.y);
        if(gap > 0) {
            NSLog(@"point1 x: %f, y: %f", point1.x, point1.y);
            NSLog(@"pointB x: %f, y: %f, x: %f", pointB.x, pointB.y, pointBX);
            NSLog(@"pointA x: %f, y: %f, x: %f", pointA.x, pointA.y, pointAX);
            NSLog(@"k = %f, tan = %f", (point1.y - pointB.y)/(point1.x - pointB.x), tan( angle / 2.0));
        }
        
    }
    
    CGFloat offset = 4/3.0*radius;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pointA];
    //    [path addCurveToPoint:pointB controlPoint1:CGPointMake(pointA.x, pointA.y-offset) controlPoint2:CGPointMake(pointB.x, pointB.y-offset)];
    [path addArcWithCenter:pointC radius:radius startAngle:M_PI + M_PI_2 - angle/2.0 endAngle:M_PI * 2 - (M_PI_2 - angle/2.0) clockwise:YES];
    [path addCurveToPoint:pointI controlPoint1:point1 controlPoint2:point2];
    [path addLineToPoint:pointH];
    [path addCurveToPoint:pointA controlPoint1:CGPointMake(kMainScrrenWidth-point2.x, point2.y) controlPoint2:CGPointMake(kMainScrrenWidth-point1.x, point1.y)];
    return path;
}

- (UIBezierPath *)resultPathWithPoint:(CGPoint)topPoint {
    //半径
    CGFloat radius = 50;
    //偏移量
    CGFloat offset = kMainScrrenWidth * (M_PI - 2) / 2.0 / M_PI;
    
    //点
    CGPoint pointA = CGPointMake(0, kMainScrrenHeight/2.0);
    CGPoint pointB = CGPointMake(kMainScrrenWidth, kMainScrrenHeight/2.0);
    CGPoint pointC = topPoint;
    CGPoint pointD = CGPointMake(pointA.x + offset, pointA.y);
    CGPoint pointE = CGPointMake(pointB.x - offset, pointB.y);
    
    CGPoint pointF, pointG;
    
    //跳动的高
    CGFloat h = kMainScrrenHeight/2.0 - topPoint.y;
//    NSLog(@"h = %f", h);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    /**
     * h < 2*radius 时， 显示正弦曲线
     * h < 3*radius 时， 向水滴效果转换
     * h >= 3*radius 时， 水滴效果形成
     */
    if(h < 2*radius) {
        pointF = CGPointMake(pointC.x - offset, pointC.y);
        pointG = CGPointMake(pointC.x + offset, pointC.y);
    }
    else if(h < 10*radius) {
        //初始角度
        CGFloat offsetAngle = M_PI*13/48.0;
        //角度
        CGFloat angle = (h-2*radius)/radius*(M_PI - offsetAngle) + offsetAngle;
        if(angle > M_PI) {
            angle = M_PI;
        }
        //中心点
        CGPoint pointH = CGPointMake(pointC.x, pointC.y + radius);
        //圆弧上的切线中点, point1为左切点， point2为右切点
        CGPoint point1 = CGPointMake(0, pointH.y + (h-radius)/5.0);
        CGPoint point2 = CGPointMake(0, pointH.y + (h-radius)/5.0);
        point2.x = [self getPointXWithY:point2.y radius:radius top:topPoint angle:angle];
        point1.x = kMainScrrenWidth - point2.x;
        
        //圆弧的两个终点
        CGPoint pointT1 = CGPointMake(pointH.x - radius * sin(angle/2.0), pointH.y - radius * cos(angle/2.0));
        CGPoint pointT2 = CGPointMake(pointH.x + radius * sin(angle/2.0), pointH.y - radius * cos(angle/2.0));
        
//        NSLog(@"point1 x: %f, y: %f", point2.x, point2.y);
//        NSLog(@"pointT2 x: %f, y: %f", pointT2.x, pointT2.y);
//        NSLog(@"k = %f, tan = %f", (pointT2.y - point2.y)/(pointT2.x - point2.x), tan( angle / 2.0));
//        
        
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:pointA];
        [path addCurveToPoint:pointT1 controlPoint1:pointD controlPoint2:point1];
        [path addArcWithCenter:pointH radius:radius startAngle:M_PI + M_PI_2 - angle/2.0 endAngle:M_PI * 2 - (M_PI_2 - angle/2.0) clockwise:YES];
        [path addCurveToPoint:pointB controlPoint1:point2 controlPoint2:pointE];
        [path addLineToPoint:pointA];
        return path;
        
        
//        //总共增加的y
//        CGFloat totalY = 1/3.0*radius;
//        //正弦值
//        CGFloat angle = asin((kMainScrrenHeight/2.0 - pointC.y - radius) / h);
//        //M点的值
//        CGPoint pointM = CGPointMake(angle/(2*M_PI)*kMainScrrenWidth, pointC.y + radius);
//        //N点与M点对应
//        CGPoint pointN = CGPointMake(kMainScrrenWidth - pointM.x, pointM.y);
//        //对应h的变化，F的y坐标的变化
//        CGFloat y = (h - 2*radius) * 1.0 / radius * totalY + pointC.y;
//        CGFloat fx = (y - pointC.y) * (3*radius - 3*offset) * 1.0 / radius + pointC.x - offset;
//        CGFloat gx = (y - pointC.y) * (3*offset - 3*radius) /radius + pointC.x + offset;
//        pointF = CGPointMake(fx, y);
//        pointG = CGPointMake(gx, y);
//        
//        //画正弦曲线
//        [path moveToPoint:pointA];
//        [path addQuadCurveToPoint:pointM controlPoint:pointD];
//        [path addCurveToPoint:pointN controlPoint1:pointF controlPoint2:pointG];
//        [path addQuadCurveToPoint:pointB controlPoint:pointE];
////        [path addCurveToPoint:pointC controlPoint1:pointD controlPoint2:pointF];
////        [path addCurveToPoint:pointB controlPoint1:pointG controlPoint2:pointE];
//        [path addLineToPoint:pointA];
//        return path;
    }
    else {
        pointF = CGPointMake(pointC.x - radius, pointC.y - 1.0/3*radius);
        pointG = CGPointMake(pointC.x + radius, pointF.y);
    }
    //画正弦曲线
    [path moveToPoint:pointA];
    [path addCurveToPoint:pointC controlPoint1:pointD controlPoint2:pointF];
    [path addCurveToPoint:pointB controlPoint1:pointG controlPoint2:pointE];
    [path addLineToPoint:pointA];
    
    return path;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
