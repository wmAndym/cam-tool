//
//  SFCAMInfo.h
//  CAMTOOL
//
//  Created by JeffZhang on 11/20/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>
#define SFCAM_LOG_UPDATED_NOTIFICATION @"SFCAM_LOG_UPDATED_NOTIFICATION"


@interface SFCAMInfo : NSObject
@property(assign,nonatomic)BOOL enable;
@property(copy)NSString *slotName;
@property(copy)NSString *cpuVoltage;
@property(copy)NSString *ssdVoltage;
@property(copy)NSString *ipAddress;
@property(copy)NSString *macAddress;
@property(retain,nonatomic)NSNumber *statusOfCamInit;
@property(retain,nonatomic)NSNumber *statusOfUUTPowerOn;
@property(retain,nonatomic)NSNumber *statusOfUUTPowerDown;
@property(assign,nonatomic)BOOL is_network_connected;
@property(copy,nonatomic)NSString *status;
-(BOOL)check_network;
@end
