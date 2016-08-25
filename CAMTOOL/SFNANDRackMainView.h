//
//  SFNANDRackMainView.h
//  CAMTOOL
//
//  Created by jifu on 12/21/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFFixtureView.h"
@protocol SFNANDRackDataSource <NSObject>

@required
-(NSUInteger)fixutureNumber;
-(NSUInteger)slotNumberOfFixtureView:(SFFixtureView *)fixtureView;

-(SFFixtureView *)fixtureViewAtIndex:(NSUInteger)index;
-(SFSlotView *)slotViewAtIndex:(NSUInteger)index ofFixtureView:(SFFixtureView *)fixtureView;

@end

@interface SFNANDRackMainView : NSView
{
    CGFloat _gap_x,_gap_y;
    CGFloat _high_of_top_header_view,_high_of_bottom_status_view;
    CGFloat _frame_border_width;
    NSString *_title;
    NSRect _fixtureViewFrame;
    id<SFNANDRackDataSource> _dataSource;
    
}
-(void)setTitle:(NSString *)title;
-(void)setDataSource:(id<SFNANDRackDataSource>)ds;
-(NSRect)fixtureViewFrame;


@end
