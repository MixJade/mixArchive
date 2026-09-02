import gzip
import os
from hashlib import pbkdf2_hmac

from Crypto.Cipher import AES

GZIP_MAGIC = b'\x1f\x8b'


def es3_decrypt(enc_data: bytes, key: bytes) -> bytes:
    r = enc_data[:16]
    derived_key = pbkdf2_hmac('sha1', key, r, 100, dklen=16)
    cipher = AES.new(derived_key, AES.MODE_CBC, r)
    ciphertext = enc_data[16:]
    decrypted_data = cipher.decrypt(ciphertext)
    pad_len = decrypted_data[-1]
    decrypted_data = decrypted_data[:-pad_len]
    # EasySave3 enables GZip compression, so the plaintext after AES
    # decryption is gzip-compressed binary. Auto-decompress it.
    if decrypted_data[:2] == GZIP_MAGIC:
        decrypted_data = gzip.decompress(decrypted_data)
    return decrypted_data


def es3_encrypt(dec_data: bytes, key: bytes) -> bytes:
    dec_data = gzip.compress(dec_data)
    iv = os.urandom(16)
    derived_key = pbkdf2_hmac('sha1', key, iv, 100, dklen=16)
    cipher = AES.new(derived_key, AES.MODE_CBC, iv)
    padding_len = 16 - (len(dec_data) % 16)
    padded_data = dec_data + bytes([padding_len] * padding_len)
    ciphertext = cipher.encrypt(padded_data)
    encrypted_data = iv + ciphertext
    return encrypted_data


def main():
    # 大侠立志传存档内置密钥
    key = 'Meow'.encode()

    print('=== 大侠立志传 存档加密/解密工具 ===')
    choice = input('请选择操作（1 解密 / 2 加密）：').strip()
    while choice not in ('1', '2'):
        choice = input('输入无效，请输入 1（解密）或 2（加密）：').strip()

    path = input('请输入文件路径：').strip().strip('"').strip("'")
    while not os.path.isfile(path):
        path = input('文件不存在，请重新输入文件路径：').strip().strip('"').strip("'")

    if choice == '1':
        # 防呆：.dec 文件是上一次解密的产物，已是明文，不再重复解密
        if path.endswith('.dec'):
            print('提示：该文件以 .dec 结尾，是解密输出文件（明文），无需再次解密。')
            print('如需重新加密回存档格式，请选择操作 2（加密）。')
            return
        # 解密：xxx.save -> xxx.save.dec
        output = path + '.dec'
        with open(path, 'rb') as f:
            data = f.read()
        result = es3_decrypt(data, key)
        with open(output, 'wb') as f:
            f.write(result)
        print(f'解密完成，输出文件：{output}')
    else:
        # 加密：优先识别 xxx.save.dec -> xxx.save，否则 -> xxx.save
        if path.endswith('.dec'):
            output = path[:-4]
        else:
            output = path + '.save'
        with open(path, 'rb') as f:
            data = f.read()
        result = es3_encrypt(data, key)
        with open(output, 'wb') as f:
            f.write(result)
        print(f'加密完成，输出文件：{output}')


if __name__ == '__main__':
    main()
