//
//  TableElement.h
//  GPS Status!
//
//  Created by Alex Ionescu on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TableElement : NSObject
@property (nonatomic, strong) NSString *title;
@property id detail;

- (TableElement *)initWithTitle:(NSString *)tit withDetail:det;
@end
