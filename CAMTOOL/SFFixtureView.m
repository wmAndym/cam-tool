//
//  SFFixtureView.m
//  CAMTOOL
//
//  Created by jifu on 12/23/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFFixtureView.h"

@implementation SFFixtureView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _slotViews =[NSMutableArray arrayWithCapacity:2];
    }
    return self;
}

-(void)addSlotView:(SFSlotView *)slotView;
{
    [_slotViews addObject:slotView];
}
-(void)removeAllSlotViews;
{
    [_slotViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
    [_slotViews removeAllObjects];
}
-(void)showSlotViews;
{
    //[self setNeedsDisplay:YES];
}
-(void)drawFixtureViewInRect:(NSRect)dirtyRect;
{
    _frame = dirtyRect;
   // [self setNeedsDisplay:YES];
}

-(NSRect)_drawBackgroundInRect:(NSRect)dirtyRect{
    CGFloat xEdge = 5.0,yEdge = 3.0;
    
    NSRect frame =NSMakeRect(dirtyRect.origin.x + xEdge, dirtyRect.origin.y +yEdge, dirtyRect.size.width - 2*xEdge, dirtyRect.size.height - 2 * yEdge);
    NSRect numberFrame,stringFrame;
    NSDivideRect(frame, &numberFrame, &stringFrame, 35, NSMinXEdge);
    
    NSBezierPath *path =[NSBezierPath bezierPathWithRoundedRect:frame xRadius:2 yRadius:2];
    NSColor *strokeColor = [NSColor lightGrayColor];

    [[NSColor whiteColor] setFill];
    [strokeColor setStroke];
    [path fill];
    [path stroke];
    //draw number value
    [[NSColor darkGrayColor] setFill];
    NSRectFill(numberFrame);
    NSFont *font = [NSFont fontWithName:@"Arial" size:16];
    NSAttributedString *attNumber =[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%li",(long)_uid + 1] attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor whiteColor]}];
    NSSize strsize = [attNumber size];
    NSPoint textDrawPoint =NSMakePoint(numberFrame.origin.x + (numberFrame.size.width - strsize.width)/2, numberFrame.origin.y + (numberFrame.size.height - strsize.height)/2);
    [attNumber drawInRect:NSMakeRect(textDrawPoint.x, textDrawPoint.y, strsize.width, strsize.height) ];
    
    return stringFrame;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    NSRect fixtureArea = [self _drawBackgroundInRect:dirtyRect]; // draw fixture view background.
    
    
    //show fixture view area.
    CGFloat dx=10,dy=5;
    NSRect fixtureViewRect =NSInsetRect(fixtureArea, dx, dy);

    /*remove all slot views*/
    NSArray *subViews = [self subviews];
    NSUInteger subViewCounts =[subViews count];
    if (subViewCounts > 0) {
        for (NSUInteger i=0; i<subViewCounts; i++) {
            [subViews[0] removeFromSuperview]; //this methods will change subViews elements after it be called.
        }
    }
    
    /* add slot view for each fixture view*/
   
   NSUInteger slotCounts=[_slotViews count];
   if (slotCounts > 0) {
       CGFloat slotViewHigh = fixtureViewRect.size.height*0.95;
       CGFloat slotViewWidth = fixtureViewRect.size.width / 2 - 10;
       slotViewHigh = slotViewHigh > 100 ? 100 :slotViewHigh; //adjust slot view high;
        for (NSUInteger idx=0; idx<slotCounts; idx++) {
            SFSlotView *slotView =[_slotViews objectAtIndex:idx];
            //[slotView setFrame:NSMakeRect(slotViewRect.origin.x, slotViewRect.origin.y + (slotCounts-idx-1)*slotViewHigh, slotViewRect.size.width, slotViewHigh)];
            [slotView setFrame:NSMakeRect(fixtureViewRect.origin.x+idx*(fixtureViewRect.size.width / 2), fixtureViewRect.origin.y + (fixtureViewRect.size.height - slotViewHigh)/2, slotViewWidth, slotViewHigh)];

            [self addSubview:slotView];
        }
    }

    
    // Drawing code here.
}

@end
