//
//  ViewController.m
//  JellyAnimation
//
//  Created by 刘春桂 on 16/6/5.
//  Copyright © 2016年 liuchungui. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Additional.h"

#define kMainScrrenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScrrenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@property (nonatomic, strong) UIView *circleView;
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
    self.shapeLayer.path = [self pathWithTopCenterPotin:CGPointMake(layer.position.x, layer.position.y-10)];
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
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake((kMainScrrenWidth-20)/2.0, kMainScrrenHeight/2.0, 20, 20)];
        view.backgroundColor = [UIColor redColor];
        view.layer.cornerRadius = 10;
        [self.view addSubview:view];
        _circleView = view;
    }
    return _circleView;
}

- (CAShapeLayer *)shapeLayer {
    if(_shapeLayer == nil) {
        CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
        shapeLayer.fillColor = [UIColor blueColor].CGColor;
        shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        shapeLayer.lineWidth = 1.0;
        shapeLayer.frame = [UIScreen mainScreen].bounds;
        [self.view.layer addSublayer:shapeLayer];
        _shapeLayer = shapeLayer;
    }
    return _shapeLayer;
}

- (CGPathRef)pathWithTopCenterPotin:(CGPoint)point {
    CGFloat scrrenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat scrrenWidth = [UIScreen mainScreen].bounds.size.width;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, scrrenHeight/2.0)];
    [path addLineToPoint:CGPointMake(0, scrrenHeight)];
    [path addLineToPoint:CGPointMake(scrrenWidth, scrrenHeight)];
    [path addLineToPoint:CGPointMake(scrrenWidth, scrrenHeight/2.0)];
//    [path addCurveToPoint:CGPointMake(0, scrrenHeight/2.0) controlPoint1:CGPointMake(scrrenWidth/2.0, 100) controlPoint2:CGPointMake(scrrenWidth/2.0, 100)];
    [path addQuadCurveToPoint:CGPointMake(0, scrrenHeight/2.0) controlPoint:point];
    return [path CGPath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
