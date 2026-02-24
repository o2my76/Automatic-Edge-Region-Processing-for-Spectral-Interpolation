% 修士論文「デュアルEOコム分光法による自動補間法におけるスペクトル境界領域の自動処理法」25KMH28 光岡 佑馬

%% 各変数の定義 (適宜確認、必要に応じて変更すること)
clear; clc; clf;                            % F5キーで実行 / Ctrl+Enterでセクション実行

tic

% 各モード間隔、RF補間量の設定 (光補間量は自動で算出してくれます)
RFDiff = 0.30e6;                             % RF補間量 [Hz] (RFモード間隔より小さく設定)
AOM = 80e6;                                  % RF中心周波数 [Hz]
OpRep = 25e9;                                % 光モード間隔 (繰り返し周波数 [Hz])
RFRep = 0.35e6;                              % RFモード間隔

% 実行するフォルダ名を入力、データ保存の有無決定
Name = 'my04';                               % 読み込むBinファイルが入ったフォルダ名を入力
Judge = 0;                                   % データ保存の有無 (Yes: 1, No: 1以外の数値 を入力)

% 波長計で取得した時間を入力 [s] (適宜変更すること)
AcquisitionMin = 5;                          % データ取得時間 [分]
AcquisitionSec = 55;                         % データ取得時間 [秒]

AcquisitionTime = 60 * AcquisitionMin + AcquisitionSec;

% 検出する吸収線ピーク値の閾値 (設定した値未満をピーク値とみなす)
PeakJudge = 0.8;

% x軸の生成 (自己研究と合致しているか確認すること)
N = 2^24;                                    % サンプル数 [S]
Fs = 200e6;                                  % サンプリングレート [S/s] 
t = (0:N-1) / Fs;                            % 時間軸の生成

disp('Measurement time [ms]'); disp(N/Fs*1e3);    % 測定時間の表示
CH2_Freq = Fs / (N * 1.5);                   % 三角波周波数 (データ取得時間範囲から左右それぞれ +30° 空けているので1.5を掛ける)

%% HITRANデータの読み込み
% HITRANデータファイルの指定
HITRANdata = readtable("C:\Users\yuma0\OneDrive - 東京電機大学 (1)\デスクトップ\研究室\MATLAB用\SpectrMixt_H13C14N");
X_Fraction = HITRANdata{:, 1};                              % HITRANのx軸の取得 (波数 [cm^-1])
HITRAN_X = X_Fraction * 29979245800;                        % 波数から光周波数に変換 [Hz]
HITRAN_Y = HITRANdata{:, 2};                                % HITRANのy軸の取得 (透過率)

%% 波長計で保存したtxtデータの読み込み、中心波長・光補間量の推定値の自動測定
% 読み込むテキストファイルの指定
wavelengthtxtFolder = "C:\Users\yuma0\OneDrive - 東京電機大学 (1)\デスクトップ\研究室\MATLAB用\txtファイル取り込む用";
wavelengthFolder = fullfile(wavelengthtxtFolder, Name + ".txt");
Tdata = readtable(wavelengthFolder);

Tdata_Time = Tdata{:, 1} / 1e3;                 % 波長計取得データの時間軸の取得 [s]
wavelength = Tdata{:, 2} / 1e9;                 % 波長計取得データの中心波長の取得 [nm]

% 波長計で取得した時間から中心波長及び光補間量の推定値を測定
TimeRange = (AcquisitionTime <= Tdata_Time) & (Tdata_Time <= AcquisitionTime + 1);     % 取得する範囲の設定
Acquisition_TimerRange = Tdata_Time(TimeRange);                                        % 設定した範囲の時間軸の取得
Acquisition_wavelength = wavelength(TimeRange).';                                      % 設定した範囲の波長軸の取得

% 設定した範囲における波長計で取得したデータの表示
figure
plot(Acquisition_TimerRange, Acquisition_wavelength, 'LineWidth', 1);
% title('Acquisition of wavelength Meter')
xlabel('Time [s]')                                                                 % x軸ラベル
ylabel('wavelength [nm]')                                                          % y軸ラベル
ax = gca;                                                                          % 現在の座標軸の取得 (gca: get current axis)
ytick_w = ax.YTick;                                                                % 現在のy軸目盛位置の数値ベクトルを返す
yticklabels(arrayfun(@(v) num2str(v*1e9), ytick_w, 'UniformOutput', false));       % nm表記に設定 (10^-9 部分を削除)
fontsize(14,"points")                                                              % フォントサイズの設定
fontname("Times New Roman")                                                        % フォント名の設定

hold on

% 波長の最大値と最小値の測定 (2/3周期のうち、最大値と最小値を検出するようにする)
[Max_wavelength, Max_LocsTime] = findpeaks(Acquisition_wavelength, Acquisition_TimerRange, 'MinPeakDistance', 1/(1.5*CH2_Freq));
[Min_wavelength, Min_LocsTime] = findpeaks(-Acquisition_wavelength, Acquisition_TimerRange, 'MinPeakDistance', 1/(1.5*CH2_Freq));
Min_wavelength = -Min_wavelength;                                                  % 反転したデータを元に戻す
plot(Max_LocsTime, Max_wavelength, 'bv', 'MarkerFaceColor', 'y');                  % 検出した最大値を谷(黄色)でプロット
plot(Min_LocsTime, Min_wavelength, 'bv', 'MarkerFaceColor', 'w');                  % 検出した最小値を谷(白色)でプロット

hold off

% 取得した最大値と最小値の平均値から中心波長の算出
disp('Min wavelength [nm]'); disp(num2str(Min_wavelength*1e9, '%.4f  '));          % 算出した中心波長の表示
disp('Max wavelength [nm]'); disp(num2str(Max_wavelength*1e9, '%.4f  '));          % 算出した中心波長の表示

Center_wavelength = (mean(Max_wavelength) + mean(Min_wavelength)) / 2;
disp('Center wavelength [nm]'); disp(num2str(Center_wavelength*1e9, '%.4f'));      % 算出した中心波長の表示
Fc = 299792458 / Center_wavelength;                                                % 中心波長から中心周波数を算出
disp('Center Frequency [THz]'); disp(Fc/1e12);                                     % 中心周波数の表示

% 中心波長の最大値と最小値から光補間量の推定値の算出
OpDiff_Max = 299792458 / mean(Max_wavelength);                                     % 波長の最大値の平均から光周波数に変換
OpDiff_Min = 299792458 / mean(Min_wavelength);                                     % 波長の最小値の平均から光周波数に変換
OpDiff_Est = (OpDiff_Min - OpDiff_Max) / 1.5;                                      % 光補間量の算出 (推定値)
disp('Optical Interpolation Amount [GHz]'); disp(OpDiff_Est/1e9);                  % 光補間量を表示


%% データの保存 (emf 形式) ※保存先があっているか確認
% Judge = 1 の時、フォルダを自動で作成し、データを保存
if Judge == 1
    BaseFolder = "C:\Users\yuma0\OneDrive - 東京電機大学 (1)\デスクトップ\研究室\MATLAB用\MATLAB取得データ";  % ファイルの保存先フォルダの選択
    SubFolder1 = string(datetime('now', 'Format', 'yyyyMMdd'));                                 % 新しいフォルダ名の設定 (ex:20250101)
    SubFolder2 = string(datetime('now', 'Format', 'HH;mm;ss'));                                 % 新しいフォルダ名の設定 (ex:11;10;30)
    SubFolder2 = SubFolder2 + '_' + Name;                                                       % 保存時刻の後に実行ファイルの記録
    NewFolder = fullfile(BaseFolder, SubFolder1, SubFolder2);                                   % 指定した保存先に新しいフォルダの作成
    % フォルダが存在しなければ作成 (~:論理NOT演算子, dir:ファイル一覧の表示)
    if ~exist(NewFolder, 'dir')
        mkdir(NewFolder);
    end
    % emf用のサブフォルダを作成
    EmfFolder = fullfile(NewFolder,[Name, '_emf']);
    if ~exist(EmfFolder, 'dir')
        mkdir(EmfFolder);
    end
