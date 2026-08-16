# atlas-to-kysely

atlas-to-kyselyは、Atlas SQLiteの`schema.hcl`ファイルから、Kysely互換のTypeScriptデータベースインターフェースを生成します。データベース接続やAtlas CLIは必要ありません。

## 使い方

インストールしたコマンドにAtlasスキーマを渡し、生成された型を標準出力へ出力します。

```bash
atlas-to-kysely --input schema.hcl
```

生成された型をファイルへ出力するか、オプションのKyselyキャメルケース変換を有効にします。

```bash
atlas-to-kysely --input schema.hcl --output src/db/types.ts
atlas-to-kysely --input schema.hcl --camel-case
```

リポジトリのfixtureを使ってローカルで一連の処理を実行できます。

```bash
go run . --input fixture/main/schema.hcl --output /tmp/types.ts
```

## 主な機能

- `ariga.io/atlas`を通じてAtlas SQLite HCLを直接解析するため、データベース接続やAtlas CLIは必要ありません。
- Atlasのinteger、float、decimal、string、binary、boolean、time、JSON、enum、およびSQLite affinity型をTypeScript型へ変換します。
- nullableなカラムを`T | null`として保持し、デフォルト値またはauto-incrementを持つカラムをKyselyの`Generated<T>`でラップします。
- 恒等変換と、Kyselyのデフォルト`CamelCasePlugin`による識別子変換を1つのbooleanフラグで切り替えます。
- `kysely-codegen`互換の、テーブル・カラム・データベースインターフェースの決定的な並び順で出力します。

## 前提条件

- **Go 1.24以降**: `go run`、`go install`、またはソースからのビルドに必要です。
- **Kysely**: 生成されたカラムが`Generated<T>`ラッパーを使う場合は、TypeScriptプロジェクトに`kysely`を追加してください。

## セットアップ

1. Goモジュールからコマンドをインストールします。

```bash
go install github.com/totto2727-org/atlas-to-kysely@latest
```

2. Atlasスキーマがあるディレクトリからコマンドを実行します。

```bash
atlas-to-kysely --input schema.hcl --output src/db/types.ts
```

3. または、リポジトリをcloneしてGoから直接実行します。

```bash
git clone https://github.com/totto2727-org/atlas-to-kysely.git
cd atlas-to-kysely
go run . --input fixture/main/schema.hcl
```

## API

サポート対象のインターフェースは`atlas-to-kysely` CLIです。Atlas SQLiteスキーマを読み込み、キャメルケース変換を任意で適用したKysely互換のTypeScriptを標準出力または出力ファイルへ書き込みます。このリポジトリは`main`パッケージであり、importして利用するGo APIは公開していません。フラグ、出力動作、失敗条件については[完全なCLIリファレンス](./AGENTS.md#cli-reference)を参照してください。

## 型マッピング

| AtlasまたはSQLiteの型 | TypeScript型 |
| --- | --- |
| `int`、`integer`、または`INT`を含む名前 | `number` |
| `real`、`float`、`double`、または`REAL`、`FLOA`、`DOUB`を含む名前 | `number` |
| `numeric`、`decimal`、または`NUMERIC`、`DECIMAL`を含む名前 | `number` |
| `text`、`char`、`clob`、または`TEXT`、`CHAR`、`CLOB`を含む名前 | `string` |
| `boolean`、`bool` | `boolean` |
| `blob`または空のSQLite型名 | `Uint8Array` |
| `date`、`datetime`、`timestamp` | `string` |
| `json`、`jsonb` | `string` |
| `enum("a", "b")` | `"a" \| "b"` |
| `null = true` | `T \| null` |
| デフォルト値または`auto_increment` | `Generated<T>` |

## 開発

リポジトリ構成、開発コマンド、コントリビューター向けガイダンスについては[AGENTS.md](./AGENTS.md)を参照してください。

## ライセンス

現在、このリポジトリにはライセンスファイルが含まれていません。

_This README was generated from the [share-artifact skill](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/SKILL.md) and [README template](https://raw.githubusercontent.com/totto2727-org/agent/refs/heads/main/plugins/totto2727-coding/skills/share-artifact/readme/template.md)._
