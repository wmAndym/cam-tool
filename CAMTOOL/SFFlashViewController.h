//
//  SFFlashViewController.h
//  CAMTOOL
//
//  Created by jifu on 11/12/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFViewController.h"

@interface SFFlashViewController : SFViewController
@property (weak) IBOutlet NSTextField *hexFilePath;
@property (weak) IBOutlet NSButton *changeBtn;
@property (weak) IBOutlet NSButton *eraseBtn;
@property (weak) IBOutlet NSButton *writeBtn;
@property (weak) IBOutlet NSProgressIndicator *progress;
@property (unsafe_unretained) IBOutlet NSTextView *console;
- (IBAction)changeHexFilePathAction:(id)sender;
- (IBAction)eraseFlashAction:(id)sender;
- (IBAction)writeFlashAction:(id)sender;

@end
