//
//  SFReportViewController.m
//  CAMTOOL
//
//  Created by jifu on 1/25/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFReportViewController.h"
#import "SFDataCenter.h"
#import "YieldReport.h"
#import "SFSlotView.h"
@interface SFReportViewController ()
{
    IBOutlet SFYieldView *yieldView;
    IBOutlet SFUPHView *uphView;
    IBOutlet NSTableView *resultView;
    IBOutlet NSSearchField *searchField;
    NSArray *_yielddata;
    NSArray *_uphData;
    NSMutableArray *_searchedResults;
    NSMutableArray *_displayResults;

}
@end


@implementation SFReportViewController

- (IBAction)filterReslutBySn:(id)sender {
    NSString *sn = [sender stringValue];
    if ([sn length] >=1) {
        NSArray *afterFiltedSn = [_searchedResults filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"sn CONTAINS %@",sn]];
        [_displayResults setArray:afterFiltedSn];
    }else{
        [_displayResults setArray:_searchedResults];

    }

    [resultView reloadData];
}

#pragma mark - NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return _displayResults.count;
}

#pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    [[cellView textField] setDrawsBackground:NO];

    if ([identifier isEqualToString:@"index"]) {
        cellView.textField.stringValue = [NSString stringWithFormat:@"%ld",row+1];
    }else if([identifier isEqualToString:@"result"]){
        id result = [_displayResults[row] valueForKey:identifier];
        [[cellView textField] setDrawsBackground:YES];

        switch ([result integerValue]) {
            case ResultViewFailedStatus:
                cellView.textField.objectValue = @"Failed";
                cellView.textField.backgroundColor = [NSColor redColor];

                break;
            case ResultViewPassStatus:
                cellView.textField.objectValue = @"Passed";
                cellView.textField.backgroundColor = [NSColor greenColor];

                break;
                
            default:
                cellView.textField.objectValue = @"Aborted";
                cellView.textField.backgroundColor = [NSColor yellowColor];

                break;
        }

    }else{
        cellView.textField.objectValue = [_displayResults[row] valueForKey:identifier];
    }

    return cellView;
}


-(NSInteger)numberOfRecordsForPlotView:(id)plotView;
{
    if(plotView == uphView){
        return [_uphData count];
    }
    return [_yielddata   count];
}

-(id)valueForPlotView:(id)plotView field:(NSString *)fieldEnum recordIndex:(NSUInteger)index;
{
    NSDictionary *dict = nil;
    if(plotView == uphView){
        dict = _uphData[index];
        
    }else{
        dict = _yielddata[index];
    }
    
    return [dict objectForKey:fieldEnum];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [yieldView setDataSource:self];
    [uphView setDataSource:self];
    [self setEndDate:[NSDate date]];
    [self setStartDate:[NSDate dateWithTimeInterval:-3600*24 sinceDate:_endDate]];
    [self searchDatabase:nil];
    
    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _searchedResults=[NSMutableArray array];
        _displayResults=[NSMutableArray array];
    }
    return self;
}

-(IBAction)updateDatabase:(id)sender;
{
    [self setEndDate:[NSDate new]];
    [self searchDatabase:sender];
}

