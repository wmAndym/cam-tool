//
//  SFTestSeqViewController.m
//  CAMTOOL
//
//  Created by jifu on 12/8/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFTestSeqViewController.h"
#include <Python.h>
#import "QREncoder.h"
#import "SFCommonFounction.h"
#import "SFWhiteMaskView.h"
#import "SFRecordWriter.h"
#import "SFAuthenticator.h"
#import "SFUserLoginVerificationWindowController.h"

#ifdef DEBUG
#import "SFSlotCommunication.h"
#endif


@interface SFTestSeqViewController ()
{
    SFWhiteMaskView *_clearViewMask;
    SFWhiteMaskView *_pairViewMask;
    SFWhiteMaskView *_unpairViewMask;
    SFUserLoginVerificationWindowController *verificationWindow;
    NSUInteger _maxSlotSize;
    NSUInteger _maxFixtureSize;
}

@end

@implementation SFTestSeqViewController

- (IBAction)clearAction:(id)sender {
    [self clearSlotView:_selectedSlotView];
}

- (IBAction)unpairAction:(id)sender {
    [self unPairSlotView:_selectedSlotView];

}
- (IBAction)pairAction:(id)sender {
    
    //check cam board connection before pair action.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_promptTextField setStringValue:@"start to pair slot"];
        [_promptTextField setTextColor:[NSColor blackColor]];
    });
    
    if ([self checkCAMConnection:_selectedSlotView.ipAddress] == NO) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_promptTextField setStringValue:@"Pairing Failed! CAMBboard is disconnection!"];
            [_promptTextField setTextColor:[NSColor redColor]];
        });
        return;
        
    }
    
    [self pairSlotView:_selectedSlotView];

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
   // Py_Finalize();
}

-(void)destroyController
{
    [super destroyController];
    [self setStart_read_adc_flag:NO];

    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //stroe slot view's start test time stamp
    NSArray *slotViews_startTimeStamp = [_slotViews valueForKeyPath:@"startedTimeStamp"];
    [[NSUserDefaults standardUserDefaults] setObject:slotViews_startTimeStamp forKey:@"SlotStartTimeStamp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
        
    
}

-(void)obtainWabisabiInfomation{
    _wabisabi_ip = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"wabisabi_ip"];
    _wabisabi_port = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"wabisabi_port"];

}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _maxSlotSize = 12;
        _maxFixtureSize=6;
        
        
        _start_read_adc_flag   = YES;

        [self obtainWabisabiInfomation];
        _fixtureViews =[NSMutableArray arrayWithCapacity:_maxFixtureSize];
        _slotViews =[NSMutableArray arrayWithCapacity:2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidEndEditingNotification:) name:NSControlTextDidEndEditingNotification object:_scanArea];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:nil];
        

       /*
        NSString *path = [[NSBundle mainBundle] pathForResource:@"MainSeq" ofType:@"py" inDirectory:@"tools"];
        Py_SetProgramName((char *)[path cStringUsingEncoding:NSUTF8StringEncoding]);
        
        setenv("PYTHONPATH", [[path stringByDeletingLastPathComponent] cStringUsingEncoding:NSUTF8StringEncoding], 0);
        
        Py_Initialize();
        callPythonScript("MainSeq","test_main");
        
        
        PyRun_SimpleString("print 'python started.==>'");
        */
    }
    

    return self;
}

