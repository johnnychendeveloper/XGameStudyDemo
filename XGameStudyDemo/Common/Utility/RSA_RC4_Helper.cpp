//
//  RSA_RC4_Helper.m
//  XGameStudyDemo
//
//  Created by JohnnyChen on 16/12/3.
//  Copyright © 2016年 YY.Inc. All rights reserved.
//

#include "RSA_RC4_Helper.h"
#include <openssl/rsa.h>
#include <sys/types.h>
#include <pthread.h>

const char rnd_seed[] = "string to make the random number generator think it has entropy";

RSA_Helper::RSA_Helper()
{
    createKey();
}

RSA_Helper::~RSA_Helper()
{
    if(key){
        RSA_free(key);
        CRYPTO_cleanup_all_ex_data();
    }
}

std::string RSA_Helper::genRC4Key()
{
    unsigned char buf[DEF_SESSIONKEY_LENGTH];
    RAND_bytes(buf, DEF_SESSIONKEY_LENGTH);
    return std::string((const char*)buf, DEF_SESSIONKEY_LENGTH);
}

void RSA_Helper::createKey()
{
    RAND_seed(rnd_seed, sizeof(rnd_seed) - 1);
    
    // no RSA_generate_key any more...
    //key =  RSA_generate_key(512, 3, NULL, NULL);
    BIGNUM *e = BN_new();
    BN_set_word(e, 3);
    key = RSA_new();
    if ( key && e )
    {
        RSA_generate_key_ex( key, 512, e, NULL );
        while(RSA_check_key(key) != 1)
        {
            RSA_free(key);
            key = RSA_new();
            RSA_generate_key_ex(key, 512, e, NULL);
        }
    }
    BN_free(e);
}

void RSA_Helper::getRSA_PubKey(std::string &n, std::string &e){
    n = std::string(BN_bn2dec(key->n));
    e = std::string(BN_bn2dec(key->e));
}

int RSA_Helper::rsaDecodeRc4(const std::string &enctext, std::string &rc4key){
    unsigned char rc4buf[100];
    int num = RSA_private_decrypt((int)enctext.length(), (const unsigned char *)enctext.data(), rc4buf, key,	RSA_PKCS1_PADDING);
    if ( num == DEF_SESSIONKEY_LENGTH)
    {
        //LOG_ASSERT(num == DEF_SESSIONKEY_LENGTH) << "RSA_Helper::rsaDecodeRc4 len:" << num;
        rc4key.assign((const char *)rc4buf, DEF_SESSIONKEY_LENGTH);
        return num;
    }
    else
    {
        return 0;
    }
}

int RSA_Helper::rsaDecodeRc4(const char* enctext, int len, std::string &rc4key)
{
    unsigned char rc4buf[100];
    int num = RSA_private_decrypt(len, (const unsigned char *)enctext, rc4buf, key,	RSA_PKCS1_PADDING);
    if ( num > 0)
    {
        rc4key.assign((const char *)rc4buf, num);
        return num;
    }
    else
    {
        return 0;
    }
}


struct CRYPTO_dynlock_value
{
    pthread_mutex_t mutex;
};

static pthread_mutex_t *mutex_buf = NULL;

/**
 * OpenSSL locking function.
 *
 * @param    mode    lock mode
 * @param    n        lock number
 * @param    file    source file name
 * @param    line    source file line number
 * @return    none
 */
static void locking_function(int mode, int n, const char *file, int line)
{
    (void)file;
    (void)line;
    
    if (mode & CRYPTO_LOCK) {
        pthread_mutex_lock(&mutex_buf[n]);
    } else {
        pthread_mutex_unlock(&mutex_buf[n]);
    }
}

/**
 * OpenSSL uniq id function.
 *
 * @return    thread id
 */
static unsigned long id_function(void)
{
    return ((unsigned long) pthread_self());
}

/**
 * OpenSSL allocate and initialize dynamic crypto lock.
 *
 * @param    file    source file name
 * @param    line    source file line number
 */
static struct CRYPTO_dynlock_value *dyn_create_function(const char *file, int
                                                        line)
{
    (void)file;
    (void)line;
    
    struct CRYPTO_dynlock_value *value;
    
    value = (struct CRYPTO_dynlock_value *)
    malloc(sizeof(struct CRYPTO_dynlock_value));
    if (!value) {
        goto err;
    }
    pthread_mutex_init(&value->mutex, NULL);
    
    return value;
    
err:
    return (NULL);
}

/**
 * OpenSSL dynamic locking function.
 *
 * @param    mode    lock mode
 * @param    l        lock structure pointer
 * @param    file    source file name
 * @param    line    source file line number
 * @return    none
 */
static void dyn_lock_function(int mode, struct CRYPTO_dynlock_value *l,
                              const char *file, int line)
{
    (void)file;
    (void)line;
    
    if (mode & CRYPTO_LOCK) {
        pthread_mutex_lock(&l->mutex);
    } else {
        pthread_mutex_unlock(&l->mutex);
    }
}

/**
 * OpenSSL destroy dynamic crypto lock.
 *
 * @param    l        lock structure pointer
 * @param    file    source file name
 * @param    line    source file line number
 * @return    none
 */

static void dyn_destroy_function(struct CRYPTO_dynlock_value *l,
                                 const char *file, int line)
{
    (void)file;
    (void)line;
    
    pthread_mutex_destroy(&l->mutex);
    free(l);
}

/**
 * Initialize TLS library.
 *
 * @return    0 on success, -1 on error
 */
int RSA_Helper::init(void)
{
    int i;
    
    /* static locks area */
    mutex_buf = (pthread_mutex_t*)malloc(CRYPTO_num_locks() * sizeof(pthread_mutex_t));
    if (mutex_buf == NULL) {
        return (-1);
    }
    for (i = 0; i < CRYPTO_num_locks(); i++) {
        pthread_mutex_init(&mutex_buf[i], NULL);
    }
    /* static locks callbacks */
    CRYPTO_set_locking_callback(locking_function);
    CRYPTO_set_id_callback(id_function);
    /* dynamic locks callbacks */
    CRYPTO_set_dynlock_create_callback(dyn_create_function);
    CRYPTO_set_dynlock_lock_callback(dyn_lock_function);
    CRYPTO_set_dynlock_destroy_callback(dyn_destroy_function);
    
    no_look_init();
    return (0);
}

/**
 * Cleanup TLS library.
 *
 * @return    0
 */
int RSA_Helper::cleanup(void)
{
    int i;
    
    if (mutex_buf == NULL) {
        return (0);
    }
    
    CRYPTO_set_dynlock_create_callback(NULL);
    CRYPTO_set_dynlock_lock_callback(NULL);
    CRYPTO_set_dynlock_destroy_callback(NULL);
    
    CRYPTO_set_locking_callback(NULL);
    CRYPTO_set_id_callback(NULL);
    
    for (i = 0; i < CRYPTO_num_locks(); i++) {
        pthread_mutex_destroy(&mutex_buf[i]);
    }
    free(mutex_buf);
    mutex_buf = NULL;
    return (0);
}

void RSA_Helper::no_look_init()
{
    RAND_load_file("/dev/urandom", 1024);
}
