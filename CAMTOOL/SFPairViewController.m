//
//  SFPairViewController.m
//  CAMTOOL
//
//  Created by jifu on 12/30/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFPairViewController.h"
#import "QREncoder.h"
#import "SFCommonFounction.h"
#import "SFWhiteMaskView.h"
#import "SFRecordWriter.h"
#import "SFSlotCommunication.h"

@interface SFPairViewController ()
{
    SFWhiteMaskView *_clearViewMask;
    SFWhiteMaskView *_pairViewMask;
    SFWhiteMaskView *_unpairViewMask;
}

@end

@implementation SFPairViewController

- (IBAction)clearAction:(id)sender {
    [SFSlotCommunication clearpairSlot:_slotNumberField.stringValue carrierID:_carrierIDField.stringValue CAMAddress:_camAddressField.stringValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_prompt setStringValue:[NSString stringWithFormat:@"Ready to accept barcodes..."]];
        [_slotNumberField setStringValue:@""];
        [_carrierIDField setStringValue:@""];
        [_camAddressField setStringValue:@""];
        [self setHiddenUnpairImageView:YES];
        [self setHiddenPairImageView:YES];
        [self setHiddenClearImageView:NO];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[self.view window] makeFirstResponder:_inputArea];
    });
}
- (IBAction)unpairAction:(id)sender {
     NSString *retStr = [SFSlotCommunication unpairSlot:_slotNumberField.stringValue carrierID:_carrierIDField.stringValue CAMAddress:_camAddressField.stringValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([retStr isEqualToString:@"OK"]) {
            [_prompt setStringValue:[NSString stringWithFormat:@"Slot %@ ,freed! Ready to accept barcodes...",_slotNumberField.stringValue]];
            [_prompt setTextColor:[NSColor blackColor]];

        }else{
            [_prompt setStringValue:retStr];
            [_prompt setTextColor:[NSColor redColor]];

        }
        [_slotNumberField setStringValue:@""];
        [_carrierIDField setStringValue:@""];
        [_camAddressField setStringValue:@""];
        [self setHiddenUnpairImageView:YES];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[self.view window] makeFirstResponder:_inputArea];
    });
}
- (IBAction)pairAction:(id)sender {
    NSString *retStr = [SFSlotCommunication pairSlot:_slotNumberField.stringValue carrierID:_carrierIDField.stringValue CAMAddress:_camAddressField.stringValue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([retStr isEqualToString:@"OK"]) {
            [_prompt setStringValue:[@"Slot,carrier,and serial port name paired!Ready to accept barcodes...\n" stringByAppendingString:retStr]];
            [_prompt setTextColor:[NSColor blackColor]];
        }else{
            [_prompt setStringValue:retStr];
            [_prompt setTextColor:[NSColor redColor]];
        }
        [_slotNumberField setStringValue:@""];
        [_carrierIDField setStringValue:@""];
        [_camAddressField setStringValue:@""];
        [self setHiddenPairImageView:YES];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[self.view window] makeFirstResponder:_inputArea];
    });
    
}

-(void)setHiddenClearImageView:(BOOL)hiddenClearImageView{
    _hiddenClearImageView = hiddenClearImageView;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_hiddenClearImageView) {
            [_clearImageView addSubview:_clearViewMask];
            [_clearImageView setEnabled:NO];

        }else{
            [_clearViewMask removeFromSuperview];
            [_clearImageView setEnabled:YES];


        }
        [_clearImageView setNeedsDisplay:YES];
    });


    
}

-(void)setHiddenPairImageView:(BOOL)hiddenPairImageView{
    _hiddenPairImageView = hiddenPairImageView ;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_hiddenPairImageView) {
            [_pairImageView addSubview:_pairViewMask];
            [_pairImageView setEnabled:NO];
            
        }else{
            [_pairViewMask removeFromSuperview];
            [_pairImageView setEnabled:YES];

            
        }
        [_pairImageView setNeedsDisplay:YES];
    });
    
}
-(void)setHiddenUnpairImageView:(BOOL)hiddenUnpairImageView{
    _hiddenUnpairImageView = hiddenUnpairImageView;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_hiddenUnpairImageView) {
            [_unpairImageView addSubview:_unpairViewMask];
            [_unpairImageView setEnabled:NO];
            
        }else{
            [_unpairViewMask removeFromSuperview];
            [_unpairImageView setEnabled:YES];

            
        }
        [_unpairImageView setNeedsDisplay:YES];
    });
    
}


-(void)dealloc{

#ifdef DEBUG
    NSLog(@"%@-->dealloced",self.nibName);
#endif
    
}

-(void)destroyController
{
     [super destroyController];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_updateTextInputTimer invalidate];
    
}






