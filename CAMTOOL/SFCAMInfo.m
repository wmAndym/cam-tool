//
//  SFCAMInfo.m
//  CAMTOOL
//
//  Created by JeffZhang on 11/20/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFCAMInfo.h"
#import "SFCommonFounction.h"
#import "SFRecordWriter.h"

@implementation SFCAMInfo

-(BOOL)check_network;
{
   
    /*
    BOOL isConnected =  check_network_connection(self.ipAddress.UTF8String, 200) == 1 ? YES :NO;
    [self setIs_network_connected:isConnected];
    return _is_network_connected;
    */
    
    //NSLog(@"check_network:%@",self.ipAddress);
    NSURL *camHttpURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/main.htm",self.ipAddress]];
    NSMutableURLRequest *urlRequest =[NSMutableURLRequest requestWithURL:camHttpURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1.0];
    NSURLResponse *urlResponse= nil;
    NSError *anyError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&anyError ];
    if (data.length > 0 && anyError == nil) {
        [self setIs_network_connected:YES];
    }else{
        [self setIs_network_connected:NO];
    }
    
    
    /*
    if (self.is_network_connected) {
        
        int fd = tcpconnect_start_client(_ipAddress.UTF8String, "5555");
        int timeout = 200;
        const unsigned char *buf ="&s";
        unsigned int buf_len=0;
        while (1) {
            int ret;
            fd_set set;
            ssize_t w;
            struct timeval tv;

            FD_ZERO(&set);
            FD_SET(fd, &set);
            tv.tv_sec = (timeout * 1000) / 1000000;
            tv.tv_usec = (timeout * 1000) % 1000000;
            
            ret = select(fd+1, NULL, &set, NULL, &tv);
            switch (ret) {
                case 0:
                    _is_network_connected = NO;
                case 1:
                    _is_network_connected = YES;
                    w = write(fd, buf, buf_len);
                    if (w == -1) {
                        continue;
                    }
                    
                   
                    break;
                default:
                    break;
            }
            
        }
        
    }
     */
    return self.is_network_connected;
}

-(instancetype)init{
    self = [super init];
    if (self) {
        _cpuVoltage = @"0";
        _ssdVoltage = @"0";
        _statusOfCamInit = @-1;
        _statusOfUUTPowerOn = @-1;
        _statusOfUUTPowerDown =@-1;
        _status=@"IDLE";
        _enable = YES;
    }
    return self;
}


-(void)excuteCommandSets:(NSArray*)commands withIdentifier:(NSString *)identifier
{
    

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      
      
      dispatch_async(dispatch_get_main_queue(), ^{
          [self setStatus:[NSString stringWithFormat:@"start %@...",identifier]];
          
      });
      
       [commands enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           NSDictionary *command = obj;
           NSString *commandName = [command objectForKey:@"Command"];
           NSArray *arguments = [command objectForKey:@"Arguments"];
           if ([@"Sleep" isEqualToString:commandName]) {
               NSLog(@"Sleep:%@",arguments[0]);
               [NSThread sleepForTimeInterval:[arguments[0] floatValue]];
           }else{
               
               NSString *url_string =[NSString stringWithFormat:@"http://%@/main.htm?%@=%@",_ipAddress,commandName,arguments[0]];
               NSLog(@"%@",url_string);
               [SFCommonFounction executeCmd:@"/usr/bin/curl" withArguments:@[url_string,@"--silent",@"--compressed",@"--max-time",@"2"]];
               
           }
           
           [[NSNotificationCenter defaultCenter] postNotificationName:SFCAM_LOG_UPDATED_NOTIFICATION object:self userInfo:@{@"LogMessage":[NSString stringWithFormat:@"[%@] Set %@ to %@",_slotName, commandName,arguments[0]]}];
       }];
      
      dispatch_async(dispatch_get_main_queue(), ^{
          [self setStatus:[NSString stringWithFormat:@"%@ done",identifier]];

      });
   });
    
}

