
//
//  GagaProtocol.m
//  Gaga
//
//  Created by lslin on 13-8-7.
//  Copyright (c) 2013年 YY Inc. All rights reserved.
//

#import "GagaProtocol.h"
#import "xgame.pb.h"
#import <libkern/OSAtomic.h>

static const uint8_t KGagaProtocolHeadLength = 12;
static volatile int32_t sSeq = 0;

@implementation GagaProtocolHead

- (id)initWithGroup:(uint8_t)aGroup sub:(uint8_t)aSub seq:(uint32_t)aSeq
{
    if (self = [super init]) {
        self.group = aGroup;
        self.sub = aSub;
        self.seq = aSeq;
    }
    return self;
}

- (id)initWithGroup:(uint8_t)aGroup sub:(uint8_t)aSub seq:(uint32_t)aSeq length:(uint32_t)aLen
{
    if (self = [super init]) {
        self.group = aGroup;
        self.sub = aSub;
        self.seq = aSeq;
        self.length = aLen;
    }
    return self;
}

- (id)initWithData:(NSData *)data
{
    if (self = [super init]) {
        [self deserialize:data];
    }
    return self;
}

- (NSData *)serialize
{
    // 消息格式定义
    // T:4个字节，包括 [协议类型|协议号|Flags1|Flags2|
    // L:4个字节，记录V的长度
    // S:4个字节，记录包的序列号，目前只有推送包有序列号
    // V:Protobuf封装
    
    NSMutableData *headData = [NSMutableData dataWithCapacity:KGagaProtocolHeadLength];
    //T: protocol type -> 4 byte;
    [headData appendBytes:&_group length:1];
    [headData appendBytes:&_sub length:1];
    [headData appendBytes:&_reserved0 length:1];
    [headData appendBytes:&_reserved1 length:1];
    //L: length -> 4 byte
    [headData appendBytes:&_length length:4];
    //S:
    [headData appendBytes:&_seq length:4];
    
    return headData;
}

- (void)deserialize:(NSData*)data
{
    NSAssert(data.length == KGagaProtocolHeadLength, @"wrong data to deserialize head");
    [data getBytes:&_group range:NSMakeRange(0, 1)];
    [data getBytes:&_sub range:NSMakeRange(1, 1)];
    [data getBytes:&_reserved0 range:NSMakeRange(2, 1)];
    [data getBytes:&_reserved1 range:NSMakeRange(3, 1)];
    [data getBytes:&_length range:NSMakeRange(4, 4)];
    [data getBytes:&_seq range:NSMakeRange(8, 4)];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"GagaProtocol group: %@, sub:%@, seq:%d",
            [GagaProtocol groupDescription:self.group],
            [GagaProtocol subDescription:self.group sub:self.sub],
            self.seq];
}

- (NSString *)toString
{
    return [NSString stringWithFormat:@"group: %@, sub:%@",
            [GagaProtocol groupDescription:self.group],
            [GagaProtocol subDescription:self.group sub:self.sub]];
}
@end

@implementation GagaProtocol

+ (GagaProtocol *)protocolWithGroup:(uint8_t)protoGroup sub:(uint8_t)protoSub serial:(uint32_t)serialNum protoBody:(pp::ProtoBody *)protoBody
{
    return [[GagaProtocol alloc] initWithGroup:protoGroup sub:protoSub serial:serialNum protoBody:protoBody];
}

+ (GagaProtocol *)protocolWithData:(const char *)data length:(size_t)length
{
    return nil;
}

+ (GagaProtocol *)protocolWithHead:(GagaProtocolHead*)aHead bodyData:(NSData*)data
{
    return [[GagaProtocol alloc] initWithBodyData:data head:aHead];
}

+ (pp::ProtoBody*)makeProtoBody:(uint8_t)group sub:(uint8_t)aSub fieldNumber:(int)field message:(google::protobuf::Message*) aMessage
{
   @synchronized (self) {
        pp::ProtoBody *body = new pp::ProtoBody();
        const google::protobuf::FieldDescriptor* fieldDescriptor = body->GetDescriptor()->FindFieldByNumber(field);
        if (fieldDescriptor) {
            google::protobuf::Message* theMessage = body->GetReflection()->MutableMessage(body, fieldDescriptor);
            if (theMessage) {
                theMessage->CopyFrom(*aMessage);
            }
            return body;
        }
   }
   
    return NULL;
}

