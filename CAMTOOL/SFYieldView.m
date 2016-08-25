//
//  YieldView.m
//  CAMTOOL
//
//  Created by jifu on 1/25/16.
//  Copyright © 2016 sifo. All rights reserved.
//


#import "SFYieldView.h"
@implementation SFYieldView


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _title=@"Yield By Slot";
        passColor=[NSColor colorWithCalibratedRed:0.1 green:5.0 blue:0.1 alpha:1.0];
        failColor =[NSColor colorWithCalibratedRed:5.0 green:0.1 blue:0.1 alpha:1.0];
        retestColor=[NSColor orangeColor];
    }
    return self;
}

-(NSInteger)maxYValue
{
    _yMaxValue = 36;
    for (int idx =0;idx<_xSegementNumber;idx++) {
        NSInteger passcount = [[_datasource valueForPlotView:self field:@"PASS" recordIndex:idx] integerValue];
        NSInteger failCount = [[_datasource valueForPlotView:self field:@"FAIL" recordIndex:idx] integerValue];
        if (passcount >_yMaxValue || failCount >_yMaxValue) {
            _yMaxValue = passcount >failCount ?passcount:failCount;
        }
    }
    _yMaxValue *= 1.2;
    return _yMaxValue;
}

-(void)drawDataInPlotArea:(NSRect)rect;
{
    [super drawDataInPlotArea:rect];
    NSAffineTransform *transform =[NSAffineTransform transform];
    [transform translateXBy:rect.origin.x yBy:rect.origin.y];
    [transform concat];
    
    NSBezierPath *_plotPathForPass;
    NSBezierPath *_plotPathForFail;
    NSBezierPath *_plotPathForRetest;
    
    _plotPathForFail=[NSBezierPath bezierPath];
    _plotPathForPass=[NSBezierPath bezierPath];
    _plotPathForRetest=[NSBezierPath bezierPath];
    
   
    CGFloat _ypiece=(rect.size.height/[self maxYValue]);
    CGFloat xMinorTickLength =_xMajorIntervalLength/_xMinorTicksPerInterval;
    
    NSFont *font = [NSFont fontWithName:@"Arial" size:10.0];
    NSDictionary *fontAttr=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    for (int idx =0;idx<_xSegementNumber;idx++) {
        NSInteger passcount = [[_datasource valueForPlotView:self field:@"PASS" recordIndex:idx] integerValue];
        NSInteger failCount = [[_datasource valueForPlotView:self field:@"FAIL" recordIndex:idx] integerValue];
        NSInteger retestCount = [[_datasource valueForPlotView:self field:@"RETEST" recordIndex:idx] integerValue];

        NSAttributedString *passStr=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",passcount] attributes:fontAttr];
        NSAttributedString *failStr=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",failCount] attributes:fontAttr];
        NSAttributedString *retestStr=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%ld",retestCount] attributes:fontAttr];

        NSRect retestRect = NSMakeRect(idx*_xMajorIntervalLength + 3*xMinorTickLength, 0, xMinorTickLength, _ypiece*retestCount);
        NSRect passRect = NSMakeRect(idx*_xMajorIntervalLength + 2*xMinorTickLength, 0, xMinorTickLength, _ypiece*passcount);
        NSRect failRect = NSMakeRect(idx*_xMajorIntervalLength + xMinorTickLength, 0, xMinorTickLength, _ypiece*failCount);

        NSSize passStrSize=[passStr size];
        NSSize failStrSize=[failStr size];
        NSSize retestStrSize=[retestStr size];

        NSRect passFontRect=NSMakeRect(passRect.origin.x + (passRect.size.width - passStrSize.width)/2, passRect.origin.y+passRect.size.height, passStrSize.width, passStrSize.height);
        NSRect failFontRect=NSMakeRect(failRect.origin.x +(failRect.size.width - failStrSize.width)/2, failRect.origin.y+failRect.size.height, failStrSize.width, failStrSize.height);
        NSRect retestFontRect=NSMakeRect(retestRect.origin.x+(retestRect.size.width - retestStrSize.width)/2, retestRect.origin.y+retestRect.size.height, retestStrSize.width, retestStrSize.height);

        
        if (retestCount != 0) {
            [retestStr drawInRect:retestFontRect];
        }
        if (passcount != 0) {
            [passStr drawInRect:passFontRect];
        }
        if (failCount != 0) {
            [failStr drawInRect:failFontRect];
        }
        
        [_plotPathForFail appendBezierPathWithRoundedRect:failRect xRadius:2 yRadius:2];
        [_plotPathForPass appendBezierPathWithRoundedRect:passRect xRadius:2 yRadius:2];
        [_plotPathForRetest appendBezierPathWithRoundedRect:retestRect xRadius:2 yRadius:2];
    }
    
    [passColor setFill];
    [_plotPathForPass fill];
    [failColor setFill];
    [_plotPathForFail fill];
    [retestColor setFill];
    [_plotPathForRetest fill];
    
    [transform invert];
    [transform concat];

}



-(void)drawLegendInRect:(NSRect)rect
{

    NSFont *font = [NSFont fontWithName:@"Arial" size:10.0];

    NSSize legendRectSize=NSMakeSize(8, 8);
    NSRect passRect=NSMakeRect(rect.origin.x + 5, rect.origin.y, legendRectSize.width, legendRectSize.height);
    NSRect failRect=NSMakeRect(rect.origin.x +5, rect.origin.y+legendRectSize.height + 5, legendRectSize.width, legendRectSize.height);
    NSRect retestRect=NSMakeRect(rect.origin.x +5, failRect.origin.y +legendRectSize.height + 5, legendRectSize.width, legendRectSize.height);
    NSAttributedString *passString=[[NSAttributedString alloc] initWithString:@"Passed" attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    NSAttributedString *failString=[[NSAttributedString alloc] initWithString:@"Failed" attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    NSAttributedString *retestString=[[NSAttributedString alloc] initWithString:@"Retest" attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    
    [passString drawAtPoint:NSMakePoint(passRect.origin.x + legendRectSize.width +2, passRect.origin.y)];
    [failString drawAtPoint:NSMakePoint(failRect.origin.x+ legendRectSize.width +2, failRect.origin.y)];
    [retestString drawAtPoint:NSMakePoint(retestRect.origin.x+ legendRectSize.width +2, retestRect.origin.y)];

    [passColor setFill];
    NSRectFill(passRect);
    [failColor setFill];
    NSRectFill(failRect);
    [retestColor setFill];
    NSRectFill(retestRect);

}
 
- (void)drawRect:(NSRect)dirtyRect
{
    _xSegementNumber =[_datasource numberOfRecordsForPlotView:self];
    _ySegementNumber =6;
    [super drawRect:dirtyRect];
    [self drawDataInPlotArea:_plotArea];
    
    [self drawXAxisLabelInRect:NSMakeRect(_graphPaddingLeft, 0 , _plotArea.size.width, _graphPaddingBottom)];
    [self drawYAxisLabelInRect:NSMakeRect(0,_graphPaddingBottom, _graphPaddingLeft, _plotArea.size.height)];
    [self drawLegendInRect:NSMakeRect(dirtyRect.size.width-_graphPaddingRight, _graphPaddingBottom + _plotArea.size.height/2, _graphPaddingRight, _plotArea.size.height)];
}
@end
