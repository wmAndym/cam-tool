//
//  SFFixtueSettingViewController.m
//  CAMTOOL
//
//  Created by jifu on 11/20/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFFixtueSettingViewController.h"
#import "SFCommonFounction.h"
#import "SFRecordWriter.h"
#import "SFSlotCommunication.h"

@interface SFFixtueSettingViewController ()
@property (weak) IBOutlet NSButton *saveBtn;

@end

@implementation SFFixtueSettingViewController

-(void)awakeFromNib{
    [_slotSettingTableView setDataSource:self];
    [_saveBtn setEnabled:NO];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [SFSlotCommunication obtainWabisabiInfomation];

        
        _slotSettings =[NSMutableArray arrayWithCapacity:10];
        [[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.Slots"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *slot = obj;
            [_slotSettings addObject:[NSMutableDictionary dictionaryWithDictionary:slot]];
            
        }];
    }
    return self;
}

-(NSMutableDictionary *)slotInfoByMAC:(NSString *)mac
{
    __block NSMutableDictionary *info=nil;
    [_slotSettings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        info = obj;
        if ([[mac uppercaseString] isEqualToString:[[info objectForKey:@"MAC"] uppercaseString]]) {
            *stop =YES;
        }
    }];
    return info;
}
- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
              row:(NSInteger)rowIndex{
    [_saveBtn setEnabled:YES];
    
}
- (void)didEndSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo{
    [sheet orderOut:self];
    
}
- (IBAction)setDefaultSettings:(id)sender {

    //update slots's user-default settings.
    NSUserDefaults  *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *settings =[NSMutableDictionary dictionaryWithDictionary:[userDefaults valueForKeyPath:@"CAMSettings"]];
    [settings setObject:_slotSettings forKey:@"Slots"];
    [userDefaults setValue:settings forKey:@"CAMSettings"];
    [userDefaults synchronize];
    [_saveBtn setEnabled:NO];
    [[SFRecordWriter sharedLogWriter] insertLog:@"Slot's settings have been changed!" Type:SFLogTypeNormal];
   // NSRunAlertPanel(@"Set Default Setting ", @"OK!", @"OK", nil, nil);
    
}



- (IBAction)updateIPAddress:(id)sender {
    [NSApp beginSheet: _probePanel
       modalForWindow: [NSApp mainWindow]
        modalDelegate: self
       didEndSelector: @selector(didEndSheet:returnCode:contextInfo:)
          contextInfo: nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *script =[[NSBundle mainBundle] pathForResource:@"mac2ip" ofType:@"py" inDirectory:@"tools"];
        NSString *mac2ip_file=@"/tmp/mac2ip.plist";
        [SFCommonFounction executeCmd:@"/usr/bin/python" withArguments:@[script,mac2ip_file]];
        NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:mac2ip_file];
        [self  willChangeValueForKey:@"slotSettings"];
        [_slotSettings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *slot = obj;
            NSString *slot_mac =[[slot objectForKey:@"MAC"] lowercaseString];
            NSString *ip_mac_map_found=[dict objectForKey:slot_mac];
            if (ip_mac_map_found != nil) {
                [slot setObject:ip_mac_map_found forKey:@"IP_Address"];
            }
        }];
        [self  didChangeValueForKey:@"slotSettings"];

        dispatch_async(dispatch_get_main_queue(), ^{
            
            [NSApp endSheet:_probePanel];
            [_slotSettingTableView setNeedsDisplay:YES];
            [_saveBtn setEnabled:YES];

        });
    });

    
}

- (IBAction)pairAll:(id)sender {

    NSAlert *alert = [NSAlert alertWithMessageText:@"Pair slot according to current settings"
                                     defaultButton:@"OK" alternateButton:@"Cancel"
                                       otherButton:nil informativeTextWithFormat:
                      @"please make sure all slot is unpaired,and then start to pair all"];
    
    if ([alert runModal] != NSOKButton) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setEnabled:NO];

        });
        NSPredicate *macAddress_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}$"];
        __block NSString *promptStr = @"all slots paired";
        [_slotSettings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *slot = obj;
            
            NSString *cam_mac_address =[[slot objectForKey:@"MAC"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *carrier_mac_address =[[slot objectForKey:@"MAC_Slot"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *slot_id=[NSString stringWithFormat:@"%ld",idx+1];
            
            if ([macAddress_predicate evaluateWithObject:cam_mac_address] && [macAddress_predicate evaluateWithObject:carrier_mac_address] ) {
                NSString *retStr =[SFSlotCommunication pairSlot:slot_id carrierID:carrier_mac_address CAMAddress:cam_mac_address];
                if ([retStr isNotEqualTo:@"OK"]) {
                    promptStr = retStr;
                    *stop = YES;
                }
            }
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setEnabled:YES];
            NSAlert *alert =[NSAlert alertWithMessageText:@"pair all slot" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",promptStr];
            [alert runModal];
        });
    });
    
}

