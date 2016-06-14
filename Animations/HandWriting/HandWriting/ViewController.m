//
//  ViewController.m
//  HandWriting
//
//  Created by 刘春桂 on 16/6/2.
//  Copyright © 2016年 liuchungui. All rights reserved.
//

#import "ViewController.h"
#import <CoreText/CoreText.h>

@interface ViewController ()
@property (nonatomic, strong) CAShapeLayer *shapeLayer;
@end

@implementation ViewController

- (IBAction)storeEndAction:(id)sender {
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"strokeEnd";
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 5.0;
    
    [self.shapeLayer addAnimation:animation forKey:@"StorkeEndAnimation"];
}
- (IBAction)animationStart:(id)sender {
}

- (IBAction)storeStartAction:(id)sender {
    CABasicAnimation *animation = [[CABasicAnimation alloc] init];
    animation.keyPath = @"strokeStart";
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.duration = 5.0;
    
    [self.shapeLayer addAnimation:animation forKey:@"StrokeStartAnimation"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    shapeLayer.strokeColor = [UIColor blueColor].CGColor;
    shapeLayer.lineWidth = 2;
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
//    shapeLayer.backgroundColor = [UIColor redColor].CGColor;
    shapeLayer.path = [self pathFromText:[self attributedStringWithString:@"liuchungui"]];
    shapeLayer.frame = CGRectMake(100, 100, 250, 250);
    [self.view.layer addSublayer:shapeLayer];
    
    self.shapeLayer = shapeLayer;
    // Do any additional setup after loading the view, typically from a nib.
}

- (NSAttributedString *)attributedStringWithString:(NSString *)string {
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName: [UIColor redColor], NSFontAttributeName: [UIFont systemFontOfSize:30]}];
    return attributeString;
}

- (CGPathRef)pathFromText:(NSAttributedString *)text {
    CGMutablePathRef lettersPath = CGPathCreateMutable();
    CTLineRef line = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)text);
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    for(CFIndex i = 0; i < CFArrayGetCount(runArray); i ++) {
        //获取某个run
        CTRunRef run = CFArrayGetValueAtIndex(runArray, i);
        CFIndex glyphCount = CTRunGetGlyphCount(run);
        //attributes
        CFDictionaryRef dictionary = CTRunGetAttributes(run);
        CTFontRef font = CFDictionaryGetValue(dictionary, kCTFontAttributeName);
        for(CFIndex j = 0; j < glyphCount; j++) {
            CGGlyph glyph;
            CFRange range = CFRangeMake(j, 1);
            CTRunGetGlyphs(run, range, &glyph);
            CGPoint position;
            CTRunGetPositions(run, range, &position);
            //获取path
            CGPathRef path = CTFontCreatePathForGlyph(font, glyph, nil);
            CGAffineTransform transform = CGAffineTransformMakeTranslation(position.x, position.y);
            CGPathAddPath(lettersPath, &transform, path);
        }
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:lettersPath];
    CGRect boundingBox = CGPathGetBoundingBox(lettersPath);
    CGPathRelease(lettersPath);
    CFRelease(line);
    
    [path applyTransform:CGAffineTransformMakeScale(1, -1)];
    [path applyTransform:CGAffineTransformMakeTranslation(0, boundingBox.size.height)];
    
    return path.CGPath;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
