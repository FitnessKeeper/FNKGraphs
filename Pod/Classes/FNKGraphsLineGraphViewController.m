//
//  FNKGraphsLineGraphViewController.m
//  Pods
//
//  Created by Phillip Connaughton on 1/11/15.
//
//

#import "FNKGraphsLineGraphViewController.h"

@interface FNKGraphsLineGraphViewController ()

/* xAxis - The X axis of the graph. This cannot be assigned but it's properties can be*/
@property (nonatomic,strong) FNKXAxis* xAxis;

/* yAxis - The Y axis of the graph. This cannot be assigned but it's properties can be*/
@property (nonatomic,strong) FNKYAxis* yAxis;

@property (nonatomic, weak) CAShapeLayer* lineLayer;
@property (nonatomic, weak) CAShapeLayer* comparisonLine;
@property (nonatomic) BOOL fillGraph;

//Graph variables
@property (nonatomic) CGFloat xScaleFactor;
@property (nonatomic) CGFloat yScaleFactor;
@property (nonatomic) CGFloat xRange;
@property (nonatomic) CGFloat yRange;

@property (nonatomic, strong) NSMutableArray* filteredGraphData;
@property (nonatomic, strong) NSMutableArray* normalizedGraphData;

@end

@implementation FNKGraphsLineGraphViewController

#pragma mark view lifecycle

-(void)initializers
{
    self.xAxis = [[FNKXAxis alloc] initWithMarginLeft:self.marginLeft marginBottom:self.marginBottom];
    self.yAxis = [[FNKYAxis alloc] initWithMarginLeft:self.marginLeft marginBottom:self.marginBottom];
    self.yAxis.ticks = 5;
    self.xAxis.ticks = 5;
    self.selectedLineLayer  = [CAShapeLayer layer];
    self.selectedLineCircleLayer = [CAShapeLayer layer];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)drawGraph
{
    [self drawGraph:nil];
}

-(void)drawGraph:(void (^) (void))completion
{
    [super drawGraph:completion];
    
    self.xAxis.graphHeight = self.graphHeight;
    self.yAxis.graphHeight = self.graphHeight;
    
    self.xAxis.graphWidth = self.graphWidth;
    self.yAxis.graphWidth = self.graphWidth;
    
    self.selectedLineLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:self.selectedLineLayer];
    
    self.selectedLineCircleLayer.strokeColor = [UIColor clearColor].CGColor;
    self.selectedLineCircleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:self.selectedLineCircleLayer];
    
    if(self.chartOverlay)
    {
        self.chartOverlay.marginBottom = self.marginBottom;
        self.chartOverlay.marginLeft = self.marginLeft;
        self.chartOverlay.graphWidth = self.graphWidth;
        self.chartOverlay.graphHeight = self.graphHeight;
    }
    
    
    [self drawAxii:self.view];
    
    [self loadData:self.dataArray];
    [self drawData:completion];
    
    if (self.chartOverlay != nil)
    {
        [self.chartOverlay drawInView:self.view];
        self.yLabelView.userInteractionEnabled = false;
    }
}

-(void)loadData:(NSMutableArray*)data
{
    self.graphData = [NSMutableArray array];
    for(id obj in data)
    {
        [self.graphData addObject:[NSValue valueWithCGPoint:self.pointForObject(obj)]];
    }
    
    [self calcMaxMin:self.graphData];
    self.normalizedGraphData = [self normalizePoints:self.graphData];
}

-(double)scaleYValue:(double)value
{
    //yVal needs to be the inverse bc of iOS coordinates
    return self.graphHeight - ((value - self.yAxis.axisMin) * self.yScaleFactor);
}

-(void)willAppear
{
    self.selectedLineLayer.strokeColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:self.selectedLineLayer];
    
    self.selectedLineCircleLayer.strokeColor = [UIColor clearColor].CGColor;
    self.selectedLineCircleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.view.layer addSublayer:self.selectedLineCircleLayer];
}

-(void)drawData:(void (^)(void))completion
{
    [self addTicks];
    
    __weak __typeof(self) safeSelf = self;
    self.lineLayer = [self drawLine:self.normalizedGraphData
                              color:self.lineStrokeColor
                         completion:^{
                             double yValue = [safeSelf scaleYValue:safeSelf.averageLine];
                             [safeSelf drawAverageLine:yValue];
                             
                             if(completion)
                             {
                                 completion();
                             }
                         }];
}

-(void)drawAxii:(UIView*)view
{
    [self.yAxis drawAxis:view];
    
    //    [self.xAxis drawAxis:view];
}

