//
//  SFSlotView.m
//  CAMTOOL
//
//  Created by jifu on 12/23/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFSlotView.h"
#import "QREncoder.h"
#import "SFRecordWriter.h"
/*
@implementation ResultViewField

-(id)initWithIdentify:(NSString *)identify uid:(NSInteger)uid;
{
    if (self = [super init]) {
        _identify = identify;
        _uid = uid;
        _serialNumber = @"";
        _matrixBuildNumber =@"";
        _status = ResultViewClearStatus;
    }
    return self;
}

@end
*/
@interface SFSlotView()
{
    CGFloat _timeRectHight;
    CGFloat _timeRectWidth;
    CGFloat _qrview_and_textView_gap;
}

@end
@implementation SFSlotView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        _identify = @"NA";
        _uid = 0;
        _serialNumber = @"--";
        _status = ResultViewClearStatus;
        _qrView = nil;
        _ct = 0;
        _isSelected = NO;
        _carrierID = @"";
        _scanID = @"";
        _enable=YES;
        _slotState = @"IDLE";
        _ipAddress = @"127.0.0.1";
        _startedTimeStamp = 0;
        _timeRectHight = 25;
        _timeRectWidth = 80;
        _qrview_and_textView_gap = 10;
    }
    return self;
}
-(void)setStatus:(ResultViewStatus)status
{
    
   
    if (_status == ResultViewPendingStatus && status != ResultViewPendingStatus) {
        if (status == ResultViewPassStatus) {
            
            [[SFRecordWriter sharedLogWriter] addUUTRecord:_serialNumber result:SFUUTPassedResult slot:_identify startTime:[NSDate dateWithTimeIntervalSince1970:self.startedTimeStamp]];
            
        }else if (status == ResultViewFailedStatus){
            [[SFRecordWriter sharedLogWriter] addUUTRecord:_serialNumber result:SFUUTFailedResult slot:_identify startTime:[NSDate dateWithTimeIntervalSince1970:self.startedTimeStamp]];
        
        }else{
            
            [[SFRecordWriter sharedLogWriter] addUUTRecord:_serialNumber result:SFUUTAbortedResult slot:_identify startTime:[NSDate dateWithTimeIntervalSince1970:self.startedTimeStamp]];
            
        }
        
    }
    _status = status;
}

-(void)setSlotState:(NSString *)state;
{
    /*
     +----+---------------------------+
     | id | description               |
     +----+---------------------------+
     |  1 | PAIRED                    |
     |  2 | STARTING                  |
     |  3 | REJECTED                  |
     |  4 | EMPTY                     |
     |  5 | MISMATCHED_SERIAL_NUMBER  |
     |  7 | FAILED_NEW_SLOT           |
     |  8 | FAILED                    |
     |  9 | FAILED_RETRY              |
     | 10 | PASSED                    |
     | 11 | TESTING                   |
     | 12 | ABORTING                  |
     | 13 | ABORTED                   |
     | 14 | PAUSING                   |
     | 15 | PAUSED                    |
     | 16 | RESUMING                  |
     | 17 | IDLE                      |
     | 18 | REGISTERED                |
     | 23 | PASSING                   |
     | 24 | FAILING                   |
     | 25 | STARTED                   |
     | 26 | REJECTING                 |
     | 28 | REQUESTED_NEW_SLOT        |
     | 29 | RESETTING                 |
     | 30 | RESET                     |
     | 31 | REPORTING_UNKNOWN_UNIT    |
     | 32 | EXCEPTIONED               |
     | 33 | HELD_FOR_FAILURE_ANALYSIS |
     +----+---------------------------+
     
     */
    
    if ([state isEqualToString:@"PASSED"]) {
        [self setStatus:ResultViewPassStatus];
    }else if ([state isEqualToString:@"ABORTED"]){
        [self setStatus:ResultViewFailedStatus];
    }else if ([state isEqualToString:@"FAILED"]){
        [self setStatus:ResultViewFailedStatus];
        
    }else if ([state isEqualToString:@"TESTING"]){
        
        [self setStatus:ResultViewPendingStatus];
        

    }else if ([state isEqualToString:@"PAIRED"]){
        [self setStatus:ResultViewReadyStatus];
    }else{
        [self setStatus:ResultViewClearStatus];
    }
    _slotState = state;
    
}

