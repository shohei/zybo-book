第３部 Linux編 第５章　ドライバの知識がなくてもOKーLinux on ZYBOで制御する加速度センサ

2016/01/19. このドキュメントの最新版は以下のサイトにあります。
http://digitalfilter.com/zybobook/README.html

以下のようにVivadoでビットストリーム生成、ZYBOで実行してください。

１．
Vivado 2014.1でxillidemoプロジェクトを開く
SourcesタブのHierarchyタブでxillydemoをダブルクリック
xillydemo.vの内容をvivado3-5/xillydemo.vと置き換えてセーブ

2.
SourcesタブのHierarchyタブでDesign Sourcesを右クリック
Add sources
Add or create design sources
Add files
vivado3-5ディレクトリのS_P.v, P_S.vを選択してFinish

3.
Run Implementation。おそらく以下のエラーが出る。出なければGenerate Bitstreamの後5.に進む。
[showstopper 0] Timing constraints weren't met. Please check your design.

4.
メニューのToolsから
Project Settings
Implementation
Optionの下の方、Rout Designにあるtcl.postのxマークをクリックしてtclファイルを消す
再度Run Implementation
成功したらGenarate Bitstream

5.
エラーなく終了したら
xillinux-eval-zybo-1.3b/verilog/vivado/xillydemo.runs/impl_1に
xillydemo.bitが出来ているのでSDカードの同ファイルと置き換える

6.
app3-5ディレクトリ（C言語やMakefileがある）をSDカードのrootにコピー（以下参照）
sudo cp -r app3-5 /media/xxx/yyy/root
（xxxやyyyはdfコマンドで調べる）

7.
SDカードをZYBOに挿して電源ON
立ち上がったらstartxコマンド

8.
Terminalを開く
cd app3-5
記事に従ってコンパイル／実行／測定

