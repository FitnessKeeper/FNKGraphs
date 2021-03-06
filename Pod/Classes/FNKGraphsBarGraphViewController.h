//
//  FNKGraphsBarGraphViewController.h
//  Pods
//
//  Created by Phillip Connaughton on 2/10/15.
//
//

#import "FNKGraphsViewController.h"
#import "FNKGraphsViewController.h"
#import "FNKXAxis.h"
#import "FNKYAxis.h"
#import "FNKBar.h"

@interface FNKGraphsBarGraphViewController : FNKGraphsViewController

@property (nonatomic, strong) UIView* yLabelView;
@property (nonatomic, strong) UIView* xLabelView;

/* xAxis - The X axis of the graph. This cannot be assigned but it's properties can be*/
@property (nonatomic,readonly) FNKXAxis* xAxis;

/* yAxis - The Y axis of the graph. This cannot be assigned but it's properties can be*/
@property (nonatomic,readonly) FNKYAxis* yAxis;

/* The label that will show up for the specific object in the graph data */
@property (nonatomic, copy) CGFloat (^labelValueForObject)(id object);

/* The value for the specific object in the graph data (the length of the bar)*/
@property (nonatomic, copy) CGFloat (^valueForObject)(id object);

/* The color for the specfic bar given the object */
@property (nonatomic, copy) UIColor* (^colorForBar)(int object);

/* The padding between each of the bars (defaults 5)*/
@property (nonatomic) CGFloat barPadding;

/* The corner radius for each bars (defaults 0)*/
@property (nonatomic) CGFloat barCornerRadius;

/* The time bucket that this object will fit into*/
@property (nonatomic, copy) void (^barAdded)(FNKBar* bar, int barNum);

/* When using the bar graph in a UITableViewCell you might have to reset the bar colors when the cell is clicked*/
-(void)resetBarColors;

/* Provides ability to pass in a value and determines where it would end up on the graph */
-(double)scaleYValue:(double)value;

@end
