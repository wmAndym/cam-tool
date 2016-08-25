//
//  SFUserStatusView.m
//  CAMTOOL
//
//  Created by jifu on 1/10/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFStatusView.h"

@implementation SFStatusView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [[NSColor lightGrayColor] setFill];
    NSRectFill(dirtyRect);
    // Drawing code here.
}

@end
