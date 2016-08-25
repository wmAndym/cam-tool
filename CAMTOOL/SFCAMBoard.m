//
//  SFCAMBoard.m
//  CAMTOOL
//
//  Created by jifu on 11/16/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFCAMBoard.h"
#import "SFCommonFounction.h"

@implementation SFCAMBoard

-(instancetype)init{
    self =[super init];
    
    if (self) {
        _camHeaderInfo= [NSMutableArray array];
        _camPortInfo= [NSMutableArray array];
        _temperature=@"0.0";
        

    }
    
    return self;
}
-(NSString *)ipAddress
{
    return _ipAddress;
}

-(void)setIpAddress:(NSString *)ipAddress
{
    _ipAddress = [ipAddress copy];
    
}

+(instancetype)boardID:(NSUInteger)identify WithIPAddress:(NSString *)ipAddresss ;
{
    SFCAMBoard *board =[[SFCAMBoard alloc] init];
    [board setIpAddress:ipAddresss];
    [board setBoardID:identify];
    [board setTempPath:[NSString stringWithFormat:@"/tmp/cam_info_%lu.plist",identify]];
    return board;
}


-(void)startProb;
{
    [self runScript];
}


- (void)runScript{
    
    NSString *script =[[NSBundle mainBundle] pathForResource:@"cam_probe" ofType:@"pl" inDirectory:@"tools"];
    [SFCommonFounction executeCmd:@"/usr/bin/perl" withArguments:@[script,self.ipAddress,self.tempPath]];
    [NSThread sleepForTimeInterval:0.2];
    [self loadCAMInfomation:self.tempPath];
}

-(void)loadCAMInfomation:(NSString *)plist;
{
    NSDictionary *dict =[NSDictionary dictionaryWithContentsOfFile:plist];
    if ([[dict objectForKey:@"ErrorCode"] isEqualToString:@"0"]) {
        
        //load header infomation
        NSDictionary *header_info = [dict objectForKey:@"HeaderInfo"];
        NSString *temp=[dict objectForKey:@"Temperature"];
        if (temp) {
            [self setTemperature:temp];
        }
        
        [_camHeaderInfo removeAllObjects];
        
        [header_info enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSMutableDictionary *item = [NSMutableDictionary dictionary];
            [item setObject:key forKey:@"pkey"];
            [item setObject:obj forKey:@"pvalue"];
            [_camHeaderInfo addObject:item];
        }];
        
        
        //load port infomation
        NSArray *port_info = [dict objectForKey:@"PortInfo"];
        [_camPortInfo removeAllObjects];
        
        self.drawerMode = 0;
        
        [port_info enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *item = obj;
            NSString *portName =[item objectForKey:@"PortName"];
            NSString *portType =[item objectForKey:@"PortType"];
            NSString *portValue =[item objectForKey:@"PortValue"];
            NSString *signal =[item objectForKey:@"PortSignal"];
            SFCAMPortItem *pItem =[SFCAMPortItem portItemWithName:portName type:portType value:portValue signal:signal];
            
            BOOL b = [portValue isEqualToString:@"1"];
            
 
            if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.LED_PASS"]]){
                [self setPassState:b];
            }
            
            else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.LED_FAIL"]]){
                [self setFailState:b];
            }
            else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.LELD_IN_PROCESS"]]){
                [self setInprocessState:b];
            }
            else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.ADAPTER"]]){
                [self setAdpaterState:b];
            }else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.BATTERY"]]){
                [self setBatteryState:b];
            }else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.IN_SENSOR"]]) {
                [self setInSensor:b];
            }else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.OUT_SENSOR"]]){
                [self setOutSensor:b];
            }else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.UP_SENSOR"]]){
                [self setUpSensor:b];
            }else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.DOWN_SENSOR"]]){
                [self setDownSensor:b];
            }
            
            else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.DRAWER_MODE_BIT0"]]){
                _drawerMode = b ? _drawerMode + 1:_drawerMode;
                
            }else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.DRAWER_MODE_BIT1"]]){
                _drawerMode = b ? _drawerMode + 2:_drawerMode;
            }
            else if ([portName isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.START_BTN_PRESSED"]]){
                [self setIsStartBtnPressed:b];
            }
            
            [_camPortInfo addObject:pItem];
        }];
        
    }
    else{
        
        [_camHeaderInfo removeAllObjects];
        [_camPortInfo removeAllObjects];
    }
}


@end
