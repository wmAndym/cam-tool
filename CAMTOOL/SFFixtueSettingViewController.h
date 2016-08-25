//
//  SFFixtueSettingViewController.h
//  CAMTOOL
//
//  Created by jifu on 11/20/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFViewController.h"
@interface SFFixtueSettingViewController : SFViewController <NSTableViewDataSource>
@property (strong) IBOutlet NSPanel *probePanel;
@property(retain)NSMutableArray *slotSettings;
@property (weak) IBOutlet NSTableView *slotSettingTableView;
@end
