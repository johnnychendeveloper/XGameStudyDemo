//
//  RSA_RC4_Helper.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/3.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#ifndef _RSA_RC4_HELPER_H_
#define _RSA_RC4_HELPER_H_

#include <openssl/crypto.h>
#include <openssl/err.h>
#include <openssl/rand.h>
#include <openssl/bn.h>
#include <openssl/rsa.h>
#include <string>

#define DEF_SESSIONKEY_LENGTH 16

class RSA_Helper
{
public:
    static int init();
    static void no_look_init();
    static int cleanup();
    static std::string genRC4Key();
    
public:
    RSA_Helper();
    ~RSA_Helper();
    void getRSA_PubKey(std::string &n, std::string &e);
    int rsaDecodeRc4(const std::string &enctext, std::string &rc4key);
    int rsaDecodeRc4(const char* enctext, int len, std::string &rc4key);
    
private:
    RSA_Helper(const RSA_Helper&);
    const RSA_Helper& operator= (const RSA_Helper&);
    
private:
    void createKey();
    
    RSA *key;
};

#endif