+ (GagaProtocol*)protocolWithMessage:(uint8_t)group sub:(uint8_t)aSub fieldNumber:(int)field message:(google::protobuf::Message*) aMessage
{
    pp::ProtoBody *body = [GagaProtocol makeProtoBody:group sub:aSub fieldNumber:field message:aMessage];
    if (body) {
        return [GagaProtocol protocolWithGroup:group sub:aSub serial:[GagaProtocol allocSeq] protoBody:body];
    }
    return nil;
}


- (void)dealloc
{
    if (_protoBody) {
        delete _protoBody;
        _protoBody = NULL;
    }
}

- (id)initWithGroup:(uint8_t)protoGroup sub:(uint8_t)protoSub serial:(uint32_t)serialNum protoBody:(pp::ProtoBody *)protoBody
{
    self = [super init];
    if (self) {
        _head = [[GagaProtocolHead alloc] initWithGroup:protoGroup sub:protoSub seq:serialNum];
        _protoBody = protoBody;
    }
    return self;
}

- (id)initWithBodyData:(NSData*)body head:(GagaProtocolHead*)aHead
{
    if (self = [super init])
    {
        _head = aHead;
        _protoBody = new pp::ProtoBody();
        _protoBody->ParseFromArray([body bytes], (int)[body length]);
    }
    return self;
}

- (NSData *)headData
{
    return [_head serialize];
}

- (NSData *)bodyData
{
    std::string serializedString;
    self.protoBody->SerializeToString(&serializedString);
    self.head.length = (uint32_t)serializedString.size();
    return [NSData dataWithBytes:serializedString.data() length:serializedString.size()];
}

- (NSString *)description
{
    return [self.head description];
}

+ (int)allocSeq
{
   return OSAtomicIncrement32(&sSeq); 
}

+ (void)initUniqueSeq
{
    sSeq = (((int)[[NSDate date] timeIntervalSince1970] * 1000) & INT_MAX);
}

#define GroupCase(e) case pp::e : return @#e; break;

+ (NSString *)groupDescription:(uint8_t)protoGroup
{
    switch (protoGroup) {
            GroupCase(PEncrypt);
            GroupCase(PLogin);
            GroupCase(PUser);
            GroupCase(PUserMsg);
            GroupCase(PGroup);
            GroupCase(PGroupMsg);
            GroupCase(PPush);
            GroupCase(PGroupApp);
            GroupCase(PReport);
            GroupCase(PGoldCoin);
            GroupCase(PConfig);
            GroupCase(PShop);
            GroupCase(PWeb);
            GroupCase(PAdmin);
        default:
            break;
    }
    return [@(protoGroup) description];
}

