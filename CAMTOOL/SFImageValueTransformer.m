//
//  SFImageValueTransformer.m
//  CAMTOOL
//
//  Created by jifu on 11/16/15.
//  Copyright (c) 2015 sifo. All rights reserved.
//

#import "SFImageValueTransformer.h"
//class SFStringToIndex


@implementation SFStringToIndex
+(Class)transformedValueClass
{
    return [NSNumber class];
}


+(BOOL)allowsReverseTransformation
{
    return YES;
}

-(id)transformedValue:(id)value
{
    NSString *stringValue =value;
    float f = [stringValue floatValue];
    return [NSNumber numberWithFloat:f];
}

-(id)reverseTransformedValue:(id)value
{
    return [NSString stringWithFormat:@"%@",value];
}
@end

///class SFStringToNumber


@implementation SFStringToNumber
+(Class)transformedValueClass
{
    return [NSNumber class];
}


+(BOOL)allowsReverseTransformation
{
    return YES;
}

-(id)transformedValue:(id)value
{
    NSString *stringValue =value;
    float f = [stringValue floatValue];
    return [NSNumber numberWithFloat:f];
}

-(id)reverseTransformedValue:(id)value
{
    return [NSString stringWithFormat:@"%@",value];
}
@end


@implementation SFImageValueTransformer
+(Class)transformedValueClass
{
    return [NSImage class];
}

+(BOOL)allowsReverseTransformation
{
    return NO;
}
-(id)transformedValue:(id)value
{
    BOOL b = [value boolValue];
    if (b) {
        return [NSImage imageNamed:@"ledgreen.png"];
    }
    return [NSImage imageNamed:@"ledgray.png"];
}
-(id)reverseTransformedValue:(id)value
{
    return nil;
}
@end
