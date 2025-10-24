# DockerイメージをミラーするTerraform

このリポジトリは、指定したコンテナイメージを AWS Elastic Container Registry (ECR) にミラーリングするための Terraform 定義です。既存の公開イメージをそのままコピーするケースと、ローカルでビルドしたカスタムイメージを ECR にプッシュするケースの両方をサポートします。

## 前提条件

- Terraform 1.10.3 以上
- AWS CLI v2 以降 (認証済みプロファイルまたは環境変数が設定されていること)
- Docker CLI (ローカルで pull/build/push が可能な状態)
- `aws`, `docker` に PATH が通っていること

## ディレクトリ構成

```text
.
├── main.tf               # `mirror_image` モジュールを複数展開
├── variables.tf          # ルートモジュールの入力変数
├── outputs.tf            # ルートモジュールの出力値
├── terraform.tf          # Terraform / AWS プロバイダーの要件
├── terraform.tfvars      # サンプルの変数定義
├── modules/
│   └── mirror_image/     # ECR 作成とイメージ push を行うモジュール
├── scripts/
│   ├── mirror_push.sh    # 既存イメージをコピーするスクリプト
│   └── build_push.sh     # カスタムビルド後に push するスクリプト
└── custom_images/        # カスタムビルド用の Docker コンテキスト
```

## 使い方

1. 変数ファイルを準備する
   - `terraform.tfvars` を編集するか、環境に応じた `.tfvars` ファイルを用意します。
2. Terraform を初期化する
   - `terraform init`
3. planを確認する
   - `terraform plan`
4. リソースを作成し、イメージを push する
   - `terraform apply`
   - apply 中に `scripts/` 配下のスクリプトが `local-exec` で呼び出され、Docker を使ってイメージがプッシュされます。
5. 後片付け
   - イメージやリポジトリが不要になった場合は `terraform destroy`

> **注意:**  
> apply 時に Docker デーモンが起動していない、あるいは AWS CLI の認証が切れていると push に失敗します。事前に `aws sts get-caller-identity` や `docker info` で確認しておくと安全です。

## `mirror_images` 変数の書き方

`mirror_images` はミラーリングしたいイメージごとの設定配列です。最低限 `name` と `source_image_ref` を指定します。

```hcl
mirror_images = [
  {
    name             = "nginx"
    source_image_ref = "docker.io/library/nginx:1.25"
    force_delete     = true
  },
  {
    name                = "custom-app"
    source_image_ref    = "alpine:3.22.2"
    alias_tag           = "v1.0.0"
    enable_custom_build = true
  }
]
```

### 各フィールドの説明

- `name` (必須): 作成する ECR リポジトリ名。Terraform 内部では一意である必要があります。
- `source_image_ref` (必須): ミラーリング元のイメージ参照 (`リポジトリ:タグ` 形式)。カスタムビルド時もベースとなるイメージとして pull されます。
- `alias_tag`: ECR に push する際のタグ。未指定の場合は `source_image_ref` のタグ部分がそのまま使われます。
- `force_delete`: Terraform destroy 時にリポジトリ内にイメージが残っていても強制削除する場合に `true`。
- `enable_custom_build`: `true` にすると `scripts/build_push.sh` が実行され、`custom_images/` 配下の Dockerfile を使ってビルドしたイメージを push します。`false` (既定) の場合は `scripts/mirror_push.sh` で単純コピーされます。

## カスタムビルドの配置ルール

- `enable_custom_build = true` のリポジトリは `custom_images/` 以下にビルドコンテキストを配置します。
- ディレクトリ名は `name` のハイフン (`-`) をアンダースコア (`_`) に置き換えたものにしてください。
  - 例: `name = "custom-app"` → `custom_images/custom_app/`
- ビルド時には `docker build -t <ECR_URL>:<tag> <コンテキスト>` が実行されます。追加のファイルやマルチステージビルドも通常の Dockerfile と同様に記述できます。

## 出力値

`terraform apply` 後は以下の出力値が得られます。

- `repository_urls`: `{ name => ECR リポジトリ URL }`
- `repository_arns`: `{ name => ECR リポジトリ ARN }`
- `repository_names`: `{ name => ECR リポジトリ名 }`

## トラブルシューティング

- **Docker push に失敗する**: `docker login` が必要な場合があります。スクリプトは `aws ecr get-login-password` を使用して自動的にログインしますが、`aws` CLI の資格情報が有効か確認してください。
- **カスタムビルドのコンテキストが見つからない**: Terraform のエラーメッセージに表示されたパスが正しいか確認し、`name` とディレクトリ名の変換ルールが一致しているか再チェックしてください。
- **destroy 時にリポジトリ削除が失敗する**: `force_delete = true` を設定すると、イメージが残っていても削除できます。ただし誤削除に注意してください。