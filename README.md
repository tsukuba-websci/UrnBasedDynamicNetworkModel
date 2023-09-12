# PLOSONE "Simulating Emergence of Novelties Using Agent-Based Models" 実験スクリプト

## セットアップ
### Julia
Julia の環境が必要。公式ページなどを参考にインストールする。
インストールした後、下記の手順で実験環境を構築する。ただし `<>` で囲んだ部分はキーボードのキー入力。

```sh
$ julia --proj
julia> <]>
(AROB2023) pkg> instantiate
(AROB2023) pkg> <delete>
```

### Python
一部の分析には Python の環境が必要。

```sh
# 必要なモジュールのインストール
poetry install
```

## 実験
### ターゲットデータであるAPSのデータを生成する
- https://doi.org/10.6084/m9.figshare.13308428.v1 からデータをダウンロードし、以下のコマンドを実行する。
  - zipファイルを解凍すると中に `APS_aff_data_ISI_original` ディレクトリがある。
- 既に生成したデータが`data/`に保存されているため、これをそのまま利用しても良い。

```sh
julia --proj src/tasks/PreprocessingAPS.jl <path-to-APS_aff_data_ISI_original>
```

### モデルを走らせて相互作用の履歴データを生成する
#### Proposed Model
以下のコマンドで、戦略sを入力して実行する。
（実行に時間がかかるため、戦略ごとに分けて実行できるようにしている）
```sh
# sには戦略"asw"か"wsw"を入力して下さい
julia --proj --threads=auto src/tasks/RunModel.jl <s>
```
`results/generated_histories` に生成されたデータが格納される。

#### Ubaldi et al. Model
```sh
julia --proj --threads=auto src/tasks/RunBaseModel.jl
```
`results/generated_histories--base` に生成されたデータが格納される。

#### Suda et al. Model
```sh
julia --proj --threads=auto src/tasks/RunPgbkModel.jl
```
`results/generated_histories--pgbk` に生成されたデータが格納される。


