//
//  SFMojoViewController.m
//  CAMTOOL
//
//  Created by jifu on 2/23/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import "SFMojoViewController.h"
#include "rs232.h"

#include <CoreFoundation/CoreFoundation.h>

#include <IOKit/IOKitLib.h>
#include <IOKit/serial/IOSerialKeys.h>
#include <IOKit/IOBSD.h>

static kern_return_t findAllSerailPortObjects(io_iterator_t *matchingServices)
{
    kern_return_t       kernResult;
    mach_port_t         masterPort;
    CFMutableDictionaryRef  classesToMatch;
    
    kernResult = IOMasterPort(MACH_PORT_NULL, &masterPort);
    if (KERN_SUCCESS != kernResult)
    {
        printf("IOMasterPort returned %d\n", kernResult);
        goto exit;
    }
    
    // Serial devices are instances of class IOSerialBSDClient.
    classesToMatch = IOServiceMatching(kIOSerialBSDServiceValue);
    if (classesToMatch == NULL)
    {
        printf("IOServiceMatching returned a NULL dictionary.\n");
    }
    else {
        CFDictionarySetValue(classesToMatch,
                             CFSTR(kIOSerialBSDTypeKey),
                             CFSTR(kIOSerialBSDRS232Type));
        
        // Each serial device object has a property with key
        // kIOSerialBSDTypeKey and a value that is one of
        // kIOSerialBSDAllTypes, kIOSerialBSDModemType,
        // or kIOSerialBSDRS232Type. You can change the
        // matching dictionary to find other types of serial
        // devices by changing the last parameter in the above call
        // to CFDictionarySetValue.
    }
    
    kernResult = IOServiceGetMatchingServices(masterPort, classesToMatch, matchingServices);
    if (KERN_SUCCESS != kernResult)
    {
        printf("IOServiceGetMatchingServices returned %d\n", kernResult);
        goto exit;
    }
    
exit:
    return kernResult;
}


@interface SFMojoViewController ()
{
    NSString *_port;
    struct rs232_port_t *p;
    unsigned int timeout;
    dispatch_source_t fileSource;
    NSMutableString *read_buffer;
    NSString *enterKeyEmulation;


}
@property (weak) IBOutlet NSButton *isLocalEcho;
@property (weak) IBOutlet NSPopUpButton *portSelection;
@property (weak) IBOutlet NSPopUpButton *baudrateSelection;
@property (weak) IBOutlet NSPopUpButton *dataBitsSelection;
@property (weak) IBOutlet NSPopUpButton *paritySelection;
@property (weak) IBOutlet NSPopUpButton *stopBitsSelection;
@property (weak) IBOutlet NSButton *sendBtn;
@property (weak) IBOutlet NSButton *connectBtn;
@property (weak) IBOutlet NSButton *rescanBtn;
@property (weak) IBOutlet NSButton *loopbackBtn;
@property (weak) IBOutlet NSTextField *sendTextField;
@property (unsafe_unretained) IBOutlet NSTextView *consoleView;
@end

@implementation SFMojoViewController

-(NSArray *)showAllSerialPortFileDescription

{
    kern_return_t   kernResult = KERN_FAILURE;
    
    io_iterator_t   serialPortIterator;
    
    kernResult = findAllSerailPortObjects(&serialPortIterator);
    
    if (kernResult == KERN_FAILURE) {
        IOObjectRelease(serialPortIterator);    // Release the iterator.
        return nil;
    }
    
    io_object_t portService;
    char deviceFilePath[MAXPATHLEN];
    NSMutableArray *fileDescpritions=[NSMutableArray array];
    
    while ((portService = IOIteratorNext(serialPortIterator)))
    {
        *deviceFilePath = '\0';

        CFTypeRef   deviceFilePathAsCFString;
        
        // Get the callout device's path (/dev/cu.xxxxx).
        // The callout device should almost always be
        // used. You would use the dialin device (/dev/tty.xxxxx) when
        // monitoring a serial port for
        // incoming calls, for example, a fax listener.
        
        deviceFilePathAsCFString = IORegistryEntryCreateCFProperty(portService,
                                                                   CFSTR(kIODialinDeviceKey),
                                                                   //CFSTR(kIOCalloutDeviceKey),
                                                                   kCFAllocatorDefault,
                                                                   0);
        if (deviceFilePathAsCFString)
        {
            Boolean result;
            
            // Convert the path from a CFString to a NULL-terminated C string
            // for use with the POSIX open() call.
            
            result = CFStringGetCString(deviceFilePathAsCFString,
                                        deviceFilePath,
                                        MAXPATHLEN,
                                        kCFStringEncodingASCII);
            CFRelease(deviceFilePathAsCFString);
            
            if (result)
            {
                printf("BSD path: %s", deviceFilePath);
                kernResult = KERN_SUCCESS;
                [fileDescpritions addObject:[NSString stringWithUTF8String:deviceFilePath]];
            }
        }
        
        printf("\n");
        
        // Release the io_service_t now that we are done with it.
        
        (void) IOObjectRelease(portService);
    }
    IOObjectRelease(serialPortIterator);    // Release the iterator.
    return fileDescpritions;
    
}