end

% 波長計で取得した時間波形の保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '0. Acquisition of wavelength.emf'), 'emf');
end

% 実験系の各パラメータを記録、保存
if Judge == 1
    % 保存するファイル名を作成 (%.6f: 小数点以下6桁の浮動小数点数を出力, \n: 改行)
    txtFileName = fullfile(NewFolder, 'Results.txt');
    fid = fopen(txtFileName, 'w');                                                % 書き込みで開く
    fprintf(fid, 'Executed at: %s\n', string(datetime('now', 'Format', 'yyyy_MMdd HH;mm;ss')));
    fprintf(fid, 'File Name: %s  \n', Name);
    fprintf(fid, 'Acquisition Time: %.f s \n', AcquisitionTime);
    fprintf(fid, 'Center wavelength: %.6f nm \n', Center_wavelength*1e9);
    fprintf(fid, 'Center Frequency: %.6f THz \n', Fc/1e12);
    fprintf(fid, 'RF Interpolation amount: %.2f MHz \n', RFDiff/1e6);
    fprintf(fid, 'Optical Interpolation amount: %.6f GHz \n\n', OpDiff_Est/1e9);
    fclose(fid);                                                                  % ファイルを閉じる
end


%% Alazarで取得したBinファイルの読み込み
% 定数を事前に計算 (Binファイルを読み込むにあたって)
nBitsPerSample = 16;                                      % サンプルのビット数
dInputRange_volts = 0.4;                                  % 入力範囲（±0.4 V）
dSampleZeroValue = (2^(nBitsPerSample - 1)) - 0.5;        % サンプルのゼロ点
dScaleFactor = dInputRange_volts / dSampleZeroValue;      % スケール係数

BaseDataFolder = "C:\Users\yuma0\OneDrive - 東京電機大学 (1)\デスクトップ\研究室\MATLAB用\データ処理用元データ";
DataFolder = fullfile(BaseDataFolder, Name);

% 1.1 ファイルパスの指定(参照光スペクトル)
FileNameA = fullfile(DataFolder, '1_1.1.1.1.A.bin');      % ここに読み込むファイルパスを入力 
fileID = fopen(FileNameA, 'r');                                                    % ファイルを読み込みモードで開く
if fileID == -1                                                                    % ファイルが正常に開けたかどうかの確認
    error('Unable to open the file: %s', FileNameA);
end
data = fread(fileID, 'uint16');                                                    % データを16ビット符号なし整数として読み込む
fclose(fileID);                                                                    % ファイルを閉じる
Y1 = dScaleFactor * (double(data) - dSampleZeroValue);                             % サンプル値を電圧値に変換

figure
plot(t,Y1)                                                                         % 参照光の時間軸波形の表示
% title('Referenced Interferogram')
xlabel('Time [μs]')                                                                % x軸ラベル
ylabel('Field [a.u.]')                                                             % y軸ラベル
ax = gca;                                                                          % 現在の座標軸の取得
ax.XTick = 0:1e-6:5e-6;                                                            % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick*1e6);                                              % μs表記に設定 (10^-6 部分を削除)
xlim([0 5e-6])                                                                     % x軸の表示範囲の設定
ylim([-0.3 0.3])                                                                   % y軸の表示範囲の設定
yticks(-0.3:0.1:0.3)                                                               % y軸のメモリ設定
fontsize(14,"points")                                                              % フォントサイズの設定
fontname("Times New Roman")                                                        % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '1.1 Referenced Interferogram.emf'), 'emf');
end

% 1.2 ファイルパスの指定（透過光スペクトル）
FileNameB = fullfile(DataFolder, '1_1.1.1.1.B.bin');      % ここに読み込むファイルパスを入力 
fileID = fopen(FileNameB, 'r');
if fileID == -1
    error('Unable to open the file: %s', FileNameB);
end
data = fread(fileID, 'uint16');                                                    % データを16ビット符号なし整数として読み込む
fclose(fileID);
Y2 = dScaleFactor * (double(data) - dSampleZeroValue);                             % サンプル値を電圧値に変換

figure
plot(t,Y2)                                                                         % 透過光の時間軸波形の表示
% title('Transmitted Interferogram')
xlabel('Time [μs]')                                                                % x軸ラベル
ylabel('Field [a.u.]')                                                             % y軸ラベル
ax = gca;                                                                          % 現在の座標軸の取得
ax.XTick = 0:1e-6:5e-6;                                                            % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick*1e6);                                              % μs表記に設定 (10^-6 部分を削除)
xlim([0 5e-6])                                                                     % x軸の表示範囲の設定
ylim([-0.3 0.3])                                                                   % y軸の表示範囲の設定
yticks(-0.3:0.1:0.3)                                                               % y軸のメモリ設定
fontsize(14,"points")                                                              % フォントサイズの設定
fontname("Times New Roman")                                                        % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '1.2 Transmitted Interferogram.emf'), 'emf');
end


%% フーリエ変換 (時間波形から周波数スペクトルに変換)
% フーリエ変換
CombA = fft(Y1);                                                                   % 参照光のフーリエ変換
f1 = (0:length(Y1)-1)*Fs/length(Y1);                                               % x軸の生成 (周波数)
CombB = fft(Y2);                                                                   % 透過光のフーリエ変換
f2 = (0:length(Y2)-1)*Fs/length(Y2);                                               % x軸の生成 (周波数)


%% スムージング処理前のRFコムスペクトルの表示
% 2.1 スムージング処理前のRFコムスペクトルの表示 (参照光・透過光)
figure                                     
plot(f2, abs(CombB), 'LineWidth', 1);                         % スムージング処理前のRF透過光スペクトルの表示

hold on

plot(f1, abs(CombA), 'LineWidth', 1);                         % スムージング処理前のRF参照光スペクトルの表示

xlabel('Frequency [MHz]')                                     % x軸ラベル
ylabel('Intensity [a.u.]')                                    % y軸ラベル
set(gca, 'YScale', 'log');                                    % y軸を対数目盛に設定
ylim([1e1 1e4])                                               % y軸の表示範囲の設定
ax = gca;                                                     % 現在の座標軸の取得
ax.XTick = 72e6:2e6:88e6;                                     % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e6);                         % MHz表記に設定 (10^6 部分を削除)
xlim([72e6 88e6])                                             % x軸の表示範囲の設定

hold off

% title('Not Smoothed RF Spectrum')                             % グラフのタイトル
legend('Transmitted RF Spectrum','Referenced RF Spectrum')    % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '2.1 Not Smoothed RF Spectrum.emf'), 'emf');
end

toc;


%% デュアルコムスペクトルのスムージング処理 (平滑化)
% スムージング処理
smth = 1.8e9 / Fs * 90;                                       % スムージング量の設定 (設定した数のサンプル数でそれぞれ平均値をとる)
disp('Smoothing Amount'); disp(smth);                         % スムージング量の表示
SmthCombA = movmean(abs(CombA), smth);                        % RF参照光スペクトルのスムージング処理
SmthCombB = movmean(abs(CombB), smth);                        % RF透過光スペクトルのスムージング処理

toc;


%% スムージング後のRFコムスペクトルの表示
% 2.2 スムージング処理後のRFコムスペクトルの表示 (参照光・透過光)
figure                         
plot(f2, SmthCombB, 'LineWidth', 1);                          % スムージング処理後のRF透過光スペクトルの表示

hold on

plot(f1, SmthCombA, 'LineWidth', 1);                          % スムージング処理後のRF参照光スペクトルの表示

xlabel('Frequency [MHz]')                                     % x軸ラベル
ylabel('Intensity [a.u.]')                                    % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 72e6:2e6:88e6;                                     % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e6);                         % MHz表記に設定 (10^6 部分を削除)
xlim([72e6 88e6])                                             % x軸の表示範囲の設定
set(gca, 'YScale', 'log');                                    % y軸を対数目盛に設定
ylim([1e1 1e4])                                               % y軸の表示範囲の設定

hold off

% title('Smoothed RF Spectrum')                                 % グラフのタイトル
legend('Transmitted RF Spectrum','Referenced RF Spectrum')    % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '2.2 Smoothed RF Spectrum.emf'), 'emf');
end


