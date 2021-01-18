//
//  FNKDemoInteractiveGraphsViewController.m
//  FNKGraphs
//
//  Created by Phillip Connaughton on 1/13/15.
//  Copyright (c) 2015 Phillip Connaughton. All rights reserved.
//

#import "FNKDemoInteractiveGraphsViewController.h"
#import "JsonUtils.h"
#import "FNKWeatherDay.h"

#define fnkAnimationDuration 0.5

@interface FNKDemoInteractiveGraphsViewController()

@property (nonatomic, strong) NSMutableArray* dataSet;
@property (nonatomic, strong) NSMutableArray* filteredDataSet;

@end

@implementation FNKDemoInteractiveGraphsViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self setupDataSet];
    [self addPieChart];
    [self addLineChart];
    [self addBarChart];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.pieGraphVC drawGraph:nil];
    [self.lineGraphVC drawGraph:nil];
    [self.barGraphVC drawGraph:nil];
}

//rainfall by day of week
-(void)addPieChart
{
    self.pieGraphVC = [[FNKGraphsPieGraphViewController alloc] initWithFrame:CGRectMake(0, 70, 320, 160)];
    [self.pieGraphVC setDataArray:self.dataSet];
    
    [self.pieGraphVC setNumberOfSlices:^int{
        return 7;
    }];
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    [self.pieGraphVC setSliceForObject:^NSInteger(id object) {
        FNKWeatherDay* day = (FNKWeatherDay*)object;
        NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday fromDate:day.date];
        NSInteger dayOfWeek = [components weekday];
        return dayOfWeek - 1;
    }];
    
    [self.pieGraphVC setValueForObject:^CGFloat(id object) {
        FNKWeatherDay* day = (FNKWeatherDay*)object;
        return day.percipitation;
    }];
    
    [self.pieGraphVC setColorForSlice:^UIColor *(int slice) {
        if(slice == 0)
        {
            return [UIColor purpleColor];
        }
        else if(slice == 1)
        {
            return [UIColor yellowColor];
        }
        else if(slice == 2)
        {
            return [UIColor orangeColor];
        }
        else if(slice == 3)
        {
            return [UIColor redColor];
        }
        else if(slice == 4)
        {
            return [UIColor magentaColor];
        }
        else if(slice == 5)
        {
            return [UIColor cyanColor];
        }
        else if(slice == 6)
        {
            return [UIColor greenColor];
        }
        return nil;
    }];
    
    [self.pieGraphVC setNameForSlice:^NSString *(int slice) {
        if(slice == 0)
        {
            return @"Sunday";
        }
        else if(slice == 1)
        {
            return @"Monday";
        }
        else if(slice == 2)
        {
            return @"Tuesday";
        }
        else if(slice == 3)
        {
            return @"Wednesday";
        }
        else if(slice == 4)
        {
            return @"Thursday";
        }
        else if(slice == 5)
        {
            return @"Friday";
        }
        else if(slice == 6)
        {
            return @"Saturday";
        }
        return nil;
    }];
    
    self.pieGraphVC.delegate = self;
    
    [self.pieGraphVC setSliceBorderColor:[UIColor lightGrayColor]];
    [self.pieGraphVC setSliceLabelColor:[UIColor grayColor]];
    [self.pieGraphVC setSliceLabelFont:[UIFont systemFontOfSize:12.0f]];
    
    [self addChildViewController:self.pieGraphVC];
    
    [self.pieChartContainer addSubview:self.pieGraphVC.view];
    
    UIView* pieView = self.pieGraphVC.view;
    
    pieView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(pieView);
    NSString *constraintString = [NSString stringWithFormat:@"|-40-[pieView]-40-|"];
    NSArray *widthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewDictionary];
    [self.pieChartContainer addConstraints:widthConstraints];
    
    constraintString = [NSString stringWithFormat:@"V:|-40-[pieView]-40-|"];
    NSArray *heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDictionary];
    [self.pieChartContainer addConstraints:heightConstraints];
    
    [self.pieChartContainer layoutSubviews];
}

