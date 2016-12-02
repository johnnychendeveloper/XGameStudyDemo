//
//  DDef.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/11/13.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#ifndef gaga_DEvent_h
#define gaga_DEvent_h

#define Def_Module(m)
#define Def_Notification(e) KN_##e,
#define Def_NotificationEx(e,thread) KN_##e,
#define Def_Const(c)
#define Def_ConstWithKey(c,k)
#define Def_ConstValue(c,v)

//Event Enum
/*********** Notification Enum ************/
typedef enum
{
#include "DDef.inl.h"
}DENotification;


#endif
