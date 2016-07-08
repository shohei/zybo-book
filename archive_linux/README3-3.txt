第３部 Linux編 第３章　ネットにつながるFPGA！　ZYBOで作る遠隔操作システム

2016/01/19. このドキュメントの最新版は以下のサイトにあります。
http://digitalfilter.com/zybobook/README.html

以下のようにVivadoでビットストリーム生成、ZYBOで実行してください。

１．
Vivado 2014.1でxillidemoプロジェクト（第３部第２章で作成したもの）を開く
SourcesタブのHierarchyタブでxillydemoをダブルクリック
xillydemo.vの内容をvivado3-3/xillydemo.vと置き換えてセーブ

2.
Generate Bitstream
エラーなく終了したら
xillinux-eval-zybo-1.3b/verilog/vivado/xillydemo.runs/impl_1に
xillydemo.bitが出来ているのでSDカードの同ファイルと置き換える

3.
app3-3ディレクトリ（C言語やMakefileがある）をSDカードのrootにコピー（以下参照）。
sudo cp -r app3-3 /media/xxx/yyy/root
（xxxやyyyはdfコマンドで調べる）

4.
SDカードをZYBOに挿して電源ON
立ち上がったらstartxコマンド

5.
Terminalを開く
cd app3-3
記事に従ってコンパイル／実行／測定

