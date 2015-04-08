//
//  CRFlatSwitch.m
//  CRFlatSwitch
//
//  Created by Vince Liang on 2015-04-07.
//  Copyright (c) 2015 crowley. All rights reserved.
//

#import "CRFlatSwitch.h"

static CGFloat finalStrokeEndForCheckmark = 0.85;
static CGFloat finalStrokeStartForCheckmark = 0.3;
static CGFloat checkmarkBounceAmount = 0.1;

@implementation CRFlatSwitch

- (id)init
{
    self = [super init];
    if (self) {
        [self setupDefaultValues];
        [self configure];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupDefaultValues];
        [self configure];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupDefaultValues];
        [self configure];
    }
    return self;
}

- (void)setupDefaultValues
{
    self.lineWidth = 2.0;
    self.strokeColor = [UIColor blackColor];
    self.trailStrokeColor = [UIColor grayColor];
    self.animationDuration = 0.3;
    selected_internal = false;
    trailCircle = [CAShapeLayer layer];
    circle = [CAShapeLayer layer];
    checkmark = [CAShapeLayer layer];
    checkmarkMidPoint = CGPointZero;
}

- (void)configure
{
    self.backgroundColor = [UIColor clearColor];
    [self configureShapeLayer:trailCircle];
    trailCircle.strokeColor = self.trailStrokeColor.CGColor;
    [self configureShapeLayer:circle];
    circle.strokeColor = self.strokeColor.CGColor;
    [self configureShapeLayer:checkmark];
    checkmark.strokeColor = self.strokeColor.CGColor;
    [self setSelected:NO animated:NO];
    [self addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureShapeLayer: (CAShapeLayer *)shapeLayer
{
    shapeLayer.lineJoin = kCALineJoinRound;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineWidth = self.lineWidth;
    shapeLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:shapeLayer];
}

#pragma mark - selected getter/setter
- (BOOL)isSelected
{
    return selected_internal;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setSelected:selected animated:false];
}

- (void)setSelected:(BOOL)selected animated: (BOOL)animated
{
    selected_internal = selected;
    [checkmark removeAllAnimations];
    [circle removeAllAnimations];
    [trailCircle removeAllAnimations];
    [self resetValues:animated];
    
    if (animated) {
        [self addAnimationsForSelected:selected_internal];
    }
}

#pragma mark - other properties setters
- (void)setLineWidth:(CGFloat)lineWidth
{
    circle.lineWidth = lineWidth;
    checkmark.lineWidth = lineWidth;
    trailCircle.lineWidth = lineWidth;
}

- (void)setStrokeColor:(UIColor *)strokeColor
{
    circle.strokeColor = strokeColor.CGColor;
    checkmark.strokeColor = strokeColor.CGColor;
}

- (void)setTrailStrokeColor:(UIColor *)trailStrokeColor
{
    trailCircle.strokeColor = trailStrokeColor.CGColor;
}

#pragma mark - draw the pictures.

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [super layoutSublayersOfLayer:layer];
    if ([layer isEqual:self.layer]) {
        CGPoint offset = CGPointZero;
        CGFloat radius = fmin(self.bounds.size.width, self.bounds.size.height) / 2;
        offset.x = self.bounds.size.width / 2 - radius;
        offset.y = self.bounds.size.height / 2 - radius;
        
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        
        CGRect circleRect = CGRectMake(offset.x, offset.y, radius * 2, radius * 2);
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:circleRect];
        trailCircle.path = circlePath.CGPath;
        circle.transform = CATransform3DIdentity;
        circle.frame = self.bounds;
        circle.path = [UIBezierPath bezierPathWithOvalInRect:circleRect].CGPath;
        circle.transform = CATransform3DMakeRotation((CGFloat)(212 * M_PI / 180), 0, 0, 1);
        
        CGPoint origin = CGPointMake(offset.x + radius, offset.y + radius);
        CGPoint checkStartPoint = CGPointZero;
        checkStartPoint.x = origin.x + radius * cos(212 * M_PI / 180.0);
        checkStartPoint.y = origin.y + radius * sin(212 * M_PI / 180.0);
        
        UIBezierPath *checkmarkPath = [UIBezierPath bezierPath];
        [checkmarkPath moveToPoint:checkStartPoint];
        
        checkmarkMidPoint = CGPointMake(offset.x + radius * 0.9, offset.y + radius * 1.4);
        [checkmarkPath addLineToPoint:checkmarkMidPoint];
        
        CGPoint checkEndPoint = CGPointZero;
        checkEndPoint.x = origin.x + radius * cos(320 * M_PI / 180.0);
        checkEndPoint.y = origin.y + radius * sin(320 * M_PI / 180.0);
        [checkmarkPath addLineToPoint:checkEndPoint];
        
        checkmark.frame = self.bounds;
        checkmark.path = checkmarkPath.CGPath;
        
        [CATransaction commit];
    }
}

