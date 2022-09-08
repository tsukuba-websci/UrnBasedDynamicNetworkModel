# AROB2023 実験スクリプト
## セットアップ
Julia の環境が必要。公式ページなどを参考にインストールする。
インストールした後、下記の手順で実験環境を構築する。ただし `<>` で囲んだ部分はキーボードのキー入力。


```sh
$ julia --proj
julia> <]>
(AROB2023) pkg> instantiate
(AROB2023) pkg> <delete>
```

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

- `results/generated_histories` に生成されたデータが格納される

### ベースモデルを走らせて相互作用の履歴データを生成する
```
julia --proj --threads=auto src/tasks/RunBaseModel.jl
```

- `results/generated_histories--base` に生成されたデータが格納される

### 相互作用の履歴データを分析して各種計測値を出す
- 事前に [モデルを走らせて相互作用の履歴データを生成する](#モデルを走らせて相互作用の履歴データを生成する) を実行しておく必要がある

```sh
# --base を付けるとベースモデルの分析になる
julia --proj --threads=auto src/tasks/AnalyzeModels.jl [--base]
```

- `results/analyzed_models.csv` または `results/analyzed_models--base.csv` に結果が保存される

```CSV
rho,nu,zeta,eta,gamma,c,oc,oo,nc,no,y,r,h,g
1,1,0.1,0.1,0.978818015295141,0.4047009698275862,0.30058742657167853,0.13123359580052493,0.20784901887264093,0.3603299587551556,0.5129046442573314,4.261350121900458,0.9715045696696164,0.45763423462530417
```

### ターゲットデータを分析して各種計測値を出す

```sh
julia --proj src/tasks/AnalyzeTargets.jl
```

- `results/analyzed_targets` に結果データが格納される

```CSV
rho,nu,zeta,eta,gamma,c,oc,oo,nc,no,y,r,h,g
0,0,0.0,0.0,0.9984550695169351,0.03842432619212163,0.009248843894513185,0.14085739282589677,0.019997500312460944,0.8298962629671292,0.7471551524820348,0.05822546891664884,0.989713855195076,0.21895938205559523
```

### 各種計測値をモデルにフィッティングする
- 事前に [相互作用の履歴データを分析して各種計測値を出す](#相互作用の履歴データを分析して各種計測値を出す) を実行しておく必要がある
- 事前に [ターゲットデータを分析して各種計測値を出す](#ターゲットデータを分析して各種計測値を出す) を実行しておく必要がある

```sh
# --base を付けるとベースモデルの分析になる
julia --proj src/tasks/CalcDiffs.jl [--base]
```

- `results/distances` または `results/distances--base` に結果が格納される

```CSV
rho,nu,zeta,eta,aps
8,10,0.1,0.5,0.3017873533979937
```


### クラス分類の変化を分析する

```sh
julia --proj src/tasks/AnalyzeClassification.jl
```

- `results/analyzed_classification` に結果が格納される


### クラス分類の結果をプロットする
- [クラス分類の変化を分析する](#クラス分類の変化を分析する) を実行しておく必要がある

```sh
julia --proj src/tasks/PlotAnalyzedClassification.jl
```
## 未整理コマンド
### クラス分類の割合推移をグラフ化する

```sh
julia --proj src/tasks/PlotClassificationRatio.jl
```