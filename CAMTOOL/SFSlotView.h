//
//  SFSlotView.h
//  CAMTOOL
//
//  Created by jifu on 12/23/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>



typedef enum _ResultViewStatus:int {
    
    ResultViewPassStatus = 0,
    ResultViewFailedStatus =1,
    ResultViewPendingStatus = 1 << 1,  // Uint under testing
    ResultViewClearStatus = 1<< 2,
    ResultViewReadyStatus = 1 << 3,  // Carrier and UUT paired
    
}ResultViewStatus;



/*
@interface ResultViewField : NSObject

@property(assign)NSInteger uid;
@property(copy)NSString *serialNumber;
@property(copy)NSString *matrixBuildNumber;
@property(copy)NSString *identify;
@property(assign)ResultViewStatus status;

-(id)initWithIdentify:(NSString *)identify uid:(NSInteger)uid;
@end
*/
@interface SFSlotView : NSView
{
    NSImageView *_qrView;

}
@property(copy,nonatomic) NSString *slotState; //raw status.
@property(assign,nonatomic)ResultViewStatus status;
@property(copy)NSString *serialNumber;
@property(copy)NSString *carrierID;
@property(copy)NSString *scanID; //scan id is also the carrier id that user defined in plist file.
@property(copy)NSString *ipAddress; // cam board's ip address.

@property(assign)NSInteger uid;
@property(copy)NSString *identify;
@property(assign)NSUInteger ct; // cycle time.
@property(assign)BOOL isSelected;
@property(assign)BOOL enable;
@property(assign)NSTimeInterval startedTimeStamp;

-(void)setClearStatus;
//-(void)setSlotState:(NSString *)state;
@end
