//
//  FNKDemoBarGraphViewController.m
//  FNKGraphs
//
//  Created by Phillip Connaughton on 1/12/15.
//  Copyright (c) 2015 Phillip Connaughton. All rights reserved.
//

#import "FNKDemoBarGraphViewController.h"
#import <FNKGraphs/FNKBarSectionData.h>

#define kDistanceKey @"distance"
#define kDateKey @"date"


@interface FNKDemoBarGraphViewController ()

@end

@implementation FNKDemoBarGraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addBarGraph];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self.barGraphVC drawGraph:nil];
}

-(void)addBarGraph
{
    self.barGraphVC = [[FNKGraphsHistogramGraphViewController alloc] initWithFrame:CGRectMake(0, 70, 320, 160)];
    
    [self.barGraphVC setDataArray:[self getData]];
    
    [self.barGraphVC setNumberOfBuckets:^int{
        return 4;        
    }];
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    
    [self.barGraphVC setBucketForObject:^int(id object) {
        NSDictionary* dict = (NSDictionary*)object;
        NSNumber* dateNumber = [dict objectForKey:kDateKey];
        
        NSDate* date = [NSDate dateWithTimeIntervalSince1970: [dateNumber integerValue]/1000];
        
        NSDateComponents *components = [cal components:NSCalendarUnitMonth fromDate:date];
        
        int month = (int)[components month];
        
        return month - 9;
    }];
    
    [self.barGraphVC setValueForObject:^CGFloat(id object) {
        NSDictionary* dict = (NSDictionary*)object;
        NSNumber* dist = [dict objectForKey:kDistanceKey];
        return dist.floatValue;
    }];
    
    [self.barGraphVC setDateForObject:^NSDate *(id object) {
        NSDictionary* dict = (NSDictionary*)object;
        NSNumber* dateNumber = [dict objectForKey:kDateKey];
        NSDate* date = [NSDate dateWithTimeIntervalSince1970: [dateNumber integerValue]/1000];
        return date;
    }];
    
    [self.barGraphVC.yAxis setTickFormat:^NSString *(CGFloat value) {
        return [NSString stringWithFormat:@"%.0f",value];
    }];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd"];
    
    [self.barGraphVC.xAxis setTickFormat:^NSString *(CGFloat value) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:value];
        return [dateFormat stringFromDate:date];
    }];
    
    
    __weak __typeof(self) safeSelf = self;
    [self.barGraphVC setBarAdded:^(FNKBar *barView, int barNum) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        [label setText:@"val"];
        [label setTextColor:[UIColor greenColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setAlpha:0.0];
        
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [safeSelf.barGraphVC.view addSubview:label];
        
        [safeSelf.barGraphVC.view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeLeft
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:barView
                                                              attribute:NSLayoutAttributeLeft
                                                             multiplier:1.0
                                                               constant:0.0]];
        [safeSelf.barGraphVC.view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:barView
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
        
        [safeSelf.barGraphVC.view addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeBottom
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:barView
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1.0
                                                               constant:2.0]];
        [safeSelf.barGraphVC.view layoutSubviews];
        
        [UIView animateWithDuration:1.5
                         animations:^{
                             [label setAlpha:1.0];
                         }];
    }];
    
    self.barGraphVC.yAxis.strokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.yAxis.fillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.yAxis.tickFillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.yAxis.tickStrokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    
    self.barGraphVC.xAxis.strokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.xAxis.fillColor =[UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.xAxis.tickFillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.xAxis.tickStrokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    
    [self.barGraphVC setColorForBar:^UIColor *(int barNum) {
        return [UIColor orangeColor];        
    }];
    
    self.barGraphVC.delegate = self;
    
    [self addChildViewController:self.barGraphVC];
    
    [self.barGraphContainer addSubview:self.barGraphVC.view];
    
    UIView* barView = self.barGraphVC.view;
    
    barView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(barView);
    NSString *constraintString = [NSString stringWithFormat:@"|-10-[barView]-10-|"];
    NSArray *widthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewDictionary];
    [self.barGraphContainer addConstraints:widthConstraints];
    
    constraintString = [NSString stringWithFormat:@"V:|-10-[barView]-10-|"];
    NSArray *heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDictionary];
    [self.barGraphContainer addConstraints:heightConstraints];
    
    [self.barGraphContainer layoutSubviews];
}

#pragma mark Delegate methods

-(void)touchedGraph:(FNKGraphsViewController*)chart val:(CGFloat)val point:(CGPoint)point userGenerated:(BOOL)userGenerated
{
}

-(void)graphTouchesEnded:(FNKGraphsViewController*)chart
{
    
}

-(void)touchedBar:(FNKGraphsViewController*)chart data:(FNKChartOverlayData*)data
{
    
}

#pragma mark Data functions

-(NSMutableArray*)getData
{
    NSMutableArray* data = [NSMutableArray array];
    //Dec 12, 2014
    [data addObject:@{kDistanceKey : @(2), kDateKey : @(1418425522000)}];
    [data addObject:@{kDistanceKey : @(4), kDateKey : @(1418425522000)}];
    [data addObject:@{kDistanceKey : @(6), kDateKey : @(1418425522000)}];
    [data addObject:@{kDistanceKey : @(1), kDateKey : @(1418425522000)}];
    
    //Nov 12, 2014
    [data addObject:@{kDistanceKey : @(1), kDateKey : @(1415833522000)}];
    [data addObject:@{kDistanceKey : @(2), kDateKey : @(1415833522000)}];
    [data addObject:@{kDistanceKey : @(5), kDateKey : @(1415833522000)}];
    [data addObject:@{kDistanceKey : @(2), kDateKey : @(1415833522000)}];

    //Oct 12, 2014
    [data addObject:@{kDistanceKey : @(9), kDateKey : @(1413155122000)}];
    [data addObject:@{kDistanceKey : @(2), kDateKey : @(1413155122000)}];
    [data addObject:@{kDistanceKey : @(7), kDateKey : @(1413155122000)}];
    [data addObject:@{kDistanceKey : @(2), kDateKey : @(1413155122000)}];
    
    //Sept 12, 2014
    [data addObject:@{kDistanceKey : @(9), kDateKey : @(1410563122000)}];
    [data addObject:@{kDistanceKey : @(1), kDateKey : @(1410563122000)}];
    [data addObject:@{kDistanceKey : @(2), kDateKey : @(1410563122000)}];
    
    return data;
}
@end
