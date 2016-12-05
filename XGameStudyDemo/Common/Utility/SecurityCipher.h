//
//  SecurityCipher.h
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/3.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#ifndef SECCIPHER_H
#define SECCIPHER_H

// INCLUDES
#include <openssl/rc4.h>
#include <stdlib.h>
#include "RSA_RC4_Helper.h"

class CSecurityCipher
{
public:
    inline CSecurityCipher(const char* key, int len)
    {
        RC4_set_key(&iOutKey, len, (const unsigned char*)key );
        RC4_set_key(&iInKey, len, (const unsigned char*)key);
    }
    
    // decrypt, actaully
    inline void inComing(char* dst, const char* src, size_t len)
    {
        RC4(&iOutKey, len, (const unsigned char*)src, (unsigned char*)dst );
    }
    // encrypt
    inline void outGoing(char* dst, const char* src, size_t len)
    {
        RC4(&iInKey, len, (const unsigned char*)src, (unsigned char*)dst );
    }
    
private:
    CSecurityCipher(const CSecurityCipher&);
    const CSecurityCipher& operator= (const CSecurityCipher&);
    
private:
    RC4_KEY  iOutKey;
    RC4_KEY  iInKey;
};

#endif // SECCIPHER_H
