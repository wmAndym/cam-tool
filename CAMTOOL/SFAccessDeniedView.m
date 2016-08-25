//
//  SFAccessDeniedView.m
//  CAMTOOL
//
//  Created by jifu on 16/1/9.
//  Copyright (c) 2016年 sifo. All rights reserved.
//

#import "SFAccessDeniedView.h"

@implementation SFAccessDeniedView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor windowBackgroundColor] setFill];
    NSRectFill(dirtyRect);
    NSFont *font = [NSFont fontWithName:@"Arial" size:56];
    NSAttributedString *attNumber =[[NSAttributedString alloc] initWithString:@"Access Denied!!" attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor whiteColor]}];
    NSSize strsize = [attNumber size];
    NSPoint textDrawPoint =NSMakePoint(dirtyRect.origin.x + (dirtyRect.size.width - strsize.width)/2, dirtyRect.origin.y + (dirtyRect.size.height - strsize.height)/2);
    NSRect textRect =NSMakeRect(textDrawPoint.x, textDrawPoint.y, strsize.width, strsize.height);

    NSBezierPath *path =[NSBezierPath bezierPathWithRoundedRect:textRect xRadius:5 yRadius:5];
    [[NSColor orangeColor] setFill];
    [path fill];
    [attNumber drawInRect:NSMakeRect(textDrawPoint.x, textDrawPoint.y, strsize.width, strsize.height) ];

}

@end