-(void)setIs_network_connected:(BOOL)is_network_connected
{
   
    if (is_network_connected != _is_network_connected) {
        if (is_network_connected) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SFCAM_LOG_UPDATED_NOTIFICATION object:self userInfo:@{@"LogMessage":[NSString stringWithFormat:@"[%@-%@] connected!",_slotName,_ipAddress]} ];
            

        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:SFCAM_LOG_UPDATED_NOTIFICATION object:self userInfo:@{@"LogMessage":[NSString stringWithFormat:@"[%@-%@] disconnected!",_slotName,_ipAddress]} ];
            

        }
    }
    
    _is_network_connected = is_network_connected;
}

-(void)setStatusOfCamInit:(NSNumber *)statusOfCamInit{
    

    if ([statusOfCamInit isEqualToNumber:@1]) {
        
        if (_is_network_connected == NO) {
            NSRunAlertPanel(@"WARNNING", @"CAM board disconnected", @"OK", nil, nil);
            return;
        }else if (_enable == NO){
            NSRunAlertPanel(@"WARNNING", @"Slot is disabled ", @"OK", nil, nil);
            return;
        }
        NSArray *commands = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.CommandSets.CAM_Init"];

        [self excuteCommandSets:commands withIdentifier:@"initialize"];
        [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"initialize %@",_slotName] Type:SFLogTypeNormal];


    }
    
    _statusOfCamInit = statusOfCamInit;

}

-(void)setStatusOfUUTPowerDown:(NSNumber *)statusOfUUTPowerDown{
    
    if ([statusOfUUTPowerDown isEqualToNumber:@1]) {
        if (_is_network_connected == NO) {
            NSRunAlertPanel(@"WARNNING", @"CAM board disconnected", @"OK", nil, nil);
            return;
        }else if (_enable == NO){
            NSRunAlertPanel(@"WARNNING", @"Slot is disabled ", @"OK", nil, nil);
            return;
        }
        
        _statusOfUUTPowerOn = @-1;
        NSArray *commands = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.CommandSets.UUT_PowerDown"];
        
        
        [self excuteCommandSets:commands withIdentifier:@"power down"];
        [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"power down %@",_slotName] Type:SFLogTypeNormal];


    }
    
    _statusOfUUTPowerDown = statusOfUUTPowerDown;

    
}

-(void)setStatusOfUUTPowerOn:(NSNumber *)statusOfUUTPowerOn{
    
    
    
    if ([statusOfUUTPowerOn isEqualToNumber:@1]) {
        if (_is_network_connected == NO ) {
            NSRunAlertPanel(@"WARNNING", @"CAM board disconnected", @"OK", nil, nil);
            return;
        }else if (_enable == NO){
            NSRunAlertPanel(@"WARNNING", @"Slot is disabled ", @"OK", nil, nil);
            return;
        }

        
        _statusOfUUTPowerDown = @-1;
        //launch nanokdp
        
        
       
        NSString *nanokdp_sh=[[NSBundle mainBundle] pathForResource:@"run_nanokdp" ofType:@"command" inDirectory:@"tools"];
        [[NSUserDefaults standardUserDefaults] setObject:_macAddress forKey:@"SELECTED_SLOT_MAC_ADDRESS"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [NSThread sleepForTimeInterval:1];
        [[NSWorkspace sharedWorkspace] openFile:nanokdp_sh];
        //execute the command sets.
        NSArray *commands = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.CommandSets.UUT_PowerOn"];
        
        [self excuteCommandSets:commands withIdentifier:@"power on"];
        
        [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"power on %@",_slotName] Type:SFLogTypeNormal];

        
    }
    
    _statusOfUUTPowerOn = statusOfUUTPowerOn;

}

-(void)setStatus:(NSString *)status
{
    _status =status;
    [[NSUserDefaults standardUserDefaults] setValue:status forKey:_slotName];
}


@end
