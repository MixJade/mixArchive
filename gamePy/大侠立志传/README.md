# 大侠立志传（Hero's Adventure）存档加密/解密工具

基于 EasySave3 存档格式：前 16 字节为 IV，PBKDF2-HMAC-SHA1（密钥 + IV，100 轮，16 字节）派生密钥，AES-128-CBC 加密，数据部分为 GZip 压缩的明文 JSON。密钥 `Meow` 已内置。

## 使用方式

直接运行，按提示交互：

```bash
python es3_cipher_tool.py
```

- 输入 `1` 解密：输入存档文件（如 `Save19/SaveObjectGame.save`），输出同目录下的 `xxx.save.dec`（明文 JSON，可直接编辑）
- 输入 `2` 加密：输入编辑后的 `.dec` 文件，自动还原为 `xxx.save`（游戏可直接读取）

文件路径支持拖拽进来带引号的路径（自动去除引号）。
