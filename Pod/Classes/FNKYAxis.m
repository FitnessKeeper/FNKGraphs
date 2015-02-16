//
//  FNKYAxis.m
//  FNKGraphs
//
//  Created by Phillip Connaughton on 11/26/14.
//  Copyright (c) 2014 fnk. All rights reserved.
//

#import "FNKYAxis.h"

@implementation FNKYAxis

-(void) drawAxis:(UIView*) view
{
    UIBezierPath* bezPath = [[UIBezierPath alloc] init];
    [bezPath moveToPoint:CGPointMake(self.marginLeft, 0)];
    [bezPath addLineToPoint:CGPointMake(self.marginLeft, self.graphHeight)];
    [bezPath closePath];
    
    CAShapeLayer* layer = [[CAShapeLayer alloc] init];
    layer.path = bezPath.CGPath;
    layer.fillColor = self.fillColor.CGColor;
    layer.strokeColor = self.strokeColor.CGColor;
    
    [view.layer addSublayer:layer];
    
    CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 2;
    pathAnimation.fromValue = @(0);
    pathAnimation.toValue = @(1);
    
    [layer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    //Draw all lines
    CGFloat tickInterval = self.graphHeight / self.ticks;
    for (int index = 0 ; index < self.ticks+1 ; index++)
    {
        UIBezierPath* bezPath = [[UIBezierPath alloc] init];
        
        CGFloat xVal = self.marginLeft;
        CGFloat yVal = (index * tickInterval);
        
        [bezPath moveToPoint:CGPointMake(xVal, yVal)];
        
        if(self.tickType == FNKTickTypeOutside)
        {
            [bezPath addLineToPoint:CGPointMake(xVal - 3.0, yVal)];
        }
        else if(self.tickType == FNKTickTypeBehind)
        {
            [bezPath addLineToPoint:CGPointMake(xVal + self.graphWidth, yVal)];
        }
        
        CAShapeLayer* layer  = [[CAShapeLayer alloc] init];
        layer.path = bezPath.CGPath;
        layer.fillColor = self.tickFillColor.CGColor;
        layer.strokeColor = self.tickStrokeColor.CGColor;
        
        [view.layer addSublayer:layer];
        
        CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 1;
        pathAnimation.fromValue = @(0);
        pathAnimation.toValue = @(1);
        
        [layer addAnimation:pathAnimation forKey:@"strokeEnd"];
    }
}

-(UIView*) addTicksToView:(UIView*) view
{
    CGFloat tickInterval = self.graphHeight / self.ticks;
    
    UIView* labelView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40,  view.frame.size.height)];
    [labelView setAlpha:0.0];
    [view addSubview:labelView];
    labelView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *labelViewDictionary = NSDictionaryOfVariableBindings(labelView);
    NSString *labelViewConstraintString = [NSString stringWithFormat:@"|-0-[labelView(%ld)]",(long)@(self.marginLeft).integerValue];
    NSArray *widthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:labelViewConstraintString
                                                                        options:0
                                                                        metrics:nil
                                                                          views:labelViewDictionary];
    [view addConstraints:widthConstraints];
    
    labelViewConstraintString = [NSString stringWithFormat:@"V:|-0-[labelView]-0-|"];
    NSArray *heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:labelViewConstraintString
                                                                         options:0
                                                                         metrics:nil
                                                                           views:labelViewDictionary];
    [view addConstraints:heightConstraints];
    
    [view layoutSubviews];
    
    UILabel* prevLabel;
    
    for (int index = 0 ; index < self.ticks ; index++)
    {
        if (index == self.ticks)
        {
            continue;
        }
        
        CGFloat yVal = (index * tickInterval);
        
        //Okay those are the ticks. Now we need the labels
        UILabel* tickLabel = [[UILabel alloc] init];
        
        CGFloat originalVal = ((self.graphHeight - yVal) / self.scaleFactor) + self.axisMin;
        tickLabel.text = self.tickFormat(originalVal);
        tickLabel.textAlignment = NSTextAlignmentRight;
        tickLabel.font = self.tickFont;
        [tickLabel setAdjustsFontSizeToFitWidth:YES];
        [tickLabel setMinimumScaleFactor:.5];
        [labelView addSubview:tickLabel];
        
        tickLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(tickLabel);
        NSString *constraintString = [NSString stringWithFormat:@"|-0-[tickLabel]-2-|"];
        NSArray *widthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                            options:0
                                                                            metrics:nil
                                                                              views:viewDictionary];
        [labelView addConstraints:widthConstraints];
        
        //TODO: This is a bit of a hack since I don't know what the height of the label is actually going to be
        constraintString = [NSString stringWithFormat:@"V:|-(%f)-[tickLabel]", yVal - 5];
        NSArray *heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewDictionary];
        [labelView addConstraints:heightConstraints];
        
        [labelView layoutSubviews];
        
        prevLabel = tickLabel;
    }
    
    [UIView animateWithDuration:1
                     animations:^{
                         [labelView setAlpha:1.0];
                         
                     }];
    
    
    
    return labelView;
}

@end
