//
//  SFFlashViewController.m
//  CAMTOOL
//
//  Created by jifu on 11/12/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFFlashViewController.h"

@interface SFFlashViewController ()

@end

@implementation SFFlashViewController

- (NSString *)runCodecDebug:(NSArray *)arguments
{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progress startAnimation:self];

    });

    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath: [[NSBundle mainBundle] pathForResource:@"codec_debug" ofType:nil inDirectory:@"tools"]];
    
    [task setArguments: arguments];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    
    [task launch];
    [task waitUntilExit];
    
    NSData *data;
    data = [file readDataToEndOfFile];
    
    NSString *output;
    output = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_progress stopAnimation:self];
        
    });
    //int exitcode = [task terminationStatus];
    return output;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

        // Initialization code here.
    }
    return self;
}
-(void)awakeFromNib{
    NSString *hexPath= [[NSUserDefaults standardUserDefaults] objectForKey:@"CAM_HEX_FILE_PATH"];
    if (hexPath) {
        [_hexFilePath setStringValue:hexPath];
    }
}


- (void)openPanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    
}

- (IBAction)changeHexFilePathAction:(id)sender {
    
	NSOpenPanel *pp = [NSOpenPanel openPanel];
    [pp setAllowedFileTypes:@[@"hex"]];
    [pp beginSheetModalForWindow:[NSApp mainWindow] completionHandler:^(NSInteger result) {
        if (result == 1 ) {
            NSURL *url = [[pp URLs] objectAtIndex:0];
            [_hexFilePath setStringValue:[url path]];
            [_writeBtn setEnabled:YES];
            [[NSUserDefaults standardUserDefaults] setObject:[url path] forKey:@"CAM_HEX_FILE_PATH"];
        }
        
    }];
}

- (IBAction)eraseFlashAction:(id)sender {
    
    [_console setString:@"please wait for erasing..."];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_writeBtn setEnabled:NO];
            [_eraseBtn setEnabled:NO];
        });
        
        
        [_console setString:[self runCodecDebug:@[@"-m", @"pic",@"-o", @"erase"]]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_writeBtn setEnabled:YES];
            [_eraseBtn setEnabled:YES];
        });
    });
    
}

- (IBAction)writeFlashAction:(id)sender {
    

    [_console setString:@"please wait for writing..."];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_writeBtn setEnabled:NO];
            [_eraseBtn setEnabled:NO];
        });
        [_console setString:[self runCodecDebug:@[@"-m", @"pic",@"-o", @"write",@"-f",_hexFilePath.stringValue]]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_writeBtn setEnabled:YES];
            [_eraseBtn setEnabled:YES];
        });
    });
    
}
@end
