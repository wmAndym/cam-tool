//
//  SFLogCenter.h
//  CAMTOOL
//
//  Created by jifu on 1/20/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFDataCenter.h"

@interface SFRecordWriter : NSObject

@property(assign,readonly) NSUInteger totalPassCount;
@property(assign,readonly) NSUInteger totalFailCount;

-(void)restoreFPY;

-(void)resetFPY;

+(instancetype)sharedLogWriter;

-(void)appendSystemLogWithFormat:(NSString *)format,...;
-(void)appendSystemLog:(NSString *)logString;
-(void)insertLog:(NSString *)logMessage Type:(SFLogType) type;

-(void)addUUTRecord:(NSString *)sn
             result:(SFUUTTestResult)result
               slot:(NSString *)slotName
          startTime:(NSDate*)startDate;

@end
