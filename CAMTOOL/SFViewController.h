//
//  SFViewController.h
//  CAMTOOL
//
//  Created by jifu on 11/25/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFAccessDeniedView.h"

@interface SFViewController : NSViewController
@property(assign)NSUInteger accessLevel;
-(void)destroyController;
-(BOOL)shouldDestroyController;
-(BOOL)canBeAccessForUserLevel:(NSUInteger)userLevel;
@end