- (IBAction)unpairAll:(id)sender {
    
    NSAlert *alert = [NSAlert alertWithMessageText:@"unpair slots settings"
                                     defaultButton:@"Yes" alternateButton:@"No"
                                       otherButton:nil informativeTextWithFormat:
                      @"Do you want to unpair all slots?"];
    
    if ([alert runModal] != NSOKButton) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setEnabled:NO];
            
        });
        NSPredicate *macAddress_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}$"];
        __block NSString *promptStr=@"all slots unpaired";
        [_slotSettings enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSMutableDictionary *slot = obj;
            
            NSString *cam_mac_address =[[slot objectForKey:@"MAC"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *carrier_mac_address =[[slot objectForKey:@"MAC_Slot"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *slot_id=[NSString stringWithFormat:@"%ld",idx+1];
            
            if ([macAddress_predicate evaluateWithObject:cam_mac_address] && [macAddress_predicate evaluateWithObject:carrier_mac_address] ) {
                NSString *retStr =[SFSlotCommunication unpairSlot:slot_id carrierID:carrier_mac_address CAMAddress:cam_mac_address];
                if ([retStr isNotEqualTo:@"OK"]) {
                    promptStr = retStr;
                    *stop = YES;
                }
            }
            
        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender setEnabled:YES];
            NSAlert *alert =[NSAlert alertWithMessageText:@"unpair all slot" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",promptStr];
            [alert runModal];

        });
    });
}

- (IBAction)unpairSlot:(id)sender {
    NSInteger row_idx =[_slotSettingTableView selectedRow];
    
    if (row_idx < [_slotSettings count]) {
        NSDictionary *slotSettings =_slotSettings[row_idx];
        NSPredicate *macAddress_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}$"];
        NSString *cam_mac_address =[[slotSettings objectForKey:@"MAC"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *carrier_mac_address =[[slotSettings objectForKey:@"MAC_Slot"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *slot_id=[NSString stringWithFormat:@"%ld",row_idx+1];
        if ([macAddress_predicate evaluateWithObject:cam_mac_address] && [macAddress_predicate evaluateWithObject:carrier_mac_address] ) {
            NSString *retStr = [SFSlotCommunication unpairSlot:slot_id carrierID:carrier_mac_address CAMAddress:cam_mac_address];
            NSAlert *alert =[NSAlert alertWithMessageText:@"unpair slot" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",retStr];
            [alert runModal];
        }
    }
    
}

- (IBAction)pairSlot:(id)sender {
        NSInteger row_idx =[_slotSettingTableView selectedRow];
    
        if (row_idx < [_slotSettings count]) {
            NSDictionary *slotSettings =_slotSettings[row_idx];
            NSPredicate *macAddress_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}$"];
            NSString *cam_mac_address =[[slotSettings objectForKey:@"MAC"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *carrier_mac_address =[[slotSettings objectForKey:@"MAC_Slot"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *slot_id=[NSString stringWithFormat:@"%ld",row_idx+1];
            if ([macAddress_predicate evaluateWithObject:cam_mac_address] && [macAddress_predicate evaluateWithObject:carrier_mac_address] ) {
                
                NSString *retStr = [SFSlotCommunication pairSlot:slot_id carrierID:carrier_mac_address CAMAddress:cam_mac_address];;
                NSAlert *alert =[NSAlert alertWithMessageText:@"pair slot" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@",retStr];
                [alert runModal];


            }
        }
}

-(BOOL)validateMenuItem:(NSMenuItem *)menuItem{
    if ([menuItem action] == @selector(pairSlot:) || [menuItem action] == @selector(unpairSlot:)) {
        NSInteger row_idx =[_slotSettingTableView selectedRow];
        if (row_idx < [_slotSettings count]) {
            NSDictionary *slotSettings =_slotSettings[row_idx];
            NSPredicate *macAddress_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}$"];
            NSString *cam_mac_address =[[slotSettings objectForKey:@"MAC"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *carrier_mac_address =[[slotSettings objectForKey:@"MAC_Slot"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if ([macAddress_predicate evaluateWithObject:cam_mac_address] && [macAddress_predicate evaluateWithObject:carrier_mac_address] ) {
                return YES;
            }else{
                return NO;
            }
        }else{
            return NO;
        }
    }
    return YES;
}
@end