-(void)addTicks
{
    self.yLabelView = [self.yAxis addTicksToView:self.view];
    self.xLabelView = [self.xAxis addTicksToView:self.view];
}

-(void)removeTicks
{
    [self.yLabelView removeFromSuperview];
    [self.xLabelView removeFromSuperview];
}

-(CAShapeLayer*)drawLine:(NSMutableArray*)data color:(UIColor*)color completion:(void (^)())completion
{
    CAShapeLayer* layer = [[CAShapeLayer alloc] init];
    layer.path = [self pathFromPoints:data].CGPath;
    layer.fillColor = nil;
    layer.strokeColor = color.CGColor;
    layer.lineWidth = 2;
    layer.lineCap = @"round";
    layer.lineJoin = @"round";
    
    
    [self.view.layer insertSublayer:layer below:self.yLabelView.layer];
    
    [CATransaction begin];
    
    __weak __typeof(self) safeSelf = self;
    [CATransaction setCompletionBlock:^{
        
        if(safeSelf.circleAtLinePoints)
        {
            CGFloat radius = 5;
            for (NSValue* val in data)
            {
                CGPoint point = [val CGPointValue];
                CAShapeLayer* linePoint = [CAShapeLayer layer];
                linePoint.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - radius/2, point.y-radius/2, radius, radius)].CGPath;
                linePoint.fillColor = safeSelf.circleAtLinePointFillColor.CGColor;
                linePoint.strokeColor = safeSelf.circleAtLinePointColor.CGColor;
                linePoint.lineWidth = 2;
                [linePoint setOpacity:0.0];
                [safeSelf.view.layer addSublayer:linePoint];
                
                CABasicAnimation* pointAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
                pointAnimation.duration = .2;
                pointAnimation.fromValue = @(0);
                pointAnimation.toValue = @(1);
                pointAnimation.removedOnCompletion = NO;
                pointAnimation.fillMode = kCAFillModeBoth;
                
                [linePoint addAnimation:pointAnimation forKey:@"opacity"];
            }
        }
        
        if(completion)
        {
            completion();
        }
        
    }];
    
    CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.fromValue = @(0);
    pathAnimation.toValue = @(1);
    
    [layer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    [CATransaction commit];
    
    return layer;
}

-(UIBezierPath*)pathFromPoints:(NSMutableArray*)data
{
    BOOL firstPoint = YES;
    
    UIBezierPath* bezPath = [[UIBezierPath alloc] init];
    
    if(self.fillGraph)
    {
        [bezPath moveToPoint:CGPointMake(0, self.graphHeight)];
        
        CGPoint lastPoint = CGPointMake(0, self.graphHeight);
        
        for (NSValue* val in data)
        {
            CGPoint point = [val CGPointValue];
            [bezPath addLineToPoint:point];
            
            lastPoint = point;
        }
        
        [bezPath addLineToPoint:CGPointMake(lastPoint.x, self.graphHeight)];
        [bezPath closePath];
    }
    else
    {
        for (NSValue* val in data)
        {
            CGPoint point = [val CGPointValue];
            if (firstPoint)
            {
                [bezPath moveToPoint:point];
                firstPoint = false;
            }
            else
            {
                [bezPath addLineToPoint:point];
            }
        }
    }
    
    return bezPath;
}

-(CGFloat)valueAtPoint:(CGPoint)point
{
    CGFloat xValue = point.x;
    CGFloat yVal = 0;
    
    if(self.filteredGraphData.count > 0)
    {
        for (NSValue* val in self.filteredGraphData)
        {
            CGPoint point = [val CGPointValue];
            if(point.x >= xValue)
            {
                yVal = point.y;
                break;
            }
        }
    }
    else
    {
        for (NSValue* val in self.normalizedGraphData)
        {
            CGPoint point = [val CGPointValue];
            if(point.x >= xValue)
            {
                yVal = point.y;
                break;
            }
        }
    }
    
    UIBezierPath* bezPath = [[UIBezierPath alloc] init];
    
    [bezPath moveToPoint:CGPointMake(point.x, 0)];
    [bezPath addLineToPoint:CGPointMake(point.x, self.graphHeight)];
    
    self.selectedLineLayer.strokeColor = self.lineStrokeColor.CGColor;
    self.selectedLineLayer.path = bezPath.CGPath;
    
    CGFloat radius = 5;
    
    self.selectedLineCircleLayer.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(point.x - radius/2, yVal-radius/2, radius, radius)].CGPath;
    self.selectedLineCircleLayer.fillColor = self.lineStrokeColor.CGColor;
    self.selectedLineCircleLayer.strokeColor = self.lineStrokeColor.CGColor;
    
    return ((self.graphHeight - yVal) / self.yScaleFactor) + self.yAxis.axisMin;
}

