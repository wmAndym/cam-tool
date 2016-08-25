//
//  SFCAMViewController.m
//  CAMTOOL
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFCAMViewController.h"
#import "SFCommonFounction.h"



@interface SFCAMViewController ()
{
    NSArray *temp_selections;
    NSArray *temp_textFields;
}
@end


@implementation SFCAMViewController

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    
    if ([tableView.identifier isEqualToString:@"header_info_table"]) {
        return [_selectedBoard.camHeaderInfo count];
    }
    
    return [_selectedBoard.camPortInfo count];
    
}


-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row;
{

    
    NSString *identify = [tableColumn identifier];
    
    if ([tableView.identifier isEqualToString:@"header_info_table"]) {
        return [[_selectedBoard.camHeaderInfo  objectAtIndex:row] valueForKey:identify];
    }
    
    //the following is datasource for cam port table view.
    
    
    
    
    if (row >= [_selectedBoard.camPortInfo  count] || identify==nil) {
        return nil;
    }
    
    id item =[[_selectedBoard.camPortInfo  objectAtIndex:row] valueForKey:identify];
    
    if ([identify isEqualToString:@"portValue"]) {
        return [NSImage imageNamed:[[_selectedBoard.camPortInfo objectAtIndex:row] valueImageName]];
    }
    
    else if ([identify isEqualToString:@"signalName"]) {
        __block NSString *signalName = item;
        [[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isEqualToString:item]) {
                *stop = YES;
                signalName = key;
            }
        }];
        return signalName;
    }
    
    return item;
}

-(BOOL)setCAMPort:(NSString *)portName statusValue:(BOOL)status
{
    return YES;
}


