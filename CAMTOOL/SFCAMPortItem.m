//
//  SFCAMPortItem.m
//  CAMTOOL
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFCAMPortItem.h"

@implementation SFCAMPortItem

+(instancetype)portItemWithName:(NSString *)name
                           type:(NSString *)type
                          value:(NSString *)value
                         signal:(NSString*)signal;
{
   
    SFCAMPortItem *obj =  [SFCAMPortItem new];
    
    [obj setPortName:name];
    [obj setPortType:type];
    [obj setPortValue:value];
    [obj setSignalName:signal];
    if ([value isEqualToString:@"0"]) {
        [obj setValueImageName:@"ledgray.png"];
    }else if ([value isEqualToString:@"1"]){
        [obj setValueImageName:@"ledgreen.png"];

    }else{
        [obj setValueImageName:@"ledred.png"];
    }
    return obj;
}


@end
