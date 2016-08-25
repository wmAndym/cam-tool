//
//  SFMainView.m
//  CAM
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFMainView.h"

@implementation SFMainView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _enabled = YES;
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{

    if (_enabled == NO) {
        [[NSColor whiteColor] setFill];
    }else{
        [NSColor windowBackgroundColor];
    }

    [super drawRect:dirtyRect];
    
}

-(void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
}

//disable mouse
-(NSView *)hitTest:(NSPoint)aPoint
{
    NSView *v =[super hitTest:aPoint];
    if (_enabled == NO) {
        v = nil;;
    }
    return v;
}

@end
