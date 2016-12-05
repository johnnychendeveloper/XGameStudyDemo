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


#undef Def_Module
#undef Def_Notification
#undef Def_NotificationEx
#undef Def_Const
#undef Def_ConstWithKey
#undef Def_ConstValue
#define Def_Module(m) KM_##m,
#define Def_Notification(e)
#define Def_NotificationEx(e, thread)
#define Def_Const(c)
#define Def_ConstWithKey(c, k)
#define Def_ConstValue(c, v)

// Module Enum
/********************* Module Enum ************************/
typedef enum
{
#include "DDef.inl.h"
    KM_Max,
}DEModule;


#endif
