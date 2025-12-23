# MATLABで光周波数コムのデータ処理
**光岡 佑馬 (Yuma Mitsuoka)** | 東京電機大学 工学研究科 電子システム工学専攻 光応用工学研究室

Mail: 25kmh28@ms.dendai.ac.jp (学校用) / yuma.0706.1510111@outlook.jp (個人用)

## 目次
1. [内容](#内容)
2. [プログラムに必要なもの](#プログラムに必要なもの) 
3. [HITRANによる混合ガスの透過率スペクトル取得方法について](#HITRANによる混合ガスの透過率スペクトル取得方法について)

## 内容
MathWorks社が提供するMATLABを用いて, データ処理からグラフ表示までを一括して行うプログラムを生成します.
<br>
本ページでは, 私が修士課程で行った研究内容とともに, 基本知識について解説します.

### 卒業研究内容
[Bachelor's Research.pdf](https://github.com/tdu-my/Automatic-Edge-Region-Processing-for-Spectral-Interpolation/blob/main/Bachelor's%20Research.pdf)というファイル名で保存しているので, 詳細はそちらを参照してください.

学士論文は[こちら](https://github.com/tdu-my/Automatic-Edge-Region-Processing-for-Spectral-Interpolation/blob/main/2024%20Bachelor's%20thesis_Yuma%20Mitsuoka.pdf)

## プログラムに必要なもの
### 1. MATLAB
MATLABをインストールしてください.

  - Campus-Wide License を導入している大学では, **大学のメールアドレス**で MATLAB を入手できます.

    詳細は[こちら](https://jp.mathworks.com/academia/tah-support-program/eligibility.html) / 東京電機大学の学生は[こちら](https://www.mrcl.dendai.ac.jp/mrcl/it-service/software/matlab/)

### 2. 使用する MATLAB Toolbox
下記の Toolbox のインストールが必要です.

  - Signal Processing Toolbox
  - Curve Fitting Toolbox

MATLAB インストール時にまとめて追加できます. インストール済みの場合は「ホーム > アドオン」から検索し、インストールしてください.

### 3. HITRAN
HITRAN とは, 分子がどの波長(周波数)の光を, どれくらい吸収するかをまとめた分子分光データベースです. <br>
HITRAN on the Web のリンクは[こちら](https://hitran.iao.ru/)

## HITRANによる混合ガスの透過率スペクトル取得方法について
※ データを作成するためには, まず**アカウントを作成する**必要があります. 右上の鍵マークからアカウントを作成してください.
<img width="1676" height="328" alt="image" src="https://github.com/user-attachments/assets/3af9d48b-fd7a-4307-abf7-c1d7db4a7e4b" />
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
最後に, 「Save」を選択して保存完了です. (別の混合ガスを生成する場合は同じ作業を繰り返してください.)
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
※保存した .txtファイルの横軸は波数なので, 光周波数に換算する場合は横軸に **29979245800** を掛けてください.
<img width="2880" height="604" alt="image" src="https://github.com/user-attachments/assets/e0755e67-145b-4428-bbc1-1100178125d8" />
<img width="3320" height="1840" alt="image" src="https://github.com/user-attachments/assets/ae09650f-5c51-4721-a82f-cd99399fe8f7" />
<br>




## 研究内容と基本知識について
### 1. 光周波数コム(光コム)とは
周波数軸上に等間隔に並ぶ成分(モード)からなる櫛形のスペクトルを持った光信号です.
光コムの"**コム**"は