-(void)removeSelection
{
    self.selectedLineLayer.strokeColor = [UIColor clearColor].CGColor;
    self.selectedLineCircleLayer.fillColor = [UIColor clearColor].CGColor;
    self.selectedLineCircleLayer.strokeColor = [UIColor clearColor].CGColor;
}

-(void)showLineComparison:(NSMutableArray*)comparisonData color:(UIColor*)lineColor duration:(CGFloat)duration completion:(void (^)(void))completion
{
    NSMutableArray* cData = [NSMutableArray array];
    
    for(id obj in comparisonData)
    {
        [cData addObject:[NSValue valueWithCGPoint:self.pointForObject(obj)]];
    }
    
    //Okay so now we need to run all of the data thru the normalizer again and get a new max and min for the graph
    NSMutableArray* allData = [NSMutableArray arrayWithArray:self.graphData];
    
    [allData addObjectsFromArray:cData];
    [self calcMaxMin:allData];
    
    [self removeTicks];
    [self addTicks];
    
    dispatch_group_t animationGroup = dispatch_group_create();
    
    //Draw the new line
    if(self.comparisonLine == nil)
    {
        dispatch_group_enter(animationGroup);
        NSMutableArray* data = [self normalizePoints:cData];
        self.comparisonLine = [self drawLine:data
                                       color:lineColor
                                  completion:^{
                                      dispatch_group_leave(animationGroup);
                                  }];
    }
    else //Animate the line transition
    {
        dispatch_group_enter(animationGroup);
        NSMutableArray* data = [self normalizePoints:cData];
        [self transitionLine:self.comparisonLine
                        data:data
                    duration:duration
                  completion:^{
                      dispatch_group_leave(animationGroup);
                  }];
    }
    
    dispatch_group_enter(animationGroup);
    self.normalizedGraphData = [self normalizePoints:self.graphData];
    [self transitionLine:self.lineLayer
                    data:self.normalizedGraphData
                duration:duration
              completion:^{
                  dispatch_group_leave(animationGroup);
              }];
    
    dispatch_group_notify(animationGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        if(completion)
        {
            completion();
        }
    });
}

-(void)filterLine:(NSMutableArray*)filteredData duration:(CGFloat)duration completion:(void (^)(void))completion
{
    if(filteredData)
    {
        self.filteredGraphData = [NSMutableArray array];
        
        for(id obj in filteredData)
        {
            [self.filteredGraphData addObject:[NSValue valueWithCGPoint:self.pointForObject(obj)]];
        }
        
        [self calcMaxMin:self.filteredGraphData];
        self.filteredGraphData = [self normalizePoints:self.filteredGraphData];
        
        [self removeTicks];
        [self addTicks];
        
        [self transitionLine:self.lineLayer
                        data:self.filteredGraphData
                    duration:duration
                  completion:^{
                      if(completion)
                      {
                          completion();
                      }
                  }];
    }
    else
    {
        [self.graphData removeAllObjects];
        [self.filteredGraphData removeAllObjects];
        
        for(id obj in self.dataArray)
        {
            [self.graphData addObject:[NSValue valueWithCGPoint:self.pointForObject(obj)]];
        }
        
        [self calcMaxMin:self.graphData];
        self.normalizedGraphData = [self normalizePoints:self.graphData];
        
        [self removeTicks];
        [self addTicks];
        
        [self transitionLine:self.lineLayer
                        data:self.normalizedGraphData
                    duration:duration
                  completion:^{
                      if(completion)
                      {
                          completion();
                      }
                  }];
        
    }
}

-(void)transitionLine:(CAShapeLayer*)line data:(NSMutableArray*)data duration:(CGFloat)duration completion:(void (^)())completion
{
    CGPathRef newPath = [self pathFromPoints:data].CGPath;
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        //Need to do this, otherwise the next animation will start at the original value.
        [line setPath:newPath];
        if(completion)
        {
            completion();
        }
    }];
    
    CABasicAnimation *morph = [CABasicAnimation animationWithKeyPath:@"path"];
    morph.duration  = duration; // Step 1
    //    morph.fromValue = (__bridge id) line.path;
    morph.toValue = (__bridge id) newPath;
    morph.autoreverses = NO;
    morph.fillMode = kCAFillModeForwards;
    morph.removedOnCompletion = NO;
    [line addAnimation:morph forKey:@"path"];
    
    [CATransaction commit];
}

