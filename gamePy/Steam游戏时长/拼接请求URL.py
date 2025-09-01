# coding=utf-8
# @Time    : 2025/4/2 20:16
# @Software: PyCharm

# Steam_app下载地址：https://store.steampowered.com//mobile#mobile_section
# 手机steam登不上可以下个手机版的uu加速器

# 替换为你的API Key和SteamID
# API_Key(32位字符): Steam-帮助-客服-我的账号-你steam账户的相关数据-开发者设置-输入localhost
API_KEY = "你的API_KEY"
# SteamID(17位数字): Steam个人资料页的地址栏参数
STEAM_ID = "你的SteamID"

API_URL = f"https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key={API_KEY}&steamid={STEAM_ID}&include_appinfo=true"
print(f"请求URL: {API_URL}")
# 剩下的请求不用看了，只能浏览器打开链接自己复制
