//
//  SFTestSeqViewController.h
//  CAMTOOL
//
//  Created by jifu on 12/8/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFViewController.h"
#import "SFNANDRackMainView.h"

@interface SFTestSeqViewController : SFViewController <SFNANDRackDataSource>
{
  
    NSMutableArray *_fixtureViews;
    NSMutableArray *_slotViews;
    SFSlotView *_selectedSlotView;
    NSString *_wabisabi_ip;
    NSString *_wabisabi_port;
    IBOutlet NSTextField *_scanArea;
    NSInteger mainWindowStyleMask;
    __weak IBOutlet NSView *scanView;
    __weak IBOutlet NSView *inputView;
    __weak IBOutlet NSButton *fullScreenBtn;
    NSRect orignalViewRect;
    
    
}
@property(assign)BOOL start_read_adc_flag;

@property (weak) IBOutlet NSButton *pairImageView;
@property (weak) IBOutlet NSButton *unpairImageView;
@property (weak) IBOutlet NSButton *clearImageView;

@property(assign,nonatomic)BOOL hiddenPairImageView;
@property(assign,nonatomic)BOOL hiddenUnpairImageView;
@property(assign,nonatomic)BOOL hiddenClearImageView;


@property (weak) IBOutlet SFNANDRackMainView *nandRackMainView;
@property (weak) IBOutlet NSTextField *promptTextField;

-(IBAction)fullScreen:(id)sender;

@end
