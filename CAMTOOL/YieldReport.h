//
//  YieldReport.h
//  CAMTOOL
//
//  Created by jifu on 1/27/16.
//  Copyright (c) 2016 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface YieldReport : NSManagedObject

@property (nonatomic, retain) NSString * mark;
@property (nonatomic, retain) NSNumber * result;
@property (nonatomic, retain) NSString * slotName;
@property (nonatomic, retain) NSString * sn;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSDate * startTimeStamp;

@end