-(void)calcMaxMin:(NSArray*)points
{
    CGFloat maxX= DBL_MIN;
    CGFloat minX = DBL_MAX;
    CGFloat maxY = DBL_MIN;
    CGFloat minY = DBL_MAX;
    
    for (NSValue* val in points)
    {
        CGPoint point = [val CGPointValue];
        if(point.x > maxX)
        {
            maxX = point.x;
        }
        
        if(point.x < minX)
        {
            minX = point.x;
        }
        
        if(point.y > maxY)
        {
            maxY = point.y;
        }
        
        if(point.y < minY)
        {
            minY = point.y;
        }
    }
    
    if(self.yAxis.overridingMin)
    {
        minY = self.yAxis.overridingMin.floatValue;
    }
    
    if(self.yAxis.overridingMax)
    {
        maxY = self.yAxis.overridingMax.floatValue;
    }
    
    if(self.xAxis.overridingMin)
    {
        minX = self.xAxis.overridingMin.floatValue;
    }
    
    if(self.xAxis.overridingMax)
    {
        maxX = self.xAxis.overridingMax.floatValue;
    }
    
    CGFloat yPadding = (maxY - minY) * self.yAxis.paddingPercentage.floatValue;
    
    minY = minY - yPadding;
    maxY = maxY + yPadding;
    
    //Okay so now we have the min's and max's
    self.xRange = maxX - minX;
    self.yRange = maxY - minY;
    
    self.xScaleFactor = self.graphWidth / self.xRange;
    self.yScaleFactor = self.graphHeight / self.yRange;
    
    self.xAxis.scaleFactor = self.xScaleFactor;
    self.yAxis.scaleFactor = self.yScaleFactor;
    self.yAxis.axisMin = minY;
    self.xAxis.axisMin = minX;
}

-(NSMutableArray*)normalizePoints:(NSArray*)points
{
    NSMutableArray* scaledPoints = [NSMutableArray array];
    
    for (NSValue* val in points)
    {
        CGPoint point = [val CGPointValue];
        [scaledPoints addObject:[NSValue valueWithCGPoint:[self normalizedPointForPoint:point]]];
    }
    
    return scaledPoints;
}

-(CGPoint)normalizedPointForPoint:(CGPoint)point
{
    CGFloat xVal = ((point.x- self.xAxis.axisMin) * self.xScaleFactor ) + self.yAxis.marginLeft;
    CGFloat yVal = [self scaleYValue:point.y];
    return CGPointMake(xVal,yVal);
}

-(void)drawAverageLine:(CGFloat)yVal
{
    if(self.averageLineColor)
    {
        UIBezierPath* bezPath = [[UIBezierPath alloc] init];
        [bezPath moveToPoint:CGPointMake(self.yAxis.marginLeft, yVal)];
        [bezPath addLineToPoint:CGPointMake(self.xAxis.graphWidth + self.yAxis.marginLeft, yVal)];
        
        CAShapeLayer* layer = [[CAShapeLayer alloc] init];
        layer.path = bezPath.CGPath;
        layer.fillColor = self.averageLineColor.CGColor;
        layer.strokeColor = self.averageLineColor.CGColor;
        layer.lineWidth = 1;
        [layer setLineDashPattern:@[@(3),@(5)]];
        layer.lineCap = @"round";
        layer.lineJoin = @"round";
        
        [self.view.layer addSublayer:layer];
        
        CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        pathAnimation.duration = 1;
        pathAnimation.fromValue = @(0);
        pathAnimation.toValue = @(1);
        
        [layer addAnimation:pathAnimation forKey:@"strokeEnd"];
    }
}

-(void)drawTrendLine:(UIColor*)color completion:(void (^) (void))completion
{
    [self drawTrendLine:color startPoint:CGPointMake(0, 0) completion:completion];
}