%% 除算によるRF吸収線スペクトルの取得・表示
% 2.3 RF吸収線スペクトルの取得及び表示
SmthAbsorption = SmthCombB ./ SmthCombA;                      % 透過率の算出
f3 = (0:length(SmthAbsorption)-1)*Fs/length(SmthAbsorption);  % X軸の生成

figure
plot(f3, SmthAbsorption, 'LineWidth', 1);
xlabel('Frequency [MHz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 72e6:2e6:88e6;                                     % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e6);                         % MHz表記に設定 (10^6 部分を削除)
xlim([72e6 88e6])                                             % x軸の表示範囲の設定
ylim([0.4 1.4])                                               % y軸の表示範囲の設定
yticks(0.4:0.2:1.4)                                           % y軸のメモリ設定

% title('RF Absorption')                               % グラフのタイトル
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '2.3 RF Absorption.emf'), 'emf');
end

%% RF吸収線スペクトルのスムージング処理 (必要であればコメント化解除して使用)
% % スムージング処理 (やり過ぎると分解能が下がるので非推奨)
% SmthAbsorption = movmean(abs(SmthAbsorption), smth);                       % RF吸収線スペクトルのスムージング処理
% 
% % スムージング処理後のRF吸収線スペクトルの表示
% figure
% plot(f3, SmthAbsorption, 'LineWidth', 1);
% xlabel('Frequency [MHz]')                                     % x軸ラベル
% ylabel('Transmittance [a.u.]')                                % y軸ラベル
% ax = gca;                                                     % 現在の座標軸の取得 
% ax.XTick = 72e6:2e6:88e6;                                     % 座標軸の取得範囲の設定 (始点:間隔:終点)
% ax.XTickLabel = string(ax.XTick/1e6);                         % MHz表記に設定 (10^6 部分を削除)
% xlim([72e6 88e6])                                             % x軸の表示範囲の設定
% ylim([0.4 1.4])                                               % y軸の表示範囲の設定
% yticks(0.4:0.2:1.4)                                           % y軸のメモリ設定
% 
% % title('Smoothed RF Absorption')                               % グラフのタイトル
% fontsize(14,"points")                                         % フォントサイズの設定
% fontname("Times New Roman")                                   % フォント名の設定
% 
% % グラフの保存 (emf形式)
% if Judge == 1
%     saveas(gcf, fullfile(EmfFolder, '2.4 Smoothed RF Absorption.emf'), 'emf');
% end
% 
% toc;


%% マスク範囲の設定 (ノイズ箇所を除去)
% マスク範囲の設定
RFmaskMin = AOM - RFRep * 17 - RFDiff / 2;
disp('RF Min [MHz]'); disp(RFmaskMin/1e6);                    % 吸収線表示箇所の最小値を表示
RFmaskMax = AOM + RFRep * 17 + RFDiff / 2;
disp('RF Max [MHz]'); disp(RFmaskMax/1e6);                    % 吸収線表示箇所の最大値を表示

% 3.1.1 マスク後のRF吸収線スペクトルの表示及び吸収線ピークの検出、表示
figure
RFmask = (RFmaskMin <= f3) & (f3 <= RFmaskMax);               % 吸収線表示範囲をmaskに設定
f3 = f3(RFmask);                                              % RF吸収線のx軸のうち、設定した「mask」の範囲のみを保存
SmthAbsorption= SmthAbsorption(RFmask);                       % RF吸収線のy軸のうち、設定した「mask」の範囲のみを保存
plot(f3, SmthAbsorption, 'LineWidth', 1);

hold on

xlabel('Frequency [MHz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 72e6:2e6:88e6;                                     % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e6);                         % MHz表記に設定 (10^6 部分を削除)
xlim([72e6 88e6])                                             % x軸の表示範囲の設定
ylim([0.4 1.4])                                               % y軸の表示範囲の設定
yticks(0.4:0.2:1.4)                                           % y軸のメモリ設定

% title('Noise masked RF Absorption')                           % グラフのタイトル
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '3.1.1 Noise masked RF Absorption.emf'), 'emf');
end




%% RF吸収線のピーク位置検出・表示
% 3.1.2 RF吸収線のピーク位置の検出
RFminPeakDistance = 0.05e6;                                                % 検出するピーク間隔の設定 (あえてここでの間隔を短くし、その後不要なピーク成分を除去)

% 設定した範囲内でのピーク値の検出 (「RFPeakAbsorption」: y軸(ピーク値)　「RFPeakLocation」: x軸(ピーク位置) )
[RFPeakAbsorption, RFPeakLocation] = findpeaks(-SmthAbsorption, f3, 'MinPeakDistance', RFminPeakDistance);
RFPeakAbsorption = -RFPeakAbsorption;                                      % 反転したデータを元に戻す

% 不要なピーク成分を除去 (ベースライン部分のノイズ箇所をピークとして検出してしまっているため)
idx = RFPeakAbsorption < PeakJudge;                                        % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
RFPeakLocation = RFPeakLocation(idx);                                      % 除去後のピーク位置(x軸)に「RFPeakLocation」を上書き
RFPeakAbsorption = RFPeakAbsorption(idx);                                  % 除去後のピーク値(y軸)に「PEPeakAbsorption」を上書き

plot(RFPeakLocation, RFPeakAbsorption, 'bv', 'MarkerFaceColor', 'r');      % 最終的に検出した吸収線ピークを谷(黄色)でプロット

hold off

disp('RF Peak Location [MHz]'); disp(RFPeakLocation/1e6);                  % 検出した吸収線ピーク位置を表示

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '3.1 Noise masked RF Absorption.emf'), 'emf');
end

%% 検出したRF吸収線のピーク間隔のうち、隣り合ったピーク間隔のみを自動で算出
% 隣り合ったRF吸収線ピーク間隔の算出及び標準偏差の算出
PeakDiff1 = RFPeakLocation(2:end) - RFPeakLocation(1:end-1);            % RF吸収線ピーク間隔の算出 (x成分)
PeakAbsorption = abs(RFPeakAbsorption(2:end) - RFPeakAbsorption(1:end-1)); % RF吸収線ピーク値の算出 (y成分)
idx = PeakDiff1 < 0.5e6;                                                % 隣り合った吸収線かどうかの判別 (間隔が0.5 MHz 未満で隣り合っていると判断し、インデックスを取得)
PeakDiff1 = PeakDiff1(idx);                                             % 隣り合った吸収線ピーク間隔のみ残す (x成分)
PeakAbsorption = PeakAbsorption(idx);                                   % 隣り合った吸収線ピーク値のみ残す (y成分)

idx = PeakAbsorption < 0.03;                                            % 隣り合った吸収線ピーク値の差分の算出 (0.03未満のみを残し、インデックスを取得)
PeakDiff2 = PeakDiff1(idx);                                             % 取得したインデックスの吸収線ピーク間隔のみ残す
disp('RF Peak Interval [MHz]'); disp(PeakDiff2/1e6);
std_PeakDiff = std(PeakDiff2);                                          % 隣り合った吸収線ピーク間隔の標準偏差を「std_PeakDiff」として保存
disp('S.D. RF Peak Interval [MHz]');
disp(std_PeakDiff/1e6);                                                 % 標準偏差の表示


%% 隣り合ったピーク間隔から光補間量を自動で算出
% 4.1 設計した光補間量から隣り合った吸収線ピーク間隔の算出 (推定値)
Est_PeakDiff = abs(OpRep * RFDiff / OpDiff_Est - RFRep);              % 推定値の大きさを「Est_PeakDiff」として保存

% 4.2.1 隣り合ったRF吸収線ピーク間隔の平均値の算出
Ave_PeakDiff = mean(PeakDiff1);                                       % 隣り合った吸収線ピーク間隔の平均値を「Ave_PeakDiff」として保存

% 4.2.2 RFピーク間隔の平均値を用いた光補間量の算出
OpDiff_Ave = OpRep * RFDiff / (-Ave_PeakDiff +RFRep);                 % 平均値から算出した光補間量を「OpDiff_Ave」として保存

