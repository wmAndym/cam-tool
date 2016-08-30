//
//  SFSlotCommunication.m
//  CAMTOOL
//
//  Created by jifu on 1/28/16.
//  Copyright (c) 2016 sifo. All rights reserved.
//

#import "SFSlotCommunication.h"
#import "SFCommonFounction.h"
#import "SFRecordWriter.h"

NSString *g_wabisabi_ip = nil;
NSString *g_wabisabi_port =nil;

@implementation SFSlotCommunication

-(instancetype)init{
    self = [super init];
    if (self) {
#ifdef DEBUG
        _debug_slot_settings=[NSMutableArray array];
#endif
    }
    return self;
}


+(instancetype)sharedSlotCommunication;
{
    static dispatch_once_t onceToken;
    static SFSlotCommunication *sharedObject =nil;
    dispatch_once(&onceToken, ^{
        
        sharedObject = [SFSlotCommunication new];
    });
    return sharedObject;
}

+(void)obtainWabisabiInfomation{
    
    if (g_wabisabi_ip == nil) {
        g_wabisabi_ip = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"wabisabi_ip"];
        g_wabisabi_port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"wabisabi_port"];
        
    }
    
}

+(NSString *)sendJsonData:(NSArray*)args
{
    NSString *cmd = @"/usr/bin/curl";
    NSString *output = @"";
    
    output = [SFCommonFounction executeCmd:cmd withArguments:args];
    
    [[SFRecordWriter sharedLogWriter] insertLog:output Type:SFLogTypeNormal];
    
    NSLog(@"%@ %@ %@",cmd,args,output);
    return  output;
    
}

+(NSString *)unpairSlot:(NSString *)slot  carrierID:(NSString *)carrierID CAMAddress:(NSString *)camAddress{
    
    [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"unpairSlot:%@  carrierID:%@ CAMAddress:%@",slot,carrierID,camAddress] Type:SFLogTypeNormal];
    
    
#ifdef DEBUG
    __block id object_will_be_removed=nil;
    [[[SFSlotCommunication sharedSlotCommunication] debug_slot_settings] enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *  stop) {
        if (obj && [[obj objectForKey:@"slot"] isEqualToString:slot]) {
            object_will_be_removed = obj;
            *stop = YES;
        }
    }];
    
    
    if (object_will_be_removed !=nil) {
        [[[SFSlotCommunication sharedSlotCommunication] debug_slot_settings] removeObject:object_will_be_removed];
    }
    
    //call unpair.command shell.
    NSString *unpairCommandPath=[[NSBundle mainBundle] pathForResource:@"unpair" ofType:@"command" inDirectory:@"actionscripts"];
    
    [SFCommonFounction executeCmd:@"/bin/sh" withArguments:@[unpairCommandPath,carrierID,slot,camAddress]];
    
    return @"OK";
#else
    
    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/slots/%@/carrier",g_wabisabi_ip,g_wabisabi_port,slot],@"-X",@"DELETE"];
    
    //call unpair.command shell.
    NSString *unpairCommandPath=[[NSBundle mainBundle] pathForResource:@"unpair" ofType:@"command" inDirectory:@"actionscripts"];
    NSString *output = [SFSlotCommunication sendJsonData:args];
    [NSThread sleepForTimeInterval:0.5];
    [SFCommonFounction executeCmd:@"/bin/sh" withArguments:@[unpairCommandPath,carrierID,slot,camAddress]];
    return output;
    
#endif
    
    
    
    
}

+(void)clearpairSlot:(NSString *)slot  carrierID:(NSString *)carrierID CAMAddress:(NSString *)camAddress{
    //TODO:clear pair slot action
    
    
}
+(NSString *)pairSlot:(NSString *)slot  carrierID:(NSString *)carrierID CAMAddress:(NSString *)camAddress{
    
#ifdef DEBUG
    
    __block BOOL changed=NO;
    [[[SFSlotCommunication sharedSlotCommunication] debug_slot_settings] enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *  stop) {
        if (obj && [[obj objectForKey:@"slot"] isEqualToString:slot]) {
            [obj setObject:@"carrier" forKey:carrierID];
            [obj setObject:@"cam" forKey:camAddress];
            changed=YES;
            *stop = YES;
            
        }
    }];
    
    
    if (changed ==NO) {
        NSDictionary *dict = @{@"slot":slot,@"carrier":carrierID,@"cam":camAddress};
        [[[SFSlotCommunication sharedSlotCommunication] debug_slot_settings] addObject:dict];
    }
    
    //call pair.command shell.
    NSString *pairCommandPath=[[NSBundle mainBundle] pathForResource:@"pair" ofType:@"command" inDirectory:@"actionscripts"];
    
    [SFCommonFounction executeCmd:@"/bin/sh" withArguments:@[pairCommandPath,carrierID,slot,camAddress]];
    
    
    
    return @"OK";