//rainfall
-(void)addLineChart
{
    self.lineGraphVC = [[FNKGraphsLineGraphViewController alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
    [self.lineGraphVC setDataArray:[self dataSet]];
    
    //    [self.paceChartsVC addChartOverlay:[[FNKChartOverlayBars alloc] init]];
    
    //Set custom colors for chart -- Not necessary as all charts will have defaults
    self.lineGraphVC.yAxis.strokeColor = [UIColor clearColor];
    self.lineGraphVC.yAxis.fillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.lineGraphVC.yAxis.tickFillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.lineGraphVC.yAxis.tickStrokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    
    self.lineGraphVC.xAxis.strokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.lineGraphVC.xAxis.fillColor =[UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.lineGraphVC.xAxis.tickFillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.lineGraphVC.xAxis.tickStrokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    
    UIColor* avColor = [UIColor blackColor];
    [self.lineGraphVC setAverageLineColor:[avColor colorWithAlphaComponent:0.2]];
    [self.lineGraphVC setAverageLineColor:[UIColor blackColor]];
    
    
    self.lineGraphVC.lineStrokeColor = [UIColor colorWithRed:0.48828125 green:0.83203125 blue:0.98828125 alpha:1.0];
    
    [self.lineGraphVC setPointForObject:^CGPoint(id object) {
        FNKWeatherDay* day = (FNKWeatherDay*) object;
        return CGPointMake([day.date timeIntervalSince1970], day.avgTemp);
    }];
    
    [self.lineGraphVC.yAxis setTickFormat:^NSString *(CGFloat value) {
        return [NSString stringWithFormat:@"%.0f",value];
    }];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd"];
    
    [self.lineGraphVC.xAxis setTickFormat:^NSString *(CGFloat value) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:value];
        return [dateFormat stringFromDate:date];
    }];
    
    self.lineGraphVC.delegate = self;
    
    [self addChildViewController:self.lineGraphVC];
    
    [self.lineGraphContainer addSubview:self.lineGraphVC.view];
    
    UIView* paceView = self.lineGraphVC.view;
    
    paceView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *viewDictionary = NSDictionaryOfVariableBindings(paceView);
    NSString *constraintString = [NSString stringWithFormat:@"|[paceView]|"];
    NSArray *widthConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                        options:0
                                                                        metrics:nil
                                                                          views:viewDictionary];
    [self.lineGraphContainer addConstraints:widthConstraints];
    
    constraintString = [NSString stringWithFormat:@"V:|-10-[paceView]-10-|"];
    NSArray *heightConstraints = [NSLayoutConstraint constraintsWithVisualFormat:constraintString
                                                                         options:0
                                                                         metrics:nil
                                                                           views:viewDictionary];
    [self.lineGraphContainer addConstraints:heightConstraints];
    
    [self.lineGraphContainer layoutSubviews];
}