/*
static void callPythonScript(const char * script,const char * func_name)
{
    PyObject *pName,*pModule,*pFunc;
    PyObject *pArgs,*pValue;
    pName = PyString_FromString(script);
    pModule = PyImport_Import(pName);
    Py_DECREF(pName);
    if (pModule != NULL) {
        pFunc = PyObject_GetAttrString(pModule, func_name);
        if (pFunc && PyCallable_Check(pFunc)) {
            pArgs = PyTuple_New(2);
            pValue = PyInt_FromLong(1);
            
            if (!pValue) {
                Py_DECREF(pArgs);
                Py_DECREF(pModule);
                fprintf(stderr, "Cannot convert argument\n");
                return;
            }
            
            PyTuple_SetItem(pArgs, 0, pValue); //pValue reference stolen here
           //Py_DECREF(pValue);
            
            pValue = PyString_FromString("First Item Name");
            if (!pValue) {
                Py_DECREF(pArgs);
                Py_DECREF(pModule);
                fprintf(stderr, "Cannot convert argument\n");
                return;
            }
            PyTuple_SetItem(pArgs, 1, pValue);
           //Py_DECREF(pValue);
            pValue = PyObject_CallObject(pFunc, pArgs);
            Py_DECREF(pArgs);
            
            if (pValue !=NULL) {
                printf("Result of  call:%ld\n",PyInt_AsLong(pValue));
                Py_DECREF(pValue);
            }else{
                Py_DECREF(pFunc);
                Py_DECREF(pModule);
                PyErr_Print();
                fprintf(stderr, "Call failed\n");
                return ;
            }
            
        }else{
            if (PyErr_Occurred()) {
                PyErr_Print();
                fprintf(stderr, "Cannot find function \"%s\"\n",func_name);
            }
        }
        Py_DECREF(pFunc);
        Py_DECREF(pModule);
        
        
    }else{
        PyErr_Print();
        fprintf(stderr, "Failed to load \"%s\"\n",script);
    }
    
}
*/
-(void)setupNandRackView
{
    //setup fixture views.
    
    for (int i=0; i<_maxFixtureSize; i++) {
        SFFixtureView *f =[SFFixtureView new];
        [f setUid:i];
        [f setIdentify:[NSString stringWithFormat:@"Fixture%i",i+1]];
        [_fixtureViews addObject:f];
    }
    
    //setup slot views.
    NSArray *slotSettings=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.Slots"];
    NSArray *allSlotsStartTimeStamp = [[NSUserDefaults standardUserDefaults] objectForKey:@"SlotStartTimeStamp"];
    for (int j=0; j<_maxSlotSize; j++) {
        SFSlotView *s =[SFSlotView new];
        id carrierid=[slotSettings[j] objectForKey:@"MAC_Slot"];
        NSString *slotName=[slotSettings[j] objectForKey:@"SlotID"];
        BOOL enable = [[slotSettings[j] objectForKey:@"Enable"] boolValue];
        NSString *ipAddress=[slotSettings[j] objectForKey:@"IP_Address"];
        
        [s setEnable:enable];
        [s setScanID:carrierid];
        [s setUid:j];
        [s setIdentify:slotName];
        [s setIpAddress:ipAddress];
        
        
        if ([allSlotsStartTimeStamp count] > 5) { // 5 can be replaced by number 0-12;
            NSTimeInterval restoredTimeStamp = [allSlotsStartTimeStamp[j] floatValue];
            if (restoredTimeStamp > 100) { //100 can be replaced by number which more than 1 and less than the real timestamp;
                [s setStartedTimeStamp:restoredTimeStamp];
            }
        }
        
        [_slotViews addObject:s];
    }
    //delete defaults start timestamps.
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"SlotStartTimeStamp"];
    
    NSImage *pairImage= [QREncoder encode:@"<PAIR" size:1 correctionLevel:QRCorrectionLevelHigh];
    NSImage *unpairImage= [QREncoder encode:@"<UNPAIR" size:1 correctionLevel:QRCorrectionLevelHigh];
    NSImage *clearImage= [QREncoder encode:@"<CLEAR" size:1 correctionLevel:QRCorrectionLevelHigh];
    _clearViewMask = [[SFWhiteMaskView alloc] initWithFrame:_clearViewMask.bounds];
    _unpairViewMask = [[SFWhiteMaskView alloc] initWithFrame:_unpairImageView.bounds];
    _pairViewMask = [[SFWhiteMaskView alloc] initWithFrame:_pairImageView.bounds];
    
    //load defaults FPY
    [[SFRecordWriter sharedLogWriter] restoreFPY];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_pairImageView setImage:pairImage];
        [_unpairImageView setImage:unpairImage];
        [_clearImageView setImage:clearImage];
        [_nandRackMainView setDataSource:self];
        [_scanArea becomeFirstResponder];
        
        [self setHiddenClearImageView:NO];
        [self setHiddenPairImageView:YES];
        [self setHiddenUnpairImageView:YES];
        [_promptTextField setStringValue:@"Ready to accept barcodes..."];
        
        [_nandRackMainView setNeedsDisplay:YES];
    });
    
}
-(void)awakeFromNib
{
    [self setupNandRackView];
    //initialize slot views.
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSNumber *delay =[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"DelayForCarrierStateRefreshing"];
        float dt = [delay floatValue];
        

        
        while (_start_read_adc_flag) {
#ifdef DEBUG
            for (int i=0; i<_maxSlotSize; i++) {
                SFSlotView *slotView =_slotViews[i];
                if (slotView.status == ResultViewReadyStatus) {
                    [NSThread sleepForTimeInterval:dt];
                    [slotView setSlotState:@"TESTING"];
                    slotView.startedTimeStamp = [[NSDate date] timeIntervalSince1970];

                }else if (slotView.status == ResultViewPendingStatus && slotView.startedTimeStamp > 0 && ([[NSDate new] timeIntervalSince1970] - slotView.startedTimeStamp) >=5){
                    
                    NSTimeInterval interval =[[NSDate new] timeIntervalSince1970] ;
                    if((long)interval % 2){
                        [slotView setSlotState:@"PASSED"];
                    }else{
                        [slotView setSlotState:@"FAILED"];
                        
                    }
                }
                
            }
#else

            [self updateCarrierState];
            
#endif
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //update FPY for nand view.
                NSUInteger failed = [[SFRecordWriter sharedLogWriter] totalFailCount];
                NSUInteger passed =[[SFRecordWriter sharedLogWriter] totalPassCount];
                NSUInteger total = failed + passed;
                float yield = total == 0 ? 100.00 : (passed /(float)total)*100 ;
                
                NSString *nandviewTitle = [NSString stringWithFormat:@"NandRack FPY:    ( Passed:%ld  Failed:%ld  Yield:%.2f%% )",passed,failed,yield];
                [_nandRackMainView setTitle:nandviewTitle];
  

                [_nandRackMainView setNeedsDisplay:YES];
                
                
            });
            [NSThread sleepForTimeInterval:dt];
            

        }
    });
  
}

