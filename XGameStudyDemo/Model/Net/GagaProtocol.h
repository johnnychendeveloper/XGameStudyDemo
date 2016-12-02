//
//  GagaProtocol.h
//  Gaga
//
//  Created by lslin on 13-8-7.
//  Copyright (c) 2013年 YY Inc. All rights reserved.
//
#import <Foundation/Foundation.h>


/****************	Declares 	****************/
namespace pp
{
    class ProtoBody;
}

namespace google {
namespace protobuf{
    class Message;
}
}


/****************	GagaProtocolHead 	****************/
@interface GagaProtocolHead : NSObject
@property uint8_t group;
@property uint8_t sub;
@property uint8_t reserved0;
@property uint8_t reserved1;
@property uint32_t length;
@property uint32_t seq;

- (id)initWithGroup:(uint8_t)aGroup sub:(uint8_t)aSub seq:(uint32_t)aSeq;
- (id)initWithGroup:(uint8_t)aGroup sub:(uint8_t)aSub seq:(uint32_t)aSeq length:(uint32_t)aLen;
- (id)initWithData:(NSData *)data;

- (NSData *)serialize;
- (void)deserialize:(NSData*)data;
- (NSString *)description;
- (NSString *)toString;
@end


/****************	GagaProtocol 	****************/
@interface GagaProtocol : NSObject

@property (nonatomic) GagaProtocolHead* head;
@property (readonly, nonatomic) pp::ProtoBody *protoBody;
@property NSTimeInterval ts;

+ (GagaProtocol *)protocolWithGroup:(uint8_t)protoGroup sub:(uint8_t)protoSub serial:(uint32_t)serialNum protoBody:(pp::ProtoBody *)protoBody;
+ (GagaProtocol *)protocolWithData:(const char *)data length:(size_t)length;
+ (GagaProtocol *)protocolWithHead:(GagaProtocolHead*)head bodyData:(NSData*)data;
+ (GagaProtocol*)protocolWithMessage:(uint8_t)group sub:(uint8_t)aSub fieldNumber:(int)field message:(google::protobuf::Message*) aMessage;

+ (NSString *)groupDescription:(uint8_t)protoGroup;

+ (NSString *)subDescription:(uint8_t)protoGroup sub:(uint8_t)protoSub;

- (NSData *)headData;
- (NSData *)bodyData;
- (NSString *)description;

+ (int)allocSeq;
+ (void)initUniqueSeq;

@end

/****************	GagaProtocol convenience macro	****************/
#define D_NET_BEGIN()\
do{\
id<NetProtocol> net = DPROTOCOL(KM_Net, NetProtocol);

#define D_NET_ADD(group, sub, delegate)\
[net addProtoHandler:group withSub:sub object:self selector:@selector(delegate)];\

#define D_NET_ADD_IN(group, sub, delegate, thread)\
[net addProtoHandler:group withSub:sub object:self selector:@selector(delegate) inThread:thread];\

#define D_NET_REMOVE(group, sub, delegate)\
[net removeProtoHandler:group withSub:sub object:self selector:@selector(delegate)];\

#define D_NET_END()\
}while(0)

#define GagaNetAddWrap(stuff) \
D_NET_BEGIN();\
stuff;\
D_NET_END();

#define GagaNetAdd(group, sub, delegate) \
GagaNetAddWrap( D_NET_ADD(group, sub, delegate) )

#define GagaNetAddIn(group, sub, delegate, thread) \
GagaNetAddWrap( D_NET_ADD_IN(group, sub, delegate, thread) )

#define GagaNetRemove(group, sub, delegate) \
GagaNetAddWrap( D_NET_REMOVE(group, sub, delegate) )


#define GagaProtocolWrap(group, Req, Stuff) \
    GagaProtocol *proto;\
    do{\
        pp::Req aReq = pp::Req();\
        pp::Req* req = &aReq;\
        Stuff;\
        proto = [GagaProtocol protocolWithMessage:pp::group\
                                    sub:pp::P##Req\
                                    fieldNumber:pp::ProtoBody::k##Req##FieldNumber\
                              message:req];\
    }while(0)

#define GagaProtocolWrapEx(group, Req, member, Stuff) \
    GagaProtocol *proto; \
    do{\
        pp::member aReq = pp::member();\
        pp::member* req = &aReq;\
        Stuff;\
        proto = [GagaProtocol protocolWithMessage:pp::group\
                                    sub:pp::P##Req\
                                    fieldNumber:pp::ProtoBody::k##member##FieldNumber\
                              message:req];\
    }while(0)

#define GagaProtocolRequestRaw(group, req, res, timeout, proto) \
    NetRequest *request = [[NetRequest alloc] init]; \
    [request setTimeOut:timeout];\
    [request setGroup:pp::group];\
    [request setResSub:pp::P##res];\
    [request setProto:proto];\
    [request run]

#define GagaProtocolRequest(group, req, res, timeout, Stuff) \
    NetRequest *request = [[NetRequest alloc] init]; \
    [request setTimeOut:timeout];\
    [request setGroup:pp::group];\
    [request setResSub:pp::P##res];\
    GagaProtocolWrap(group, req, Stuff);\
    [request setProto:proto];\
    [request run]

#define GagaProtocolRequestEx(group, req, res, timeout, member, Stuff) \
    NetRequest *request = [[NetRequest alloc] init]; \
    [request setTimeOut:timeout];\
    [request setGroup:pp::group];\
    [request setResSub:pp::P##res];\
    GagaProtocolWrapEx(group, req, member, Stuff);\
    [request setProto:proto];\
    [request run]

#define GagaProtocolRequestWithSeqEx(group, req, res, timeout, member, aSeq, Stuff) \
    NetRequest *request = [[NetRequest alloc] init]; \
    [request setTimeOut:timeout];\
    [request setGroup:pp::group];\
    [request setResSub:pp::P##res];\
    GagaProtocolWrapEx(group, req, member, Stuff);\
    proto.head.seq = aSeq;\
    [request setProto:proto];\
    [request run]

#define GagaProtocolRequestWithSeq(group, req, res, timeout, aSeq, Stuff) \
    NetRequest *request = [[NetRequest alloc] init]; \
    [request setTimeOut:timeout];\
    [request setGroup:pp::group];\
    [request setResSub:pp::P##res];\
    GagaProtocolWrap(group, req, Stuff);\
    proto.head.seq = aSeq;\
    [request setProto:proto];\
    [request run]

#define GagaProtocolSendWrap(group, req, Stuff1, Stuff2) \
    do {\
        GagaProtocolWrap(group, req, Stuff1);\
        Stuff2;\
    }while(0)

#define GagaProtocolInWrap(a, b)\
    do{\
        a;\
        b;\
    }while(0)