-(void)destroyController
{
    
    [super destroyController];
    
    rs232_close(p);
    rs232_end(p);
    
}
-(void)awakeFromNib{
    [_sendBtn setEnabled:NO];
    [_loopbackBtn setEnabled:NO];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _ports = [self showAllSerialPortFileDescription];
        p =  rs232_init();
        timeout = 10;
        read_buffer = [NSMutableString string];
        enterKeyEmulation = @"\r\n";
    }
    
    return self;
}
-(void)writeString:(NSString *)string
{
    unsigned int len_writen=0;
    const  char *str = [[string stringByAppendingString:enterKeyEmulation] UTF8String];
    unsigned int ret = rs232_write(p,(const unsigned char *)str, (unsigned int)strlen(str),&len_writen);
    if (ret == RS232_ERR_NOERROR) {
        [_sendTextField setStringValue:@""];
    }
}

-(NSString *)read
{
    unsigned char * buf;
    unsigned int buf_len=1024;
    unsigned int read_len=0;
    unsigned int ret = rs232_read_timeout(p, buf, buf_len, &read_len, timeout);
    
    if (ret != RS232_ERR_NOERROR) {
        printf("==>%s\n",rs232_strerror(ret));
    }else{
        printf("==>%s\n",buf);
    }
    return nil;
}

-(void)connectPort:(NSString *)port;
{
     rs232_set_device(p, [port cStringUsingEncoding:NSUTF8StringEncoding]);
     unsigned int ret =  rs232_open(p);
    if (ret == RS232_ERR_NOERROR) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_sendBtn setEnabled:YES];
            [_loopbackBtn setEnabled:YES];

            [_connectBtn setTitle:@"disconnect"];
            [_portSelection setEnabled:NO];
            /*
            [_baudrateSelection setEnabled:NO];
            [_dataBitsSelection setEnabled:NO];
            [_paritySelection setEnabled:NO];
            [_stopBitsSelection setEnabled:NO];
             */
            [_rescanBtn setEnabled:NO];
            [_loopbackBtn setEnabled:YES];

            
        });
        
        [self setBaudrate:_baudrateSelection];
        [self setParity:_paritySelection];
        [self setDataBits:_dataBitsSelection];
        [self setStopBits:_stopBitsSelection];
        
        unsigned infd = rs232_fd(p);
        if (fcntl(infd, F_SETFL,O_NONBLOCK) != 0) {
            NSLog(@"Set F_SETFL,O_NONBLOCK failed!");
            return;
        }
        fileSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_READ, infd, 0, dispatch_queue_create("read source queue",NULL));
        
        dispatch_source_set_event_handler( fileSource, ^{
            char buffer[256];
            memset(buffer, 0, 256);
            size_t estimated = dispatch_source_get_data(fileSource);
           // printf("Estimated bytes available: %ld\n", estimated);
            ssize_t actual = read(infd, buffer, sizeof(buffer));
            if (actual == -1) {
                if (errno != EAGAIN) {
                    perror("read");
                    //exit(-1);
                }
            } else {
                
                [read_buffer appendFormat:@"%s",buffer];

                if  (estimated>actual) {
                   // printf("  bytes read: %ld\n", actual);
                } else {
                    // end of file has been reached.
                    //printf("  last bytes read: %ld\n", actual);

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[_consoleView textStorage] setAttributedString:[[NSAttributedString alloc] initWithString:[read_buffer copy]]];
                        [_consoleView scrollRangeToVisible:NSMakeRange([[_consoleView string] length], 0)];
                        [_consoleView setNeedsDisplay:YES];
                    });
                    
                }
            }
        });
        
        dispatch_source_set_cancel_handler( fileSource, ^{
        // release all our associated dispatch data structures
        //  dispatch_release(fileSource);
        // dispatch_release(dispatch_get_current_queue());
        // close the file descriptor because we are done reading it
            rs232_close(p);
            
         });
        
        dispatch_resume(fileSource);
        
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSRunAlertPanel(@"Open failed", @"Open serial port failed!", @"OK", nil, nil);
        });
        
    }
    

}

-(void)disconnectPort:(NSString *)port;
{
    dispatch_source_cancel(fileSource);
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [_connectBtn setTitle:@"connect"];
        
        [_portSelection setEnabled:YES];
        /*
        [_baudrateSelection setEnabled:YES];
        [_dataBitsSelection setEnabled:YES];
        [_paritySelection setEnabled:YES];
        [_stopBitsSelection setEnabled:YES];
        */
        
        [_rescanBtn setEnabled:YES];
        [_loopbackBtn setEnabled:NO];
        
        [_sendBtn setEnabled:NO];
        [_loopbackBtn setEnabled:NO];
    
    });

}

