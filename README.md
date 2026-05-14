# MATLABで光周波数コムのデータ処理
**光岡 佑馬 (Yuma Mitsuoka)** | 東京電機大学大学院 工学研究科 電子システム工学専攻 光応用工学研究室

Mail: 25kmh28@ms.dendai.ac.jp (学校用) / yuma.0706.1510111@outlook.jp (個人用)

## 目次
1. [内容](#内容)
2. [プログラムに必要なもの](#プログラムに必要なもの)
3. [データ処理プログラムの解説](#データ処理プログラムの解説)
4. [その他のソフトウェアについて](#その他のソフトウェアについて) <br>
   4.1 [HITRANによる混合ガスの透過率スペクトル取得方法について](#HITRANによる混合ガスの透過率スペクトル取得方法について)
5. [免責事項](#免責事項)

## 内容
MathWorks社が提供するMATLABを用いて, データ処理からグラフ表示までを一括して行うプログラムを構築します.
<br>
本ページでは, 私が修士課程で行った研究内容とともに, プログラムについて解説します.

### 卒業研究内容
[Bachelor's Research.pdf](https://github.com/tdu-my/Automatic-Edge-Region-Processing-for-Spectral-Interpolation/blob/main/Bachelor's%20Research.pdf)というファイル名で保存しているので, 詳細はそちらを参照してください.

学士論文は[こちら](https://github.com/tdu-my/Automatic-Edge-Region-Processing-for-Spectral-Interpolation/blob/main/2024%20Bachelor's%20thesis_Yuma%20Mitsuoka.pdf)

### プログラムのダウンロード
MATLABプログラムは以下からリポジトリ全体をzip形式でダウンロードしてください. <br>
[Download Zip（最新版）](https://github.com/o2my76/AutoInterpolate/archive/refs/heads/main.zip)

動作環境：MATLAB R2025b 以降

## プログラムに必要なもの
### 1. MATLAB
MATLABをインストールしてください.

> [!NOTE]
> Campus-Wide License を導入している大学では, **大学のメールアドレス**で MATLAB を入手できます.
> 詳細は[こちら](https://jp.mathworks.com/academia/tah-support-program/eligibility.html) / 東京電機大学の学生は[こちら](https://www.mrcl.dendai.ac.jp/mrcl/it-service/software/matlab/)

### 2. 使用する MATLAB Toolbox
下記の Toolbox のインストールが必要です.

| アイコン | Toolbox | 使用用途 |
| --- | --- | --- |
| <img width="199" height="142" alt="image" src="https://github.com/user-attachments/assets/963ec24e-512e-4074-82f4-cc21ae08d081" /> | Signal Processing Toolbox | 信号処理用の Toolbox です. 均一 / 不均一 にサンプリングされた信号の管理・解析・前処理・特徴抽出を行うことができます. |
| <img width="203" height="143" alt="image" src="https://github.com/user-attachments/assets/f5469b4d-a800-47ed-9cd6-1c733b6cee77" /> | Curve Fitting Toolbox | 測定データに対して曲線や曲面を当てはめるための Toolbox です. 本研究では, 測定データへの関数によるフィッティングのために使用しています. |

MATLAB インストール時にまとめて追加できます. インストール済みの場合は「ホーム > アドオン」から検索し、インストールしてください.

### 3. HITRAN
HITRAN とは, 分子がどの波長(周波数)の光を, どれくらい吸収するかをまとめた分子分光データベースです.

HITRAN on the Web のリンクは[こちら](https://hitran.iao.ru/)

### 4. Visual Studio Code
Visual Studio Code (VSCode) とは, Microsoft社が提供するコードエディタです. 
<br>
さまざまなプログラミング言語に対応しており, 拡張機能を用いることで MATLAB 言語にも対応可能です. 
<br>
さらに, GitHub と連携することでソースコードのバージョン管理と共有を行うことができます. 

Visual Studio Code のダウンロードリンクは[こちら](https://code.visualstudio.com/download)

### 5. 使用する VSCode 拡張機能
VSCode には様々な拡張機能がありますが, ここでは必須の拡張機能に加え, 便利な拡張機能を紹介します.

| アイコン | 拡張機能名 | 使用用途 |
| --- | --- | --- |
| <img width="200" height="200" alt="image" src="https://github.com/user-attachments/assets/9d5fefbe-694a-43a8-af04-e98ad602bb6d" /> | MATLAB | VSCode で MATLAB を実行するための必須ツールです. |
| <img width="176" height="199" alt="image" src="https://github.com/user-attachments/assets/57180c1c-e0d1-4885-9019-02d92c3d4621" /> | Japanese Language Pack for Visual Studio Code | VSCode ではデフォルトの表示言語が英語になっているため, 表示言語を日本語にすることができるツールです. |
| <img width="185" height="192" alt="image" src="https://github.com/user-attachments/assets/2c719c8c-8090-4e8f-adb8-997761cd476b" /> | GitLens | VSCode 上でソースコードのコミット履歴等を確認することができる強力ツールです. |
| <img width="168" height="168" alt="image" src="https://github.com/user-attachments/assets/e868de76-bf25-4f3f-a17a-1af42a657bd7" /> | Indent Rainbow | VSCode でコードのインデントを色分けして表示してくれるツールです. |
| <img width="154" height="156" alt="image" src="https://github.com/user-attachments/assets/0b5e7fe0-f06a-48d3-b579-4c8d7f44ebd9" /> | Identicator | 現在カーソルがあるインデント階層を縦線で強調表示してくれるツールです. |

## データ処理プログラムの解説
主な処理内容は以下のとおりです.

| No. | 処理項目 | 処理内容 | 使用する関数 |
| --- | --- | --- | --- |
| 1 | 波長計 txt データの読み込み | 取得データから光中心波長・光周波数シフト量の推定値を測定します. | `readtable`, `findpeaks` |
| 2 | HITRAN txt データの読み込み | 吸収線データベース（HITRAN）を読み込みます. | `readtable` |
| 3 | Bin ファイルの読み込み | Alazar で取得した時間波形（インターフェログラム）を読み込みます. | `fopen`, `fread`, `fclose` |
| 4 | フーリエ変換・RF 周波数軸の生成 | 時間波形から周波数スペクトルに変換し, サンプル数とサンプリングレートからRF周波数軸を生成します. | `fft` |
| 5 | RF 吸収スペクトルの取得 | RF 透過スペクトルをRF参照スペクトルで除算することでRF吸収スペクトルを取得します. |
| 6 | スムージング処理（移動平均処理） | RF 吸収スペクトルに含まれる細かなノイズを低減することで, 吸収線を見やすくします. | `movmean` |
| 7 | RF 吸収ピーク位置の抽出 | RF 吸収ピーク位置を抽出し, 後の光周波数シフト量の計測に使用します. | `findpeaks` |
| 8 | 光周波数シフト量の計測 | 隣接する RF 吸収ピーク位置からピーク間隔を計測し, 光周波数シフト量の計測を行います. | 
| 9 | RF 領域から光領域への換算 | 計測した光周波数シフト量を用いて RF 領域から光領域への換算処理を行います. | `cellfun`, `vertcat` |
| 10 | 光吸収スペクトルの取得 | 透過光スペクトルを参照光スペクトルで除算することで光吸収スペクトルを取得します. |
| 11 | 光吸収スペクトルのベースライン補正 | 2×2カプラ の特性に起因して生じるベースラインの傾きを補正します. | `fitoptions`, `fit`, `feval`, `coeffvalues` |
| 12 | 光吸収ピーク位置の抽出 | 光吸収ピーク位置を抽出し, HITRAN の吸収ピーク位置との残差を測定に使用します. | `findpeaks` |
| 13 | ピーク位置残差の標準偏差の測定・評価 | 取得データと HITRAN とのピーク位置の残差を測定し, 標準偏差を算出します. | `findpeaks` |

### 入力データ
本プログラムでは, 以下のデータを入力として使用します.

| データ | 使用用途 |
| --- | --- |
| 波長計 txt データ | 光中心周波数と光周波数シフト量の推定に使用します. |
| HITRAN txt データ | 測定した光吸収スペクトルとの比較・評価に使用します. |
| Alazar Bin データ | データ処理の元データとして使用します. |

### 出力結果
本プログラムを実行することで, 以下の結果を出力します.

| Figure No. | 出力内容 | 説明 |
| --- | --- | --- |
| 1 | 光中心周波数の変動波形 | 測定したタイミングから 1 s の範囲で波長計で取得した時間波形 |
| 2, 3 | インターフェログラム | No.2：RF 参照側, No.3：RF 透過側 のインターフェログラム |
| 4, 5 | RF コムスペクトル | No.4：スムージング前, No.5：スムージング後 の RF コム |
| 6, 7, 8 | RF 吸収スペクトル | No.5：マスク前, No.6：マスク後, No.7：ピークプロット後 の RF 吸収スペクトル |
| 9, 10 | 切り取り前の EO コムスペクトル | No.9：推定値, No.10：提案手法 によって計測した光周波数シフト量を用いて光領域へ換算した EO コムスペクトル |
| 11, 13 | 切り取り後の EO コムスペクトル | No.11：推定値, No.13：提案手法 によって取得した EO コムスペクトルの切り取り後の結果 |
| 12, 14 | 光吸収スペクトル & HITRAN | No.12：推定値, No.14：提案手法 によって取得した光吸収スペクトルと HITRAN の重ね合わせた結果 |
| 15, 16 | ピークフィットに伴うベースライン補正用マスク範囲の指定 | No.15：推定値, No.16：提案手法 において吸収線ピーク周辺部分の影響を受けずにベースライン補正を行うためのマスク範囲を破線で表示 |
| 17, 18 | ベースライン補正用の近似曲線 | No.17：推定値, No.18：提案手法 においてベースライン補正用の近似曲線の出力結果 |
| 19, 20 | ベースライン補正後の光吸収スペクトル & HITRAN | No.19：推定値, No.20：提案手法 においてベースライン補正後の光吸収スペクトル |

### 使用方法

1. Alazar で取得した Bin データを保存します.
   この時, ファイル名は`1`として保存します
2. 保存後に生成される以下の2つの Bin データを新規フォルダにまとめます.
   ```text
   1_1.1.1.1.A.bin
   1_1.1.1.1.B.bin
   ```
   フォルダ名の例：`my00`
3. Alazar でデータを取得した時刻を記録し，同時に波長計の lta データを保存します. <br>
   このとき，lta データのファイル名は，**Bin データを保存したフォルダ名と同じ**にします.
4. `lta_txt変換プログラム.nb`を用いて, 波長計で取得した lta データを txt データに変換します.
5. MATLABプログラム内で, 実行するフォルダ名と波長計データの取得時刻を入力します.
6. 実験条件に合わせてそのほかの変数を変更し, プログラムを実行します.



## その他のソフトウェアについて
### HITRANによる混合ガスの透過率スペクトル取得方法について
> [!NOTE]
> データを作成するためには, まず**アカウントを作成する**必要があります. 右上の鍵マークからアカウントを作成してください.
> <img width="1676" height="328" alt="image" src="https://github.com/user-attachments/assets/3af9d48b-fd7a-4307-abf7-c1d7db4a7e4b" /> <br>
アカウント作成後, 「Gas mixture > Mixtures of isotopologues」から混合したいガスを選択します.

例として, 研究室で扱っている シアン化水素ガス (HCN-13-H(5.5)-25-FCAPC) の透過率スペクトルを取得してみます. <br>
データシートは[こちら](https://www.wavelengthreferences.com/wp-content/uploads/Data-HCN.pdf) (Wavelength References 社) 

まず, 左側から混合したいガスを選択し, 「Origin of the mixture」のプルダウンから「User-difined」を選択します.
<img width="1852" height="344" alt="image" src="https://github.com/user-attachments/assets/616c7ee0-0015-4a0b-9f4d-2f26fbcb01d6" />
<br>
選択すると, 最初は下のように「No results found.」と表記されるので, 右上の「Create mixture」から混合ガスを生成します.
<img width="1924" height="320" alt="image" src="https://github.com/user-attachments/assets/ad3ff722-ae78-4954-94f2-102084b608e1" />
<br>
その後, 「Title」を入力し, 「Mixing ratio」の「+」アイコンから同位体を選択します.
<img width="1620" height="920" alt="image" src="https://github.com/user-attachments/assets/e2950a42-0dd2-4f0d-8617-88a6b43921fa" />
<br>
今回は「2 : H13C14N (134)」を選択します.
<img width="1932" height="480" alt="image" src="https://github.com/user-attachments/assets/6bdde8e2-c52d-4abb-96c0-78e12dd78689" />
<br>
選択後, 「Volume share」からガス濃度を入力し, 保存アイコンを選択して値を保存します. (1 → 100%)
<img width="1944" height="364" alt="image" src="https://github.com/user-attachments/assets/8d6ea561-fb9b-400b-b038-835b83022a51" />
<br>
最後に, 「Save」を選択して保存完了です. (別の同位体を選択する場合は同じ作業を繰り返してください.)
<img width="1828" height="992" alt="image" src="https://github.com/user-attachments/assets/844bd6a6-d685-4df1-8652-5f331ea20dcb" />

ここまででは, 混合ガスの比率を設定しただけなので, まだシアン化水素ガスとしての保存ができていません. <br>
次に, 「Gas mixtures > Gas mixtures」から先ほど生成した混合ガスをシアン化水素ガスとして保存します.

まず, 先ほどと同様に「Origin of the mixture > User-defined」から右上の「Create mixture」を選択します.
<img width="2424" height="292" alt="image" src="https://github.com/user-attachments/assets/209794af-ca87-41e2-bb85-991b41f04074" />
<br>
選択後, 「Mixing ratio」の「+」アイコンを選択し, 「Molecule」を決定します. (今回は「23 : Hydrogen cyanide (HCN)」を選択します.)
<img width="1412" height="360" alt="image" src="https://github.com/user-attachments/assets/7685c3ba-6687-403b-95c7-12e3788470da" />
<br>
その後, 「Mixture of isotopologues」のプルダウンから先ほど保存した混合ガスを選択します.
<img width="2224" height="492" alt="image" src="https://github.com/user-attachments/assets/623808b0-a0ec-4c72-85a9-513af13967b1" />
選択後, 「Volume share」からガス濃度を入力 → 保存アイコンを選択して値を保存し, 「Title」を入力後, 「Save」を選択して保存完了です.
<img width="2132" height="404" alt="image" src="https://github.com/user-attachments/assets/c8cc510a-d551-4540-ac43-8d34c877e2b9" />

最後に, 「Gas mixtures > Launch simulation」から透過率スペクトルの取得を行います. <br>
まず, 「Gas mixture」のプルダウンから先ほど生成した混合ガスを選択します. (一番下に「U : ～ 」と表記) <br>
また, 今回取得したいのは透過率スペクトルなので, 「Simulation type」のプルダウンから「Transmittance function」を選択します.
<img width="2632" height="288" alt="image" src="https://github.com/user-attachments/assets/a4bdb794-c81d-49e6-87d6-43291246c1ce" />
<br>
その後, 波数/温度/圧力/光路長 などの各パラメータを入力して「Start simulation」より実行します. (パラメータはデータシートを参照)
<img width="3008" height="920" alt="image" src="https://github.com/user-attachments/assets/7077c7f5-d130-4c8d-8168-e80985634fcf" />
<br>
実行結果は, 「Gas mixtures > Simulation results」から確認でき, 「Plot selected」より見ることができます. <br>
また, 右側にあるダウンロードアイコンから .txt 形式で透過率スペクトルの保存ができます. <br>
<img width="2880" height="604" alt="image" src="https://github.com/user-attachments/assets/e0755e67-145b-4428-bbc1-1100178125d8" />
<img width="3320" height="1840" alt="image" src="https://github.com/user-attachments/assets/ae09650f-5c51-4721-a82f-cd99399fe8f7" />

> [!IMPORTANT]
> 保存した .txtファイルの横軸は波数なので, 光周波数に換算する場合は横軸に **29979245800** を掛けてください.

## 免責事項
本リポジトリで提供するプログラム，スクリプト，およびドキュメント類は，参考目的で公開するものです．内容や動作については可能な限り検証していますが，その正確性，完全性，安全性，動作，特定用途への適合性を保証するものではありません．

本リポジトリのプログラムやコードを使用したことによってユーザーまたは第三者に生じたいかなる損害，トラブル，データ損失，または不利益についても，作者は一切の責任を負いません．

利用する場合は，ユーザー自身の責任において動作環境や依存関係，ライセンス条件を十分確認したうえでご利用ください．

本リポジトリの内容は予告なく変更，削除されることがありますので，あらかじめご了承ください．
