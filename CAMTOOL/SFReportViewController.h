//
//  SFReportViewController.h
//  CAMTOOL
//
//  Created by jifu on 1/25/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFViewController.h"

#import "SFUPHView.h"
#import "SFYieldView.h"

@interface SFReportViewController : SFViewController <PlotViewDataSource,NSTableViewDataSource,NSTableViewDelegate>


@property(strong,nonatomic)NSDate *startDate;
@property(strong,nonatomic)NSDate *endDate;
-(IBAction)searchDatabase:(id)sender;
-(IBAction)updateDatabase:(id)sender;

@end
