//
//  HMAC.h
//  dwcloud
//
//  Created by rannger on 14-9-24.
//  Copyright (c) 2014年 rannger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HMAC)
- (NSData*)hmac;
@end

@interface NSString (SHA1)
- (NSString*)sha1;

@end