-(void)drawTrendLine:(UIColor*)color startPoint:(CGPoint)startPoint completion:(void (^) (void))completion
{
    //        Consider this data set of three (x,y) points: (1,3) (2, 5) (3,6.5). Let n = the number of data points, in this case 3.
    //        Step 2
    //        Let a equal n times the summation of all x-values multiplied by their corresponding y-values, like so: a = 3 x {(1 x 3) +( 2 x 5) + (3 x 6.5)} = 97.5
    //        Step 3
    //        Let b equal the sum of all x-values times the sum of all y-values, like so: b = (1 + 2 + 3) x (3 + 5 + 6.5) = 87
    //        Step 4
    //        Let c equal n times the sum of all squared x-values, like so: c = 3 x (1^2 + 2^2 + 3^2) = 42
    //        Step 5
    //        Let d equal the squared sum of all x-values, like so: d = (1 + 2 + 3)^2 = 36
    //        Step 6
    //        Plug the values that you calculated for a, b, c, and d into the following equation to calculate the slope, m, of the regression line: slope = m = (a - b) / (c - d) = (97.5 - 87) / (42 - 36) = 10.5 / 6 = 1.75
    
    CGFloat a = 0;
    CGFloat b = 0;
    CGFloat c = 0;
    CGFloat d = 0;
    CGFloat sumX = 0;
    CGFloat sumY = 0;
    
    for (NSValue* val in self.normalizedGraphData)
    {
        CGPoint point = [val CGPointValue];
        
        a += point.x * point.y;
        sumX += point.x;
        sumY += point.y;
        c += point.x * point.x;
    }
    
    a = a * self.normalizedGraphData.count;
    b = sumX * sumY;
    c = c * self.normalizedGraphData.count;
    d = sumX * sumX;
    
    CGFloat slope = (a - b) / (c - d);
    
    if(isnan(slope))
    {
        if(completion)
        {
            completion();
        }
        return;
    }
    
    CGPoint p1 = [[self.normalizedGraphData firstObject] CGPointValue];
    
    CGFloat yIntercept = p1.y - slope * p1.x;
    
    CGFloat endX = self.graphWidth;
    CGFloat y2 = slope * endX + yIntercept;
    
    //Don't let the trend line draw off the bottom of the graph area
    if(y2 > self.graphHeight - self.marginBottom)
    {
        y2 = self.graphHeight - self.marginBottom;
        endX = (y2 - yIntercept) / slope;
    }
    
    CGPoint endPoint = CGPointMake(endX, y2);
    
    UIBezierPath* bezPath = [[UIBezierPath alloc] init];
    [bezPath moveToPoint:startPoint];
    [bezPath addLineToPoint:endPoint];
    
    CAShapeLayer* layer = [[CAShapeLayer alloc] init];
    layer.path = bezPath.CGPath;
    layer.fillColor = color.CGColor;
    layer.strokeColor = color.CGColor;
    layer.lineWidth = 2;
    [layer setLineDashPattern:@[@(3),@(5)]];
    layer.lineCap = @"round";
    layer.lineJoin = @"round";
    
    [self.view.layer addSublayer:layer];
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:completion];
    
    CABasicAnimation* pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1;
    pathAnimation.fromValue = @(0);
    pathAnimation.toValue = @(1);
    
    [layer addAnimation:pathAnimation forKey:@"strokeEnd"];
    
    [CATransaction commit];
}

-(CGPoint)normalizedPointForObject:(id)object
{
    return [self normalizedPointForPoint:self.pointForObject(object)];
}

#pragma mark gestures

// we capture the touch move events by overriding touchesMoved method

-(void)touchedGraphAtPoint:(CGPoint)point userGenerated:(BOOL)userGenerated
{
    //Take the x value and get the corresponding y value;
    
    CGFloat value = [self valueAtPoint:point];
    
    if(self.delegate)
    {
        [self.delegate touchedGraph:self val:value point:point userGenerated:userGenerated];
    }
}

-(void)handlePan:(UIPanGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    
    if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self removeSelection];
        
        if(self.delegate)
        {
            [self.delegate graphTouchesEnded:self];
        }
    }
    else
    {
        [self handleGesture:point];
    }
}

-(void)handleTap:(UITapGestureRecognizer*)recognizer
{
    CGPoint point = [recognizer locationInView:self.view];
    
    [self handleGesture:point];
}

-(void) handleGesture:(CGPoint)point
{
    if(point.x > self.graphWidth + self.marginLeft || point.x < self.marginLeft)
    {
        [self removeSelection];
        
        if(self.delegate)
        {
            [self.delegate graphTouchesEnded:self];
        }
    }
    else
    {
        [self touchedGraphAtPoint:point userGenerated:YES];
        
        FNKChartOverlayData* data = [self.chartOverlay touchAtPoint:point view:self.view];
        
        if (data != nil && self.delegate)
        {
            [self.delegate touchedBar:self data: data];
        }
    }
}

-(void) focusAtPoint:(CGPoint)point show:(BOOL)show
{
    if(show)
    {
        [self touchedGraphAtPoint:point userGenerated:NO];
    }
    else
    {
        [self removeSelection];
    }
}

@end
