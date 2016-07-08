第３部 Linux編 第１章　ZYBOにLinuxを載せて使ってみる－OSからFPGAのロジックを制御

2016/01/19. このドキュメントの最新版は以下のサイトにあります。
http://digitalfilter.com/zybobook/README.html

以下のようにVivadoでビットストリーム生成、ZYBOで実行してください。

１．
Vivado 2014.1でxillidemo.xpr(Vivadoプロジェクト)を開く
SourcesタブのHierarchyタブでxillydemoをダブルクリック
xillydemo.vの内容をvivado3-1/xillｙdemo.vと置き換えてセーブ

2.
Generate Bitstream
エラーなく終了したら
xillinux-eval-zybo-1.3b/verilog/vivado/xillydemo.runs/impl_1に
xillydemo.bitが出来ているのでSDカードの同ファイルと置き換える

3.
SDカードをZYBOに挿して電源ON
立ち上がったらstartxコマンド

4.
Terminalを開く
記事に従って実行


