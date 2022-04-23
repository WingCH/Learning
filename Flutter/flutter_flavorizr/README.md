# flutter_flavorizr


> [flutter_flavorizr](https://pub.dev/packages/flutter_flavorizr) is meant to be run once and only once
>
> https://github.com/AngeloAvv/flutter_flavorizr/issues/4#issuecomment-638034165

這個library的設計是只生成**一次**，並不是每次更新再重新生成，這樣會覆蓋舊的文件。

如果要更新的話，可以嘗試使用 `process`

---

## Goals

|           |         Production         | UAT |
| :-------: | :-----------------: | :-------------: |
| bundle Id | com.mall.app | com.mall.app.uat |
| app name  | Mall | UAT Mall |
|   icon    | <img src="doc/README/image-20220423224250389.png" alt="image-20220423224250389" style="zoom: 25%;" /> | <img src="doc/README/image-20220423224215407.png" alt="image-20220423224215407" style="zoom: 25%;" /> |
| base url | https://www.api.com | https://www.uat.api.com |