-(NSUInteger)getSlotUIDByCarrierID:(NSString *)mac
{
   /* __block NSUInteger locationID = 0;
    NSArray *slots_info=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"CAMSettings.Slots"];
    [slots_info enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *thisSlotInfo=obj;
        NSString *carrierID=[[thisSlotInfo objectForKey:@"MAC_Slot"] uppercaseString];
        if ([carrierID isEqualToString:[mac uppercaseString]]) {
            *stop = YES;
            locationID = idx + 1;
        }
    }];
    */
#ifdef DEBUG
    __block NSInteger slotID = -1;
    [[[SFSlotCommunication sharedSlotCommunication] debug_slot_settings] enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
        if (obj && [[obj objectForKey:@"carrier"] isEqualToString:mac]) {
            slotID = idx +1;
            *stop = YES;
        }
    }];
    return  slotID;
#else
    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/carriers/%@",_wabisabi_ip,_wabisabi_port,mac]];
    NSString *output = [self sendJsonData:args];
    
    NSDictionary *retInfo =[NSJSONSerialization
                            JSONObjectWithData:[output dataUsingEncoding:NSUTF8StringEncoding]
                            options:NSJSONReadingMutableLeaves error:nil];
    id slot = [retInfo valueForKeyPath:@"slot.sioSlot"];
    if ([slot isKindOfClass:[NSNumber class]]) {
        return [slot integerValue];
    }
    
    return -1;
#endif
}

-(void)applicationDidBecomeActive:(NSNotification *)notification
{
   
    NSLog(@"applicationDidBecomeActive");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self view] window] makeFirstResponder:_scanArea];

    });
}