toc;


%% 準備：配列の初期化 / 事前割り当て・倍率の算出
% 事前準備1: 配列の初期化・事前割り当て (これをするとデータ処理時間が格段に速くなる)
n = 35;
RF_Center = zeros(1,n); OP_Center = zeros(1,n);
B_Est = zeros(1, n);    B_Ave = zeros(1, n);
RFX1 = cell(n, 1); RFX2 = cell(n, 1); 
RFY1 = cell(1, n); RFY2 = cell(1, n); 
OPX1_Est = cell(n, 1); OPX1_Ave = cell(n, 1); 
OPX2_Est = cell(n, 1); OPX2_Ave = cell(n, 1); 
cutOPX1_Est = cell(n, 1); cutOPX1_Ave = cell(n, 1);
cutOPY1_Est = cell(1, n); cutOPY1_Ave = cell(1, n);
cutOPX2_Est = cell(n, 1); cutOPX2_Ave = cell(n, 1);
cutOPY2_Est = cell(1, n); cutOPY2_Ave = cell(1, n);


% 事前準備2: 算出したそれぞれのピーク間隔より算出した光補間量による倍率算出 (光補間量/RF補間量)
A_Est = OpDiff_Est / RFDiff;                         % 推定値の倍率の算出
A_Ave = OpDiff_Ave / RFDiff;                         % 平均値を用いた倍率の算出

%% 算出した倍率を用いて、RF領域から光領域へ自動で変換
% 算出した倍率を用いてRF領域から光領域へ変換 ※スペクトル毎に変換式が異なるので注意
for i = 1:n
    RFc = AOM + RFRep * (i - 18);                                                        % RFコムスペクトルの中心周波数を算出 (共通)
    RF_Center(i) = RFc;                                                                  % 各RFコムスペクトル中心周波数を「RF_Center」に格納
    B_Est_temp = Fc + (OpRep * (i - 18)) - (A_Est * (AOM + RFRep * (i - 18)));           % オフセット周波数の算出 (推定値)
    B_Est(i) = B_Est_temp;                                                               % 各RFコムスペクトルのオフセット周波数を「B_Est」に格納
    B_Ave_temp = Fc + (OpRep * (i - 18)) - (A_Ave * (AOM + RFRep * (i - 18)));           % オフセット周波数の算出 (平均値)
    B_Ave(i) = B_Ave_temp;                                                               % 各RFコムスペクトルのオフセット周波数を「B_Ave」に格納

    % 5.1 RFコムの切り取り範囲の設定 (共通)
    RFmin = -RFDiff / 2 + RFc;                                              % RFコムスペクトルの中心から切り取る範囲の最小値
    RFmax = RFDiff / 2 + RFc;                                               % RFコムスペクトルの中心から切り取る範囲の最大値
    cut_RF = (RFmin <= f1) & (f1 <= RFmax);                                 % RFコムスペクトルの切り取る範囲を「cut_RF」として保存
    % 5.2 RF参照光スペクトルの切り取り、結果を格納 (共通)
    cutf1 = f1(cut_RF);                                                     % x軸のうち「cut」で指定した範囲を切り取り、「cutf1」として保存
    RFX1{i} = cutf1;                                                        % 「RFX1」に格納
    cutSmthCombA = SmthCombA(cut_RF);                                       % y軸のうち「cut」で指定した範囲を切り取り、「cutSmthCombA」として保存
    RFY1{i} = cutSmthCombA;                                                 % 「RFY1」に格納
    % 5.3 RF透過光スペクトルの切り取り、結果を格納 (共通)
    cutf2 = f2(cut_RF);                                                     % x軸のうち「cut」で指定した範囲を切り取り、「cutf2」として保存
    RFX2{i} = cutf2;                                                        % 「RFX2」に格納
    cutSmthCombB = SmthCombB(cut_RF);                                       % y軸のうち「cut」で指定した範囲を切り取り、「cutSmthCombB」として保存
    RFY2{i} = cutSmthCombB;                                                 % 「RFY2」に格納
    % 5.4 RF領域から光領域へ変換、結果を格納
    OP1_Est = A_Est .* cutf1 + B_Est_temp;                                  % 光領域へ変換した参照光スペクトルの保存
    OPX1_Est{i} = OP1_Est;                                                  % 「OPX1_Est」に格納
    OP2_Est = A_Est .* cutf2 + B_Est_temp;                                  % 光領域へ変換した透過光スペクトルの保存
    OPX2_Est{i} = OP2_Est;                                                  % 「OPX2_Est」に格納
    OP1_Ave = A_Ave .* cutf1 + B_Ave_temp;                                  % 光領域へ変換した参照光スペクトルの保存
    OPX1_Ave{i} = OP1_Ave;                                                  % 「OPX1_Est」に格納
    OP2_Ave = A_Ave .* cutf2 + B_Ave_temp;                                  % 光領域へ変換した透過光スペクトルの保存
    OPX2_Ave{i} = OP2_Ave;                                                  % 「OPX2_Est」に格納
    
    % 6.1 取得したEOコムスペクトルの中心周波数から光モード間隔分の切り取り
    OPFc = Fc + OpRep * (i - 18);                                   % EOコムスペクトルの中心周波数を算出
    OP_Center(i) = OPFc;                                            % 各EOコムスペクトルの中心周波数を「OP_Center」に格納
    % 6.2 EOコムの切り取り範囲の設定、切り取りの実行、結果を格納
    OPmin = -OpRep / 2 + OPFc;                                      % EOコムスペクトルの中心から切り取る範囲の最小値
    OPmax = OpRep / 2 + OPFc;                                       % EOコムスペクトルの中心から切り取る範囲の最大値
        % 6.2.1 推定値
        cutOP_Est = (OPmin <= OP1_Est) & (OP1_Est < OPmax);     % 推定値におけるEOコムスペクトルの切り取る範囲を「cutOP_Est」として保存
        X1_Est = OP1_Est(cutOP_Est);                            % 切り取り後の参照光スペクトルのx軸の保存
        cutOPX1_Est{i} = X1_Est;                                % 「cutOPX1_Est」に格納
        Y1_Est = cutSmthCombA(cutOP_Est);                       % 切り取り後の参照光スペクトルのy軸の保存
        cutOPY1_Est{i} = Y1_Est;                                % 「cutOPY1_Est」に格納
        X2_Est = OP2_Est(cutOP_Est);                            % 切り取り後の透過光スペクトルのx軸の保存
        cutOPX2_Est{i} = X2_Est;                                % 「cutOPX2_Est」に格納
        Y2_Est = cutSmthCombB(cutOP_Est);                       % 切り取り後の透過光スペクトルのy軸の保存
        cutOPY2_Est{i} = Y2_Est;                                % 「cutOPY2_Est」に格納
        % 6.2.2 平均値
        cutOP_Ave = (OPmin <= OP1_Ave) & (OP1_Ave < OPmax);     % 以下同様
        X1_Ave = OP1_Ave(cutOP_Ave);
        cutOPX1_Ave{i} = X1_Ave;
        Y1_Ave = cutSmthCombA(cutOP_Ave);
        cutOPY1_Ave{i} = Y1_Ave;
        X2_Ave = OP2_Ave(cutOP_Ave);
        cutOPX2_Ave{i} = X2_Ave;
        Y2_Ave = cutSmthCombB(cutOP_Ave);
        cutOPY2_Ave{i} = Y2_Ave;
end

toc;

%% 光領域変換後のEOコムスペクトルの表示 (切り取り前)
% 7.1 切取前の光領域変換後のEOコムスペクトルの表示 (推定値)
figure
for i = 1:n
plot(OPX2_Est{i}, RFY2{i}, 'g', 'LineWidth', 1);
hold on
plot(OPX1_Est{i}, RFY1{i}, 'r', 'LineWidth', 1);
end
xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Intensity [a.u.]')                                    % y軸ラベル
set(gca, 'YScale', 'log');                                    % y軸を対数目盛に設定
ylim([1e1 1e4])                                               % y軸の表示範囲の設定
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
% title('Optically Transformed EO-Comb Spectrum of Estimated')  % グラフのタイトル
legend('Transmitted Optical Spectrum','Referenced Optical Spectrum')    % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定
hold off
disp('Est Peak Interval [MHz]'); disp(Est_PeakDiff/1e6);      % 推定値の表示
disp('Optical Interpolation of Estimated [GHz]');
disp(OpDiff_Est/1e9);                                         % 推定値の光補間量の表示

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '7.1 EO-Comb Spectrum of Estimated.emf'), 'emf');
end

