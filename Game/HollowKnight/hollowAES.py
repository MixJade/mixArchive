# coding=utf-8
# @Time    : 2025/8/25 21:29
# @Software: PyCharm
import base64

from Crypto.Cipher import AES
from Crypto.Util.Padding import pad, unpad

# 常量定义
c_sharp_header = bytes([0, 1, 0, 0, 0, 255, 255, 255, 255, 1, 0, 0, 0, 0, 0, 0, 0, 6, 1, 0, 0, 0])
aes_key = 'UKu52ePUBwetZ9wNX88o54dnfKRu0T1l'.encode('utf-8')

# 初始化AES ECB模式加密器
cipher = AES.new(aes_key, AES.MODE_ECB)


def aes_decrypt(bytes_data: bytes) -> bytes:
    """AES解密并移除PKCS7填充"""
    decrypted = cipher.decrypt(bytes_data)
    # 移除PKCS7填充
    return unpad(decrypted, AES.block_size)


def aes_encrypt(bytes_data: bytes) -> bytes:
    """PKCS7填充后进行AES加密"""
    # 使用PKCS7填充
    padded = pad(bytes_data, AES.block_size)
    return cipher.encrypt(padded)


def generate_length_prefixed_string(length: int) -> bytes:
    """生成长度前缀字符串（参考MSDN规范）"""
    length = min(0x7FFFFFFF, length)
    bytes_list = []
    for _ in range(4):
        if (length >> 7) != 0:
            bytes_list.append((length & 0x7F) | 0x80)
            length >>= 7
        else:
            bytes_list.append(length & 0x7F)
            length >>= 7
            break
    if length != 0:
        bytes_list.append(length)
    return bytes(bytes_list)


def add_header(bytes_data: bytes) -> bytes:
    """添加固定头部和长度前缀"""
    length_data = generate_length_prefixed_string(len(bytes_data))
    # 计算总长度：固定头部 + 长度前缀 + 数据 + 结尾固定字节(11)
    total_length = len(c_sharp_header) + len(length_data) + len(bytes_data) + 1
    new_bytes = bytearray(total_length)

    # 设置固定头部
    new_bytes[:len(c_sharp_header)] = c_sharp_header
    # 设置长度前缀
    new_bytes[len(c_sharp_header):len(c_sharp_header) + len(length_data)] = length_data
    # 设置数据
    start_idx = len(c_sharp_header) + len(length_data)
    new_bytes[start_idx:start_idx + len(bytes_data)] = bytes_data
    # 设置结尾固定字节
    new_bytes[-1] = 11

    return bytes(new_bytes)


def remove_header(bytes_data: bytes) -> bytes:
    """移除头部信息"""
    # 移除固定头部和结尾的11
    bytes_data = bytes_data[len(c_sharp_header):-1]

    # 移除长度前缀
    length_count = 0
    for i in range(5):
        length_count += 1
        if (bytes_data[i] & 0x80) == 0:
            break

    return bytes_data[length_count:]


def decode(bytes_data: bytes) -> str:
    """解码流程：去头部 -> Base64解码 -> AES解密 -> 转字符串"""
    bytes_data = remove_header(bytes_data)
    bytes_data = base64.b64decode(bytes_data)
    bytes_data = aes_decrypt(bytes_data)
    return bytes_data.decode('utf-8')


def encode(json_string: str) -> bytes:
    """编码流程：字符串转字节 -> AES加密 -> Base64编码 -> 添加头部"""
    bytes_data = json_string.encode('utf-8')
    bytes_data = aes_encrypt(bytes_data)
    bytes_data = base64.b64encode(bytes_data)
    return add_header(bytes_data)
