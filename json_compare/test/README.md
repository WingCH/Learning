# JSON 結構比對工具測試案例

此目錄包含用於測試 JSON 結構比對工具的測試案例。

## 測試案例目錄

### case1 - 型態改變
- `expected.json`: 包含字串類型的 ID
- `actual.json`: 包含數字類型的 ID
- 預期結果: `Type Mismatch: id (expected: string, actual: integer)`

### case2 - 欄位缺失
- `expected.json`: 包含 name 和 email 欄位
- `actual.json`: 只包含 name 欄位
- 預期結果: `Missing Field: email`

### case3 - 複雜巢狀結構
- `expected.json`: 包含複雜的巢狀用戶資料結構
- `actual.json`: 包含與預期有多處差異的實際資料
- 預期結果:
  ```
  Type Mismatch: user.id (expected: string, actual: integer)
  Field Missing: user.profile.age
  Field Missing: user.profile.contact.phone
  Type Mismatch: user.roles (expected: array, actual: string)
  Field Missing: user.settings.notifications
  New Field: user.settings.language
  ```

### case4 - 層級改變
- `expected.json`: name 欄位在 profile 子物件中
- `actual.json`: name 欄位直接在 user 物件底下
- 預期結果:
  ```
  Field Missing: user.profile.name
  New Field: user.name
  ```

## 使用方法

這些測試案例可以用於驗證 JSON 結構比對工具的功能是否符合需求，包括:
1. 欄位型態變更檢測
2. 欄位缺失檢測
3. 新增欄位檢測
4. 巢狀結構處理
5. 複雜資料結構比對 