//
//  SFLocalBootViewController.h
//  CAMTOOL
//
//  Created by JeffZhang on 11/20/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFViewController.h"

@interface SFLocalBootViewController : SFViewController<NSTableViewDataSource,NSTableViewDelegate>
{
    NSMutableArray *cam_info_list;
}
@property(assign)BOOL start_read_adc_flag;
@property (unsafe_unretained) IBOutlet NSTextView *logTextView;
@property (weak) IBOutlet NSTableView *camInfoTableView;
@end
