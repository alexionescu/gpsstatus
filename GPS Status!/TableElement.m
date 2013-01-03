//
//  TableElement.m
//  GPS Status!
//
//  Created by Alex Ionescu on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TableElement.h"

@implementation TableElement
@synthesize title = _title;
@synthesize detail = _detail;

- (TableElement *)initWithTitle:(NSString *)tit withDetail:det

{
    self = [super init];
    if(self)
    {
        _title = tit;
        _detail = det;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@", _title, _detail];
}

- (NSString *)detail
{
    return [NSString stringWithFormat:@"%@", _detail];
}

- (void)dealloc
{
    _title = nil;
    _detail = nil;
}
@end
