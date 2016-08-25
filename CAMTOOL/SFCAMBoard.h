//
//  SFCAMBoard.h
//  CAMTOOL
//
//  Created by jifu on 11/16/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SFCAMPortItem.h"

@interface SFCAMBoard : NSObject

{
    NSString *_ipAddress;
}

@property(assign)NSUInteger boardID;
@property(copy)NSString *tempPath;

@property(assign)BOOL upSensor;
@property(assign)BOOL downSensor;
@property(assign)BOOL InSensor;
@property(assign)BOOL OutSensor;

@property(assign)BOOL failState;
@property(assign)BOOL passState;
@property(assign)BOOL inprocessState;
@property(assign)BOOL adpaterState;
@property(assign)BOOL batteryState;

@property(copy)NSString *temperature;


/*
@property(assign)NSInteger cpuTemperature;
@property(assign)NSInteger ssdTemperature;
@property(assign)NSInteger topTemperature;
@property(assign)NSInteger bottomTemperature;
*/

@property(assign)BOOL isStartBtnPressed;
@property(assign)NSUInteger drawerMode;


@property(retain,readwrite)NSMutableArray *camHeaderInfo;
@property(retain,readwrite)NSMutableArray *camPortInfo;



-(NSString *)ipAddress;
-(void)setIpAddress:(NSString *)ipAddress;



+(instancetype)boardID:(NSUInteger)identify WithIPAddress:(NSString *)ipAddresss ;
-(void)startProb;

@end