//rainfall by month
-(void)addBarChart
{
    self.barGraphVC = [[FNKGraphsHistogramGraphViewController alloc] initWithFrame:CGRectMake(0, 70, 320, 160)];
    
    [self.barGraphVC setDataArray:self.dataSet];
    
    [self.barGraphVC setNumberOfBuckets:^int{
        return 12;
    }];
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    
    [self.barGraphVC setBucketForObject:^int(id object) {
        FNKWeatherDay* day = (FNKWeatherDay*)object;
        NSDateComponents *components = [cal components:NSCalendarUnitMonth fromDate:day.date];
        return (int)[components month] - 1;
    }];
    
    [self.barGraphVC setValueForObject:^CGFloat(id object) {
        FNKWeatherDay* day = (FNKWeatherDay*)object;
        return day.percipitation;
    }];
    
    [self.barGraphVC setMinDate:((FNKWeatherDay*)[self.dataSet firstObject]).date];
    [self.barGraphVC setMaxDate:((FNKWeatherDay*)[self.dataSet lastObject]).date];
    
    self.barGraphVC.yAxis.strokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.yAxis.fillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.yAxis.tickFillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.yAxis.tickStrokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    
    self.barGraphVC.xAxis.strokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.xAxis.fillColor =[UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.xAxis.tickFillColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    self.barGraphVC.xAxis.tickStrokeColor = [UIColor colorWithRed:0.91015625 green:0.91015625 blue:0.91015625 alpha:0.7];
    
    [self.barGraphVC.yAxis setTickFormat:^NSString *(CGFloat value) {
        return [NSString stringWithFormat:@"%.0f",value];
    }];
    
    [self.barGraphVC setDateForObject:^NSDate *(id object) {
        FNKWeatherDay* day = (FNKWeatherDay*)object;
        return day.date;
    }];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd"];
    
    [self.barGraphVC.xAxis setTickFormat:^NSString *(CGFloat value) {
        NSDate* date = [NSDate dateWithTimeIntervalSince1970:value];
        return [dateFormat stringFromDate:date];
    }];
    
    [self.barGraphVC setColorForBar:^UIColor *(int barNum) {
        return [UIColor orangeColor];
    }];
    
    __weak __typeof(self) safeSelf = self;
    [self.barGraphVC setBarAdded:^(FNKBar * barView, int barNum) {
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
        
        FNKWeatherDay* day = (FNKWeatherDay*)[safeSelf.dataSet objectAtIndex:barNum];
        [label setText:[NSString stringWithFormat:@"%4.f", day.percipitation]];
        [label setTextColor:[UIColor greenColor]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setAlpha:0.0];
        [label setMinimumScaleFactor:.1];
        [label setAdjustsFontSizeToFitWidth:YES];
        
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

#pragma mark Create data set

-(void)setupDataSet
{
    self.dataSet = [NSMutableArray array];
    NSString* filePath = [[NSBundle mainBundle] pathForResource:@"BostonWeather" ofType:@"json"];
    NSError* error;
    
    NSMutableString* fileContents = [NSMutableString stringWithContentsOfFile: filePath
                                                                 usedEncoding: nil
                                                                        error: &error];
    
    NSArray* jsonArray = [JsonUtils arrayFromJson:fileContents];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    for(NSDictionary* dict in jsonArray)
    {
        FNKWeatherDay* wDay = [[FNKWeatherDay alloc] init];
        
        NSNumber* dateNumber = [dict objectForKey:@"DATE"];
        NSString* dateString = [dateNumber stringValue];
        NSDate *capturedDate = [dateFormatter dateFromString: dateString];
        
        [wDay setAvgTemp:((NSNumber*)[dict objectForKey:@"TMAX"]).floatValue]; //Maximum temperature (tenths of degrees C)
        [wDay setPercipitation:((NSNumber*)[dict objectForKey:@"PRCP"]).floatValue]; // Precipitation (tenths of mm)
        [wDay setWindSpeed:((NSNumber*)[dict objectForKey:@"AWND"]).floatValue]; //Average daily wind speed (tenths of meters per second)
        [wDay setDate:capturedDate];
        
        [self.dataSet addObject:wDay];
    }
    
    
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

-(void)pieSliceSelected:(FNKGraphsViewController *)chart sliceIndex:(int)sliceIndex
{
    if(sliceIndex == -1)
    {
        [self.lineGraphVC filterLine:nil duration:fnkAnimationDuration completion:nil];
        [self.barGraphVC filterBars:nil duration:fnkAnimationDuration completion:nil];
        return;
    }
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    self.filteredDataSet = [NSMutableArray array];
    for(FNKWeatherDay* wDay in self.dataSet)
    {
        NSDateComponents *components = [gregorian components:NSCalendarUnitWeekday fromDate:wDay.date];
        NSInteger dayOfWeek = [components weekday] - 1;
        
        if(dayOfWeek == sliceIndex)
        {
            [self.filteredDataSet addObject:wDay];
        }
    }
    
    [self.lineGraphVC filterLine:self.filteredDataSet duration:fnkAnimationDuration completion:nil];
    [self.barGraphVC filterBars:self.filteredDataSet duration:fnkAnimationDuration completion:nil];
}

@end
