#ifndef _SNOX_PACKET_H_INCLUDE__
#define _SNOX_PACKET_H_INCLUDE__

#include "int_types.h"
#include "blockbuffer.h"
#include "varstr.h"

#include <string>
#include <iostream>
#include <stdexcept>
#include <map> // CARE
#include <vector>
#include <set>
#include <string.h>

#ifdef ANDROID
#undef HAS_EXCEPTION
#define NO_EXCEPTION
#endif

#ifdef __EXCEPTIONS
#define HAS_EXCEPTION
#else
#define NO_EXCEPTION
#endif

#ifdef __SYMBIAN32__
#define HAS_EXCEPTION
#undef NO_EXCEPTION
#endif

#ifdef NO_EXCEPTION
#undef throw
//  #if defined(ANDROID)
//   #include <jni.h>
// extern JNIEnv* env_ndk;
// extern void jniThrowException(JNIEnv* env, const char* exc, const char* msg);
//  #define _THROW_EXECPTION(condition, message) \
// if (!(condition))                                                       \
//      jniThrowException(env_ndk, "java/lang/RuntimeException", message);

//  #define throw(message) \
//     jniThrowException(env_ndk, "java/lang/RuntimeException", message);
//  #endif
// #else
 #define throw assert(0);
#endif



namespace sox {

#ifdef HAS_EXCEPTION
struct PacketError : public std::runtime_error {
	PacketError(const std::string & w) :
		std::runtime_error(w) {
	}
};

struct PackError : public PacketError {
	PackError(const std::string & w) :
		PacketError(w) {
	}
};

struct UnpackError : public PacketError {
	UnpackError(const std::string & w) :
		PacketError(w) {
	}
};
#endif
    
class PackBuffer {
public:
	char * data() {
		return bb.data();
	}
	size_t size() const {
		return bb.size();
	}

	void resize(size_t n) {
		if (bb.resize(n))
			return;
		throw("resize buffer overflow");
	}
	void append(const char * data, size_t size) {
		if (bb.append(data, size))
			return;
		throw("append buffer overflow");
	}
	void append(const char * data) {
		append(data,:: strlen(data));}
	void replace(size_t pos, const char * rep, size_t n) {
		if (bb.replace(pos, rep, n)) return;
		throw("replace buffer overflow");
	}
	void reserve(size_t n) {
		if (bb.reserve(n)) return;
		throw("reserve buffer overflow");
	}

private:
	// use big-block. more BIG? MAX 64K*4k = 256M
				typedef BlockBuffer<def_block_alloc_4k, 65536> BB;
				BB bb;
			};



#define XHTONS
#define XHTONL
#define XHTONLL

#define XNTOHS XHTONS
#define XNTOHL XHTONL
#define XNTOHLL XHTONLL

class Pack
{
private:
	Pack (const Pack & o);
	Pack & operator = (const Pack& o);
public:
	uint16_t xhtons(uint16_t i16) { return XHTONS(i16); }
	uint32_t xhtonl(uint32_t i32) { return XHTONL(i32); }
	uint64_t xhtonll(uint64_t i64) { return XHTONLL(i64); }

	// IMPORTANT remember the buffer-size before pack. see data(), size()
	// reserve a space to replace packet header after pack parameter
	// sample below: OffPack. see data(), size()
	Pack(PackBuffer & pb, size_t off = 0) : m_buffer(pb)
	{
		m_offset = pb.size() + off;
		m_buffer.resize(m_offset);
	}

	// access this packet.
	char * data()       { return m_buffer.data() + m_offset; }
	const char * data()  const { return m_buffer.data() + m_offset; }
	size_t size() const { return m_buffer.size() - m_offset; }

	Pack & push(const void * s, size_t n) { m_buffer.append((const char *)s, n); return *this; }
	Pack & push(const void * s)           { m_buffer.append((const char *)s); return *this; }

	Pack & push_uint8(uint8_t u8)	 { return push(&u8, 1); }
	Pack & push_uint16(uint16_t u16) { u16 = xhtons(u16); return push(&u16, 2); }
	Pack & push_uint32(uint32_t u32) { u32 = xhtonl(u32); return push(&u32, 4); }
	Pack & push_uint64(uint64_t u64) { u64 = xhtonll(u64); return push(&u64, 8); }

