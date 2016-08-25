//
//  NavigationController.m
//  CAM
//
//  Created by jifu on 11/13/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "NavigationController.h"
#import "SFStatusView.h"
@implementation NavigationController;

-(instancetype)init
{
    self = [super init];
    
    if (self ) {
        _rootItems=nil;
    }
    return self;
}

+(NavigationController *)sharedController;

{
    static NavigationController *nc;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        nc = [NavigationController new];
    });
    return nc;
}

-(void)setDefautSelection;
{
   
    [_navigationView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];

}

-(void)setDelegate:(id)delegate;
{
    _delegate = delegate;
}

-(void)setNavigationOutlineView:(NSOutlineView *)view
{
    _navigationView=view;
    [_navigationView setDataSource:self];
    [_navigationView setDelegate:self];
}

-(void)reloadNavigationView
{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        _rootItems=[NavigationItem rootItems];
        [_navigationView reloadData];
        [_navigationView setNeedsDisplay:YES];
    });

}

-(NSArray *)rootItems;
{
    return _rootItems;
}

-(NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    
    if (item ==nil) {
        return [_rootItems count];
    }
    return [[item children] count];
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
{
    if (item ==nil) {
        return [_rootItems objectAtIndex:index];
    }
    return [[item children] objectAtIndex:index];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
{
    return ![item isLeaf];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;
{
    return [item name];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    
    if ([outlineView parentForItem:item] == nil) {
        return YES;
    } else {
        return NO;
    }
}

-(NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    if ([outlineView parentForItem:item] == nil) {
        NSTextField *result = [outlineView makeViewWithIdentifier:@"HeaderTextField" owner:self];
        NSString *value = [[item name] uppercaseString];
        [result setStringValue:value];
        return result;
    }
    else {
        NSTableCellView *result = [outlineView makeViewWithIdentifier:@"MainCell" owner:self];
        result.textField.stringValue = [item name];
        NSString *icon = [item iconName];
        if (icon !=nil && [icon length] >0) {
            result.imageView.image=[NSImage imageNamed:icon];
            
        }else{
            result.imageView.image=[NSImage imageNamed:NSImageNameIconViewTemplate];
        }
        return result;

    }
}

-(BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    NavigationItem *selectedItem=item;

    if (selectedItem !=nil && [_delegate respondsToSelector:@selector(navigationView:shouldSelectNavigationItem:)]) {

        return [_delegate navigationView:_navigationView shouldSelectNavigationItem:item];
    }
    return NO;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
  
    NSInteger rowIndex = [_navigationView selectedRow];
    NavigationItem *selectedItem=[_navigationView itemAtRow:rowIndex];
    NSString *itemName=[selectedItem name];
    NSString *nibName=[selectedItem nibName];
    NSString *owner=[selectedItem owner];
    NSNumber *minorUserLevel =[selectedItem minorUserLevel];
   if (itemName !=nil && nibName !=nil && _delegate !=nil && [_delegate respondsToSelector:@selector(navigationViewSelectionDidChange:)]) {
       NSDictionary *userInfo=@{@"SELECTED_ITEM_NAME":itemName,@"SELECTED_NIB_NAME":nibName,@"OWNER_NAME":owner,@"USER_LEVEL":minorUserLevel};
       NSNotification *notification=[NSNotification notificationWithName:@"NavigationViewSelectionDidChanged" object:self userInfo:userInfo];
       [_delegate navigationViewSelectionDidChange:notification];
    }
    
    //post notification after navigation item selection  did changed.
    
}

@end