-(void)textDidEndEditingNotification:(NSNotification *)notification
{
    NSString *str=[_scanArea stringValue];
   // NSLog(@"Input:%@",inputStr);

    if (str == nil || [str length] < 1) {
        return;
    }
    
    [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"Scan text:%@",str] Type:SFLogTypeNormal];
    //trim whitespace and  newlineCharacter
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
   //NSPredicate
    NSString *prefixSN=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"PrefixOfUnitSN"];
    NSString *prefixCarrier=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"PrefixOfCarrierID"];

    NSPredicate *mac_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",prefixCarrier];
    NSPredicate *sn_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",prefixSN];

    if ([mac_predicate evaluateWithObject:str]) {
       
        NSUInteger locationID = [self getSlotUIDByCarrierID:str];
        if (locationID <= 12 && locationID >0) {
            if(_selectedSlotView !=nil){
                [_selectedSlotView setIsSelected:NO];
            }
            _selectedSlotView =[_slotViews objectAtIndex:locationID-1]; // set selected slot view.
            //if selected slot view is disabled
            
            if (_selectedSlotView.enable == NO) {
                [_promptTextField setStringValue:[NSString stringWithFormat:@"Carrier:%@ / Slot-%lu is disabled!",str,locationID]];
                
                [_promptTextField setTextColor:[NSColor blackColor]];

                return;
                
            }
            
            [_selectedSlotView setIsSelected:YES];
            [_selectedSlotView setCarrierID:str];

            
            NSMutableDictionary *infomation=[NSMutableDictionary dictionaryWithCapacity:5];
            //check if this carrier is paired ?
            if ([self checkIsCarrierPaired:str information:infomation]) {
                // carried already paried
                NSString *sn = [infomation valueForKeyPath:@"unit.id"];
                if (sn) {
                    [_promptTextField setStringValue:[NSString stringWithFormat:@"Previously Paired Unit:%@\nPreviously Paired Carrier:%@\n Unpair?",sn,str]];
                    [_promptTextField setTextColor:[NSColor blackColor]];
                    [_selectedSlotView setSerialNumber:sn];
                    [self setHiddenUnpairImageView:NO];
                    [self setHiddenPairImageView:YES];
                }


            }else{
                //this carried not paired yet
                [_promptTextField setStringValue:@"Ready to accept barcodes..."];
                [_promptTextField setTextColor:[NSColor blackColor]];

            }
            
        }else{
            [_promptTextField setStringValue:[NSString stringWithFormat: @"Not Found Paired Carrier ID/MAC:%@",_scanArea.stringValue ]];
            [_promptTextField setTextColor:[NSColor redColor]];
        }
        

        
    }else if([sn_predicate evaluateWithObject:str]){
        
        NSMutableDictionary *infomation=[NSMutableDictionary dictionaryWithCapacity:5];
        if ([self checkIsUnitPaired:str information:infomation]) {
            // unit already paired
            NSString *carrier = [infomation valueForKeyPath:@"carrier.id"];
            if (carrier) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_promptTextField setStringValue:[NSString stringWithFormat:@"Previously Paired Unit:%@\nPreviously Paired Carrier:%@\n Unpair?",carrier,str]];
                    [_promptTextField setTextColor:[NSColor blackColor]];
                    [self setHiddenUnpairImageView:NO];
                    [self setHiddenPairImageView:YES];

                });

                
                //highlight the paired unit / carrier
                NSUInteger locationID = [self getSlotUIDByCarrierID:carrier];
                if (locationID <= _maxSlotSize && locationID >0) {
                    _selectedSlotView =[_slotViews objectAtIndex:locationID-1]; // set selected slot view.
                    [_selectedSlotView setIsSelected:YES];
                    [_selectedSlotView setCarrierID:carrier];

                }
            }
            
        }else{
            // unit not paired yet.
            if (_selectedSlotView) {
                [_selectedSlotView setSerialNumber:str];
                [self setHiddenPairImageView:NO];
                [self setHiddenUnpairImageView:YES];

                
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_promptTextField setStringValue:[NSString stringWithFormat:@"Please select a slot before scan serial number:%@",str]];
                    [_promptTextField setTextColor:[NSColor blackColor]];
                });
            }

            
        }

    }else if ([str isEqualToString:@"<CLEAR"]){
            
        [_selectedSlotView setIsSelected:NO];
        [self clearSlotView:_selectedSlotView];
        [self setHiddenPairImageView:YES];
        [self setHiddenUnpairImageView:YES];
        
    }else if ([str isEqualToString:@"<PAIR"] ){
            [self pairSlotView:_selectedSlotView];
    }else if ([str isEqualToString:@"<UNPAIR"]){
            [self unPairSlotView:_selectedSlotView];
            
    }else if ([str isEqualToString:@"<SCREEN"]){
        
        [self fullScreen:fullScreenBtn];
        
    }else if ([str isEqualToString:@"<FPY"]){
        [[SFRecordWriter sharedLogWriter] resetFPY];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_promptTextField setStringValue:[NSString stringWithFormat:@"2D barcode not match:%@",str]];
            [_promptTextField setTextColor:[NSColor redColor]];
        });
    }
    
    [_scanArea setStringValue:@""];

    dispatch_async(dispatch_get_main_queue(), ^{
        [_nandRackMainView setNeedsDisplay:YES];
        [[self.view window] makeFirstResponder:_scanArea];
    });
    
}

-(BOOL)checkIsUnitPaired:(NSString *)serialnumber information:(NSMutableDictionary *) info{
    
#ifdef DEBUG
    return NO;
#endif
    
    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/units/%@",_wabisabi_ip,_wabisabi_port,serialnumber]];
    NSString *output = [self sendJsonData:args];

    NSDictionary *retInfo =[NSJSONSerialization
                         JSONObjectWithData:[output dataUsingEncoding:NSUTF8StringEncoding]
                         options:NSJSONReadingMutableLeaves error:nil];
    
    [info setDictionary:retInfo];
    NSString *carrierID=[[retInfo valueForKeyPath:@"carrier.id"] description];
    if (carrierID && [carrierID isNotEqualTo:@"<null>"]) {
        return  YES;
    }
    return NO;
}

