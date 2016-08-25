//
//  SFFixtureView.h
//  CAMTOOL
//
//  Created by jifu on 12/23/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFSlotView.h"

@interface SFFixtureView : NSView
{
    NSMutableArray *_slotViews;
}
@property(assign)NSInteger uid;
@property(copy)NSString *identify;

-(void)drawFixtureViewInRect:(NSRect)dirtyRect;
-(void)addSlotView:(SFSlotView *)slotView;
-(void)removeAllSlotViews;
-(void)showSlotViews;
@end
