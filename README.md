# AROB2023 実験スクリプト

## コマンド
### APSのデータを生成する
- https://doi.org/10.6084/m9.figshare.13308428.v1 からデータをダウンロードする
  - zipファイルを解凍すると中に `APS_aff_data_ISI_original` ディレクトリがある

```sh
julia --proj src/tasks/PreprocessingAPS.jl <path-to-APS_aff_data_ISI_original>
```

### モデルを走らせて相互作用の履歴データを生成する

```sh
julia --proj --threads=auto src/tasks/RunModel.jl
```

`results/generated_histories` に生成されたデータが格納される。