	Pack & push_varstr(const Varstr & vs)     { return push_varstr(vs.data(), vs.size()); }
	Pack & push_varstr(const void * s)        { return push_varstr(s, strlen((const char *)s)); }
	Pack & push_varstr(const std::string & s) { return push_varstr(s.data(), s.size()); }
	Pack & push_varstr(const void * s, size_t len)
	{
		if (len > 0xFFFF) throw("push_varstr: varstr too big");
		return push_uint16(uint16_t(len)).push(s, len);
	}
	Pack & push_varstr32(const void * s, size_t len)
	{
		if (len > 0xFFFFFFFF) throw("push_varstr32: varstr too big");
		return push_uint32(uint32_t(len)).push(s, len);
	}
#if defined(WIN32) || defined(__SYMBIAN32__)
	Pack & push_varwstring32(const std::wstring &ws){
		size_t len = ws.size() * 2;
		return push_uint32((uint32_t)len).push(ws.data(), len);
	}
#else // wchar_t is 4 bytes!!
	Pack & push_varwstring32(const std::wstring &ws)
	{
	    size_t len = ws.size() * 2;
	    unsigned short * buf = new unsigned short[ws.size()];
	    for ( size_t i = 0; i < ws.size(); i++ )
	    {
	        buf[i] = (unsigned short)(ws[i] & 0xFF);
	    }
	    return push_uint32((uint32_t)len).push(buf, len);
	    delete[] buf;
	}	
#endif
	/*
	Pack & push_octlen(size_t len)
	{
		uint8_t oct[sizeof(len)];
		int i = sizeof(len);

		// 0.7, <=127 //
		// 1.7-0.7 <= 16k //
		// 1.7-1.7-0.7 < 2^21
		do
		{
			oct[--i] = len & 0x7f;
			len >>= 7;
		} while (len > 0);

		for ( ; i < sizeof(len) - 1; ++i)
			push_uint8(oct[i]|0x80);
		push_uint8(oct[i]);
	}
	struct octstr
	{
		octstr(const std::string & s) : str(s) { }
	};
	size_t pop_octlen()
	{
		size_t len = 0;
		uint8_t oct;
		do
		{
			oct = pop_uint8();
			len <<= 7;
			len |= (oct & 0x7f);
		} while (oct > 0x7f);
		return len;
	}

	Pack & push_octstr(const Varstr & vs)          { return push_octstr(vs.data(), vs.size()); }
	Pack & push_octstr(const void * s)             { return push_octstr(s, strlen((const char *)s)); }
	Pack & push_octstr(const std::string & s)      { return push_octstr(s.data(), s.size()); }
	Pack & push_octstr(const void * s, size_t len) { return push_octlen(len).push(s, len); }
	*/

	virtual ~Pack() {}
public:
	// replace. pos is the buffer offset, not this Pack m_offset
	size_t replace(size_t pos, const void * data, size_t rplen) {
		m_buffer.replace(pos, (const char*)data, rplen);
		return pos + rplen;
	}
	size_t replace_uint8(size_t pos, uint8_t u8)    { return replace(pos, &u8, 1); }
	size_t replace_uint16(size_t pos, uint16_t u16) {
		u16 = xhtons(u16);
		return replace(pos, &u16, 2);
	}
	size_t replace_uint32(size_t pos, uint32_t u32) {
		u32 = xhtonl(u32);
		return replace(pos, &u32, 4);
	}
protected:
	PackBuffer & m_buffer;
	size_t m_offset;
};

/* sample
struct OffPack : public Pack
{
	enum { BYTES = 12 };
	OffPack(PackBuffer &pb) : Pack(pb, BYTES)
	{
	}
	void endpack()
	{
		//assert(m_offset >= BYTES);
		m_offset -= BYTES;

		// use relace method to fill the reserve space
		size_t rppos = m_offset; // beginning of the reserve-space
		rppos = replace_uint32(rppos, 1); // 4 bytes
		rppos = replace(rppos, "123456", 6); // 6 bytes
		rppos = relpace_uint16(rppos, 2); // 2 bytes
	}
};
*/

class Unpack
{
public:
	uint16_t xntohs(uint16_t i16) const { return XNTOHS(i16); }
	uint32_t xntohl(uint32_t i32) const { return XNTOHL(i32); }
	uint64_t xntohll(uint64_t i64) const { return XNTOHLL(i64); }

	Unpack(const void * data, size_t size)
	{
		reset(data, size);
	}
	void reset(const void * data, size_t size) const
	{
		m_data = (const char *)data;
		m_size = size;
	}

	virtual ~Unpack() { m_data = NULL;  }

	operator const void *() const { return m_data; }
	bool operator!() const  { return (NULL == m_data); }

	std::string pop_varstr() const {
		Varstr vs = pop_varstr_ptr();
		return std::string(vs.data(), vs.size());
	}

