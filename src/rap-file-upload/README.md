# RAP でのファイルアップロード実装について

## 背景

ファイルアップロードしたい場合、ファイルデータのみだけではなく、他のフォームデータもあわせて送信したいことが多いが、　RAP ではおそらく、 `Content-Type: multipart/form-data` のリクエストは扱えない。  
このため、アップロードリクエストの扱いだけを考えると、　RAP ではなく、 `if_http_service_extension` を利用して HTTP サービスを実装する方がよいが、アップロード処理には DB への登録・更新・削除処理など　RAP フレームワークを利用したい処理が色々含まれることがほとんどだと思われるため、 RAP を利用してファイルアップロードを実装する方法について記述する。

## 方法

基本的に、 https://qiita.com/tami/items/e030ad2ce87d26dd3b75 で紹介されているやり方（アップロード処理部分）でOK。  
処理としては、フロントエンド側でファイルデータを取得して BASE64 エンコードして JSON にセットして送信し、　RAP では BASE64 デコードする方式となる。  
上の記事では、 JSON データとなる Abstract Entity のファイルデータの型を `abap.rawstring(0)` としているが、実際には　BASE64 エンコード済の文字列を送信するので、次のように `abap.string(0)` でよい。  

```
@EndUserText.label: 'ZI_FILE01'
define abstract entity ZI_FILE01
{
    mimeType : abap.string(0);
    fileName: abap.string(0);
    fileContent: abap.string(0);
    fileExtension: abap.string(0);    
}
```

Behavior Definition の実装は、次のような感じになる。

```
  METHOD upload.
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.
    CHECK sy-subrc = 0.
    DATA(file_content) = <ls_keys>-%param-fileContent.

    "BASE64 ecodeded sting -> decoded xstring
    DATA(decode_base64_xstr) = cl_web_http_utility=>decode_x_base64( encoded = file_content ).
    ...
  ENDMETHOD.
```

## 例.

### テーブル

```
@EndUserText.label : 'ZLEARNIN01'
@AbapCatalog.enhancement.category : #NOT_EXTENSIBLE
@AbapCatalog.tableCategory : #TRANSPARENT
@AbapCatalog.deliveryClass : #A
@AbapCatalog.dataMaintenance : #RESTRICTED
define table zlearnin01 {
  key client            : abap.clnt not null;
  key id                : abap.raw(16) not null;
  name                  : abap.char(10);
  val                   : abap.int4;
  created_by            : abp_creation_user;
  created_at            : abp_creation_tstmpl;
  last_changed_by       : abp_locinst_lastchange_user;
  local_last_changed_at : abp_locinst_lastchange_tstmpl;
  last_changed_at       : abp_lastchange_tstmpl;
}
```

### BDEF

```
managed implementation in class ZBP_R_LEARNIN01 unique;
strict ( 2 );
with draft;
extensible;
define behavior for ZR_LEARNIN01 alias ZrLearnin01
persistent table ZLEARNIN01
extensible
draft table ZLEARNIN01_D
etag master LocalLastChangedAt
lock master total etag LastChangedAt
authorization master( global )
{
  field ( mandatory : create )
   ID;

  field ( readonly )
   CreatedBy,
   CreatedAt,
   LastChangedBy,
   LocalLastChangedAt,
   LastChangedAt;

  field ( readonly : update )
   ID;


  create;
  update;
  delete;

  draft action Activate optimized;
  draft action Discard;
  draft action Edit;
  draft action Resume;
  draft determine action Prepare;

  static action upload parameter ZI_FILE01;

  mapping for ZLEARNIN01 corresponding extensible
  {
    ID = id;
    Name = name;
    Val = val;
    CreatedBy = created_by;
    CreatedAt = created_at;
    LastChangedBy = last_changed_by;
    LocalLastChangedAt = local_last_changed_at;
    LastChangedAt = last_changed_at;
  }
}
```

```
projection implementation in class ZBP_C_LEARNIN01 unique;
strict ( 2 );
extensible;
use draft;
use side effects;
define behavior for ZC_LEARNIN01 alias ZcLearnin01
extensible
use etag
{
  use create;
  use update;
  use delete;

  use action Edit;
  use action Activate;
  use action Discard;
  use action Resume;
  use action Prepare;

  use action upload;
}
```

### BDEF 実装

```
CLASS lhc_zr_learnin01 DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING
      REQUEST requested_authorizations FOR ZrLearnin01
      RESULT result.

    METHODS upload FOR MODIFY
      IMPORTING keys FOR ACTION ZrLearnin01~upload.
ENDCLASS.

CLASS lhc_zr_learnin01 IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD upload.
    READ TABLE keys ASSIGNING FIELD-SYMBOL(<ls_keys>) INDEX 1.
    CHECK sy-subrc = 0.
    DATA(file_content) = <ls_keys>-%param-fileContent.

    "BASE64 ecodeded sting -> decoded xstring
    DATA(decode_base64_xstr) = cl_web_http_utility=>decode_x_base64( encoded = file_content ).
  ENDMETHOD.
ENDCLASS.
```

## フロントエンド側の実装について

前述の記事の通りでOK。  
なお、

```
onst operation = model?.bindContext("/Product/" + this.namespace + "fileUpload(...)") as ODataContextBinding
```

となっている箇所で `this.namespace` は `namespace = "com.sap.gateway.srvd.zui_yproduct_o4.v0001."` となっているが、 `bindContext` の引数のパスには　`/エンティティ名/ネームスペース.action名(...)`　を指定すればよく、ネームスペースは OData の metadata の `<Schema Namespace="..." ...>` を見ればよい。