#define SubCaseBegin(p, s) case pp::p : switch(s) {
#define SubCaseEnd() } break;
+ (NSString *)subDescription:(uint8_t)protoGroup sub:(uint8_t)protoSub
{
    switch (protoGroup) {
          SubCaseBegin(PEncrypt, protoSub)
            GroupCase(PKeyExchangeReq)
            GroupCase(PKeyExchangeRes)
            SubCaseEnd()
          SubCaseBegin(PLogin, protoSub)
            GroupCase(PUserLoginReq)
            GroupCase(PUserLoginRes)
            GroupCase(PUserActivateReq)
            GroupCase(PUserActivateRes)
            GroupCase(PUserHeartBeatReq)
            GroupCase(PUserHeartBeatRes)
            GroupCase(PSessionResumeReq)
            GroupCase(PSessionResumeRes)
            GroupCase(PSessionSuspendReq)
            GroupCase(PUserPasswordModifyReq)
            GroupCase(PUserPasswordModifyRes)
            GroupCase(PUptokenReq)
            GroupCase(PUptokenRes)
            GroupCase(PUserTokenReq)
            GroupCase(PUserTokenRes)
            GroupCase(PUserWebLoginReq)
            GroupCase(PUserWebLoginRes)
            GroupCase(PUserPushTokenRegisterReq)
            GroupCase(PUserPushTokenRegisterRes)
            GroupCase(PAccountBindReq)
            GroupCase(PAccountBindRes)
            GroupCase(PUserLogoutReq)
            GroupCase(PUserLogoutRes)
            SubCaseEnd()
          SubCaseBegin(PUser, protoSub)
            GroupCase(PUserInfoReq)
            GroupCase(PUserInfoRes)
            GroupCase(PUserInfoModifyReq)
            GroupCase(PUserInfoModifyRes)
            GroupCase(PUserInfoListReq)
            GroupCase(PUserInfoListRes)
            GroupCase(PUserImageReq)
            GroupCase(PUserImageRes)
            GroupCase(PUserImageListReq)
            GroupCase(PUserImageListRes)
            GroupCase(PUserImageOpReq)
            GroupCase(PUserImageOpRes)
            GroupCase(PUserImageLikeReq)
            GroupCase(PUserImageLikeRes)
            GroupCase(PUserRecommendRegisterReq)
            GroupCase(PUserRecommendRegisterRes)
            GroupCase(PUserRefererListReq)
            GroupCase(PUserRefererListRes)
            GroupCase(PUserProductListReq)
            GroupCase(PUserProductListRes)
            GroupCase(PUserActiveDataReq)
            GroupCase(PUserActiveDataRes)
            GroupCase(PUserStatDataReq)
            GroupCase(PUserStatDataRes)
            GroupCase(PUserActiveDataListReq)
            GroupCase(PUserActiveDataListRes)
            GroupCase(PUserProfileViewReq)
            GroupCase(PUserProfileViewRes)
            GroupCase(PUserAppRateReq)
            GroupCase(PUserAppRateRes)
            GroupCase(PUserExpressAddrOpReq)
            GroupCase(PUserExpressAddrOpRes)
          SubCaseEnd()
          SubCaseBegin(PUserMsg, protoSub)
            GroupCase(PUserMsgListReq)
            GroupCase(PUserMsgListRes)
            GroupCase(PUserMsgSendReq)
            GroupCase(PUserMsgSendRes)
            GroupCase(PUserMsgBroadcastReq)
            GroupCase(PUserMsgBroadcastRes)
            GroupCase(PUserMsgRejectListSetReq)
            GroupCase(PUserMsgRejectListSetRes)
            GroupCase(PUserMsgRejectListGetReq)
            GroupCase(PUserMsgRejectListGetRes)
            GroupCase(PMsgReadRevisionSetReq)
            GroupCase(PMsgReadRevisionSetRes)
            GroupCase(PMsgReadRevisionGetReq)
            GroupCase(PMsgReadRevisionGetRes)
            SubCaseEnd()
          SubCaseBegin(PGroup, protoSub)
            GroupCase(PGroupCreateReq)
            GroupCase(PGroupCreateRes)
            GroupCase(PGroupApplyReq)
            GroupCase(PGroupApplyRes)
            GroupCase(PGroupQuitReq)
            GroupCase(PGroupQuitRes)
            GroupCase(PGroupInfoReq)
            GroupCase(PGroupInfoRes)
            GroupCase(PGroupInfoModifyReq)
            GroupCase(PGroupInfoModifyRes)
            GroupCase(PGroupSearchReq)
            GroupCase(PGroupSearchRes)
            GroupCase(PGroupListReq)
            GroupCase(PGroupListRes)
            GroupCase(PGroupDestroyReq)
            GroupCase(PGroupDestroyRes)
            GroupCase(PGroupMemberListReq)
            GroupCase(PGroupMemberListRes)
            GroupCase(PGroupMemberCountReq)
            GroupCase(PGroupMemberCountRes)
            GroupCase(PGroupMemberReq)
            GroupCase(PGroupMemberRes)
            GroupCase(PGroupMemberModifyReq)
            GroupCase(PGroupMemberModifyRes)
            GroupCase(PGroupPropReq)
            GroupCase(PGroupPropRes)
            GroupCase(PGroupMemberSearchReq)
            GroupCase(PGroupMemberSearchRes)
            GroupCase(PGroupJoinedListReq)
            GroupCase(PGroupJoinedListRes)
            GroupCase(PTopicListReq)
            GroupCase(PTopicListRes)
            GroupCase(PGroupTagCreateReq)
            GroupCase(PGroupTagCreateRes)
            GroupCase(PFamilyStatReq)
            GroupCase(PFamilyStatRes)
            GroupCase(PGroupMemberRolerListReq)
            GroupCase(PGroupMemberRolerListRes)
            GroupCase(PGroupMemberRolerSetReq)
            GroupCase(PGroupMemberRolerSetRes)
            GroupCase(PShowGameStartReq)
            GroupCase(PShowGameStartRes)
            SubCaseEnd()
          SubCaseBegin(PGroupMsg, protoSub)
            GroupCase(PGroupMsgListReq)
            GroupCase(PGroupMsgListRes)
            GroupCase(PGroupMsgSendReq)
            GroupCase(PGroupMsgSendRes)
            GroupCase(PGroupMsgSearchReq)
            GroupCase(PGroupMsgSearchRes)
            SubCaseEnd()
          SubCaseBegin(PPush, protoSub)
            GroupCase(PPushPack)
            SubCaseEnd()
          SubCaseBegin(PGroupApp, protoSub)
            GroupCase(PGroupAppSendReq)
            GroupCase(PGroupAppSendRes)
            GroupCase(PGroupAppListReq)
            GroupCase(PGroupAppListRes)
            GroupCase(PGroupMsgAppReq)
            GroupCase(PGroupMsgAppRes)
            SubCaseEnd()
          SubCaseBegin(PReport, protoSub)
            GroupCase(PReportViolatorReq)
            GroupCase(PReportViolatorRes)
            SubCaseEnd()
          SubCaseBegin(PConfig, protoSub)
            GroupCase(PAdListReq)
            GroupCase(PAdListRes)
            GroupCase(PAdModifyReq)
            GroupCase(PAdModifyRes)
            GroupCase(PAdRemoveReq)
            GroupCase(PAdRemoveRes)
            GroupCase(PUserSettingSetReq)
            GroupCase(PUserSettingSetRes)
            GroupCase(PUserSettingGetReq)
            GroupCase(PUserSettingGetRes)
            GroupCase(PAppStateCheckReq)
            GroupCase(PAppStateCheckRes)
            GroupCase(PAppStateUpdateReq)
            GroupCase(PAppStateUpdateRes)
            GroupCase(PAppActConfigReq)
            GroupCase(PAppActConfigRes)
            GroupCase(PAppProtoVersionUpdateReq)
            GroupCase(PAppProtoVersionUpdateRes)
            SubCaseEnd()
        SubCaseBegin(PShop, protoSub)
            GroupCase(PProductListReq)
            GroupCase(PProductListRes)
            GroupCase(PProductOpReq)
            GroupCase(PProductOpRes)
            GroupCase(PProductBuyReq)
            GroupCase(PProductBuyRes)
            SubCaseEnd()
         SubCaseBegin(PAdmin, protoSub)
            GroupCase(PPublicNumAddReq)
            GroupCase(PPublicNumAddRes)
            GroupCase(PUserRoleModifyReq)
            GroupCase(PUserRoleModifyRes)
            SubCaseEnd()
        SubCaseBegin(PWeb, protoSub)
            GroupCase(PWebQRCodeScanReq)
            GroupCase(PWebQRCodeScanRes)
            GroupCase(PWebUserInfoReq)
            GroupCase(PWebUserInfoRes)
            GroupCase(PWebRecommendsReq)
            GroupCase(PWebRecommendsRes)
            GroupCase(PWebYYIconOnReq)
            GroupCase(PWebYYIconOnRes)
            GroupCase(PWebRankingReq)
            GroupCase(PWebRankingRes)
            GroupCase(PChrisLotHitListReq)
            GroupCase(PChrisLotHitListRes)
            GroupCase(PWebTokenVerifyReq)
            GroupCase(PWebTokenVerifyRes)
            GroupCase(PWebUserTokenReq)
            GroupCase(PWebUserTokenRes)
            GroupCase(PUserDataAdjustReq)
            GroupCase(PUserDataAdjustRes)
            GroupCase(PConfigDataReq)
            GroupCase(PConfigDataRes)
            GroupCase(PPageDataExchangeReq)
            GroupCase(PPageDataExchangeRes)
            GroupCase(PUserForbidListReq)
            GroupCase(PUserForbidListRes)
            GroupCase(PActLuckyTryReq)
            GroupCase(PActLuckyTryRes)
            GroupCase(PConfigJsonActListReq)
            GroupCase(PConfigJsonActListRes)
            GroupCase(PConfigJsonActModifyReq)
            GroupCase(PActStarFormReq)
            GroupCase(PConfigJsonActStarReq)
            GroupCase(PConfigJsonActRes)
            GroupCase(PActMsgListReq)
            GroupCase(PActMsgListRes)
            GroupCase(PActMsgModifyReq)
            SubCaseEnd()
        default:
            break;
    }
    return [@(protoSub) description];
}

@end
