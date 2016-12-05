//
//  DMacro.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/3.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DMacro : NSObject

@end

/******************** Macros For Module ***************/



/****************	Macros	For safe Calling ****************/

#define __CALL(x,...) if(x) { x(__VA_ARGS__); }

#ifndef __dassert
#define __dassert(x, y, z) ((void)0)
#endif

#if defined(DEBUG)
#define __DBUGAssert(e) \
(__builtin_expect(!(e), 0) ? __dassert(#e, __FILE__, __LINE__) : (void)0)
#else
#define __DBUGAssert(e) ((void)0)
#endif



/******************** Macros For safe Check *****************/

#define __IF_DO(exp, stuff) if((exp)) { stuff; }

#define __CHECK(exp) if(!(exp)) { return; }

#define __CHECK_RET(exp, x) if(!(exp)) { return x; }

#define __CHECK_ASSERT(exp) if(!(exp)) { GTMLoggerDebug(@"FAILED CHECK:%@", @#exp); __DBUGAssert(false); return;}

#define __CHECK_ASSERT_RET(exp, x) if(!(exp)) { GTMLoggerDebug(@"FAILED CHECK:%@", @#exp); __DBUGAssert(false); return x;}
