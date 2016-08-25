//
//  SFLogViewController.m
//  CAMTOOL
//
//  Created by jifu on 1/16/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFLogViewController.h"
#import "SFDataCenter.h"
#import "SFAuthenticator.h"
#import "SFRecordWriter.h"
#import "SFCommonFounction.h"
@interface SFLogViewController ()
{
    const NSArray *messageTypeList ;

}
@property (weak) IBOutlet NSTableView *logTableView;

@end

@implementation SFLogViewController
-(void)destroyController{
    [super destroyController];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)search:(id)sender {
   NSPredicate *predicate_date = [NSPredicate predicateWithFormat:@"timestamp >= %@ AND timestamp <= %@", _startDate,_endDate];
    NSFetchRequest *matchingLogsRequest = [NSFetchRequest fetchRequestWithEntityName:@"SystemLogs"];
    [matchingLogsRequest setPredicate:predicate_date];
    
    
    NSArray * results = [[[SFDataCenter sharedDataCenter] managedObjectContext] executeFetchRequest:matchingLogsRequest error:nil];
    if (!results) {
        return;
    }
    [self setLogs:results];
    [_logTableView reloadData];
    
}
-(void)awakeFromNib{

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChangedNotification:) name:SFUserChangedNotification object:nil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        [self setCanOperateDB:[[SFAuthenticator sharedAutheticator] userLevel] == 0];
        messageTypeList = @[@"Information",@"Warning",@"Error"];
        // Do view setup here.
        
        NSDate *endDate = [NSDate date];
        NSTimeInterval timeInterval= [endDate timeIntervalSinceReferenceDate];
        timeInterval -=3600*24;
        NSDate *beginDate = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
        
        [self setStartDate:beginDate];
        [self setEndDate:endDate];
        [self search:nil];

    }
    return self;
}


#pragma mark - NSTableViewDataSource

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.logs.count;
}

#pragma mark - NSTableViewDelegate

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    
    SystemLogs *log = self.logs[row];
    
    if ([identifier isEqualToString:@"message"]) {
        cellView.textField.stringValue = log.message;
    }
    else if ([identifier isEqualToString:@"type"]) {
        NSUInteger idx = log.type.unsignedIntegerValue > 2 ? 2 : log.type.unsignedIntegerValue;
        cellView.textField.objectValue = messageTypeList[idx];
    }
    else if ([identifier isEqualToString:@"time"]) {
        cellView.textField.objectValue = log.timestamp;
    }else{
        cellView.textField.objectValue = @(row+1);

    }
    //set background color
    if (log.type.integerValue == SFLogTypeWarning) {
        [[cellView textField] setDrawsBackground:YES];
        cellView.textField.backgroundColor = [NSColor yellowColor];
    }else if (log.type.integerValue == SFLogTypeError){
        [[cellView textField] setDrawsBackground:YES];
        cellView.textField.backgroundColor = [NSColor redColor];
    }else{
        [[cellView textField] setDrawsBackground:NO];

    }
    
    return cellView;
}

-(void)userChangedNotification:(NSNotification*)notification
{
    [self setCanOperateDB:[[SFAuthenticator sharedAutheticator] userLevel] == 0];
}

- (IBAction)export:(id)sender {
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    NSDateFormatter *df=[NSDateFormatter new];
    [df setDateFormat:@"MMddHHmmss"];
    
    [savePanel setNameFieldStringValue:[NSString stringWithFormat:@"sifo_records_%@.csv",[df stringFromDate:[NSDate date]]]];
    [savePanel beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        if (result ==NSOKButton) {
            NSString *path_csv =[[savePanel URL] path];
            
            NSURL *storeURL =[[[SFDataCenter sharedDataCenter] applicationDocumentsDirectory]URLByAppendingPathComponent:@"SiFOCoreData.db"];
            NSString *path = [storeURL path];
            NSString *csvData = [SFCommonFounction executeCmd:@"/usr/bin/sqlite3" withArguments:@[@"-header",@"-csv",path,@"select * from ZSYSTEMLOGS;"]];
            [csvData writeToFile:path_csv atomically:YES encoding:NSUTF8StringEncoding error:nil];

        }
        
    }];

    
}

- (IBAction)delete:(id)sender {
    NSAlert *alert = [NSAlert alertWithMessageText:@"Delete the record?"
                                     defaultButton:@"OK" alternateButton:@"Cancel"
                                       otherButton:nil informativeTextWithFormat:
                      @"Deleted records cannot be restored."];
    if ([alert runModal] != NSOKButton) {
        // OK clicked, delete the record
        return;
    }
    
    [[self logs] enumerateObjectsUsingBlock:^(SystemLogs *  obj, NSUInteger idx, BOOL *  stop) {
        [[[SFDataCenter sharedDataCenter] managedObjectContext] deleteObject:obj];
    }];
    
    [self setLogs:nil];
    [[SFRecordWriter sharedLogWriter] insertLog:[NSString stringWithFormat:@"%@ delete all records",[[SFAuthenticator sharedAutheticator] user]] Type:SFLogTypeWarning];
    [_logTableView reloadData];
}

@end
