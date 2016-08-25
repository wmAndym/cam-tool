//
//  SFLocalBootViewController.m
//  CAMTOOL
//
//  Created by JeffZhang on 11/20/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFLocalBootViewController.h"
#import "SFCAMInfo.h"
#import "SFCommonFounction.h"
#import "SFRecordWriter.h"

@interface SFLocalBootViewController ()

@end

@implementation SFLocalBootViewController


-(void)destroyController
{
   
    [super destroyController];

    [self setStart_read_adc_flag:NO];
    

}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self]; //remove SFCAM_LOG_UPDATED_NOTIFICATION
#ifdef DEBUG
    NSLog(@"%@-->dealloced",self.nibName);
#endif

}

-(SFCAMInfo *)camInfoByIPAddress:(NSString *)ip
{
    __block SFCAMInfo *camInfo=nil;
    [cam_info_list   enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SFCAMInfo *cam = obj;
        if ([cam.ipAddress isEqualToString:ip]) {
            *stop = YES;
            camInfo = cam;
        }
    }];
    return camInfo;
}

-(void)auto_start{
    NSString *adc_file = @"/tmp/cam_read_adc.plist";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *script =[[NSBundle mainBundle] pathForResource:@"read_adc" ofType:@"py" inDirectory:@"tools"];
        NSString *cpuVoltageSignal=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.PPVCC_S0_CPU"] ;
        NSString *ssdVoltageSignal=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.PP0V9_SSD_REG"] ;
       
        while (_start_read_adc_flag) {
            
            NSMutableArray *arguments = [NSMutableArray arrayWithArray:@[script,@"--file",adc_file,@"--ip"]];
            
            [cam_info_list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                SFCAMInfo *camInfo = obj;
                if (camInfo.enable && [camInfo check_network]) {
                    [arguments addObject:camInfo.ipAddress];
                };
                
            }];
            
            //NSLog(@"start to read adc");

            if ([arguments count] >4) {
                [SFCommonFounction executeCmd:@"/usr/bin/python" withArguments:arguments];
            }
            
            [arguments removeAllObjects];
            
            NSDictionary *adc_data =[NSDictionary dictionaryWithContentsOfFile:adc_file];
            [adc_data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                SFCAMInfo *camInfo =[self camInfoByIPAddress:key];
                NSString *cpuVoltage =[obj objectForKey:cpuVoltageSignal];
                NSString *ssdVoltage =[obj objectForKey:ssdVoltageSignal];
                [camInfo setSsdVoltage:ssdVoltage];
                [camInfo setCpuVoltage:cpuVoltage];
                
            }];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_camInfoTableView setNeedsDisplay:YES];
            });
            [NSThread sleepForTimeInterval:1];
        }
    });
}

-(void)awakeFromNib{

    [_camInfoTableView setDataSource:self];
    [_camInfoTableView setDelegate:self];
    [self auto_start];
     
}

/*
-(void)navigationItemDidChangedNotification:(NSNotification *)notification{
    NSDictionary *userInfo=[notification userInfo];
    if([[userInfo objectForKey:@"SELECTED_NIB_NAME"] isEqualToString:self.nibName])
    {
        return;
    }
    
}
*/

