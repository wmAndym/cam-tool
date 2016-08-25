//
//  SFNANDRackMainView.m
//  CAMTOOL
//
//  Created by jifu on 12/21/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFNANDRackMainView.h"
#import "SFSlotView.h"
@implementation SFNANDRackMainView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _title = @"NAND RACK GUI";
        _frame_border_width = 2;
        _high_of_bottom_status_view = 5;
        _high_of_top_header_view = 25;
        _gap_x = _gap_y = 5;
        _fixtureViewFrame =NSZeroRect;
        
    }
    
    return self;
}

-(void)setTitle:(NSString *)title;
{
    _title = [title copy];
}
-(NSRect)fixtureViewFrame;
{
    return _fixtureViewFrame;
}
-(void)setDataSource:(id<SFNANDRackDataSource>)ds;
{
    _dataSource = ds;
}
-(void)drawFixtureRect:(NSRect)dirtyRect;
{
    ///
    //Draw fixture view here.
    const NSUInteger fixtureCount = [_dataSource fixutureNumber];

    CGFloat fixtureHigh=dirtyRect.size.height / fixtureCount;
    CGFloat fixtureWidth = dirtyRect.size.width;
    
    
    /*remove all old fixture views if exist*/
    
    NSArray *subViews = [self subviews];
    NSUInteger subViewCounts =[subViews count];
    
    if (subViewCounts > 0) {
        for (NSUInteger i=0; i<subViewCounts; i++) {
            if ([ subViews[0] isKindOfClass:[SFFixtureView class]]) {
                [subViews[0] removeAllSlotViews];
            }
            [subViews[0] removeFromSuperview]; //this methods will change subViews elements after it be called.
        }
    }
    
    /*add fixture views*/
    
    for (int i=0; i<fixtureCount; i++) {
        
        NSRect fRect =NSMakeRect(dirtyRect.origin.x , dirtyRect.origin.y + (fixtureCount - i -1)*fixtureHigh, fixtureWidth, fixtureHigh);
        SFFixtureView *f =[_dataSource fixtureViewAtIndex:i];
        [f setFrame:fRect];
        [self addSubview:f];
        
        const NSUInteger slotCountOfFixture =[_dataSource slotNumberOfFixtureView:f];
        
        for (int j=0; j<slotCountOfFixture; j++) {
            SFSlotView *s =[_dataSource slotViewAtIndex:j ofFixtureView:f];
            [f addSlotView:s];
        }
       // [f showSlotViews];
    }
}

-(NSRect)caculateFixtureRect:(NSRect)dirtyRect
{
    //draw mainview's frame and background
    NSRect insetRect = NSInsetRect(dirtyRect, _gap_x, _gap_y);
    NSBezierPath *path =[NSBezierPath bezierPathWithRoundedRect:insetRect xRadius:0 yRadius:0];
    NSColor *strokeColor = [NSColor lightGrayColor];
    [[NSColor grayColor] setFill];
    [path setLineWidth:_frame_border_width];
    [strokeColor setStroke];
    
    [path fill];
    [path stroke];
    
    

    // obtain top title view area.
    NSRect titleRect = NSMakeRect(insetRect.origin.x, insetRect.origin.y + insetRect.size.height - _high_of_top_header_view , insetRect.size.width, _high_of_top_header_view);
    [[NSColor grayColor] setFill];
    NSRectFill(titleRect);
    
    //draw system date time.
    NSDateFormatter *formatter =[NSDateFormatter new];
    formatter.dateFormat = @"[yyyy-MM-dd HH:mm]";
    NSString *dt =[formatter stringFromDate:[NSDate new]];
    NSAttributedString *dt_attributedString=[[NSAttributedString alloc] initWithString:dt attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Arial" size:14],NSForegroundColorAttributeName:[NSColor blackColor]}];
    NSSize dt_size = [dt_attributedString size];
    NSPoint dt_textDrawPoint =NSMakePoint(titleRect.origin.x + titleRect.size.width - dt_size.width -10, titleRect.origin.y + (titleRect.size.height - dt_size.height)/2 + 3);
    
    [dt_attributedString drawAtPoint:dt_textDrawPoint];

    // draw top title view area.

    NSAttributedString *titleAttributedString=[[NSAttributedString alloc] initWithString:_title attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Arial Black" size:16],NSForegroundColorAttributeName:[NSColor whiteColor]}];
    NSSize strsize = [titleAttributedString size];
    NSPoint textDrawPoint =NSMakePoint(titleRect.origin.x + (titleRect.size.width - strsize.width)/2, titleRect.origin.y + (titleRect.size.height - strsize.height)/2 + 3);
    [titleAttributedString drawAtPoint:textDrawPoint];
    
    //draw bottom status view area.
    NSRect statusRect = NSMakeRect(insetRect.origin.x, insetRect.origin.y  , insetRect.size.width, _high_of_bottom_status_view);
    [[NSColor lightGrayColor] setFill];
    NSRectFill(statusRect);
    
    //Calculate fixture view Rect.
    NSRect fixtureViewRect = NSMakeRect(dirtyRect.origin.x , dirtyRect.origin.y +_high_of_bottom_status_view,  dirtyRect.size.width, dirtyRect.size.height - _high_of_bottom_status_view - _high_of_top_header_view);
    return fixtureViewRect;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    _fixtureViewFrame = [self caculateFixtureRect:dirtyRect];
    
    [self drawFixtureRect:_fixtureViewFrame];

    
    // Drawing code here.
}

@end