- (IBAction)loopbackTest:(id)sender {
    NSString *loopbackStrings = @"abcdefghijklmnopqrstuvwxyz1234567890~!@#$%^&*()_+{};',./:\"<>?";
    [read_buffer setString:@""];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [_sendTextField setStringValue:loopbackStrings];
    });
    
    [self writeString:loopbackStrings];
    [NSThread sleepForTimeInterval:1];

    dispatch_async(dispatch_get_main_queue(), ^{
        NSAttributedString *resultString=nil;
        if ([read_buffer isEqualToString:[loopbackStrings stringByAppendingString:enterKeyEmulation]]) {
            
            resultString = [[NSAttributedString alloc] initWithString:@"\n========\nPASSED\n========\n" attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Arial" size:16],NSForegroundColorAttributeName:[NSColor greenColor]}];


        }else{
            resultString = [[NSAttributedString alloc] initWithString:@"\n========\nFAILED\n========\n" attributes:@{NSFontAttributeName:[NSFont fontWithName:@"Arial" size:16],NSForegroundColorAttributeName:[NSColor redColor]}];

        }
        
        [[_consoleView textStorage] appendAttributedString:resultString ];
        [_consoleView scrollRangeToVisible:NSMakeRange([[_consoleView string] length], 0)];
        [_consoleView setNeedsDisplay:YES];
    });

}
- (IBAction)scanSerialPort:(id)sender {
    
    [self setPorts: [self showAllSerialPortFileDescription]];

}

- (IBAction)send:(id)sender {
    NSInteger state =[_isLocalEcho state];
    NSString *str = [_sendTextField stringValue];
    
    if (state == 1) {
        [read_buffer appendString:[str stringByAppendingString:@"\n"]];
        [NSThread sleepForTimeInterval:0.1];

    }
    [self writeString:str];
    
    
    [NSThread sleepForTimeInterval:0.2];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[_consoleView textStorage] setAttributedString:[[NSAttributedString alloc] initWithString:[read_buffer copy]]];
        [_consoleView scrollRangeToVisible:NSMakeRange([[_consoleView string] length], 0)];
        [_consoleView setNeedsDisplay:YES];
    });

}

- (IBAction)connect:(id)sender {
    _port = [[_portSelection selectedItem] title];
    
    if ([[sender title] isEqualToString:@"connect"]) {
        
        [self connectPort:_port];
        
    }
    else if ([[sender title] isEqualToString:@"disconnect"])
    {
 
        
        [self disconnectPort:_port];
        

        
    }
}

- (IBAction)setEnterKeyEmulation:(id)sender {
    NSMenuItem *item =[sender selectedItem];
    switch ([item tag]) {
        
        case 0:
            enterKeyEmulation = @"\r\n";
            break;
        case 1:
            enterKeyEmulation = @"\r";
            break;
        case 2:
            enterKeyEmulation = @"\n";
            break;
        default:
            break;
    }
    
}

- (IBAction)setStopBits:(id)sender {
    
    NSMenuItem *item =[sender selectedItem];
    switch ([item tag]) {
        
        case 0:
            rs232_set_stop(p, RS232_STOP_1);
            break;
        case 1:
            rs232_set_stop(p, RS232_STOP_MAX);
            break;
        case 2:
            rs232_set_stop(p, RS232_STOP_2);
            break;
        default:
            break;
    }
}

- (IBAction)setParity:(id)sender {
    

    
    NSMenuItem *item =[sender selectedItem];
    switch ([item tag]) {
        case 0:
            rs232_set_parity(p, RS232_PARITY_NONE);
            break;
        case 1:
            rs232_set_parity(p, RS232_PARITY_ODD);
            break;
        case 2:
            rs232_set_parity(p, RS232_PARITY_EVEN);
            break;
        default:
            break;
    }
    
}

- (IBAction)setDataBits:(id)sender {
    NSMenuItem *item =[sender selectedItem];
    switch ([item tag]) {
        case 3:
            rs232_set_data(p, RS232_DATA_8);
            break;
        case 2:
            rs232_set_data(p, RS232_DATA_7);
            break;
        case 1:
            rs232_set_data(p, RS232_DATA_6);
            
            break;
        case 0:
            rs232_set_data(p, RS232_DATA_5);
            
            break;
        default:
            break;
    }
    
}

- (IBAction)setBaudrate:(id)sender {
    NSMenuItem *item =[sender selectedItem];
    unsigned int ret = RS232_ERR_NOERROR;
    switch ([item tag]) {
        case 0:
            ret=rs232_set_baud(p, RS232_BAUD_9600);
            break;
        case 1:
            ret=rs232_set_baud(p, B14400);
            break;
        case 2:
            ret=rs232_set_baud(p, RS232_BAUD_19200);
            
            break;
            
        case 3:
            ret=rs232_set_baud(p, B28800);
            break;
        case 4:
            ret=rs232_set_baud(p, RS232_BAUD_38400);
            break;
            
        case 5:
            ret=rs232_set_baud(p, RS232_BAUD_57600);
            break;
        case 6:
            ret=rs232_set_baud(p, RS232_BAUD_115200);
            break;
            
        case 7:
            ret=rs232_set_baud(p, B230400);
            break;
        case 8:
            ret=rs232_set_baud(p, RS232_BAUD_1250000);
            break;
        default:
            break;
    }
    
    
}

@end
