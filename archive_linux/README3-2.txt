第３部 Linux編 第２章　ロジック×ARMで実現！ 堅牢で柔軟なディジタル・フィルタ

2016/01/19. このドキュメントの最新版は以下のサイトにあります。
http://digitalfilter.com/zybobook/README.html

以下のようにVivadoでビットストリーム生成、ZYBOで実行してください。

１．
Vivado 2014.1でxillidemoプロジェクト（第３部第１章で作成したもの）を開く
SourcesタブのHierarchyタブでxillydemoをダブルクリック
xillydemo.vの内容をvivado3-2/xillydemo.vと置き換えてセーブ

2.
SourcesタブのHierarchyタブでDesign Sourcesを右クリック
Add sources
Add or create design sources
Add files
vivado3-2ディレクトリのMuxIir.v, S_P.v, P_S.v, initial_latch.vを選択してFinish

3.
Run Implementation。おそらく以下のエラーが出る。
[showstopper 0] Timing constraints weren't met. Please check your design.

4.
メニューのToolsから
Project Settings
Implementation
Optionの下の方、Rout Designにあるtcl.postのxマークをクリックしてtclファイルを消す
再度Run Implementation
成功したらGenerate Bitstream

5.
エラーなく終了したら
xillinux-eval-zybo-1.3b/verilog/vivado/xillydemo.runs/impl_1に
xillydemo.bitが出来ているのでSDカードの同ファイルと置き換える

6.
app3-2ディレクトリ（C言語やMakefileがある）をSDカードのrootにコピー（以下参照）
sudo cp -r app3-2 /media/xxx/yyy/root
（xxxやyyyはdfコマンドで調べる）

7.
SDカードをZYBOに挿して電源ON
立ち上がったらstartxコマンド
Terminalを開く

8.
/etc/pulse/default.paの変更（リスト3-6参照）
/usr/local/bin/zybo_sound_setup.plの変更（リスト3-7参照)
セーブしてリブートする

9.
Terminalを開く
cd app3-2
記事に従ってコンパイル／実行／測定