% 7.2 切取前の光領域変換後のEOコムスペクトルの表示 (平均値)
figure
for i = 1:n
plot(OPX2_Ave{i}, RFY2{i}, 'g', 'LineWidth', 1);
hold on
plot(OPX1_Ave{i}, RFY1{i}, 'r', 'LineWidth', 1);
end
xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Intensity [a.u.]')                                    % y軸ラベル
set(gca, 'YScale', 'log');                                    % y軸を対数目盛に設定
ylim([1e1 1e4])                                               % y軸の表示範囲の設定
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
% title('Optically Transformed EO-Comb Spectrum of Average')    % グラフのタイトル
legend('Transmitted Optical Spectrum','Referenced Optical Spectrum')    % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定
hold off
disp('Ave Peak Interval [MHz]'); disp(Ave_PeakDiff/1e6);      % 平均値の表示
disp('Optical Interpolation of Average [GHz]');
disp(OpDiff_Ave/1e9);                                         % 平均値から算出した光補間量の表示

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '7.2 EO-Comb Spectrum of Average.emf'), 'emf');
end


%% 測定したRF吸収線ピーク間隔・算出した光補間量をtxtファイルに書き込み・保存
% txt形式で各ピーク間隔と光補間量を記録、保存
if Judge == 1
    % 保存するファイル名を作成 (%.6f: 小数点以下6桁の浮動小数点数を出力, \n: 改行)
    txtFileName = fullfile(NewFolder, 'Results.txt');
    fid = fopen(txtFileName, 'a');                                                % 書き込みで開く
    fprintf(fid, 'RF Peak Interval [MHz]: '); fprintf(fid, '%.6f ', PeakDiff2/1e6); fprintf(fid, '\n');
    fprintf(fid, 'S.D. RF Peak Interval: %.6f MHz \n\n', std_PeakDiff/1e6);
    fprintf(fid, 'Estimated_Optical Peak Interval: %.6f MHz \n', Est_PeakDiff/1e6);
    fprintf(fid, 'Average_Optical Peak Interval: %.6f MHz \n', Ave_PeakDiff/1e6);
    fprintf(fid, 'Average_Optical Interpolation amount: %.6f GHz \n\n', OpDiff_Ave/1e9);
    fclose(fid);                                                                  % ファイルを閉じる
end

%% EOコムスペクトルの表示範囲に合わせて、HITRANのマスク・ピーク位置の検出
% 準備: HITRANのマスク範囲の設定、実行
OPmaskMin = Fc - OpRep * 17.5;
disp('OPtical Min [THz]'); disp(OPmaskMin/1e12);                % HITRAN表示箇所の最小値を表示
OPmaskMax = Fc + OpRep * 17.5;
disp('OPtical Max [THz]'); disp(OPmaskMax/1e12);                % HITRAN表示箇所の最大値を表示
OPmask = (OPmaskMin <= HITRAN_X) & (HITRAN_X <= OPmaskMax);     % HITRAN表示範囲を設定
HITRAN_X = HITRAN_X(OPmask);                                    % HITRANのx軸の指定した範囲をマスク
HITRAN_Y = HITRAN_Y(OPmask);                                    % HITRANのy軸の指定した範囲をマスク

% HITRANのピーク位置の検出
OPminPeakDistance = 0.05e12;            % 検出ピーク間隔の設定 (これもRF同様あえて値を小さくし、その後余分なピーク成分を除去)

% ピーク検出の実行
[Peak_HITRAN_Y, Peak_HITRAN_X] = findpeaks(-HITRAN_Y, HITRAN_X, 'MinPeakDistance', OPminPeakDistance);
Peak_HITRAN_Y = -Peak_HITRAN_Y;         % 反転したデータを元に戻す

% HITRANの不要なピーク成分を除去
idx = Peak_HITRAN_Y < PeakJudge;       % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
Peak_HITRAN_X = Peak_HITRAN_X(idx);    % 除去後のHITRANのx軸に上書き
Peak_HITRAN_Y = Peak_HITRAN_Y(idx);    % 除去後のHITRANのy軸に上書き


%% 切り取り後のEOコムスペクトル・吸収線スペクトルの表示・ピーク位置の検出
%%% 推定値 (波長計で測定した光補間量)
% 8.1.1 切取後の光領域変換後のEOコムスペクトルの表示 (推定値)
figure
% Cell中のベクトルをすべて縦ベクトルに変換
AX2_col = cellfun(@(v) v(:), cutOPX2_Est, 'UniformOutput', false);
AY2_col = cellfun(@(v) v(:), cutOPY2_Est, 'UniformOutput', false);
AX1_col = cellfun(@(v) v(:), cutOPX1_Est, 'UniformOutput', false);
AY1_col = cellfun(@(v) v(:), cutOPY1_Est, 'UniformOutput', false);
% 縦方向に連結し、1本のスペクトルの線にする
AX2 = vertcat(AX2_col{:}); AY2 = vertcat(AY2_col{:});
AX1 = vertcat(AX1_col{:}); AY1 = vertcat(AY1_col{:});
% グラフの表示
plot(AX2, AY2, 'g', 'LineWidth', 1);
hold on
plot(AX1, AY1, 'r', 'LineWidth', 1);

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Intensity [a.u.]')                                    % y軸ラベル
set(gca, 'YScale', 'log');                                    % y軸を対数目盛に設定
ylim([1e1 1e4])                                               % y軸の表示範囲の設定
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
% title('After Cutting EO-Comb Spectrum of Estimated')          % グラフのタイトル
legend('Transmitted Optical Spectrum','Referenced Optical Spectrum')    % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '8.1.1 Cutted EO-Comb Spectrum of Estimated.emf'), 'emf');
end

% 8.1.2 吸収線スペクトルの取得及び表示、HITRANとの比較 (推定値)
Absorption_Est = AY2 ./ AY1;                                  % 透過率の算出
figure
plot(AX1, Absorption_Est, 'r', 'LineWidth', 1);               % 測定結果の表示 (実線)
hold on
plot(HITRAN_X, HITRAN_Y, '--g', 'LineWidth', 1);              % HITRANの表示 (破線)

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
ylim([0.4 1.4])                                               % y軸の表示範囲の設定
yticks(0.4:0.2:1.4)                                           % y軸のメモリ設定
% title('Optical Absorption of Estimated')                      % グラフのタイトル
legend('Measurement of Average','HITRAN')                     % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '8.1.2 Optical Absorption of Estimated.emf'), 'emf');
end

%% ピーク位置の検出 (推定値)
% 8.1.3 吸収線ピーク位置の検出、HITRANとの比較 (推定値)
[PeakAbsorption_Est, PeakLocation_Est] = findpeaks(-Absorption_Est, AX1, 'MinPeakDistance', OPminPeakDistance);
PeakAbsorption_Est = -PeakAbsorption_Est;                                   % 反転したデータを元に戻す
idx = PeakAbsorption_Est < PeakJudge;                                      % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
PeakLocation_Est = PeakLocation_Est(idx);                                  % 除去後のx軸に上書き
PeakAbsorption_Est = PeakAbsorption_Est(idx);                              % 除去後のy軸に上書き

% HITRANとサイズが異なる場合に、サイズの小さい方に合わせる
if length(Peak_HITRAN_X) ~= length(PeakLocation_Est)
    MinLen = min(length(Peak_HITRAN_X), length(PeakLocation_Est));
    Peak_HITRAN_X = Peak_HITRAN_X(1:MinLen);
    Peak_HITRAN_Y = Peak_HITRAN_Y(1:MinLen);
    PeakLocation_Est = PeakLocation_Est(1:MinLen);
    PeakAbsorption_Est = PeakAbsorption_Est(1:MinLen);
