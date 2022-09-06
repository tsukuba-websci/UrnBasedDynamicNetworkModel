# AROB2023 実験スクリプト

## コマンド
### モデルを走らせて相互作用の履歴データを生成する

```sh
julia --proj=. --threads=auto src/tasks/RunModel.jl
```

`results/generated_histories` に生成されたデータが格納される。