	std::string pop_varstr32() const {
		Varstr vs = pop_varstr32_ptr();
		return std::string(vs.data(), vs.size());
	}
	
#if defined(WIN32) || defined(__SYMBIAN32__)
	std::wstring pop_varwstring32() const{
		Varstr vs = pop_varstr32_ptr();
		return std::wstring((wchar_t *)vs.data(), vs.size() / 2);
	}
#else // wchar_t is 4 bytes on linux!
	std::wstring pop_varwstring32() const
    {
	    Varstr vs = pop_varstr32_ptr();
        std::wstring ws;
        size_t len = vs.size() / 2;
        for ( size_t i = 0; i < len; i++)
        {
            unsigned short * buf = (unsigned short *)vs.data();
            ws.push_back((wchar_t)buf[i]);
        }
        return ws;
    }   
#endif
    
	std::string pop_fetch(size_t k) const {
		return std::string(pop_fetch_ptr(k), k);
	}

	void finish() const {
		if (!empty()) throw("finish: too much data");
	}

	uint8_t pop_uint8() const {
		if (m_size < 1u)
			throw("pop_uint8: not enough data");

		uint8_t i8 = *((uint8_t*)m_data);
		m_data += 1u; m_size -= 1u;
		return i8;
	}

	uint16_t pop_uint16() const {
		if (m_size < 2u)
			throw("pop_uint16: not enough data");

		//uint16_t i16 = *((uint16_t*)m_data);
		uint16_t i16 = 0;
		memcpy(&i16, m_data, sizeof(uint16_t));
		i16 = xntohs(i16);

		m_data += 2u; m_size -= 2u;
		return i16;
	}

	uint32_t pop_uint32() const {
		if (m_size < 4u)
			throw("pop_uint32: not enough data");
		//uint32_t i32 = *((uint32_t*)m_data);
		uint32_t i32 = 0;
		memcpy(&i32, m_data, sizeof(uint32_t));
		i32 = xntohl(i32);
		m_data += 4u; m_size -= 4u;
		return i32;
	}

	/**
	 * Ϊ������unmarshal_containerʱ��ȡ��������size����reserve�ڴ�����
	 */
	uint32_t peek_uint32() const {
		if (m_size < 4u)
			throw("peek_uint32: not enough data");
		//uint32_t i32 = *((uint32_t*)m_data);
		uint32_t i32 = 0;
		memcpy(&i32, m_data, sizeof(uint32_t));
		i32 = xntohl(i32);
		return i32;
	}

	uint64_t pop_uint64() const {
		if (m_size < 8u)
			throw("pop_uint64: not enough data");
		//uint64_t i64 = *((uint64_t*)m_data);
		uint64_t i64 = 0;
		memcpy(&i64, m_data, sizeof(uint64_t));
		i64 = xntohll(i64);
		m_data += 8u; m_size -= 8u;
		return i64;
	}

	Varstr pop_varstr_ptr() const {
		// Varstr { uint16_t size; const char * data; }
		Varstr vs;
		vs.m_size = pop_uint16();
		vs.m_data = pop_fetch_ptr(vs.m_size);
		return vs;
	}

	Varstr pop_varstr32_ptr() const {
		Varstr vs;
		vs.m_size = pop_uint32();
		//__android_log_print(ANDROID_LOG_DEBUG, "yy", "pop_uint32:%d", vs.m_size);
		//__android_log_print(ANDROID_LOG_DEBUG, "yy", "this->m_size:%d", this->m_size);
		vs.m_data = pop_fetch_ptr(vs.m_size);
		return vs;
	}

	const char * pop_fetch_ptr(size_t k) const {
		if (m_size < k)
		{
			throw("pop_fetch_ptr: not enough data");
		}

		const char * p = m_data;
		m_data += k; m_size -= k;
		return p;
	}

	bool empty() const	  { return m_size == 0; }
	const char * data() const { return m_data; }
	size_t size() const	  { return m_size; }

private:
	mutable const char * m_data;
	mutable size_t m_size;
};

struct Marshallable
{
	virtual void marshal(Pack &) const = 0;
	virtual void unmarshal(const Unpack &) = 0;
	virtual ~Marshallable() {}
	virtual std::ostream & trace(std::ostream & os) const
	{ return os << "trace Marshallable [ not immplement ]"; }
};

// Marshallable helper
inline std::ostream & operator << (std::ostream & os, const Marshallable & m)
{
	return m.trace(os);
}

inline Pack & operator << (Pack & p, const Marshallable & m)
{
	m.marshal(p);
	return p;
}

inline const Unpack & operator >> (const Unpack & p, const Marshallable & m)
{
	const_cast<Marshallable &>(m).unmarshal(p);
	return p;
}

struct Voidmable : public sox::Marshallable
{
	virtual void marshal(Pack &) const {}
	virtual void unmarshal(const Unpack &) {}
};

struct Mulmable : public sox::Marshallable
{
	Mulmable(const sox::Marshallable & m1, const sox::Marshallable & m2)
		: mm1(m1), mm2(m2) { }

