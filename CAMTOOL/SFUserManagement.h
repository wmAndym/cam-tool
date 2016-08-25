//
//  SFUserManagement.h
//  CAMTOOL
//
//  Created by jifu on 1/15/16.
//  Copyright © 2016 sifo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SFUserManagement : NSWindowController<NSWindowDelegate>
{
    IBOutlet NSTableView		*myTableView;
    IBOutlet NSArrayController	*myContentArray;
    
    IBOutlet NSForm				*myFormFields;
    
    IBOutlet NSButton			*addButton;
    IBOutlet NSButton			*removeButton;
    

}
@property(retain)NSMutableArray *accounts;

@end
