//
//  SFSlotCommunication.h
//  CAMTOOL
//
//  Created by jifu on 1/28/16.
//  Copyright (c) 2016 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *g_wabisabi_ip;
extern NSString *g_wabisabi_port;

@interface SFSlotCommunication : NSObject

#ifdef DEBUG
@property(retain)NSMutableArray *debug_slot_settings;
#endif

+(instancetype)sharedSlotCommunication;

+(void)obtainWabisabiInfomation;
+(NSString *)sendJsonData:(NSArray*)args;
+(NSString *)pairSlot:(NSString *)slot  carrierID:(NSString *)carrierID CAMAddress:(NSString *)camAddress;
+(void)clearpairSlot:(NSString *)slot  carrierID:(NSString *)carrierID CAMAddress:(NSString *)camAddress;
+(NSString *)unpairSlot:(NSString *)slot  carrierID:(NSString *)carrierID CAMAddress:(NSString *)camAddress;
+(BOOL)checkIsCarrierPaired:(NSString *)mac information:(NSMutableDictionary *) info;
+(BOOL)checkIsSlotPaired:(NSString *)slotID information:(NSMutableDictionary *) info;

@end
