//
//  UPHView.m
//  CAMTOOL
//
//  Created by jifu on 1/25/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFUPHView.h"

@implementation SFUPHView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        lineColor=[NSColor blueColor];
    }
    return self;
}
-(NSInteger)maxYValue
{
    _yMaxValue = 40;
    for (int idx =0;idx<_xSegementNumber;idx++) {
        NSInteger count = [[_datasource valueForPlotView:self field:@"Output" recordIndex:idx] integerValue];
        if (count >_yMaxValue) {
            _yMaxValue = count;
        }
    }
    _yMaxValue *= 1.2;
    return _yMaxValue;
}
-(void)drawXAxisLabelInRect:(NSRect)rect;
{
    [super drawXAxisLabelInRect:rect];
    
    NSAffineTransform *transform =[NSAffineTransform transform];
    [transform translateXBy:rect.origin.x yBy:rect.origin.y+ rect.size.height];
    [transform concat];
    for (int idx=0;idx<_xSegementNumber;idx++) {
        NSRect lineRect = NSMakeRect(idx*_xMajorIntervalLength, 0, _xMajorIntervalLength, _plotArea.size.height);
        if (idx % 2) {
            [[NSColor colorWithDeviceRed:0.7 green:0.8 blue:0.6 alpha:0.6] setFill];

        }else{
            [[NSColor colorWithDeviceRed:0.7 green:0.8 blue:0.6 alpha:1.0] setFill];
        }

        NSRectFill(lineRect);
    }
    [transform invert];
    [transform concat];
}
-(void)drawDataInPlotArea:(NSRect)plotArea
{
    [super drawDataInPlotArea:plotArea];
    CGFloat _ypiece=(plotArea.size.height/[self maxYValue]);
    NSFont *font = [NSFont fontWithName:@"Arial" size:10.0];
    NSDictionary *fontAttr=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    
    NSAffineTransform *transform =[NSAffineTransform transform];
    [transform translateXBy:plotArea.origin.x yBy:plotArea.origin.y];
    [transform concat];
   
    
    NSBezierPath *path=[NSBezierPath bezierPath];
    NSBezierPath *pointpath=[NSBezierPath bezierPath];

    
    
    for (int idx=0; idx<_xSegementNumber; idx++) {
        NSInteger qty = [[_datasource valueForPlotView:self field:@"Output" recordIndex:idx] integerValue];
        CGFloat yValue=_ypiece*qty;
        NSPoint point=NSMakePoint(_xMajorIntervalLength*idx, yValue);
        if (idx == 0) {
            [path moveToPoint:point];
        }else{
            NSAttributedString *str=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",qty] attributes:fontAttr];
            [str drawAtPoint:NSMakePoint(point.x -7, point.y +7)];
            [path lineToPoint:point];
            [pointpath appendBezierPathWithOvalInRect:NSMakeRect(point.x - 2.5, point.y -2.5, 5, 5)];

        }
    }
    [lineColor setStroke];
    [lineColor setFill];
    
    [path setLineWidth:2];
    //[path setLineJoinStyle:NSLineBreakByTruncatingMiddle];
    [path stroke];
    [pointpath fill];

    [transform invert];
    [transform concat];
}
- (void)drawRect:(NSRect)dirtyRect
{
    _graphPaddingTop = 30;
    _xSegementNumber =[_datasource numberOfRecordsForPlotView:self];
    _ySegementNumber = 10;
    
    [super drawRect:dirtyRect];
    [self drawXAxisLabelInRect:NSMakeRect(_graphPaddingLeft, 0 , _plotArea.size.width, _graphPaddingBottom)];

    [self drawDataInPlotArea:_plotArea];
    
    [self drawYAxisLabelInRect:NSMakeRect(0,_graphPaddingBottom, _graphPaddingLeft, _plotArea.size.height)];
    
    
    // Drawing code here.
}

@end
