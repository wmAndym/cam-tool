//
//  SystemLogs.h
//  CAMTOOL
//
//  Created by jifu on 1/27/16.
//  Copyright (c) 2016 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface SystemLogs : NSManagedObject

@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSNumber * uid;

@end