-(NSArray *)recordsFormDate:(NSDate *)startDate ToDate:(NSDate *)endDate;
{
    //TODO:recordsFormDate
   
    NSMutableArray *records=[NSMutableArray array];
   
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@ AND timestamp <= %@", _startDate,_endDate];

    //caculate pass count

    NSFetchRequest *matchingLogsRequest = [NSFetchRequest fetchRequestWithEntityName:@"YieldReport"];
    [matchingLogsRequest setPredicate:predicate];
    NSArray* results = [[[SFDataCenter sharedDataCenter] managedObjectContext] executeFetchRequest:matchingLogsRequest error:nil];
    [_searchedResults setArray:results];
    NSArray *slot_identifies =[results valueForKeyPath:@"slotName"];
    if (slot_identifies != nil) {
        slot_identifies =[[NSOrderedSet orderedSetWithArray:slot_identifies] array];
        NSArray *all_passed_results=[[results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.result == %@",@(SFUUTPassedResult)]] valueForKey:@"sn"];
        
        [slot_identifies enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
            NSArray *passed_results= [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.result == %@ and SELF.slotName==%@",@(SFUUTPassedResult),obj ] ];
            NSUInteger pass_count = [passed_results count];
            
            NSArray *failed_results = [results filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.result == %@  and SELF.slotName==%@",@(SFUUTFailedResult),obj ] ];
            NSUInteger fail_count = [failed_results count];

            NSMutableDictionary *slotInfo =[NSMutableDictionary dictionary];
            [slotInfo setObject:@(fail_count) forKey:@"FAIL"];
            [slotInfo setObject:@(pass_count) forKey:@"PASS"];
            
            __block NSUInteger retest_count=0;
            
            [[failed_results valueForKey:@"sn"] enumerateObjectsUsingBlock:^(id   obj, NSUInteger idx, BOOL *  stop) {
                if ([all_passed_results containsObject:obj]) {
                    retest_count+=1;
                }
            }];
            
            [slotInfo setObject:@(retest_count) forKey:@"RETEST"];
            [slotInfo setObject:obj forKey:@"Name"];
            [records addObject:slotInfo];
        }];
    }
    
    //sort records by slot name;
    
    return [records sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"Name" ascending:YES]]];

   // return records;
}

-(NSUInteger)uphFromDate:(NSDate *)startDate ToDate:(NSDate *)endDate;
{
    //TODO:uphFromDate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@ AND timestamp <= %@", startDate,endDate];
    NSFetchRequest *matchingLogsRequest = [NSFetchRequest fetchRequestWithEntityName:@"YieldReport"];
    [matchingLogsRequest setPredicate:predicate];
    NSArray* results = [[[SFDataCenter sharedDataCenter] managedObjectContext] executeFetchRequest:matchingLogsRequest error:nil];
    return results.count;
}

-(void)updateUph
{
    //FIXME:updateUph

    NSMutableArray *data=[NSMutableArray arrayWithCapacity:24];
    NSDateFormatter *df=[NSDateFormatter new];
    [df setDateFormat:@"MM-dd HH:mm" ];
    NSUInteger uph=0;
    NSTimeInterval interval = [_endDate timeIntervalSinceDate:_startDate];
    if ( interval> 3600) { //by hour
        for (int i=24; i>0; i--) {
            NSDate *sartTime = [NSDate dateWithTimeInterval:-3600*i sinceDate:_endDate];
            NSDate *endTime = [NSDate dateWithTimeInterval:-3600*(i-1) sinceDate:_endDate];
            uph =[self uphFromDate:sartTime ToDate:endTime];
            [data addObject:@{@"Name":[df stringFromDate:endTime],@"Output":@(uph)}];
        }
    }else{ //by  minutes
        int segements= 6;
        int time =interval < 360 ? 360 : interval / 6;
        for (int i=0; i<segements; i++) {
            NSDate *sartTime = [NSDate dateWithTimeInterval:time*(i - segements) sinceDate:_endDate];
            NSDate *endTime = [NSDate dateWithTimeInterval:time*(i -segements +1) sinceDate:_endDate];
            uph =[self uphFromDate:sartTime ToDate:endTime];
            [data addObject:@{@"Name":[df stringFromDate:endTime],@"Output":@(uph)}];
        }
    }
    
    _uphData =data;
    [uphView setTitle:[NSString stringWithFormat:@"Current UPH: %ld (pcs/hour)",uph]];
    [uphView setNeedsDisplay:YES];
    
}
-(void)updateYield
{
    //FIXME:updateYield
    _yielddata =[self recordsFormDate:_startDate ToDate:_endDate];
    
    if (_yielddata == nil) {
        return;
    }
    
    NSArray *passcounts=[_yielddata valueForKeyPath:@"PASS"];
    NSArray *failcounts=[_yielddata valueForKeyPath:@"FAIL"];
    NSArray *retestcounts=[_yielddata valueForKeyPath:@"RETEST"];
    __block NSInteger passTotal=0;
    __block NSInteger failTotal=0;
    __block NSInteger retestTotal=0;
    [passcounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {
            passTotal +=[obj integerValue];
        }
    }];
    [failcounts enumerateObjectsUsingBlock:^(id  obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {

        failTotal +=[obj integerValue];
        }
    }];
    [retestcounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSNumber class]]) {

        retestTotal +=[obj integerValue];
        }
    }];
    
    float yield=((float)passTotal/(passTotal+failTotal) )*100;
    float retestRate=((float)retestTotal/(passTotal+failTotal))*100;
    [yieldView setTitle:[NSString stringWithFormat:@"Yield:%.2f%% / RetestRate:%.2f%%",yield,retestRate]];
    
    [yieldView setNeedsDisplay:YES];
    

}

-(IBAction)searchDatabase:(id)sender;
{
    [sender setEnabled:NO];
    [self updateYield];
    [self updateUph];
    [_displayResults setArray:_searchedResults];
    [searchField setStringValue:@""];
    [resultView reloadData];
    [sender setEnabled:YES];
    
}
@end
