//
//  SFLogViewController.h
//  CAMTOOL
//
//  Created by jifu on 1/16/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFViewController.h"
#import "SystemLogs.h"
@interface SFLogViewController : SFViewController <NSTableViewDataSource,NSTableViewDelegate>

@property(retain)NSDate *startDate;
@property(retain)NSDate *endDate;
@property(retain)NSArray  *logs;
@property(assign)BOOL canOperateDB;
@end

