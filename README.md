# study-local-glue

AWS Glueのローカル環境

## 初期設定

1. direnvをインストール
2. `cp .envrc.sample .envrc` を実行して、 `AWS_ACCESS_KEY_ID` と `AWS_SECRET_ACCESS_KEY` を修正
3. `docker-compose build` , `docker-compose up` を実行

### サンプルCSVを配置する

```console
aws s3 mb s3://test-csv --endpoint-url="http://localhost:4566"
aws s3 cp sample.csv s3://test-csv/ --endpoint-url="http://localhost:4566"
```

## 実行

```console
docker-compose exec glue ./bin/bash
aws-glue-libs/bin/gluesparksubmit /share/glue.py --JOB_NAME 'test'
```

## S3からローカルにダウンロードして確認

```console
aws s3 cp s3://test-csv/write ~/Downloads --recursive --endpoint-url="http://localhost:4566"
```

## 参考サイト

- <https://docs.aws.amazon.com/ja_jp/glue/latest/dg/aws-glue-programming-etl-libraries.html>
- <https://future-architect.github.io/articles/20191101/>
- <https://takap.net/local_glue_docker/>
- <https://dev.classmethod.jp/articles/aws-glue-local/>