//pair with serial number

-(BOOL)checkIsCarrierPaired:(NSString *)mac information:(NSMutableDictionary *) info{
#ifdef DEBUG
    
    if ([_selectedSlotView status] == ResultViewClearStatus){
        return NO;
    }
    NSDictionary *uid = @{@"id" : _selectedSlotView.serialNumber};
    [info setObject:uid forKey:@"unit"];
    return YES;
#endif
    
    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/carriers/%@",_wabisabi_ip,_wabisabi_port,mac]];
    NSString *output = [self sendJsonData:args];
    
    NSDictionary *retInfo =[NSJSONSerialization
                            JSONObjectWithData:[output dataUsingEncoding:NSUTF8StringEncoding]
                            options:NSJSONReadingMutableLeaves error:nil];
    
    [info setDictionary:retInfo];
    
    
    NSString *sn = [[retInfo valueForKeyPath:@"unit.id"] description];
    
    if (sn != nil && [sn isNotEqualTo:@"<null>"] ) {
        return  YES;
    }
    
    return NO;
}



-(void)updateCarrierState
{
  

    NSURL *url =[NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%@/api/carriers",_wabisabi_ip,_wabisabi_port]];
    
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (!data) {
            [_promptTextField setStringValue:@"Failed to connect to wabisabi"];
            [_promptTextField setTextColor:[NSColor redColor]];
            return ;
        }
        id retInfo =[NSJSONSerialization
                     JSONObjectWithData:data
                     options:NSJSONReadingMutableLeaves error:nil];
        
        if([retInfo isKindOfClass:[NSArray class]]){
            
            [retInfo enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                id slotID=[obj valueForKeyPath:@"slot.sioSlot"];
                id  unitID=[[obj valueForKeyPath:@"unit.id"] description];
                id  state =[[obj valueForKeyPath:@"unit.state"] description];
                id lastping=[obj valueForKeyPath:@"unit.lastPing"];

                if ([slotID isKindOfClass:[NSNumber class]]) {
                    NSUInteger idx =[slotID unsignedIntegerValue];
                    SFSlotView *slotView =[_slotViews objectAtIndex:idx-1];
                    [slotView setSlotState:state];
                    
                    if ([slotView.serialNumber isEqualToString:@"--"] || [slotView.serialNumber isEqualToString:@"<null>"]) {
                        [slotView setSerialNumber:unitID];
                    }
                    
                    if ((slotView.status == ResultViewPendingStatus)) { //uut under test
                        //mark last ping time when test started.
                        if ((slotView.startedTimeStamp == 0) ) {
                            //
                            NSTimeInterval currentTimeStamp = [[NSDate date] timeIntervalSince1970]; //make sure  last ping time less then current time stamp
                            if ([lastping isKindOfClass:[NSNumber class]] && [lastping floatValue] < currentTimeStamp ) {
                                slotView.startedTimeStamp = [lastping floatValue];
                            }else{
                                slotView.startedTimeStamp = currentTimeStamp;
                            }
                            
                        }else{
                            //update cycle time.
                            NSTimeInterval endT = [[NSDate date] timeIntervalSince1970];
                            NSTimeInterval dt = endT - slotView.startedTimeStamp;
                            [slotView setCt:dt];
                        }
    
                    }else{ // uut finished test .
                        
                        //reset startedTimeStamp when uut test finished
                        
                        //update cycle time.
                        if (ResultViewPassStatus == slotView.status || ResultViewFailedStatus == slotView.status) {
                            
                            
                        }else{
                            NSTimeInterval endT = [[NSDate date] timeIntervalSince1970];
                            NSTimeInterval dt = endT - slotView.startedTimeStamp;
                            [slotView setCt:dt];
                            
                        }
                        [slotView setStartedTimeStamp:0];
                    }
                }
            }];
        }
        
    }];
    


}

-(BOOL)checkCAMConnection:(NSString *)ipAddress
{
#ifdef DEBUG
    NSURL *camHttpURL=[NSURL URLWithString:@"http://www.baidu.com"];

#else
    NSURL *camHttpURL=[NSURL URLWithString:[NSString stringWithFormat:@"http://%@/main.htm",ipAddress]];

#endif

    NSMutableURLRequest *urlRequest =[NSMutableURLRequest requestWithURL:camHttpURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:1.0];
    NSURLResponse *urlResponse= nil;
    NSError *anyError = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&urlResponse error:&anyError ];
    if (data.length > 0 && anyError == nil) {
        return YES;
    }
    return   NO;
}