- (void)resetValues:(BOOL)animated
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if ((selected_internal && animated) || (selected_internal == false && animated == false))  {
        checkmark.strokeEnd = 0.0;
        checkmark.strokeStart = 0.0;
        trailCircle.opacity = 0.0;
        circle.strokeStart = 0.0;
        circle.strokeEnd = 1.0;
    } else {
        checkmark.strokeEnd = finalStrokeEndForCheckmark;
        checkmark.strokeStart = finalStrokeStartForCheckmark;
        trailCircle.opacity = 1.0;
        circle.strokeStart = 0.0;
        circle.strokeEnd = 0.0;
    }
    [CATransaction commit];
}

- (void)addAnimationsForSelected: (BOOL)selected
{
    CFTimeInterval circleAnimationDuration = self.animationDuration * 0.5;
    
    CFTimeInterval checkmarkEndDuration = self.animationDuration * 0.8;
    CFTimeInterval checkmarkStartDuration = checkmarkEndDuration - circleAnimationDuration;
    CFTimeInterval checkmarkBounceDuration = self.animationDuration - checkmarkEndDuration;
    
    CAAnimationGroup *checkmarkAnimationGroup = [CAAnimationGroup animation];
    checkmarkAnimationGroup.removedOnCompletion = false;
    checkmarkAnimationGroup.fillMode = kCAFillModeForwards;
    checkmarkAnimationGroup.duration = self.animationDuration;
    checkmarkAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CAKeyframeAnimation *checkmarkStrokeEnd = [CAKeyframeAnimation animationWithKeyPath:@"strokeEnd"];
    checkmarkStrokeEnd.duration = checkmarkEndDuration + checkmarkBounceDuration;
    checkmarkStrokeEnd.removedOnCompletion = false;
    checkmarkStrokeEnd.fillMode = kCAFillModeForwards;
    checkmarkStrokeEnd.calculationMode = kCAAnimationPaced;
    
    if (selected) {
        checkmarkStrokeEnd.values = [NSArray arrayWithObjects:  [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:finalStrokeEndForCheckmark + checkmarkBounceAmount], [NSNumber numberWithFloat:finalStrokeEndForCheckmark], nil];
        checkmarkStrokeEnd.keyTimes = [NSArray arrayWithObjects:  [NSNumber numberWithDouble:0.0], [NSNumber numberWithDouble:checkmarkEndDuration], [NSNumber numberWithDouble:checkmarkEndDuration + checkmarkBounceDuration], nil];
    } else {
        checkmarkStrokeEnd.values = [NSArray arrayWithObjects:  [NSNumber numberWithFloat:finalStrokeEndForCheckmark], [NSNumber numberWithFloat:finalStrokeEndForCheckmark + checkmarkBounceAmount], [NSNumber numberWithFloat:-0.1], nil];
        checkmarkStrokeEnd.keyTimes = [NSArray arrayWithObjects:  [NSNumber numberWithDouble:0.0], [NSNumber numberWithDouble:checkmarkBounceDuration], [NSNumber numberWithDouble:checkmarkEndDuration + checkmarkBounceDuration], nil];
    }
    
    CAKeyframeAnimation *checkmarkStrokeStart = [CAKeyframeAnimation animationWithKeyPath:@"strokeStart"];
    checkmarkStrokeStart.duration = checkmarkStartDuration + checkmarkBounceDuration;
    checkmarkStrokeStart.removedOnCompletion = false;
    checkmarkStrokeStart.fillMode = kCAFillModeForwards;
    checkmarkStrokeStart.calculationMode = kCAAnimationPaced;
    
    if (selected) {
        checkmarkStrokeStart.values = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:0.0],
                                       [NSNumber numberWithFloat:finalStrokeStartForCheckmark + checkmarkBounceAmount],
                                       [NSNumber numberWithFloat:finalStrokeStartForCheckmark], nil];
        checkmarkStrokeStart.keyTimes = [NSArray arrayWithObjects:
                                         [NSNumber numberWithDouble:0.0],
                                         [NSNumber numberWithDouble:checkmarkStartDuration],
                                         [NSNumber numberWithDouble:checkmarkStartDuration + checkmarkBounceDuration],
                                         nil];
    } else {
        checkmarkStrokeStart.values = [NSArray arrayWithObjects:
                                       [NSNumber numberWithFloat:finalStrokeStartForCheckmark],
                                       [NSNumber numberWithFloat:finalStrokeStartForCheckmark + checkmarkBounceAmount],
                                       [NSNumber numberWithFloat:0.0],
                                       nil];
        checkmarkStrokeStart.keyTimes = [NSArray arrayWithObjects:
                                         [NSNumber numberWithDouble:0.0],
                                         [NSNumber numberWithDouble:checkmarkBounceDuration],
                                         [NSNumber numberWithDouble:checkmarkStartDuration + checkmarkBounceDuration],
                                         nil];
    }
    
    if (selected) {
        checkmarkStrokeStart.beginTime = circleAnimationDuration;
    }
    
    checkmarkAnimationGroup.animations = @[checkmarkStrokeEnd, checkmarkStrokeStart];
    [checkmark addAnimation:checkmarkAnimationGroup forKey:@"checkmarkAnimation"];
    
    CAAnimationGroup *circleAnimationGroup = [CAAnimationGroup animation];
    circleAnimationGroup.duration = self.animationDuration;
    circleAnimationGroup.removedOnCompletion = false;
    circleAnimationGroup.fillMode = kCAFillModeForwards;
    circleAnimationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    CABasicAnimation *circleStrokeEnd = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    circleStrokeEnd.duration = circleAnimationDuration;
    if (selected) {
        circleStrokeEnd.beginTime = 0.0;
        
        circleStrokeEnd.fromValue = [NSNumber numberWithFloat:1.0];
        circleStrokeEnd.toValue = [NSNumber numberWithFloat: -0.1];
    } else {
        circleStrokeEnd.beginTime = self.animationDuration - circleAnimationDuration;
        
        circleStrokeEnd.fromValue = [NSNumber numberWithFloat:0.0];
        circleStrokeEnd.toValue = [NSNumber numberWithFloat: 1.0];
    }
    circleStrokeEnd.removedOnCompletion = false;
    circleStrokeEnd.fillMode = kCAFillModeForwards;
    
    circleAnimationGroup.animations = @[circleStrokeEnd];
    [circle addAnimation:circleAnimationGroup forKey:@"circleStrokeEnd"];
    
    CABasicAnimation *trailCircleColor = [CABasicAnimation animationWithKeyPath:@"opacity"];
    trailCircleColor.duration = self.animationDuration;
    if (selected) {
        trailCircleColor.fromValue = [NSNumber numberWithFloat: 0.0];
        trailCircleColor.toValue = [NSNumber numberWithFloat: 1.0];
    } else {
        trailCircleColor.fromValue = [NSNumber numberWithFloat: 1.0];
        trailCircleColor.toValue = [NSNumber numberWithFloat: 0.0];
    }
    trailCircleColor.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    trailCircleColor.fillMode = kCAFillModeForwards;
    trailCircleColor.removedOnCompletion = false;
    [trailCircle addAnimation:trailCircleColor forKey:@"trailCircleColor"];
}

#pragma mark - actions

- (void)didTouchUpInside: (id)sender
{
    [self setSelected:!self.selected animated:YES];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end