-(NSString *)formatedCycleTimeValue:(NSInteger)ct
{
    ct = ct >= 24*3600 ? 0 : ct; // cycle more than a day ,as invalid value ,should be set to zero.
    UInt hour=0;
    UInt min=0;
    UInt second=0;
    if (ct >= 3600 ) {
        hour = (UInt)(ct / 3600);
        min = ((ct % 3600) / 60 ) ;
    }
    else if (ct >= 60){
        min =(UInt)(ct / 60);
    }
    second = ct % 60;
    
    NSString *h = [NSString stringWithFormat:@"%02i",hour];
    NSString *m = [NSString stringWithFormat:@"%02i",min];
    NSString *s = [NSString stringWithFormat:@"%02i",second];
    
    NSString *digitalString =[NSString stringWithFormat:@"%@:%@:%@",h,m,s];
    return digitalString;
}

-(void)_drawTextCellInRect:(NSRect)dirtyRect{
    CGFloat xEdge = 5.0,yEdge = 3;
    
    NSRect frame =NSMakeRect(dirtyRect.origin.x + xEdge, dirtyRect.origin.y +yEdge, dirtyRect.size.width - 2*xEdge, dirtyRect.size.height - 2 * yEdge);
    NSRect tagFrame,stringFrame;
    NSDivideRect(frame, &tagFrame, &stringFrame, 45, NSMinXEdge);
    
    NSBezierPath *path =[NSBezierPath bezierPathWithRoundedRect:frame xRadius:2 yRadius:2];
    NSColor *strokeColor = [NSColor grayColor];
    [path setLineWidth:2];
    if (_isSelected == YES) {
        strokeColor = [NSColor blueColor];
        [path setLineWidth:4];

    }
    
    NSColor *_textCellBackgroundColor = nil;
    switch (_status) {
        case ResultViewClearStatus:_textCellBackgroundColor = [NSColor whiteColor];break;
        case ResultViewFailedStatus:_textCellBackgroundColor = [NSColor redColor];break;
        case ResultViewPassStatus:_textCellBackgroundColor = [NSColor greenColor];break;
        case ResultViewPendingStatus:_textCellBackgroundColor = [NSColor yellowColor];break;
        case ResultViewReadyStatus:_textCellBackgroundColor = [NSColor cyanColor];break;

        default:break;
    }
    
    //防止出现有时测试结果也会刷新成白色，不是PASS或FAIL的绿红色
    if ([_slotState isEqualToString:@"PASSED"]) {
        _textCellBackgroundColor = [NSColor greenColor];
    }else if ([_slotState isEqualToString:@"FAILED"]){
        _textCellBackgroundColor = [NSColor redColor];
    }
    
    //if slot is disabled,
    if (self.enable == NO) {
        _serialNumber = @"DISABLED";
        _textCellBackgroundColor = [NSColor lightGrayColor];
    }
    
    [_textCellBackgroundColor setFill];
    [strokeColor setStroke];
    [path fill];
    [path stroke];
    
    //draw text value ,serial number
    NSFont *font = [NSFont fontWithName:@"Arial" size:24];

    //fixed <null> string issue. use [_serialNumber description] replaced _serialNumber.
    NSAttributedString *attStr =[[NSAttributedString alloc] initWithString:[_serialNumber description] attributes:@{NSFontAttributeName:font}];
    NSSize strsize = [attStr size];
    //
   
    CGFloat x = (stringFrame.size.width - strsize.width)/2 < 0?0:(stringFrame.size.width - strsize.width)/2;
    CGFloat y = (stringFrame.size.height - strsize.height)/2 <0 ? 0 :(stringFrame.size.height - strsize.height)/2;
    strsize.width = strsize.width > stringFrame.size.width ? stringFrame.size.width : strsize.width;
    strsize.height = strsize.height > stringFrame.size.height ? stringFrame.size.height : strsize.height;
    
    NSPoint textDrawPoint =NSMakePoint(stringFrame.origin.x + x, stringFrame.origin.y + y);
    
    [attStr drawInRect:NSMakeRect(textDrawPoint.x, textDrawPoint.y, strsize.width, strsize.height)];
    //draw slot state

    NSAttributedString *stateStr =[[NSAttributedString alloc] initWithString:_slotState attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Arial" size:12],NSForegroundColorAttributeName:[NSColor grayColor]}];

    NSSize stateSize = [stateStr size];
    
    NSPoint sDrawPoint =NSMakePoint(stringFrame.origin.x + stringFrame.size.width - stateSize.width -5, stringFrame.origin.y+2);
    [stateStr drawInRect:NSMakeRect(sDrawPoint.x, sDrawPoint.y, stateSize.width, stateSize.height)];

    //draw slot's IP address
    NSAttributedString *ipAddress =[[NSAttributedString alloc] initWithString:_ipAddress attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Arial" size:12],NSForegroundColorAttributeName:[NSColor grayColor]}];
    
    NSSize ipSize = [ipAddress size];
    
    NSPoint ipDrawPoint =NSMakePoint(stringFrame.origin.x + 5, stringFrame.origin.y+2);
    [ipAddress drawInRect:NSMakeRect(ipDrawPoint.x, ipDrawPoint.y, ipSize.width, ipSize.height)];
    
    
    
    //draw identify/uid value
    [strokeColor setFill];
    NSRectFill(tagFrame);
    font = [NSFont fontWithName:@"Arial" size:14];
    NSAttributedString *attNumber =[[NSAttributedString alloc] initWithString:_identify attributes:@{NSFontAttributeName:font,NSForegroundColorAttributeName:[NSColor whiteColor]}];
    strsize = [attNumber size];
    textDrawPoint =NSMakePoint(tagFrame.origin.x + (tagFrame.size.width - strsize.width)/2, tagFrame.origin.y + (tagFrame.size.height - strsize.height)/2);
    [attNumber drawInRect:NSMakeRect(textDrawPoint.x, textDrawPoint.y, strsize.width, strsize.height) ];
}

-(void)drawCarrierIDQRcodeInRect:(NSRect)dirtyRect;
{
    if (_qrView == nil && [_scanID isNotEqualTo:@""]) {
        _qrView =[[NSImageView alloc] initWithFrame:dirtyRect];
        [_qrView setImageScaling:NSImageScaleProportionallyUpOrDown];
        NSImage *qr= [QREncoder encode:_scanID size:2 correctionLevel:QRCorrectionLevelMedium];
        [_qrView setImage:qr];
        [self addSubview:_qrView];
        
        if (_enable == NO ) {
            [_qrView setAlphaValue:0.3];
        }
        
    }
}

-(void)drawCycleTime:(NSString *)timeStringValue InRect:(NSRect)dirtyRect;
{
    //draw text value
    NSAttributedString *attStr =[[NSAttributedString alloc] initWithString:timeStringValue attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Arial" size:15],NSForegroundColorAttributeName:[NSColor grayColor]}];
    NSSize strsize = [attStr size];
    //
    CGFloat x = (dirtyRect.size.width - strsize.width)/2 < 0?0:(dirtyRect.size.width - strsize.width)/2;
    CGFloat y = (dirtyRect.size.height - strsize.height)/2 <0 ? 0 :(dirtyRect.size.height - strsize.height)/2;
    strsize.width = strsize.width > dirtyRect.size.width ? dirtyRect.size.width : strsize.width;
    strsize.height = strsize.height > dirtyRect.size.height ? dirtyRect.size.height : strsize.height;
    
    NSPoint textDrawPoint =NSMakePoint(dirtyRect.origin.x + x, dirtyRect.origin.y + y);
    
    [attStr drawInRect:NSMakeRect(textDrawPoint.x, textDrawPoint.y, strsize.width, strsize.height)];
}

-(void)removeFromSuperview{
   // [_qrView removeFromSuperview];
    [super removeFromSuperview];
    
}

-(void)setClearStatus;
{
    _serialNumber = @"--";
    _status = ResultViewClearStatus;
    _isSelected = NO;
    _startedTimeStamp = 0;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];

    [[NSColor whiteColor] setFill];
    NSRectFill(dirtyRect);
    CGFloat slotHigh = dirtyRect.size.height * 0.85;
    CGFloat qr_side_length = dirtyRect.size.height * 0.75;
    CGFloat textAreaWidth=dirtyRect.size.width - qr_side_length - _qrview_and_textView_gap;

    NSSize qrSize=NSMakeSize(qr_side_length, qr_side_length);
    NSRect qrRect = NSMakeRect(dirtyRect.origin.x , dirtyRect.origin.y + (slotHigh - qrSize.height) /2 , qrSize.width, qrSize.height);
    [_qrView setFrame:qrRect];
    [self drawCarrierIDQRcodeInRect:qrRect];

    NSRect snRect =NSMakeRect(qrRect.origin.x + qrRect.size.width + _qrview_and_textView_gap, dirtyRect.origin.y, textAreaWidth, slotHigh);
    [self _drawTextCellInRect:snRect];
    
   // NSRect cycleTimeRect =NSMakeRect(snRect.origin.x + snRect.size.width + 20, snRect.origin.y, 100, slotHigh);

    NSRect cycleTimeRect =NSMakeRect(snRect.origin.x + snRect.size.width - _timeRectWidth, snRect.origin.y + snRect.size.height - _timeRectHight, _timeRectWidth, _timeRectHight);
    
    
    [self drawCycleTime:[self formatedCycleTimeValue:_ct] InRect:cycleTimeRect];
    // Drawing code here.
}

@end