-(NSString *)sendJsonData:(NSArray*)args
{
    NSString *cmd = @"/usr/bin/curl";
    NSString *output = @"";
   output = [SFCommonFounction executeCmd:cmd withArguments:args];
    //output =[NSString stringWithContentsOfFile:@"/a.txt" encoding:NSUTF8StringEncoding error:NULL];
    
    NSLog(@"%@ %@ %@",cmd,args,output);
    return  output;

}

-(void)preUUT
{
    
    NSString *preUUTPath=[[NSBundle mainBundle] pathForResource:@"pre_uut" ofType:@"command" inDirectory:@"actionscripts"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [SFCommonFounction executeCmd:@"/bin/sh" withArguments:@[preUUTPath,_selectedSlotView.serialNumber,_selectedSlotView.carrierID,[@(_selectedSlotView.uid +1 ) description],_selectedSlotView.ipAddress]];
    });
    [NSThread sleepForTimeInterval:0.5];

    
}

-(void)postUUT
{
    NSString *postUUTPath=[[NSBundle mainBundle] pathForResource:@"post_uut" ofType:@"command" inDirectory:@"actionscripts"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

    [SFCommonFounction executeCmd:@"/bin/sh" withArguments:@[postUUTPath,_selectedSlotView.serialNumber,_selectedSlotView.carrierID,[@(_selectedSlotView.uid +1 ) description],_selectedSlotView.ipAddress]];
    });
    
    [NSThread sleepForTimeInterval:0.5];


}

//MARK:scan slot action
-(void)clearSlotView:(SFSlotView *)slotView;
{
    

    
    if (_selectedSlotView == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_promptTextField setStringValue:[NSString stringWithFormat:@"<WARNING> No Selection , Clear slot failed!"]];
            [_promptTextField setTextColor:[NSColor redColor]];
        });
        return;
    }
    [slotView setClearStatus];
    _selectedSlotView = nil;
    
}

-(void)pairSlotView:(SFSlotView *)slotView;
{

    //slot没有被选择
    if (_selectedSlotView == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_promptTextField setStringValue:[NSString stringWithFormat:@"<WARNING> No Selection , Pair slot failed!"]];
            [_promptTextField setTextColor:[NSColor redColor]];
        });
        return;
    }
    //serial number不符合规则？
    NSString *sn=slotView.serialNumber;
    NSString *prefixSN=[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"PrefixOfUnitSN"];
    NSPredicate *sn_predicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",prefixSN];
    if (nil == sn || ![sn_predicate evaluateWithObject:sn]) {
        [_promptTextField setStringValue:[NSString stringWithFormat:@"<WARNING> Wrong Serial Number!"]];
        [_promptTextField setTextColor:[NSColor redColor]];
        return ;
    }
#ifdef DEBUG
    
    [_selectedSlotView setSlotState:@"PAIRED"];
    
# else
    
    NSString *mac=slotView.carrierID;

    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/units/%@",_wabisabi_ip,_wabisabi_port,sn],@"-X",@"PUT"];
    
    NSString *retStr=[self sendJsonData:args];
    /*
     //DONOT CHECK RETURN STRING
     //it does not matter for this error.
     
     if ([retStr isNotEqualTo:@"Created"]) {
     [_promptTextField setStringValue:[NSString stringWithFormat:@"failed to put:%@\n",retStr]];
     [_promptTextField setTextColor:[NSColor redColor]];
     
     [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"failed to put:%@",retStr] Type:SFLogTypeError];
     
     return ;
     }
     */
    
    [[SFRecordWriter sharedLogWriter] insertLog:retStr Type:SFLogTypeNormal];
    
    
    [NSThread sleepForTimeInterval:0.1];
    args=@[[NSString stringWithFormat:@"%@:%@/api/carriers/%@/unit",_wabisabi_ip,_wabisabi_port,mac],@"-X",@"PUT",@"-d",[NSString stringWithFormat:@"{\"id\":\"%@\"}",sn],@"-H",@"Content-Type: application/json"];
    
    retStr = [self sendJsonData:args];
    
    if ([retStr isNotEqualTo:@"Created"]) {
        [_promptTextField setStringValue:[NSString stringWithFormat:@"failed to pair unit:%@\n",retStr]];
        [_promptTextField setTextColor:[NSColor redColor]];
        [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"failed to pair unit:%@",retStr] Type:SFLogTypeError];
        return ;
    }
    