-(void)textDidEndEditingNotification:(NSNotification *)notification
{
    NSString *str = [_inputArea stringValue];
  //  NSLog(@"Input:%@",str);
    if ([str length] < 1) {
        return;
    }
 
    
    [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"Scan text:%@",str] Type:SFLogTypeNormal];
    
    
    //trim whitespace and  newlineCharacter
    str = [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    

    //NSPredicate
    NSString *prefixCarrier=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"PrefixOfCarrierID"];
    NSString *prefixCAM=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"PrefixOfCAMID"];

    NSPredicate *macAddress_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}:\\w{2}$"];
    NSPredicate *carrier_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",prefixCarrier];
    NSPredicate *cam_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",prefixCAM];
    NSPredicate *slot_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^\\d{1,2}$"];

    if ([macAddress_predicate evaluateWithObject:str]) {
        
        if ([cam_predicate evaluateWithObject:str]){
            [_camAddressField setStringValue:str];
            
        }
        else if ([carrier_predicate evaluateWithObject:str]) {
            [_carrierIDField setStringValue:str];

            NSMutableDictionary *info=[NSMutableDictionary dictionaryWithCapacity:5];
            if ([SFSlotCommunication checkIsCarrierPaired:str information:info]) {
                id slotID=[info valueForKeyPath:@"slot.sioSlot"];
                if ([slotID isKindOfClass:[NSNumber class]]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_slotNumberField setStringValue:[slotID description]];
                        [_prompt setStringValue:[NSString stringWithFormat:@"Previously Paired Slot:%@\nPreviously Paired Carrier:%@\n Unpair?",slotID,str]];
                        [_prompt setTextColor:[NSColor blackColor]];
                        [self setHiddenUnpairImageView:NO];
                        [self setHiddenPairImageView:YES];

                    });
                    
                }
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_prompt setStringValue:@"Ready to accept barcodes..."];
                    [_prompt setTextColor:[NSColor blackColor]];
                    
                });

            }
            
        }else{
            [_prompt setStringValue:[NSString stringWithFormat: @"MAC Address can not be identified!:%@",str ]];
            [_prompt setTextColor:[NSColor redColor]];
        }

    }else if ([slot_predicate evaluateWithObject:str]){
        NSUInteger locationID = [str integerValue];
        if (locationID <= 12 && locationID >0) {
            [_slotNumberField setStringValue:str];

            NSMutableDictionary *infomation=[NSMutableDictionary dictionaryWithCapacity:5];
            //check if this slot is paired ?
            if ([SFSlotCommunication checkIsSlotPaired:str information:infomation]) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_carrierIDField setStringValue:[infomation objectForKey:@"id"]];
                    [_camAddressField setStringValue:@""];

                    [_prompt setStringValue:[NSString stringWithFormat:@"Previously Paired Slot:%@\nPreviously Paired Carrier:%@\n Unpair?",str,[infomation objectForKey:@"id"]]];
                    [_prompt setTextColor:[NSColor blackColor]];
                    [self setHiddenUnpairImageView:NO];
                });
 
            }else{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_carrierIDField setStringValue:@""];
                    [_camAddressField setStringValue:@""];
                    
                    [_prompt setStringValue:@"Ready to accept barcodes..."];
                    [_prompt setTextColor:[NSColor blackColor]];
                    [self setHiddenPairImageView:YES];
                    [self setHiddenUnpairImageView:YES];

                });
                
            }
        }else{

            dispatch_async(dispatch_get_main_queue(), ^{
                [_prompt setStringValue:[NSString stringWithFormat: @"Slot number out of range! ==> %@",str]];
                [_prompt setTextColor:[NSColor redColor]];
            });

        }

        
        
    }else if ([str isEqualToString:@"<PAIR"]){
        [self pairAction:_pairImageView];
    }else if ([str isEqualToString:@"<UNPAIR"]){
        [self unpairAction:_unpairImageView];
        
    }else if ([str isEqualToString:@"<CLEAR"]){
        [self clearAction:_clearImageView];

    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_prompt setStringValue:[NSString stringWithFormat:@"Barcode can't not be identified:%@",str]];
            [_prompt setTextColor:[NSColor redColor]];
        });
    }
    
    if (_hiddenUnpairImageView == YES && [[_slotNumberField stringValue] length] > 0  &&[[_carrierIDField stringValue] length] > 0 && [[_camAddressField stringValue] length] > 0) { //make sure this slot is unpaired before pairing.
        [self setHiddenPairImageView:NO];
    }

    [_inputArea setStringValue:@""];

    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[self.view window] makeFirstResponder:_inputArea];
    });
}





- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [SFSlotCommunication obtainWabisabiInfomation];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditingNotification:) name:NSControlTextDidEndEditingNotification object:_inputArea];

                      [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

-(void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSLog(@"ApplicationBeActived!");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self view] window] makeFirstResponder:_inputArea];
        
    });
}

-(void)awakeFromNib
{
    
    [_clearImageView setTarget:self];
    [_pairImageView setTarget:self];
    [_unpairImageView setTarget:self];
    _clearViewMask = [[SFWhiteMaskView alloc] initWithFrame:_clearViewMask.bounds];
    _unpairViewMask = [[SFWhiteMaskView alloc] initWithFrame:_unpairImageView.bounds];
    _pairViewMask = [[SFWhiteMaskView alloc] initWithFrame:_pairImageView.bounds];

    
    NSImage *pairImage= [QREncoder encode:@"<PAIR" size:1 correctionLevel:QRCorrectionLevelHigh];
    NSImage *unpairImage= [QREncoder encode:@"<UNPAIR" size:1 correctionLevel:QRCorrectionLevelHigh];
    NSImage *clearImage= [QREncoder encode:@"<CLEAR" size:1 correctionLevel:QRCorrectionLevelHigh];
    _inputArea=[[NSTextField alloc] initWithFrame:self.view.frame];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self setHiddenClearImageView:NO];
        [self setHiddenPairImageView:YES];
        [self setHiddenUnpairImageView:YES];
        
        [_pairImageView setImage:pairImage];
        [_unpairImageView setImage:unpairImage];
        [_clearImageView setImage:clearImage];
        [_inputArea setHidden:YES];
        [_prompt setStringValue:@"Ready to accept barcodes..."];
        [_prompt setTextColor:[NSColor blackColor]];
        [[self view ] addSubview:_inputArea];
        [[self.view window] makeFirstResponder:_inputArea];
        
    });
    _updateTextInputTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateUI) userInfo:nil repeats:YES];
    

}
-(void)updateUI{
    NSLog(@"update..");
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[self.view window] makeFirstResponder:_inputArea];
    });
    
}
@end
