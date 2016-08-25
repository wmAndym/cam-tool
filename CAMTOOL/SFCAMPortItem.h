//
//  SFCAMPortItem.h
//  CAMTOOL
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SFCAMPortItem : NSObject
@property(copy)NSString *signalName;
@property(copy)NSString *portName;
@property(copy)NSString *portType;
@property(copy)NSString *portValue;
@property(copy)NSString *valueImageName;

+(instancetype)portItemWithName:(NSString *)name
                           type:(NSString *)type
                          value:(NSString *)value
                         signal:(NSString*)signal;
@end
