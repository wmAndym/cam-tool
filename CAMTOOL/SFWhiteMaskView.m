//
//  SFWhiteMaskView.m
//  CAMTOOL
//
//  Created by jifu on 16/1/8.
//  Copyright (c) 2016年 sifo. All rights reserved.
//

#import "SFWhiteMaskView.h"

@implementation SFWhiteMaskView

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
    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    
    // Drawing code here.
}

@end