#endif
    
    [self preUUT];

    
    dispatch_async(dispatch_get_main_queue(), ^{

        [[SFRecordWriter sharedLogWriter] insertLog:@"unit paired! OK!" Type:SFLogTypeNormal];
        [slotView setStatus:ResultViewReadyStatus];
        [_promptTextField setStringValue:@"Paired! Ready to accept barcodes..."];
        [_promptTextField setTextColor:[NSColor blackColor]];
        [self setHiddenPairImageView:YES];
        [_selectedSlotView setIsSelected:NO];
        _selectedSlotView = nil;
    });


}

-(void)unPairSlotView:(SFSlotView *)slotView;
{
    //没有选择slot
    if (_selectedSlotView == nil)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_promptTextField setStringValue:[NSString stringWithFormat:@"<WARNING> No Selection , Unpair slot failed!"]];
            [_promptTextField setTextColor:[NSColor redColor]];
        });
        return;
    }
    //slot状态不符合？
    NSArray *validState=@[@"PAIRED",@"FAILED",@"PASSED",@"ABORTED"];
    NSString *rawState = slotView.slotState;
    if (nil == rawState || ![validState containsObject:rawState]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_promptTextField setStringValue:[NSString stringWithFormat:@"<WARNING> Forbidden unpair <%@>, Unpair slot failed!",rawState]];
            [_promptTextField setTextColor:[NSColor redColor]];
        });
        return;
    }
#ifdef DEBUG
    [_selectedSlotView setSlotState:@"EMPTY"];
#else

    
    [self postUUT];
    // NSString *ethAddress=[thisSlotInfo objectForKey:@"MAC_Slot"];
    NSArray *args=@[[NSString stringWithFormat:@"%@:%@/api/carriers/%@/unit",_wabisabi_ip,_wabisabi_port,slotView.carrierID],@"-X",@"DELETE"];
    
    NSString *retStr=[self sendJsonData:args];
    
    if ([retStr isNotEqualTo:@"OK"]) {
        [_promptTextField setStringValue:[NSString stringWithFormat:@"failed to unpair unit:%@\n",retStr]];
        [_promptTextField setTextColor:[NSColor redColor]];
        [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"failed to unpaire unit:%@",retStr] Type:SFLogTypeError];
        return ;
    }
    
#endif

    
    dispatch_async(dispatch_get_main_queue(), ^{

        [slotView setStatus:ResultViewClearStatus];
        [_promptTextField setStringValue:@"Carrier and unit unpaired! Ready to accept barcodes..."];
        [_promptTextField setTextColor:[NSColor blackColor]];
        
        [[SFRecordWriter sharedLogWriter] insertLog:@"Carrier and unit unpaired!" Type:SFLogTypeNormal];

        [self setHiddenUnpairImageView:YES];
        [_selectedSlotView setClearStatus];
        [_selectedSlotView setIsSelected:NO];
        _selectedSlotView = nil;
    });


}

#pragma mark -- SFNANDRackDataSource implementions.
-(NSUInteger)fixutureNumber;
{
    return [_fixtureViews count];
}

-(NSUInteger)slotNumberOfFixtureView:(SFFixtureView *)fixtureView;
{
    return 2;
}

-(SFFixtureView *)fixtureViewAtIndex:(NSUInteger)index;
{
    return [_fixtureViews objectAtIndex:index];
}

-(SFSlotView *)slotViewAtIndex:(NSUInteger)index ofFixtureView:(SFFixtureView *)fixtureView;{
    

    NSUInteger slotCount = [_slotViews count];
    
    NSUInteger slotIndex = fixtureView.uid*2 +index;
    if (slotIndex < slotCount) {
        return [_slotViews objectAtIndex:slotIndex];
    }
    return  nil;
}

//MARK:ToggleFullScreen

