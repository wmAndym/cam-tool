//
//  SFCAMViewController.h
//  CAMTOOL
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFViewController.h"

#import "SFCAMBoard.h"

@interface SFCAMViewController : SFViewController<NSTableViewDataSource>

{
   //NSMutableArray *_CAMBoardsIpAddress;
    BOOL _shouldDestroyWhenUserChangedNavigationItem;
}
@property(assign) BOOL isStartProbe;
@property (weak) IBOutlet NSTableView *seqTableView;
@property(retain,readwrite)NSMutableArray *CAMSequnces;
@property(retain)NSMutableArray *CAMBoardsIpAddress;
@property (weak) IBOutlet SFCAMBoard *selectedBoard;
@property (weak) IBOutlet NSButton *startBtn;
@property (weak) IBOutlet NSButton *setIpBtn;
@property (weak) IBOutlet NSTextField *IpAddressField;
@property (weak) IBOutlet NSPopUpButton *slotSelector;
@property (weak) IBOutlet NSTableView *headerTableView;
@property (weak) IBOutlet NSTableView *portInfoTableView;
//@property (weak) IBOutlet NSProgressIndicator *progress;
@property (weak) IBOutlet NSComboBox *signals;
@property (weak) IBOutlet NSTextField *drawerModeTextField;
@property (weak) IBOutlet NSPopUpButton *popBtnValueUserDefinition;
@property (strong) IBOutlet NSArrayController *sequnceArrayController;
@property (weak) IBOutlet NSTextField *cpuTemp;
@property (weak) IBOutlet NSTextField *ssdTemp;
@property (weak) IBOutlet NSTextField *topTemp;
@property (weak) IBOutlet NSTextField *botTemp;

- (IBAction)updateSignalValue:(id)sender;
- (IBAction)updateLEDStates:(id)sender;

- (IBAction)pingCheck:(id)sender;

- (IBAction)setIpAddress:(id)sender;
- (IBAction)startProbe:(id)sender;
-(IBAction)changeSlot:(id)sender;
- (IBAction)setDrawerAction:(id)sender;
@end