-(void)logDidChangedNotification:(NSNotification *)notification
{
    NSDictionary *dict =[notification userInfo];
    NSDateFormatter *formatter =[NSDateFormatter new];
    formatter.dateFormat = @"[yyyy-MM-dd HH:mm:ss] ";
    
    NSString *msg =[NSString stringWithFormat:@"%@  %@\n",[formatter stringFromDate:[NSDate new]],[dict objectForKey:@"LogMessage"]];
    
    [[SFRecordWriter sharedLogWriter] insertLog:[dict objectForKey:@"LogMessage"] Type:SFLogTypeWarning];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString* attr = [[NSAttributedString alloc] initWithString:msg];
        [[_logTextView textStorage] appendAttributedString:attr];
        [_logTextView scrollRangeToVisible:NSMakeRange([[_logTextView string] length], 0)];
        [_camInfoTableView setNeedsDisplay:YES];

    });
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.

        cam_info_list =[NSMutableArray arrayWithCapacity:10];
        _start_read_adc_flag   = YES;

        
        [[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.Slots"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SFCAMInfo *camInfo =[SFCAMInfo new];
            [camInfo setIpAddress:[obj objectForKey:@"IP_Address"]];
            [camInfo setSlotName:[obj objectForKey:@"SlotID"]];
            [camInfo setMacAddress:[[obj objectForKey:@"MAC"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
            [camInfo setEnable:[[obj objectForKey:@"Enable"] boolValue]];

            //load slot status.
            [camInfo setStatus:[[NSUserDefaults standardUserDefaults] stringForKey:camInfo.slotName]];
            
            [cam_info_list addObject:camInfo];
        }];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logDidChangedNotification:) name:SFCAM_LOG_UPDATED_NOTIFICATION  object:nil];


        
    }
    return self;
}

-(void)auto_update_voltage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

        [NSThread sleepForTimeInterval:0.2];
        
        dispatch_async(dispatch_get_main_queue(), ^{
        });
        
        while (1) {
            [SFCommonFounction executeCmd:@"/usr/bin/python" withArguments:@[]];
            
            [NSThread sleepForTimeInterval:0.5];
        }
        
    });

}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [cam_info_list count];
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{
   
    NSString *identify = [tableColumn identifier];
    if (!identify ) {
        return nil ;
    }
    SFCAMInfo *cInfo = [cam_info_list objectAtIndex:row];

     id value = [cInfo valueForKey:tableColumn.identifier];

    if ([identify isEqualToString:@"statusOfCamInit"] || [identify isEqualToString:@"statusOfUUTPowerOn"] || [identify isEqualToString:@"statusOfUUTPowerDown"]) {
        if (![value isEqualToNumber:@1]) {
            return @0;
        }
        
    }else if ([identify isEqualToString:@"is_network_connected"]){

        BOOL isConnected =[value boolValue];
        
        if (isConnected) {
            return [NSImage imageNamed:@"connected.png"];
        }
        return [NSImage imageNamed:@"disconnected.png"];
    }
    
    return value;
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    
    NSString *identify = [tableColumn identifier];
    if (!identify ) {
        return  ;
    }
    SFCAMInfo *cInfo = [cam_info_list objectAtIndex:row];
    [cInfo setValue:object forKey:identify];

}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    //NSLog(@"%@",notification);
}

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identify = [tableColumn identifier];
    if (!identify ) {
        return  ;
    }
    SFCAMInfo *cInfo = [cam_info_list objectAtIndex:row];
    
    if ([identify isEqualToString:@"statusOfCamInit"]) {
       
        NSButtonCell *btnCell =cell;
        [btnCell setEnabled:cInfo.enable];
        if ([[cInfo statusOfCamInit] isEqualToNumber:@-1]) {
            [btnCell setTitle:@"IDLE"];
        }else {
            [btnCell setTitle:@"Done"];
        }
       
    }   else if ([identify isEqualToString:@"statusOfUUTPowerOn"]) {
        NSButtonCell *btnCell =cell;
        [btnCell setEnabled:cInfo.enable];

        if ([[cInfo statusOfUUTPowerOn] isEqualToNumber:@-1]) {
            [btnCell setTitle:@"IDLE"];
        }else {
            [btnCell setTitle:@"Done"];

        }
        
    }else  if ([identify isEqualToString:@"statusOfUUTPowerDown"]) {
        NSButtonCell *btnCell =cell;
        [btnCell setEnabled:cInfo.enable];

        if ([[cInfo statusOfUUTPowerDown] isEqualToNumber:@-1]) {
            [btnCell setTitle:@"IDLE"];
        }else {
            [btnCell setTitle:@"Done"];
        }
    }
    
}
@end
