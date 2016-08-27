//
//  SFPairViewController.h
//  CAMTOOL
//
//  Created by jifu on 12/30/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SFViewController.h"

@interface SFPairViewController : SFViewController{
     NSTextField *_inputArea;
    NSTimer *_updateTextInputTimer;
}
@property (weak) IBOutlet NSTextField *slotNumberField;
@property (weak) IBOutlet NSTextField *carrierIDField;
@property (weak) IBOutlet NSTextField *camAddressField;

@property (weak) IBOutlet NSButton *clearImageView;
@property (weak) IBOutlet NSButton *unpairImageView;
@property (weak) IBOutlet NSButton *pairImageView;
@property (weak) IBOutlet NSTextField *prompt;

@property(assign,nonatomic)BOOL hiddenPairImageView;
@property(assign,nonatomic)BOOL hiddenUnpairImageView;
@property(assign,nonatomic)BOOL hiddenClearImageView;
@end