end

plot(Peak_HITRAN_X, Peak_HITRAN_Y, 'bv', 'MarkerFaceColor', 'c');           % HITRANのピーク位置に谷(シアン)でプロット
plot(PeakLocation_Est, PeakAbsorption_Est, 'bv', 'MarkerFaceColor', 'm');   % 最終的に検出した吸収線ピークを谷(マゼンタ)でプロット
legend('Measurement of Estimated','HITRAN')                                 % 凡例

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '8.1.3 Peak Plotted Optical Absorption of Estimated.emf'), 'emf');
end

%% 平均値 (隣り合ったRF吸収線のピーク間隔の平均値)
% 8.2.1 切取後の光領域変換後のEOコムスペクトルの表示 (平均値)
figure
% Cell中のベクトルをすべて縦ベクトルに変換
BX2_col = cellfun(@(v) v(:), cutOPX2_Ave, 'UniformOutput', false);
BY2_col = cellfun(@(v) v(:), cutOPY2_Ave, 'UniformOutput', false);
BX1_col = cellfun(@(v) v(:), cutOPX1_Ave, 'UniformOutput', false);
BY1_col = cellfun(@(v) v(:), cutOPY1_Ave, 'UniformOutput', false);
% 縦方向に連結し、1本のスペクトルの線にする
BX2 = vertcat(BX2_col{:}); BY2 = vertcat(BY2_col{:});
BX1 = vertcat(BX1_col{:}); BY1 = vertcat(BY1_col{:});
% グラフの表示
plot(BX2, BY2, 'g', 'LineWidth', 1);
hold on
plot(BX1, BY1, 'r', 'LineWidth', 1);

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Intensity [a.u.]')                                    % y軸ラベル
set(gca, 'YScale', 'log');                                    % y軸を対数目盛に設定
ylim([1e1 1e4])                                               % y軸の表示範囲の設定
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
% title('After Cutting EO-Comb Spectrum of Average')            % グラフのタイトル
legend('Transmitted Optical Spectrum','Referenced Optical Spectrum')    % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '8.2.1 Cutted EO-Comb Spectrum of Average.emf'), 'emf');
end

% 8.2.2 吸収線スペクトルの取得及び表示、HITRANとの比較 (平均値)
Absorption_Ave = BY2 ./ BY1;                                  % 透過率の算出
figure
plot(BX1, Absorption_Ave, 'r', 'LineWidth', 1);               % 測定結果の表示 (実線)
hold on
plot(HITRAN_X, HITRAN_Y, '--g', 'LineWidth', 1);              % HITRANの表示 (破線)

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
ylim([0.4 1.4])                                               % y軸の表示範囲の設定
yticks(0.4:0.2:1.4)                                           % y軸のメモリ設定
% title('Optical Absorption of Average')                        % グラフのタイトル
legend('Measurement of Average','HITRAN')                     % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '8.2.2 Optical Absorption of Average.emf'), 'emf');
end

mean(diff(BX1/1e6))


%% ピーク位置の検出 (平均値)
% 8.2.3 吸収線ピーク位置の検出、HITRANとの比較 (平均値)
[PeakAbsorption_Ave, PeakLocation_Ave] = findpeaks(-Absorption_Ave, BX1, 'MinPeakDistance', OPminPeakDistance);
PeakAbsorption_Ave = -PeakAbsorption_Ave;                                   % 反転したデータを元に戻す
idx = PeakAbsorption_Ave < PeakJudge;                                      % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
PeakLocation_Ave = PeakLocation_Ave(idx);                                  % 除去後のx軸に上書き
PeakAbsorption_Ave = PeakAbsorption_Ave(idx);                              % 除去後のy軸に上書き

% HITRANとサイズが異なる場合に、サイズの小さい方に合わせる
if length(Peak_HITRAN_X) ~= length(PeakLocation_Ave)
    MinLen = min(length(Peak_HITRAN_X), length(PeakLocation_Ave));
    Peak_HITRAN_X = Peak_HITRAN_X(1:MinLen);
    Peak_HITRAN_Y = Peak_HITRAN_Y(1:MinLen);
    PeakLocation_Ave = PeakLocation_Ave(1:MinLen);
    PeakAbsorption_Ave = PeakAbsorption_Ave(1:MinLen);
end

plot(Peak_HITRAN_X, Peak_HITRAN_Y, 'bv', 'MarkerFaceColor', 'c');           % HITRANのピーク位置に谷(シアン)でプロット
plot(PeakLocation_Ave, PeakAbsorption_Ave, 'bv', 'MarkerFaceColor', 'm');   % 最終的に検出した吸収線ピークを谷(マゼンタ)でプロット
legend('Measurement of Average','HITRAN')                                   % 凡例

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '8.2.3 Peak Plotted Optical Absorption of Average.emf'), 'emf');
end

toc;

%% 吸収線スペクトルのスムージング処理 (必要であればコメント化解除して使用)
% スムージング処理 (やり過ぎると分解能が下がるので注意)
Absorption_Est = movmean(abs(Absorption_Est), smth); %/A_Est);
Absorption_Ave = movmean(abs(Absorption_Ave), smth); %/A_Ave);

toc;

%% 取得データとHITRANのピーク間隔の差分の測定 / 比較・標準偏差の算出
% HITRANと取得した吸収線ピーク位置の残差の算出及び表示
PeakRes_HITRAN_AX = abs(Peak_HITRAN_X(1:end).' - PeakLocation_Est(1:end).');                    % HITRANと推定値とのピーク位置の差分の算出
PeakRes_HITRAN_BX = abs(Peak_HITRAN_X(1:end).' - PeakLocation_Ave(1:end).');                    % HITRANと平均値とのピーク位置の差分の算出
disp('Peak Residual Between HITRAN and Est [GHz]'); disp(PeakRes_HITRAN_AX/1e9);
disp('Peak Residual Between HITRAN and Ave [GHz]'); disp(PeakRes_HITRAN_BX/1e9);

% 標準偏差の算出及び表示 (ここ大事)
PeakRes_HITRAN_AX_SD = std(PeakRes_HITRAN_AX);
PeakRes_HITRAN_BX_SD = std(PeakRes_HITRAN_BX);
disp('S.D. Peak Residual Between HITRAN and Est [GHz]'); disp(PeakRes_HITRAN_AX_SD/1e9);
disp('S.D. Peak Residual Between HITRAN and Ave [GHz]'); disp(PeakRes_HITRAN_BX_SD/1e9);

toc;


%% 吸収線スペクトルのベースライン補正
%%% 参照光・透過光スペクトル強度の不均一さによって生じるベースラインの傾きを補正する
%%% 事前設定
% 吸収線ピーク位置から切り取る範囲 (適宜変更)
PeakRange = 15e9;       % ±範囲

% 配列の初期化・事前割り当て
Basemask_Est = true(size(AX1));
Basemask_Ave = true(size(BX1));

%% 切り取る吸収線範囲を破線で表示
%%% 推定値 (波長計で測定した光補間量)
% 9.1 切り取る吸収線範囲を破線で表示 (推定値)
figure
plot(AX1, Absorption_Est, 'r', 'LineWidth', 1);               % 測定結果の表示 (実線)
hold on

for i = 1:length(PeakLocation_Est)
    % マスクする吸収線の存在範囲を設定
    PeakRangeStart_Est = PeakLocation_Est(i) - PeakRange / 2;
    PeakRangeEnd_Est = PeakLocation_Est(i) + PeakRange / 2;
    Basemask_Est = Basemask_Est & ((AX1 <= PeakRangeStart_Est) | (PeakRangeEnd_Est <= AX1));

    % 吸収線ピークの範囲をプロット
    xline(PeakRangeStart_Est, 'g--', 'LineWidth', 0.5);       % 開始位置を赤い破線で表示
    xline(PeakRangeEnd_Est, 'g--', 'LineWidth', 0.5);         % 終了位置を赤い破線で表示
