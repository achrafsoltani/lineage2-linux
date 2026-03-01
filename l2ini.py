#!/usr/bin/env python3
"""L2.ini decrypt/encrypt tool for Lineage 2 Interlude (Lineage2Ver413 format)."""

import zlib, struct, binascii, re, sys, os

MODULUS = int(
    "75b4d6de5c016544068a1acf125869f43d2e09fc55b8b1e289556daf9b875763"
    "5593446288b3653da1ce91c87bb1a5c18f16323495c55d7d72c0890a83f69bfd"
    "1fd9434eb1c02f3e4679edfa43309319070129c267c85604d87bb65bae205de3"
    "707af1d2108881abb567c3b3d069ae67c3a4c6a3aa93d26413d4c66094ae2039",
    16,
)
PRIV_EXP = 0x1D
PUB_EXP = int(
    "30b4c2d798d47086145c75063c8e841e719776e400291d7838d3e6c4405b504c"
    "6a07f8fca27f32b86643d2649d1d5f124cdd0bf272f0909dd7352fe10a77b34d"
    "831043d9ae541f8263c6fe3d1c14c2f04e43a7253a6dda9a8c1562cbd493c1b6"
    "31a1957618ad5dfe5ca28553f746e2fc6f2db816c7db223ec91e955081c1de65",
    16,
)


def align4(x):
    return (x + 3) & ~3


def decrypt(filepath):
    with open(filepath, "rb") as f:
        data = f.read()
    body = data[28:-20]
    payloads = []
    for i in range(len(body) // 128):
        block = body[i * 128 : (i + 1) * 128]
        plain = pow(int.from_bytes(block, "big"), PRIV_EXP, MODULUS).to_bytes(128, "big")
        size = plain[3]
        start = 128 - align4(size)
        payloads.append(plain[start : start + size])
    return zlib.decompress(b"".join(payloads)[4:])


def encrypt(plaintext_bytes, output_path):
    compressed = zlib.compress(plaintext_bytes)
    payload = struct.pack("<I", len(plaintext_bytes)) + compressed
    blocks = []
    offset = 0
    while offset < len(payload):
        chunk = payload[offset : offset + 124]
        block = bytearray(128)
        block[3] = len(chunk)
        start = 128 - align4(len(chunk))
        block[start : start + len(chunk)] = chunk
        blocks.append(bytes(block))
        offset += 124
    encrypted = b"".join(
        pow(int.from_bytes(b, "big"), PUB_EXP, MODULUS).to_bytes(128, "big") for b in blocks
    )
    header = "Lineage2Ver413".encode("utf-16-le")
    body = header + encrypted
    crc = binascii.crc32(body) & 0xFFFFFFFF
    with open(output_path, "wb") as f:
        f.write(body + b"\x00" * 12 + struct.pack("<I", crc) + b"\x00" * 4)


def find_ini():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    for candidate in [
        os.path.join(script_dir, "system", "l2.ini"),
        os.path.join(script_dir, "system", "L2.ini"),
        os.path.join(script_dir, "client", "system", "l2.ini"),
        os.path.join(script_dir, "client", "system", "L2.ini"),
    ]:
        if os.path.isfile(candidate):
            return candidate
    return None


def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <command> [args]")
        print(f"  {sys.argv[0]} status           Show current server address")
        print(f"  {sys.argv[0]} decrypt          Decrypt L2.ini to stdout")
        print(f"  {sys.argv[0]} set <ip>         Set server address")
        print(f"  {sys.argv[0]} decrypt <path>   Decrypt a specific L2.ini file")
        sys.exit(1)

    cmd = sys.argv[1].lower()
    ini = sys.argv[2] if len(sys.argv) >= 3 and os.path.isfile(sys.argv[2]) else find_ini()

    if not ini:
        print("Error: could not find L2.ini. Specify the path as an argument.")
        sys.exit(1)

    if cmd == "decrypt":
        print(decrypt(ini).decode("utf-8"))
    elif cmd == "status":
        text = decrypt(ini).decode("utf-8")
        for line in text.splitlines():
            if line.strip().startswith("ServerAddr="):
                print(f"Server: {line.strip().split('=', 1)[1]}")
                return
        print("ServerAddr not found")
    elif cmd == "set" and len(sys.argv) >= 3:
        addr = sys.argv[2]
        text = decrypt(ini).decode("utf-8")
        new_text = re.sub(r"ServerAddr=[\d.]+", f"ServerAddr={addr}", text)
        encrypt(new_text.encode("utf-8"), ini)
        print(f"Server set to {addr}")
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)


if __name__ == "__main__":
    main()
