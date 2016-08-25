//
//  YieldView.h
//  CAMTOOL
//
//  Created by jifu on 1/25/16.
//  Copyright © 2016 sifo. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "SFBasePlotView.h"

@interface SFYieldView : SFBasePlotView
{
    NSColor *passColor;
    NSColor *failColor;
    NSColor *retestColor;
}

@end