#else
    
    [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"pairSlot:%@  carrierID:%@ CAMAddress:%@",slot,carrierID,camAddress] Type:SFLogTypeNormal];
    
    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/carriers/%@",g_wabisabi_ip,g_wabisabi_port,carrierID],@"-X",@"PUT"];
    [self sendJsonData:args];
    
    [NSThread sleepForTimeInterval:0.1];
    args=@[[NSString stringWithFormat:@"%@:%@/api/slots/%@/carrier",g_wabisabi_ip,g_wabisabi_port,slot],@"-X",@"PUT",@"-d",[NSString stringWithFormat:@"{\"id\":\"%@\"}",carrierID],@"-H",@"Content-Type: application/json"];
    [self sendJsonData:args];
    [NSThread sleepForTimeInterval:0.1];
    args=@[[NSString stringWithFormat:@"%@:%@/api/carriers/%@",g_wabisabi_ip,g_wabisabi_port,carrierID],@"-X",@"PATCH",@"-d",[NSString stringWithFormat:@"{\"serialPort\":\"%@\"}",camAddress],@"-H",@"Content-Type: application/json"];
    
    //call pair.command shell.
    
    NSString *pairCommandPath=[[NSBundle mainBundle] pathForResource:@"pair" ofType:@"command" inDirectory:@"actionscripts"];
    NSString *output = [self sendJsonData:args];
    [NSThread sleepForTimeInterval:0.5];
    [SFCommonFounction executeCmd:@"/bin/sh" withArguments:@[pairCommandPath,carrierID,slot,camAddress]];
    return output;
    
#endif
    
    
    
    
    
}

+(BOOL)checkIsCarrierPaired:(NSString *)mac information:(NSMutableDictionary *) info;
{
    
#ifdef DEBUG
    __block BOOL isPaired= NO;
    [[[SFSlotCommunication sharedSlotCommunication] debug_slot_settings] enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        if (obj && [[obj valueForKey:@"carrier"] isEqualToString:mac]) {
            isPaired = YES;
            *stop = YES;
            NSDictionary *slot=@{@"sioSlot":[obj objectForKey:@"slot"]};
            [info setObject:slot forKey:@"slot"];
        }
    }];
    return isPaired;
#else
    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/carriers/%@",g_wabisabi_ip,g_wabisabi_port,mac]];
    NSString *output = [SFSlotCommunication sendJsonData:args];
    
    NSDictionary *retInfo =[NSJSONSerialization
                            JSONObjectWithData:[output dataUsingEncoding:NSUTF8StringEncoding]
                            options:NSJSONReadingMutableLeaves error:nil];
    
    [info setDictionary:retInfo];
    
    if ([[retInfo valueForKeyPath:@"state"] isEqualToString:@"PAIRED"] || [retInfo valueForKeyPath:@"slot.id"]) {
        return  YES;
    }
    return NO;
#endif
}
+(BOOL)checkIsSlotPaired:(NSString *)slotID information:(NSMutableDictionary *) info{
    
#ifdef DEBUG
    __block BOOL isPaired= NO;
    [[[SFSlotCommunication sharedSlotCommunication] debug_slot_settings] enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        if (obj && [[obj valueForKey:@"slot"] isEqualToString:slotID]) {
            isPaired = YES;
            *stop = YES;
            [info setObject:[obj valueForKey:@"carrier"] forKey:@"id"];
        }
    }];
    return isPaired;
    
#else
    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/slots/%@/carrier",g_wabisabi_ip,g_wabisabi_port,slotID]];
    NSString *output = [SFSlotCommunication sendJsonData:args];
    
    NSDictionary *retInfo =[NSJSONSerialization
                            JSONObjectWithData:[output dataUsingEncoding:NSUTF8StringEncoding]
                            options:NSJSONReadingMutableLeaves error:nil];
    
    [info setDictionary:retInfo];
    
    
    if ([retInfo valueForKeyPath:@"id"]) {
        return  YES;
    }
    return NO;
#endif
}
@end
