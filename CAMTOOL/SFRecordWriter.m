//
//  SFLogCenter.m
//  CAMTOOL
//
//  Created by jifu on 1/20/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFRecordWriter.h"
#import "SystemLogs.h"
#import "SFAuthenticator.h"
#import "YieldReport.h"
@implementation SFRecordWriter
-(instancetype)init{
    self =[super init];
    
    if ( self) {
        _totalFailCount = 0;
        _totalPassCount = 0;
    }
    return self;
}
+(instancetype)sharedLogWriter;
{
    static dispatch_once_t onceToken;
    static SFRecordWriter *sharedLogCenter = nil;
    dispatch_once(&onceToken, ^{
        sharedLogCenter=[SFRecordWriter new];
    });
    return sharedLogCenter;
}

-(void)insertLog:(NSString *)logMessage Type:(SFLogType) type;
{
    NSManagedObjectContext *manamgedObjectContext = [[SFDataCenter sharedDataCenter] managedObjectContext];
    SystemLogs *log = [NSEntityDescription insertNewObjectForEntityForName:@"SystemLogs" inManagedObjectContext:manamgedObjectContext];
    if (log != nil) {
        log.message = logMessage;
        log.type = @(type);
        log.uid =@([[SFAuthenticator sharedAutheticator] userLevel]);
        log.timestamp = [NSDate new];
        
    }else{
        NSLog(@"failed to create the new log entity description");
    }
}

-(void)addUUTRecord:(NSString *)sn
             result:(SFUUTTestResult)result
               slot:(NSString *)slotName
          startTime:(NSDate*)startDate;
{
    NSManagedObjectContext *manamgedObjectContext = [[SFDataCenter sharedDataCenter] managedObjectContext];
    YieldReport *report = [NSEntityDescription insertNewObjectForEntityForName:@"YieldReport" inManagedObjectContext:manamgedObjectContext];
    if (report != nil) {
        report.sn = sn;
        report.result = @(result);
        report.slotName =slotName;
        report.timestamp = [NSDate new];
        report.startTimeStamp = startDate;
        
        if(result == SFUUTPassedResult){
            report.mark = @"Passed";
            _totalPassCount +=1;
        }else{
            report.mark = @"Failed";
            _totalFailCount +=1;
        }
        [self storeFPY];
    }else{
        NSLog(@"addUUTRecord :failed to create the new log entity description");
    }
}

-(void)appendSystemLogWithFormat:(NSString *)format,...;
{
   // NSLog(format,_VA_LIST);
    
    /*
    NSMutableArray *args=[NSMutableArray array];
    va_list argList;
    
    id arg;
    if (format) {
        va_start(argList,format);
        while ((arg = va_arg(argList, id))) {
            [args addObject:arg];
        }
        va_end(argList);
    }
     */
    
}

-(void)restoreFPY;
{
    NSDictionary *fpy = [[NSUserDefaults standardUserDefaults] objectForKey:@"FPY"];
    if (fpy) {
        _totalFailCount = [[fpy objectForKey:@"TotoalFailedCount"] unsignedIntegerValue];
        _totalPassCount = [[fpy objectForKey:@"TotoalPassedCount"] unsignedIntegerValue];
    }
}
-(void)storeFPY;
{
    NSDictionary *fpy = @{@"TotoalFailedCount":@(_totalFailCount),@"TotoalPassedCount":@(_totalPassCount)};
    [[NSUserDefaults standardUserDefaults] setObject:fpy forKey:@"FPY"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
-(void)resetFPY;
{
    _totalFailCount = 0;
    _totalPassCount = 0;
    [self storeFPY];
}
-(void)appendSystemLog:(NSString *)logString;
{
    
}
@end