-(void)loadCAMSequnce;
{
    NSArray *seq =[[NSUserDefaults standardUserDefaults] objectForKey:@"CAMSequnces"];
    if (!seq) {
        seq = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"CAMSequnce" ofType:@"plist"]];
        [[NSUserDefaults standardUserDefaults] setObject:seq forKey:@"CAMSequnces"];
        

    }
    _CAMSequnces =[NSMutableArray arrayWithCapacity:10];

    [seq enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:obj ];
        [_CAMSequnces addObject:dict];
    }];
    
}
-(void)destroyController{
    [super destroyController];
    [self setIsStartProbe:NO] ;
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{


    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isStartProbe = NO;
        _shouldDestroyWhenUserChangedNavigationItem = YES;
        
    [self setCAMBoardsIpAddress:  [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.Slots.IP_Address"]]];
        [self loadCAMSequnce];
    }
    
    return self;
}

-(void)dealloc{
    
    NSLog(@"%@-->dealloced",self.nibName);
    
}


- (void)controlTextDidChange:(NSNotification *)notification {
    
    [_setIpBtn setEnabled:YES];
}
-(void)setPort:(NSString *)port toValue:(NSInteger)value
{
    NSString *url_string =[NSString stringWithFormat:@"http://%@/main.htm?%@=%lu",_selectedBoard.ipAddress,port,value];
    [SFCommonFounction executeCmd:@"/usr/bin/curl" withArguments:@[url_string,@"--silent",@"--compressed",@"--max-time",@"2"]];
    NSLog(@"Set port:%@ to %lu",port,value);
}
-(void)updatePortStatusByCommand:(NSString *)command
{
    NSString *url_string =[NSString stringWithFormat:@"http://%@/main.htm?%@",_selectedBoard.ipAddress,command];
    [SFCommonFounction executeCmd:@"/usr/bin/curl" withArguments:@[url_string,@"--silent",@"--compressed",@"--max-time",@"2"]];
    NSLog(@"set multi-port status:%@",command);

}
- (IBAction)updateSignalValue:(id)sender {
    
    NSString *portName = [_signals stringValue];
    NSInteger value =  [[_popBtnValueUserDefinition selectedItem] tag];
    [self setPort:portName toValue:value];
    
}

- (IBAction)updateLEDStates:(id)sender {
    
   
    NSString *title =[sender title];
    NSString *port = nil;
    if ([title isEqualToString:@"BATTERY"]) {
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.BATTERY"];
        
    }else if ([title isEqualToString:@"ADAPTER"]){
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.ADAPTER"];
    }
    else if ([title isEqualToString:@"IN PROCESS"]){
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.LELD_IN_PROCESS"];
    }
    else if ([title isEqualToString:@"PASS"]){
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.LED_PASS"];
    }
    else if ([title isEqualToString:@"FAIL"]){
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.LED_FAIL"];
    }
    if (port) {
        [self setPort:port toValue:[sender state]];
    }
}

- (IBAction)pingCheck:(id)sender {
    

    if ( [SFCommonFounction checkNetworkConnection:_IpAddressField.stringValue] == NO) {
         NSRunAlertPanel(@"NETWROK CHECK RESULT" ,@"Connection to host failed!", nil, nil, nil);
    }else{
        NSRunAlertPanel(@"NETWROK CHECK RESULT" ,@"Connection to host succeeded!", nil, nil, nil);
    }
}

- (IBAction)setIpAddress:(id)sender {
    
    [_selectedBoard setIpAddress:_IpAddressField.stringValue];
    [_setIpBtn setEnabled:NO];
    NSInteger idx = [_slotSelector selectedTag];
    _CAMBoardsIpAddress[idx] = _IpAddressField.stringValue;
    
    //update slots's user-default settings.
    NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *settings =[NSMutableDictionary dictionaryWithDictionary:[userDefaults valueForKeyPath:@"CAMSettings"]];
    NSMutableArray *slots_settings=[NSMutableArray arrayWithArray: [userDefaults valueForKeyPath:@"CAMSettings.Slots"]];
    //[systemSettings setObject:[NSNumber numberWithInteger:_retestPolicyIndex] forKey:@"RetestPolicy"];
    //[settings setObject:systemSettings forKey:@"SystemSettings"];
    NSMutableDictionary *slot =[NSMutableDictionary dictionaryWithDictionary:slots_settings[idx]];
    [slot setObject:_IpAddressField.stringValue forKey:@"IP_Address"];
    slots_settings[idx]=slot;
    [settings setObject:slots_settings forKey:@"Slots"];
    [userDefaults setValue:settings forKey:@"CAMSettings"];
    [userDefaults synchronize];
    
}


-(IBAction)changeSlot:(id)sender;
{
  //  [_progress stopAnimation:self];
    [self setIsStartProbe:NO]; //disable another slot to start probe.
    [_startBtn setTitle:@"Start"];
    NSInteger idx = [sender tag];
    [_selectedBoard setIpAddress:[_CAMBoardsIpAddress objectAtIndex:idx]];
    [_selectedBoard setTempPath:[NSString stringWithFormat:@"/tmp/cam_info_%@.plist",[sender title]]];
    [_IpAddressField setStringValue:[_selectedBoard ipAddress]];
    [_setIpBtn setEnabled:YES];
    
}

- (IBAction)setDrawerAction:(id)sender {
    NSString *title =[sender title];
    NSString *port = nil;
    if ([title isEqualToString:@"UP"]) {
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.DRAWER_UP"];
        
    }else if ([title isEqualToString:@"DN"]){
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.DRAWER_DOWN"];
    }
    else if ([title isEqualToString:@"IN"]){
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.DRAWER_IN"];
    }
    else if ([title isEqualToString:@"OUT"]){
        port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.SignalMaps.DRAWER_OUT"];
    }
    if (port) {
        [self setPort:port toValue:[sender state]];
    }
}

-(void)awakeFromNib{
    temp_selections=@[@"CPU_Temp_Selection",@"TOP_Temp_Selection",@"BOTTOM_Temp_Selection",@"SSD_Temp_Selection"];
    temp_textFields=@[_cpuTemp,_topTemp,_botTemp,_ssdTemp];
    
    [_portInfoTableView setDataSource:self];
    [_headerTableView setDataSource:self];
    //default slot1 is selected.

    [_selectedBoard setIpAddress:[self.CAMBoardsIpAddress objectAtIndex:0]];
    [_selectedBoard setTempPath:[NSString stringWithFormat:@"/tmp/cam_info_%@.plist",[_slotSelector title]]];

    [_IpAddressField setStringValue:[_selectedBoard ipAddress]];

    [self setSelectedBoard:_selectedBoard];
}



- (IBAction)startProbe:(id)sender {
    
    
    NSDictionary *all_temp_sequnces_set=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.TemperatureSelection"];
    
    if ([[sender title]isEqualToString:@"Start"]) {
     //   [_progress startAnimation:self];
        [sender setTitle:@"Stop"];
        [self setIsStartProbe: YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //just update signal names at the first time.
            [_selectedBoard startProb];
            [NSThread sleepForTimeInterval:0.2];
            NSArray *signalnames= [[_selectedBoard camPortInfo] valueForKeyPath:@"portName"];
           
            dispatch_async(dispatch_get_main_queue(), ^{
                [_portInfoTableView reloadData];
                [_headerTableView reloadData];
                if ([signalnames count] > 0) {
                    [_signals removeAllItems];
                    [_signals addItemsWithObjectValues:signalnames];
                    [_signals selectItemAtIndex:0];
                }
            });
            
            NSUInteger i=0;
            while (_isStartProbe) {
                
                if ( [SFCommonFounction checkNetworkConnection:_selectedBoard.ipAddress] == NO) {
                    continue;
                }
                
                //update port info every 2 second.
                
                //[NSThread sleepForTimeInterval:0.3];
                //NSLog(@"probing..");
                
                //setup temperature selection
                
                NSUInteger idx=i%4;
                NSString *temp_selection = temp_selections[idx];
                NSDictionary *seq=[all_temp_sequnces_set objectForKey:temp_selection];
                NSMutableArray *portCommands=[NSMutableArray array];
                [seq enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    //[self setPort:key toValue:[obj integerValue]];
                    [portCommands addObject:[NSString stringWithFormat:@"%@=%@",key,obj]];
                }];
                
                [self updatePortStatusByCommand:[portCommands componentsJoinedByString:@"&"]];
                NSTextField *selectedTempTextField=temp_textFields[idx];
                //delay after selection
                [NSThread sleepForTimeInterval:1];

                [_selectedBoard startProb];
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_portInfoTableView reloadData];
                    [_headerTableView reloadData];
                    [selectedTempTextField setStringValue:_selectedBoard.temperature];
                });
                
                switch (_selectedBoard.drawerMode) {
                    case 0:
                        [_drawerModeTextField setStringValue:@"Auto Mode"];
                        break;
                    case 1:
                        [_drawerModeTextField setStringValue:@"Semi Auto"];
                        break;
                    case 2:
                        [_drawerModeTextField setStringValue:@"Debug Mode"];
                        break;
                    default:
                        break;
                }
                i++;
            }
            
            NSLog(@"stop probe");

        });
        
    }else if([[sender title] isEqualToString:@"Stop"]){
        [sender setTitle:@"Start"];
      //  [_selectedBoard stopProb];
        [self setIsStartProbe:NO];
 //       [_progress stopAnimation:self];

    }
    
}

