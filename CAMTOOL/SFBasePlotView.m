//
//  BasePlotView.m
//  CAMTOOL
//
//  Created by jifu on 1/25/16.
//  Copyright © 2016 sifo. All rights reserved.
//


#import "SFBasePlotView.h"

@implementation SFBasePlotView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _graphPaddingLeft=50;
        _graphPaddingRight =60;
        _graphPaddingTop=50.0;
        _graphPaddingBottom =50.0;
        _xMajorIntervalLength=20.0;
        _yMajorIntervalLength=20;
        _xMinorTicksPerInterval=5;
        _yMaxValue=0;
        _xSegementNumber=0;
        _ySegementNumber=6;
    }
    return self;
}

-(void)setDataSource:(id<PlotViewDataSource>)datasource;
{
    _datasource = datasource;
}
-(void)drawGraph:(NSRect)rect;
{
    [[NSColor lightGrayColor] setFill];
     NSRectFill(rect);
}

-(void)drawPlot:(NSRect)rect
{
    [[NSColor whiteColor] setFill];
     NSRectFill(rect);
    [[NSBezierPath bezierPathWithRect:rect] stroke];
}

-(void)drawDataInPlotArea:(NSRect)plotArea;
{
   
    _xMajorIntervalLength = plotArea.size.width / _xSegementNumber;
    _yMajorIntervalLength = plotArea.size.height / _ySegementNumber;
    
}
-(void)drawXAxisLabelInRect:(NSRect)rect;
{

        _xMajorIntervalLength =_xSegementNumber >0 ? (_plotArea.size.width/_xSegementNumber): 0;
        NSFont *font = [NSFont fontWithName:@"Arial" size:10];
        NSDictionary *fontDict=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
        for (int idx=0;idx<_xSegementNumber;idx++) {
            NSString *label=[_datasource valueForPlotView:self field:@"Name" recordIndex:idx];
            NSAffineTransform *transform =[NSAffineTransform transform];
            NSAttributedString *attr=[[NSAttributedString alloc] initWithString:label attributes:fontDict];
            NSSize fontSize = [attr size];
            CGFloat xoffset =idx*_xMajorIntervalLength + _graphPaddingLeft + _xMajorIntervalLength/2 - fontSize.width/1.414+ 2;
            CGFloat yoffset =rect.origin.y + rect.size.height - fontSize.width/1.414 - 8;
            [transform translateXBy:xoffset yBy:yoffset];
            [transform rotateByDegrees:45];
            [transform concat];
            
            [attr drawAtPoint:NSZeroPoint];
            
            [transform invert];
            [transform concat];
        }
}

-(void)drawYAxisLabelInRect:(NSRect)rect;
{
   // NSRectFill(rect);
    NSAffineTransform *transform =[NSAffineTransform transform];
    [transform translateXBy:rect.origin.x yBy:rect.origin.y];
    [transform concat];
    NSBezierPath *yLabel=[NSBezierPath bezierPath];
    int segementHight = (int)(_yMaxValue/_ySegementNumber );
    _yMajorIntervalLength = _plotArea.size.height / _ySegementNumber;
    for (int i=0; i<=_ySegementNumber; i++) {
        
        NSRect ySegementLine=NSMakeRect(rect.size.width,_yMajorIntervalLength*i, 3, 1);
        [yLabel appendBezierPathWithRect:ySegementLine];
        NSAttributedString *font=[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%i",segementHight * i]
                                                                 attributes:nil];
        NSRect fontrect=rect;
        NSSize fontSize=[font size];
        fontrect.origin.y=_yMajorIntervalLength*i  - fontSize.height/2;
        fontrect.origin.x=rect.size.width - fontSize.width -5;
        fontrect.size.height=fontSize.height;
        [font drawInRect:fontrect];
    }
    [yLabel fill];
    [transform invert];
    [transform concat];
}
-(void)setTitle:(NSString *)title;
{
    _title =title;
}
-(void)drawTitleInRect:(NSRect )rect
{
    if (_title == nil) {
        return;
    }
    NSFont *font = [NSFont fontWithName:@"Palatino-Roman" size:14];
    NSAttributedString *attrString =[[NSAttributedString alloc] initWithString:_title
                                                                    attributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
    NSSize fontsize=[attrString size];
    NSRect drawrect=NSMakeRect(rect.origin.x+(rect.size.width-fontsize.width)/2, rect.origin.y + (rect.size.height - fontsize.height)/2, rect.size.width, fontsize.height);
    [attrString drawInRect:drawrect];
}

- (void)drawRect:(NSRect)dirtyRect
{
   
    [super drawRect:dirtyRect];
    [self drawGraph:dirtyRect];
    CGFloat plotSizeWidth = dirtyRect.size.width - _graphPaddingLeft - _graphPaddingRight;
    CGFloat plotSizeHight  = dirtyRect.size.height - _graphPaddingTop -_graphPaddingBottom;
    _plotArea =NSMakeRect(_graphPaddingLeft, _graphPaddingBottom, plotSizeWidth, plotSizeHight);
    [self drawPlot:_plotArea];
    [self drawTitleInRect:NSMakeRect(_graphPaddingLeft,dirtyRect.size.height-_graphPaddingTop, _plotArea.size.width, _graphPaddingTop)];

   
}

@end
