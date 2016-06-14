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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.position = [self originPoint];
    
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
    
    if(point.y < [self originPoint].y) {
        CGFloat waterRadius = [self originPoint].y - point.y;
        self.topLayer.path = [self getBezierPathFromPoint1:point radius1:waterRadius Point2:CGPointMake(layer.position.x, kMainScrrenHeight) radius2:kMainScrrenHeight/2.0-5*waterRadius];
        //顶部的水滴
        self.topWaterView.size = CGSizeMake(waterRadius*2, waterRadius*2);
        self.topWaterView.layer.cornerRadius = waterRadius;
        self.topWaterView.center = point;
    }
    else {
        self.topLayer.path = nil;
        
    }
    if(y != kMainScrrenHeight/2.0) {
        NSLog(@"start: y = %f", y - kMainScrrenHeight/2.0);
    }
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
        shapeLayer.fillColor = [UIColor blueColor].CGColor;
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
