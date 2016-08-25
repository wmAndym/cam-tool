//
//  BasePlotView.h
//  CAMTOOL
//
//  Created by jifu on 1/25/16.
//  Copyright © 2016 sifo. All rights reserved.
//


#import <Cocoa/Cocoa.h>

@protocol PlotViewDataSource <NSObject>

@required
-(NSInteger)numberOfRecordsForPlotView:(id)plotView;
-(id)valueForPlotView:(id)plotView field:(NSString *)fieldEnum recordIndex:(NSUInteger)index;

@end

@interface SFBasePlotView : NSView
{
    NSString *_title;

    CGFloat _graphPaddingLeft;
    CGFloat _graphPaddingRight;
    CGFloat _graphPaddingTop;
    CGFloat _graphPaddingBottom;
    CGFloat _xMajorIntervalLength;
    CGFloat _yMajorIntervalLength;
    CGFloat _xMinorTicksPerInterval;
    CGFloat _yMaxValue;
    NSInteger _xSegementNumber,_ySegementNumber;
    NSRect _plotArea;
    __weak id<PlotViewDataSource> _datasource;
    
}

-(void)setDataSource:(id<PlotViewDataSource>)datasource;
-(void)drawXAxisLabelInRect:(NSRect)rect;
-(void)drawYAxisLabelInRect:(NSRect)rect;
-(void)drawTitleInRect:(NSRect )rect;
-(void)drawDataInPlotArea:(NSRect)plotArea;
-(void)setTitle:(NSString *)title;

@end