### 相互作用の履歴データを分析して各種計測値を出す
事前に [モデルを走らせて相互作用の履歴データを生成する](#モデルを走らせて相互作用の履歴データを生成する) を実行しておく必要がある。

```sh
# modelには"proposed"か"base"、"pgbk"を入力して下さい
# 指定しない場合はProposed Modelになります
julia --proj --threads=auto src/tasks/AnalyzeModels.jl <model>
```

`results/analyzed_models/`にモデル、戦略ごとに以下のような形式で結果が保存される。

```CSV
rho,nu,zeta,eta,gamma,c,oc,oo,nc,no,y,r,h,g
1,1,0.1,0.1,0.978818015295141,0.4047009698275862,0.30058742657167853,0.13123359580052493,0.20784901887264093,0.3603299587551556,0.5129046442573314,4.261350121900458,0.9715045696696164,0.45763423462530417
```

### ターゲットデータを分析して各種計測値を出す

```sh
julia --proj src/tasks/AnalyzeTargets.jl
```

`results/analyzed_targets` に結果データが格納される。

```CSV
rho,nu,zeta,eta,gamma,c,oc,oo,nc,no,y,r,h,g
0,0,0.0,0.0,0.9984550695169351,0.03842432619212163,0.009248843894513185,0.14085739282589677,0.019997500312460944,0.8298962629671292,0.7471551524820348,0.05822546891664884,0.989713855195076,0.21895938205559523
```

### 各種計測値をモデルにフィッティングする
ターゲットデータとモデルを走らせた結果の各種計測値の差を計算する。

以下を実行しておく必要がある。
- [相互作用の履歴データを分析して各種計測値を出す](#相互作用の履歴データを分析して各種計測値を出す)
- [ターゲットデータを分析して各種計測値を出す](#ターゲットデータを分析して各種計測値を出す)

```sh
# modelには"proposed"か"base"、"pgbk"を入力して下さい
# 指定しない場合はProposed Modelになります
julia --proj src/tasks/CalcDiffs.jl <model>
```

`results/distances` または `results/distances--base`、`results/distances--pgbk`に結果が格納される。

```CSV
rho,nu,zeta,eta,aps
8,10,0.1,0.5,0.3017873533979937
```


### クラス分類の変化を分析する
```sh
julia --proj src/tasks/AnalyzeClassification.jl
```

`results/analyzed_classification` に結果が格納される。


### エージェントの累積活動回数と所属クラスを分析する
事前に [クラス分類の変化を分析する](#クラス分類の変化を分析する) を実行しておく必要がある。
```sh
julia --proj src/tasks/AnalyzeAgentActivity.jl
```

`results/triangle/aps`に結果が格納される。


### Proposed Modelの10回分の各種指標の平均を取る
提案モデルのパラメータζ/ηと指標G、<h>、R、Yの関係を示す図のためのスクリプトである。
実行にはかなり時間を要するため、注意して下さい。

#### Proposed Modelを10回走らせる
```sh
julia --proj src/tasks/RunModel_10times.jl
```
`results/generated_histories_10times`に結果が格納される。

#### 履歴データを分析して各種計測値を出す
```sh
julia --proj src/tasks/AnalyzeHistory_10times.jl
```
`results/analyzed_model_10times`に結果が格納される。

#### 計測値の平均を出す
```sh
julia --proj src/tasks/MergeAnalyzedHistories.jl
```
`results/analyzed_model_10times/mean.csv`に結果が格納される。


## 可視化
### 各種グラフをプロットする
以下の4種類のグラフが生成される。図番号は論文に対応している。
- Fig2: ターゲットデータとの距離を示す棒グラフ
- Fig3: 各種指標を示すレーダーチャート
- Fig4: インターバル中に注目を集めたエージェントと誕生ステップの関係を示す散布図
- Fig5: エージェントが誕生したステップとアクティブ頻度の関係を示す散布図

事前に以下を実行しておく必要がある。
- [モデルを走らせて相互作用の履歴データを生成する](#モデルを走らせて相互作用の履歴データを生成する)
- [相互作用の履歴データを分析して各種計測値を出す](#相互作用の履歴データを分析して各種計測値を出す)
- [ターゲットデータを分析して各種計測値を出す](#ターゲットデータを分析して各種計測値を出す)
- [各種計測値をモデルにフィッティングする](#各種計測値をモデルにフィッティングする)

```sh
julia --proj src/tasks/PlotGraphs.jl
```
出力される図は`results/imgs` 以下に保存される。


### 提案モデルのパラメータζ/ηと指標G、<h>、R、Yの関係を示す図をプロットする
Fig6の図が生成される。
事前に[Proposed Modelの10回分の各種指標の平均を取る](#proposed-modelの10回分の各種指標の平均を取る) を実行しておく必要がある。

`params_and_novelty.ipynb`を順に実行して下さい。


### クラス分類の結果をプロットする
以下の2種類のグラフが生成される。
- Fig7: 各クラスに属するエージェントの数を示す図
- Fig8: 各クラスが選択される確率を示す図

事前に[クラス分類の変化を分析する](#クラス分類の変化を分析する) を実行しておく必要がある。
```sh
julia --proj src/tasks/PlotAnalyzedClassification.jl
```
出力される図は`results/imgs/classification` に保存される。


### エージェント累積アクティブ数とクラスの関係を示す図をプロットする
Fig9の図が生成される。
事前に[エージェントの累積活動回数と所属クラスを分析する](#エージェントの累積活動回数と所属クラスを分析する) を実行しておく必要がある。
```sh
poetry run python python/triangle.py
```
出力される図は`results/imgs/triangle/aps` に保存される。


## 備考
論文再投稿の際に出力形式を変更したことで、整合性が取れなくなったため、論文の実験に関わらないスクリプトは削除しました。
必要な場合はTag"v0.1.1"の時点のスクリプトを参照して下さい。