	const sox::Marshallable & mm1;
	const sox::Marshallable & mm2;

	virtual void marshal(Pack &p) const          { p << mm1 << mm2; }
	virtual void unmarshal(const sox::Unpack &p) { (void)p;assert(false); }
	virtual std::ostream & trace(std::ostream & os) const { return os << mm1 << mm2; }
};

struct Mulumable : public sox::Marshallable
{
	Mulumable(sox::Marshallable & m1, sox::Marshallable & m2)
		: mm1(m1), mm2(m2) { }

	sox::Marshallable & mm1;
	sox::Marshallable & mm2;

	virtual void marshal(Pack &p) const          { p << mm1 << mm2; }
	virtual void unmarshal(const sox::Unpack &p) { p >> mm1 >> mm2; }
	virtual std::ostream & trace(std::ostream & os) const { return os << mm1 << mm2; }
};

struct Rawmable : public sox::Marshallable
{
	Rawmable(const char * data, size_t size) : m_data(data), m_size(size) {}

	template < class T >
	explicit Rawmable(T & t ) : m_data(t.data()), m_size(t.size()) { }

	const char * m_data;
	size_t m_size;

	virtual void marshal(sox::Pack & p) const   { p.push(m_data, m_size); }
	virtual void unmarshal(const sox::Unpack &) { assert(false); }
	//virtual std::ostream & trace(std::ostream & os) const { return os.write(m_data, m_size); }
};

// base type helper
inline Pack & operator << (Pack & p, bool sign)
{
	p.push_uint8(sign ? 1 : 0);
	return p;
}

inline Pack & operator << (Pack & p, uint8_t  i8)
{
	p.push_uint8(i8);
	return p;
}

inline Pack & operator << (Pack & p, uint16_t  i16)
{
	p.push_uint16(i16);
	return p;
}

inline Pack & operator << (Pack & p, uint32_t  i32)
{
	p.push_uint32(i32);
	return p;
}
inline Pack & operator << (Pack & p, uint64_t  i64)
{
		p.push_uint64(i64);
		return p;
}

inline Pack & operator << (Pack & p, const std::string & str)
{
	p.push_varstr(str);
	return p;
}
//#ifdef WIN32
inline Pack & operator << (Pack & p, const std::wstring & str)
{
	p.push_varwstring32(str);
	return p;
}
//#endif
inline Pack & operator << (Pack & p, const Varstr & pstr)
{
	p.push_varstr(pstr);
	return p;
}

inline const Unpack & operator >> (const Unpack & p, Varstr & pstr)
{
	pstr = p.pop_varstr_ptr();
	return p;
}

// pair.first helper
// XXX std::map::value_type::first_type unpack ��Ҫ�ر���
inline const Unpack & operator >> (const Unpack & p, uint32_t & i32)
{
	i32 =  p.pop_uint32();
	return p;
}

inline const Unpack & operator >> (const Unpack & p, uint64_t & i64)
{
		i64 =  p.pop_uint64();
		return p;
}

inline const Unpack & operator >> (const Unpack & p, std::string & str)
{
	// XXX map::value_type::first_type
	str = p.pop_varstr();
	return p;
}
//#ifdef WIN32
inline const Unpack & operator >> (const Unpack & p, std::wstring & str)
{
	// XXX map::value_type::first_type
	str = p.pop_varwstring32();
	return p;
}
//#endif
inline const Unpack & operator >> (const Unpack & p, uint16_t & i16)
{
	i16 =  p.pop_uint16();
	return p;
}

inline const Unpack & operator >> (const Unpack & p, uint8_t & i8)
{
	i8 =  p.pop_uint8();
	return p;
}

inline const Unpack & operator >> (const Unpack & p, bool & sign)
{
	sign =  (p.pop_uint8() == 0) ? false : true;
	return p;
}


template <class T1, class T2>
inline std::ostream& operator << (std::ostream& s, const std::pair<T1, T2>& p)
{
	s << p.first << '=' << p.second;
	return s;
}

template <class T1, class T2>
inline Pack& operator << (Pack& s, const std::pair<T1, T2>& p)
{
	s << p.first << p.second;
	return s;
}

template <class T1, class T2>
inline const sox::Unpack& operator >> (const sox::Unpack& s, std::pair<const T1, T2>& p)
{
	const T1& m = p.first;
	T1 & m2 = const_cast<T1 &>(m);
	s >> m2 >> p.second;
	return s;
}

template <class T1, class T2>
inline const sox::Unpack& operator >> (const sox::Unpack& s, std::pair<T1, T2>& p)
{
	s >> p.first >> p.second;
	return s;
}
/*
// vc . only need this
template <class T1, class T2>
inline const sox::Unpack& operator>>(const sox::Unpack& s, std::pair<T1, T2>& p)
{
	s >> p.first;
	s >> p.second;
	return s;
}
*/

// container marshal helper

// add by luowl, 20100118
template <class T>
inline Pack& operator << (Pack& p, const std::vector<T>& vec)
{
	marshal_container(p, vec);
	return p;
}

template <class T>
inline const sox::Unpack& operator >> (const sox::Unpack& p, std::vector<T>& vec)
{
	unmarshal_container(p, std::back_inserter(vec)); 
	return p;
}
// end, luowl

template <class T>
inline Pack& operator << (Pack& p, const std::set<T>& set)
{
	marshal_container(p, set);
	return p;
}

template <class T>
inline const sox::Unpack& operator >> (const sox::Unpack& p, std::set<T>& set)
{
	unmarshal_container(p, std::inserter(set, set.begin()));
	return p;
}

template < typename ContainerClass >
inline void marshal_container(Pack & p, const ContainerClass & c)
{
	p.push_uint32(uint32_t(c.size())); // use uint32 ...
	for (typename ContainerClass::const_iterator i = c.begin(); i != c.end(); ++i)
		p << *i;
}

template < typename OutputIterator >
inline void unmarshal_container(const Unpack & p, OutputIterator i)
{
	for (uint32_t count = p.pop_uint32(); count > 0; --count)
	{
		typename OutputIterator::container_type::value_type tmp;
		p >> tmp;
		*i = tmp;
		++i;
	}
}
    
// marshal container like this: list< map<key_type, value_ype> >
// container marshal helper
template < typename ContainerClass >
inline void marshal_composite_container(Pack & p, const ContainerClass & c)
{
    p.push_uint32(uint32_t(c.size())); // use uint32 ...
    for (typename ContainerClass::const_iterator i = c.begin(); i != c.end(); ++i)
        marshal_container(p, *i);
}
// unmarshal container like this: list< map<key_type, value_ype> >
template < typename OutputIterator >
inline void unmarshal_composite_container(const Unpack & up, OutputIterator i)
{
    for (uint32_t count = up.pop_uint32(); count > 0; --count)
    {
        typename OutputIterator::container_type::value_type tmp;
        unmarshal_container(up, std::inserter(tmp, tmp.begin()));
        *i = tmp;
        ++i;
    }
}

template < typename OutputIterator >
inline void unmarshal_container_pair(const Unpack &p, OutputIterator i )
{
	for (uint32_t count = p.pop_uint32(); count > 0; --count)
	{
		typename OutputIterator::container_type::value_type::second_type d;
		typename OutputIterator::container_type::value_type tmp(0,d);
		p >> tmp;
		*i = tmp;
		++i;
	}
}

//add by heiway 2005-08-08
//and it could unmarshal list,vector etc..
template < typename OutputContainer>
inline void unmarshal_containerEx(const Unpack & p, OutputContainer & c)
{
	for(uint32_t count = p.pop_uint32() ; count >0 ; --count)
	{
		typename OutputContainer::value_type tmp;
		tmp.unmarshal(p);
		c.push_back(tmp);
	}
}

template < typename ContainerClass >
inline std::ostream & trace_container(std::ostream & os, const ContainerClass & c, char div='\n')
{
	for (typename ContainerClass::const_iterator i = c.begin(); i != c.end(); ++i)
		os << *i << div;
	return os;
}

inline void PacketToString(const sox::Marshallable &objIn, std::string &strOut)
{
    PackBuffer buffer;
    Pack pack(buffer);
    objIn.marshal(pack);
    strOut.assign(pack.data(), pack.size());
}

#ifdef HAS_EXCEPTION
inline bool StringToPacket(const std::string &strIn, sox::Marshallable &objOut)
{
    try {
        Unpack unpack(strIn.data(), strIn.length());
        objOut.unmarshal(unpack);
    } catch (UnpackError e) {
        return false;
    }
    return true;
}
#else
inline bool StringToPacket(const std::string &strIn, sox::Marshallable &objOut)
{
	Unpack unpack(strIn.data(), strIn.length());
	objOut.unmarshal(unpack);
    return true;
}
#endif


} // namespace sox

#endif // _SNOX_PACKET_H_INCLUDE__