- (IBAction)setDefaultSequnce:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setObject:_CAMSequnces forKey:@"CAMSequnces"];
    NSRunAlertPanel(@"SetDefalutSequnces", @"Set Default OK", @"OK", nil, nil);
}

- (IBAction)runSequnce:(id)sender {
    
   
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setEnabled:NO];
        });
        
       [_CAMSequnces enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
           NSString *portName =[obj objectForKey:@"Port_Name"];
           NSNumber *value =[obj objectForKey:@"Port_Type"];
           NSNumber *wait_time =[obj objectForKey:@"Wait_Before_Run"];
           [NSThread sleepForTimeInterval:[wait_time floatValue]];
           [self setPort:portName toValue:[value integerValue]];
           dispatch_async(dispatch_get_main_queue(), ^{
               [_seqTableView scrollRowToVisible:idx];
               [_seqTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
           });
       }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [sender setEnabled:YES];
            });
        });
   });
}

- (IBAction)importSequnce:(id)sender {
    
    NSOpenPanel *panel=[NSOpenPanel openPanel];
    [panel setAllowedFileTypes:@[@"csv",@"seq"]];
    __block NSMutableArray *new_seq=[NSMutableArray arrayWithCapacity:10];
    [panel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        if (result ==NSOKButton) {
            NSString *path_csv =[[panel URL] path];
            NSString *path_plist =[NSTemporaryDirectory() stringByAppendingPathComponent:@"seq_import.plist"];
            NSString *script=[[NSBundle mainBundle] pathForResource:@"seq_by_csv_plist" ofType:@"py" inDirectory:@"tools"];
            [SFCommonFounction executeCmd:@"/usr/bin/python" withArguments:@[script,@"-s",path_csv,@"-t",path_plist,@"-p",@"csv2plist"]];
            NSArray *seq=[NSArray arrayWithContentsOfFile:path_plist];
            [seq enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSMutableDictionary *dict =[NSMutableDictionary dictionaryWithDictionary:obj ];
                [new_seq addObject:dict];
            }];
            [self setCAMSequnces:new_seq];
        }
    }];
    



    
}

- (IBAction)exportSequnce:(id)sender {
    
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    //[savePanel setAllowedFileTypes:@[@"csv",@"seq"]];

    NSDateFormatter *df=[NSDateFormatter new];
    [df setDateFormat:@"MMddHHmmss"];
    
    [savePanel setNameFieldStringValue:[NSString stringWithFormat:@"sequnce_%@.csv",[df stringFromDate:[NSDate date]]]];
    [savePanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        if (result ==NSOKButton) {
            NSString *path_csv =[[savePanel URL] path];
            NSString *path_plist =[NSTemporaryDirectory() stringByAppendingPathComponent:@"seq_export.plist"];
            [_CAMSequnces writeToFile:path_plist atomically:YES];
            NSString *script=[[NSBundle mainBundle] pathForResource:@"seq_by_csv_plist" ofType:@"py" inDirectory:@"tools"];
            [SFCommonFounction executeCmd:@"/usr/bin/python" withArguments:@[script,@"-s",path_plist,@"-t",path_csv,@"-p",@"plist2csv"]];

        }
        
    }];
}

- (IBAction)runSelectedItem:(id)sender {
    [[_sequnceArrayController selectedObjects] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *portName =[obj objectForKey:@"Port_Name"];
        NSNumber *value =[obj objectForKey:@"Port_Type"];
        NSNumber *wait_time =[obj objectForKey:@"Wait_Before_Run"];
        [NSThread sleepForTimeInterval:[wait_time floatValue]];
        [self setPort:portName toValue:[value integerValue]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_seqTableView scrollRowToVisible:idx];
            [_seqTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:idx] byExtendingSelection:NO];
        });
    }];
}

@end