end

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
ylim([0.9 1.2])                                               % y軸の表示範囲の設定
yticks(0.9:0.1:1.2)                                           % y軸のメモリ設定
% title('Mask Range of Estimated')                              % グラフのタイトル
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '9.1 Mask Range of Estimated.emf'), 'emf');
end

%% 平均値 (隣り合ったRF吸収線のピーク間隔の平均値)
% 9.2 切り取る吸収線範囲を破線で表示 (平均値)
figure
plot(BX1, Absorption_Ave, 'r', 'LineWidth', 1);               % 測定結果の表示 (実線)
hold on

for i = 1:length(PeakLocation_Ave)
    % マスクする吸収線の存在範囲を設定
    PeakRangeStart_Ave = PeakLocation_Ave(i) - PeakRange / 2;
    PeakRangeEnd_Ave = PeakLocation_Ave(i) + PeakRange / 2;

    Basemask_Ave = Basemask_Ave & ((BX1 <= PeakRangeStart_Ave) | (PeakRangeEnd_Ave <= BX1));

    % 吸収線ピークの範囲をプロット
    xline(PeakRangeStart_Ave, 'g--', 'LineWidth', 0.5);       % 開始位置を赤い破線で表示
    xline(PeakRangeEnd_Ave, 'g--', 'LineWidth', 0.5);         % 終了位置を赤い破線で表示
end

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
ylim([0.9 1.2])                                               % y軸の表示範囲の設定
yticks(0.9:0.1:1.2)                                           % y軸のメモリ設定
% title('Mask Range of Average')                                % グラフのタイトル
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '9.2 Mask Range of Average.emf'), 'emf');
end

%% 吸収線部分をマスクし、ベースラインのみを残す
% ベースラインのみ保存
Baseline_AX = AX1(Basemask_Est);
Baseline_AY = Absorption_Est(Basemask_Est);
Baseline_BX = BX1(Basemask_Ave);
Baseline_BY = Absorption_Ave(Basemask_Ave);


%% 曲線フィッターによる近似曲線生成シミュレーション
% curveFitter(Baseline_AX, Baseline_AY);
% curveFitter(Baseline_BX, Baseline_BY);

%% ベースラインの正規化 (センタリングとスケーリングの実行)
%%% センタリング：データの平均値を基準に「平均値からのズレ」としてデータを変換する処理 (平均値で減算)
%%% スケーリング：データのばらつきを±１程度のズレに収める処理 (標準偏差で除算)
%%% これらはNormalizeを"ON"にすることで実行可能
% 正規化あり
n = 9;                                          % 次数の設定 (1～9)
Degree = sprintf('poly%d', n);
options1 = fitoptions('Normalize', 'on');       % 正規化ON
% 近似関数の生成
fA1 = fit(Baseline_AX, Baseline_AY, Degree, options1);
fB1 = fit(Baseline_BX, Baseline_BY, Degree, options1);
disp(fA1); disp(fB1);                           % 結果の表示

State1 = options1.Normalize;                    % 正規化状態を格納 (後にtxt形式で保存したいから)

%% 近似曲線の算出
% 近似曲線の生成 (正規化あり)
Fit_AX1 = feval(fA1, AX1);
Fit_BX1 = feval(fB1, BX1);

%% 近似関数の保存 (任意の次数に対応)
if Judge == 1
    % 保存するファイル名を作成 (%.6f: 小数点以下6桁の浮動小数点数を出力, \n: 改行)
    txtFileName = fullfile(NewFolder, 'Results.txt');
    fid = fopen(txtFileName, 'a');                                                % 書き込みで開く
    fprintf(fid, 'Approximate Polynomial Degree:  %d\n', n);
    fprintf(fid, 'Model: F(x) = p1*x^%d + p2*x^%d + ... + p%d*x + p%d\n', n, n-1, n, n+1);
    fprintf(fid, 'Normalize: %s\n\n', State1);
    
    % 近似関数の各係数を格納
    CoeffA = coeffvalues(fA1);
    CoeffB = coeffvalues(fB1);

    width = length(num2str(length(CoeffA)));        % 係数pの桁幅を記録
    
    % 近似関数の各係数をtxt形式で保存
    fprintf(fid, '         Estimated       Average\n\n');
    for i = 1:length(CoeffA)
        fprintf(fid, sprintf('p%%%dd =  %%10.6f %%15.6f\n', width), i, CoeffA(i), CoeffB(i));
    end
    fprintf(fid, '\n');

    fclose(fid);
end

%% 正規化なしver. ※使う場合はコメント化解除 (実行すると警告文が表示される)
% % 正規化なし
% options2 = fitoptions('Normalize', 'off');        % 正規化OFF
% fA2 = fit(Baseline_AX, Baseline_AY, Degree, options2);
% fB2 = fit(Baseline_BX, Baseline_BY, Degree, options2);
% disp(fA2); disp(fB2);                             % 結果の表示

% % 近似曲線の生成 (正規化なし)
% Fit_AX2 = feval(fA2, Baseline_AX);
% Fit_BX2 = feval(fB2, Baseline_BX);


%% ベースラインと近似曲線の表示
%%% 推定値 (波長計で測定した光補間量)
% 10.1 結果の表示 (推定値)
figure
plot(Baseline_AX, Baseline_AY, '.r', 'LineWidth', 1);          % 測定結果の表示 (赤点線)
hold on
plot(AX1, Fit_AX1, 'g', 'LineWidth', 1.5);                      % 正規化ありの近似曲線 (緑線)

% plot(AX1, Fit_AX2, 'y', 'LineWidth', 1.5);                      % 正規化なしの近似曲線 (黄線)

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
ylim([0.9 1.2])                                               % y軸の表示範囲の設定
yticks(0.9:0.1:1.2)                                           % y軸のメモリ設定
% title('Baseline of Estimated')                                % グラフのタイトル
legend('Baseline of Estimated','Polynomial Trendline')        % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '10.1 Baseline of Estimated.emf'), 'emf');
end

%% 平均値 (隣り合ったRF吸収線のピーク間隔の平均値)
% 10.2 結果の表示 (平均値)
figure
plot(Baseline_BX, Baseline_BY, '.r', 'LineWidth', 1);          % 測定結果の表示 (赤点線)
hold on
plot(BX1, Fit_BX1, 'g', 'LineWidth', 1.5);                      % 正規化ありの近似曲線 (緑線)

% plot(BX1, Fit_BX2, 'y', 'LineWidth', 1.5);                      % 正規化なしの近似曲線 (黄線)

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
ylim([0.9 1.2])                                               % y軸の表示範囲の設定
yticks(0.9:0.1:1.2)                                           % y軸のメモリ設定
% title('Baseline of Average')                                  % グラフのタイトル
legend('Baseline of Average','Polynomial Trendline')          % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '10.2 Baseline of Average.emf'), 'emf');
end

toc;


%% 算出した近似曲線の除算による吸収線スペクトルのベースライン補正
% 近似曲線で除算・ベースライン補正の実行
Div_Absorption_Est = Absorption_Est ./ Fit_AX1;
Div_Absorption_Ave = Absorption_Ave ./ Fit_BX1;

%% 推定値 (波長計で測定した光補間量)
% 11.1.1 除算後の吸収線スペクトル (推定値)
figure
plot(AX1, Div_Absorption_Est, 'r', 'LineWidth', 1);
hold on
plot(HITRAN_X, HITRAN_Y, '--g', 'LineWidth', 1);              % HITRANの表示 (破線)

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
ylim([0.4 1.4])                                               % y軸の表示範囲の設定
yticks(0.4:0.2:1.4)                                           % y軸のメモリ設定
% title('Baseline Corrected Optical Absorption of Estimated')   % グラフのタイトル
legend('Corrected Measurement of Estimated','HITRAN')         % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '11.1.1 Baseline Corrected Optical Absorption of Estimated.emf'), 'emf');
end