-(IBAction)fullScreen:(NSButton *)sender;
{
    if ([[sender title] isEqualToString:@"EnterFullScreen"]) {
        mainWindowStyleMask = [[NSApp mainWindow] styleMask]; // store style mask;
        [[NSApp mainWindow] setStyleMask:NSFullScreenWindowMask | NSTitledWindowMask | NSClosableWindowMask ];
        [NSMenu setMenuBarVisible:NO];
        NSRect screenRect=[[NSScreen mainScreen] frame];
        [[NSApp mainWindow] setFrame:screenRect display:YES];
        [[NSApp mainWindow] setFrameOrigin:CGPointMake(0, 0)];
        [[NSApp mainWindow] setHasShadow:NO];
        [sender setTitle:@"ExitFullScreen"];
        [sender setHidden:YES];
        //post notification to window's delegate.

        if ([[[NSApp mainWindow] delegate] respondsToSelector:@selector(windowDidEnterFullScreen:)])
        {
            [self responseEnterFullScreen];

            [[[NSApp mainWindow] delegate] windowDidEnterFullScreen:[NSNotification notificationWithName:NSWindowDidEnterFullScreenNotification object:sender]];
            

        }
    
    }else{
        if (mainWindowStyleMask != 0) {
            [[NSApp mainWindow] setStyleMask: mainWindowStyleMask];
            [NSMenu setMenuBarVisible:YES];
            [[NSApp mainWindow] setHasShadow:YES];
            [sender setTitle:@"EnterFullScreen"];
            [sender setHidden:NO];

          //  [self verifyPassword];
            
            //post notification to window's delegate.
            if ([[[NSApp mainWindow] delegate] respondsToSelector:@selector(windowDidExitFullScreen:)])
            {
                [self responseExitFullScreen];
                
                [[[NSApp mainWindow] delegate] windowDidExitFullScreen:[NSNotification notificationWithName:NSWindowDidExitFullScreenNotification object:sender]];
                
            }
        }
    }
    
    
#ifdef DEBUG
#else
   [[NSApp mainWindow] setLevel:CGShieldingWindowLevel()];
#endif

}


-(void)responseEnterFullScreen
{
    orignalViewRect = self.view.frame;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self view] window] makeFirstResponder:_scanArea];
        CGFloat xSpace=30;
        CGFloat ySpace=30;

        CGFloat spacOfNand_scanArea =10;
        
        self.view.frame = [[NSScreen mainScreen] frame];
        NSRect  fullframe = self.view.frame;
        NSRect inputAreaFram = inputView.frame;
        [inputView setFrameOrigin:NSMakePoint(xSpace, fullframe.size.height - inputAreaFram.size.height)];

        NSRect scanAreaFrame=[scanView frame];
        CGFloat nandViewWidth = fullframe.size.width - xSpace - scanAreaFrame.size.width - spacOfNand_scanArea;
        CGFloat nandViewHight =fullframe.size.height - inputAreaFram.size.height - ySpace - 10;
        
        [_nandRackMainView setFrameSize:NSMakeSize(nandViewWidth, nandViewHight)];
        [_nandRackMainView setFrameOrigin:NSMakePoint(xSpace, ySpace)];

        [scanView setFrameOrigin:NSMakePoint(_nandRackMainView.frame.origin.x + nandViewWidth + spacOfNand_scanArea, _nandRackMainView.frame.origin.y + (nandViewHight - scanView.frame.size.height)/2)];
        
    });
    
}

-(void)responseExitFullScreen
{
    self.view.frame = orignalViewRect;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[[self view] window] makeFirstResponder:_scanArea];
        /*
        NSRect  cframe = _nandRackMainView.frame;
        NSRect scanFrame=[scanView frame];
        [scanView setFrame:NSMakeRect(cframe.origin.x + cframe.size.width +20 , scanFrame.origin.y, scanFrame.size.width, scanFrame.size.height)];
        [[NSApp mainWindow] setLevel:0];
         */
        
        CGFloat xSpace=10;
        CGFloat ySpace=10;
        
        CGFloat spacOfNand_scanArea =10;
        NSRect  fullframe = self.view.frame;
        NSRect inputAreaFram = inputView.frame;
        [inputView setFrameOrigin:NSMakePoint(xSpace, fullframe.size.height - inputAreaFram.size.height)];
        
        NSRect scanAreaFrame=[scanView frame];
        CGFloat nandViewWidth = fullframe.size.width - xSpace - scanAreaFrame.size.width - spacOfNand_scanArea;
        CGFloat nandViewHight =fullframe.size.height - inputAreaFram.size.height - ySpace - 10;
        
        [_nandRackMainView setFrameSize:NSMakeSize(nandViewWidth, nandViewHight)];
        [_nandRackMainView setFrameOrigin:NSMakePoint(xSpace, ySpace)];
        
        [scanView setFrameOrigin:NSMakePoint(_nandRackMainView.frame.origin.x + nandViewWidth + spacOfNand_scanArea, _nandRackMainView.frame.origin.y )];
        
        
    });
    
}

@end
