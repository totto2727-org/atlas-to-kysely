# atlas-to-kysely

atlas-to-kyselyは、Atlas SQLiteの`schema.hcl`ファイルから、Kysely互換のTypeScriptデータベースインターフェースを生成します。データベース接続やAtlas CLIは必要ありません。

## 使い方

Atlas SQLiteスキーマを`schema.hcl`として保存します。

```hcl
schema "main" {}

table "users" {
  schema = schema.main
  column "id" {
    type           = integer
    null           = false
    auto_increment = true
  }
  column "display_name" {
    type = text
    null = true
  }
}
```

インストールせずに、最新のGoモジュールからコマンドを一度実行します。

```bash
go run github.com/totto2727-org/atlas-to-kysely@latest --input schema.hcl
```

または、インストールせずにNix経由で同じコマンドを実行します。

```bash
nix run 'github:totto2727-org/atlas-to-kysely' -- --input schema.hcl
```

同じ入力は、インストール済みの`atlas-to-kysely`コマンドでも生成できます。

```bash
atlas-to-kysely --input schema.hcl
```

標準出力には、次のKysely互換型が含まれます。

```typescript
import type { Generated } from "kysely";

export interface Users {
  display_name: string | null;
  id: Generated<number>;
}

export interface DB {
  users: Users;
}
```

生成された型をファイルへ出力するか、オプションのKyselyキャメルケース変換を有効にします。

```bash
atlas-to-kysely --input schema.hcl --output src/db/types.ts
atlas-to-kysely --input schema.hcl --camel-case
```

`--output`を指定したコマンドは`src/db/types.ts`を作成または上書きし、結果を標準エラー出力へ表示します。3テーブルのスキーマでは、例えば`Generated: src/db/types.ts  (3 table(s))`と表示されます。

## 主な機能

- `ariga.io/atlas`を通じてAtlas SQLite HCLを直接解析するため、データベース接続やAtlas CLIは必要ありません。
- Atlasのinteger、float、decimal、string、binary、boolean、time、JSON、enum、およびSQLite affinity型をTypeScript型へ変換します。
- nullableなカラムを`T | null`として保持し、デフォルト値またはauto-incrementを持つカラムをKyselyの`Generated<T>`でラップします。
- 恒等変換と、Kyselyのデフォルト`CamelCasePlugin`による識別子変換を1つのbooleanフラグで切り替えます。
- `kysely-codegen`互換の、テーブル・カラム・データベースインターフェースの決定的な並び順で出力します。

## 前提条件

- **Go 1.24以降**: `go install`を使う経路でのみ必要です。
- **flakesを有効にしたNix**: `nix run`、`nix profile add`、およびconsumer flakeを使う経路でのみ必要です。
- **Kysely**: 生成されたカラムが`Generated<T>`ラッパーを使う場合は、TypeScriptプロジェクトに`kysely`を追加してください。

## セットアップ

インストール経路を1つ選んでください。このプロジェクトはnpmパッケージを公開していないため、`npx`と`npm install --global`は利用できません。

### 永続インストールなしで実行する

プロファイルまたは`PATH`へ追加せずに、最新コマンドを取得してヘルプを確認します。

```bash
go run github.com/totto2727-org/atlas-to-kysely@latest --help
```

```bash
nix run 'github:totto2727-org/atlas-to-kysely' -- --help
```

スキーマから型を生成する例と出力は[使い方](#使い方)を参照してください。

### 永続的にインストールする

1. Goモジュールからコマンドをインストールします。

```bash
go install github.com/totto2727-org/atlas-to-kysely@latest
```

2. 公開flakeパッケージをデフォルトのNixプロファイルへインストールします。

```bash
nix profile add 'github:totto2727-org/atlas-to-kysely#atlas-to-kysely'
```

3. consumerの`flake.nix`へパッケージを追加します。この例はCLIを含む再利用可能なパッケージを作成します。必要に応じて`aarch64-darwin`をサポート対象のターゲットへ置き換えてください。

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    atlas-to-kysely.url = "github:totto2727-org/atlas-to-kysely";
  };

  outputs = { nixpkgs, atlas-to-kysely, ... }:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = pkgs.buildEnv {
        name = "schema-tools";
        paths = [ atlas-to-kysely.packages.${system}.atlas-to-kysely ];
      };
    };
}
```

## API

サポート対象のインターフェースは`atlas-to-kysely` CLIです。このリポジトリは`main`パッケージであり、importして利用するGo APIは公開していません。

### フラグ

| フラグ | デフォルト | 説明 |
| --- | --- | --- |
| `--input`、`-i` | 必須 | Atlasの`schema.hcl`ファイルへのパス。 |
| `--output`、`-o` | 標準出力 | 生成する`.ts`ファイルへのパス。 |
| `--camel-case` | `false` | テーブルとカラムの識別子にKyselyのデフォルト`CamelCasePlugin`変換を適用する。 |
| `--help` | — | 使い方とフラグのヘルプを表示し、正常終了する。 |

### 出力

`--output`を指定しない場合、生成したTypeScriptを標準出力へ書き込みます。`--output`を指定した場合はTypeScriptファイルを書き込み、`Generated: <path>  (<count> table(s))`を標準エラー出力へ表示します。`--camel-case`はテーブルとカラムの識別子を変換し、指定しない場合は識別子を保持します。

### 失敗時

必須の入力がない場合、入力ファイルを読み込めない場合、HCLが不正またはスキーマを含まない場合、または出力ファイルを書き込めない場合、コマンドは非ゼロで終了し、標準エラー出力へ`Error:`メッセージを書き込みます。未対応のフラグを渡した場合は、フラグエラーと使い方を表示した後、非ゼロで終了します。

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