% 11.1.2 吸収線ピーク位置の検出、HITRANとの比較 (推定値)
[DivPeakAbsorption_Est, DivPeakLocation_Est] = findpeaks(-Div_Absorption_Est, AX1, 'MinPeakDistance', OPminPeakDistance);
DivPeakAbsorption_Est = -DivPeakAbsorption_Est;                                   % 反転したデータを元に戻す
idx = DivPeakAbsorption_Est < PeakJudge;                                         % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
DivPeakLocation_Est = DivPeakLocation_Est(idx);                                  % 除去後のx軸に上書き
DivPeakAbsorption_Est = DivPeakAbsorption_Est(idx);                              % 除去後のy軸に上書き

% HITRANとサイズが異なる場合に、サイズの小さい方に合わせる
if length(Peak_HITRAN_X) ~= length(DivPeakLocation_Est)
    MinLen = min(length(Peak_HITRAN_X), length(DivPeakLocation_Est));
    Peak_HITRAN_X = Peak_HITRAN_X(1:MinLen);
    Peak_HITRAN_Y = Peak_HITRAN_Y(1:MinLen);
    DivPeakLocation_Est = DivPeakLocation_Est(1:MinLen);
    DivPeakAbsorption_Est = DivPeakAbsorption_Est(1:MinLen);
end

plot(Peak_HITRAN_X, Peak_HITRAN_Y, 'bv', 'MarkerFaceColor', 'c');                 % HITRANのピーク位置に谷(シアン)でプロット
plot(DivPeakLocation_Est, DivPeakAbsorption_Est, 'bv', 'MarkerFaceColor', 'm');   % 最終的に検出した吸収線ピークを谷(マゼンタ)でプロット
legend('Corrected Measurement of Estimated','HITRAN')         % 凡例

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '11.1.2 Peak Plotted Baseline Corrected Optical Absorption of Estimated.emf'), 'emf');
end

%% 平均値 (隣り合ったRF吸収線のピーク間隔の平均値)
%11.2.1 除算後の吸収線スペクトル (平均値)
figure
plot(BX1, Div_Absorption_Ave, 'r', 'LineWidth', 1);
hold on
plot(HITRAN_X, HITRAN_Y, '--g', 'LineWidth', 1);              % HITRANの表示 (破線)

xlabel('Frequency [THz]')                                     % x軸ラベル
ylabel('Transmittance [a.u.]')                                % y軸ラベル
ax = gca;                                                     % 現在の座標軸の取得 
ax.XTick = 194.9e12:0.2e12:195.9e12;                          % 座標軸の取得範囲の設定 (始点:間隔:終点)
ax.XTickLabel = string(ax.XTick/1e12);                        % THz表記に設定 (10^12 部分を削除)
xlim([194.9e12 195.9e12])                                     % x軸の表示範囲の設定
ylim([0.4 1.4])                                               % y軸の表示範囲の設定
yticks(0.4:0.2:1.4)                                           % y軸のメモリ設定
% title('Baseline Corrected Optical Absorption of Average')     % グラフのタイトル
legend('Corrected Measurement of Average','HITRAN')           % 凡例
fontsize(14,"points")                                         % フォントサイズの設定
fontname("Times New Roman")                                   % フォント名の設定

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '11.2.1 Baseline Corrected Optical Absorption of Average.emf'), 'emf');
end

% 11.2.2 吸収線ピーク位置の検出、HITRANとの比較 (平均値)
[DivPeakAbsorption_Ave, DivPeakLocation_Ave] = findpeaks(-Div_Absorption_Ave, BX1, 'MinPeakDistance', OPminPeakDistance);
DivPeakAbsorption_Ave = -DivPeakAbsorption_Ave;                                   % 反転したデータを元に戻す
idx = DivPeakAbsorption_Ave < PeakJudge;                                         % 不要なピーク成分を除去 (設定した値未満のみをピークと判断し、インデックスを取得)
DivPeakLocation_Ave = DivPeakLocation_Ave(idx);                                  % 除去後のx軸に上書き
DivPeakAbsorption_Ave = DivPeakAbsorption_Ave(idx);                              % 除去後のy軸に上書き

% HITRANとサイズが異なる場合に、サイズの小さい方に合わせる
if length(Peak_HITRAN_X) ~= length(DivPeakLocation_Ave)
    MinLen = min(length(Peak_HITRAN_X), length(DivPeakLocation_Ave));
    Peak_HITRAN_X = Peak_HITRAN_X(1:MinLen);
    Peak_HITRAN_Y = Peak_HITRAN_Y(1:MinLen);
    DivPeakLocation_Ave = DivPeakLocation_Ave(1:MinLen);
    DivPeakAbsorption_Ave = DivPeakAbsorption_Ave(1:MinLen);
end

plot(Peak_HITRAN_X, Peak_HITRAN_Y, 'bv', 'MarkerFaceColor', 'c');                 % HITRANのピーク位置に谷(シアン)でプロット
plot(DivPeakLocation_Ave, DivPeakAbsorption_Ave, 'bv', 'MarkerFaceColor', 'm');   % 最終的に検出した吸収線ピークを谷(マゼンタ)でプロット
legend('Corrected Measurement of Average','HITRAN')           % 凡例

hold off

% グラフの保存 (emf形式)
if Judge == 1
    saveas(gcf, fullfile(EmfFolder, '11.2.2 Peak Plotted Baseline Corrected Optical Absorption of Average.emf'), 'emf');
end

toc;


%% ベースライン補正後の取得データとHITRANのピーク間隔の差分の測定 / 比較・標準偏差の算出
% HITRANとベースライン補正後の吸収線ピーク位置の残差の算出及び表示
DivPeakRes_HITRAN_AX = Peak_HITRAN_X(1:end).' - DivPeakLocation_Est(1:end).';                    % HITRANと推定値とのピーク位置の差分の算出
DivPeakRes_HITRAN_BX = Peak_HITRAN_X(1:end).' - DivPeakLocation_Ave(1:end).';                    % HITRANと平均値とのピーク位置の差分の算出
disp('Corrected Peak Residual Between HITRAN and Est [GHz]'); disp(DivPeakRes_HITRAN_AX/1e9);
disp('Corrected Peak Residual Between HITRAN and Ave [GHz]'); disp(DivPeakRes_HITRAN_BX/1e9);

% 標準偏差の算出及び表示
DivPeakRes_HITRAN_AX_SD = std(abs(DivPeakRes_HITRAN_AX));
DivPeakRes_HITRAN_BX_SD = std(abs(DivPeakRes_HITRAN_BX));
disp('S.D. Corrected Peak Residual Between HITRAN and Est [GHz]'); disp(DivPeakRes_HITRAN_AX_SD/1e9);
disp('S.D. Corrected Peak Residual Between HITRAN and Ave [GHz]'); disp(DivPeakRes_HITRAN_BX_SD/1e9);

%% 測定したピーク間隔の差分・標準偏差をtxtファイルに書き込み・保存
% txt形式で各ピーク間隔の差分・標準偏差と平均値、標準偏差を記録、保存
if Judge == 1
    % 保存するファイル名を作成 (%.6f: 小数点以下6桁の浮動小数点数を出力, \n: 改行)
    txtFileName = fullfile(NewFolder, 'Results.txt');
    fid = fopen(txtFileName, 'a');                                                % 書き込みで開く
    fprintf(fid, 'PeakJudge: %.2f \n', PeakJudge);
    fprintf(fid, 'Corrected Peak Residual Between HITRAN and Estimated [GHz]: '); fprintf(fid, ' %.4f ', DivPeakRes_HITRAN_AX/1e9);
    fprintf(fid, '\n');
    fprintf(fid, 'Corrected Peak Residual Between HITRAN and Average [GHz]:   '); fprintf(fid, ' %.4f ', DivPeakRes_HITRAN_BX/1e9);
    fprintf(fid, '\n\n');
    fprintf(fid, 'S.D. Corrected Peak Residual Between HITRAN and Estimated: %.6f GHz \n', DivPeakRes_HITRAN_AX_SD/1e9);
    fprintf(fid, 'S.D. Corrected Peak Residual Between HITRAN and Average:   %.6f GHz \n', DivPeakRes_HITRAN_BX_SD/1e9);
    fclose(fid);                                                                  % ファイルを閉じる
end

toc;

