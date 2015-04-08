//
//  CRFlatSwitch.h
//  CRFlatSwitch
//
//  Created by Vince Liang on 2015-04-07.
//  Copyright (c) 2015 crowley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CRFlatSwitch : UIControl {
    @private
    CAShapeLayer *trailCircle;
    CAShapeLayer *circle;
    CAShapeLayer *checkmark;
    CGPoint checkmarkMidPoint;
    BOOL selected_internal;
}

@property (assign, nonatomic) IBInspectable CGFloat lineWidth;
@property (strong, nonatomic) IBInspectable UIColor *strokeColor;
@property (strong, nonatomic) IBInspectable UIColor *trailStrokeColor;
@property (assign, nonatomic) IBInspectable CFTimeInterval animationDuration;
//@property (assign, nonatomic) IBInspectable BOOL selected;

@end
