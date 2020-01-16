; From : https://github.com/jNizM/AHK_Scripts/tree/master/src/hash_checksum

; ===============================================================================================================================
; Adler-32 is a checksum algorithm
; ===============================================================================================================================

Adler32(str)
{
    a := 1, b := 0
    loop, parse, str
        b := Mod(b + (a := Mod(a + Asc(A_LoopField), 0xFFF1)), 0xFFF1)
    return Format("{:#x}", (b << 16) | a)
}

; ===============================================================================================================================
; In cryptography, SHA-1 (Secure Hash Algorithm 1) is a cryptographic hash function
; ===============================================================================================================================

SHA1(string, case := 0)
{
    static SHA_DIGEST_LENGTH := 20
    hModule := DllCall("LoadLibrary", "Str", "advapi32.dll", "Ptr")
    , VarSetCapacity(SHA_CTX, 136, 0), DllCall("advapi32\A_SHAInit", "Ptr", &SHA_CTX)
    , DllCall("advapi32\A_SHAUpdate", "Ptr", &SHA_CTX, "AStr", string, "UInt", StrLen(string))
    , DllCall("advapi32\A_SHAFinal", "Ptr", &SHA_CTX, "UInt", &SHA_CTX + 116)
    loop % SHA_DIGEST_LENGTH
        o .= Format("{:02" (case ? "X" : "x") "}", NumGet(SHA_CTX, 115 + A_Index, "UChar"))
    return o, DllCall("FreeLibrary", "Ptr", hModule)
}

; ===============================================================================================================================
; The MD5 algorithm is a widely used hash function producing a 128-bit hash value
; ===============================================================================================================================

MD5(string, case := 0)
{
    static MD5_DIGEST_LENGTH := 16
    hModule := DllCall("LoadLibrary", "Str", "advapi32.dll", "Ptr")
    , VarSetCapacity(MD5_CTX, 104, 0), DllCall("advapi32\MD5Init", "Ptr", &MD5_CTX)
    , DllCall("advapi32\MD5Update", "Ptr", &MD5_CTX, "AStr", string, "UInt", StrLen(string))
    , DllCall("advapi32\MD5Final", "Ptr", &MD5_CTX)
    loop % MD5_DIGEST_LENGTH
        o .= Format("{:02" (case ? "X" : "x") "}", NumGet(MD5_CTX, 87 + A_Index, "UChar"))
    return o, DllCall("FreeLibrary", "Ptr", hModule)
}

; ===============================================================================================================================
; CRC32 Implementation in AutoHotkey
; ===============================================================================================================================

CRC32(str)
{
    static table := []
    loop 256 {
        crc := A_Index - 1
        loop 8
            crc := (crc & 1) ? (crc >> 1) ^ 0xEDB88320 : (crc >> 1)
        table[A_Index - 1] := crc
    }
    crc := ~0
    loop, parse, str
        crc := table[(crc & 0xFF) ^ Asc(A_LoopField)] ^ (crc >> 8)
    return Format("{:#x}", ~crc)
}
