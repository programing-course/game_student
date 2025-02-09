# **04_環境構築（Windows）**

## **1. Gitのインストール**

①公式サイトからインストーラーをダウンロード  

https://git-scm.com/download/win

<br>

![Gitのインストール](img/dev1-1.png)  

<br>

[Next]をひたすらクリック  
[Install]をクリック  
最後に[Finish]をクリック  

![Gitのインストール](img/dev1-2.png)  
![Gitのインストール](img/dev1-3.png)  
![Gitのインストール](img/dev1-4.png)  

<br>

## **2. FlutterSDKのインストール**

<br>

①公式サイトからFlutterSDKをダウンロード  

https://docs.flutter.dev/get-started/install/windows

<br>

![FlutterSDKのインストール](img/dev2-1.png)  

<br>

画面右上（または左下）のアイコンでダウンロードの進行状況が確認できます

![FlutterSDKのインストール](img/dev2-2i.png)  

<br>

ダウンロードの途中でも②に進みましょう

<br>

②フォルダを作成

Cドライブ直下に「src」　その下に「projects」フォルダを作成する

![フォルダを作る](img/dev2-2.png)

<br>

③ ①のダウンロード完了後、「ダウンロード」フォルダからzipファイルを右クリック > すべて展開　

![展開](img/dev2-3.png)

<br>

---
<br>

「参照」ボタンをクリックし、Cドライブ＞srcフォルダを選択

![展開](img/dev2-4.png)

---
<br>

![展開](img/dev2-5.png)

---
<br>

右下の「展開」ボタンをクリックする。  
![展開](img/dev2-6.png)

---
<br>

## **3. PATHを通す**

①src > flutter > bin を開き、アドレスバーのbinの上で右クリック > アドレスとテキストとしてコピー　をクリック

![PATHを通す](img/dev3-1.png)

<br>

②タスクバーの検索に「env」と入力し、「システム環境変数の編集」をクリック

![PATHを通す](img/dev3-2.png)

<br>

![PATHを通す](img/dev3-3.png)

<br>

③「環境変数」をクリック、「Path」を選択し「編集」をクリック

![PATHを通す](img/dev3-4.png)

<br>

![PATHを通す](img/dev3-5.png)

<br>

④「新規」をクリックし、①でコピーしたアドレスを貼り付けてOKをクリック  
![PATHを通す](img/dev3-6.png)

<br>

## **4. 設定の確認**

①タスクバーの検索に「PowerShell」と入力し「Windows PowerShell」をクリック  

![確認](img/dev4-1.png)

<br>

![確認](img/dev4-2.png)

<br>

②「flutter doctor」コマンドを入力し、エンター  

![確認](img/dev4-3.png)

<br>

![確認](img/dev4-4.png)

<br>

下記の項目に緑のチェックがついていればOK

   - Flutter
   - Chrome
   - VS Code

<br>

## **5. VSCodeの設定**

<br>

①拡張機能を追加

   - Flutter
   - Flutter Widget Snippets
   - Dart
   - Code runner  

<br>

![VSCode](img/dev5-1.png)
<br>

![VSCode](img/dev5-2.png)
<br>

![VSCode](img/dev5-3.png)
<br>

②Code runnerの設定

左下の歯車マークから「設定」を選択、「設定の選択」に「Code runner」と入力、「Run In Terminal」にチェックを入れる  

![VSCode](img/dev5-4.png)  
<br>
