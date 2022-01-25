# QrzLookup Tool

## Overview

QrzLookupツールは、入力されたコールサインの情報をQRZ.COMのデータベースから取得するツールです。  
QRZ.COMの QRZ XML Logbook Data Subscription に加入する必要があります。  

また、QRZCQ.COMからも情報を取得できます。こちらはPremium会員の資格が必要です。  

## QrzLookup.ini

QRZ.COMへのログイン情報はQrzLookup.iniファイルに記述します。  

~~~
[SETTINGS]
; アクセス先サイト
; 0:QRZ.COM
; 1:QRZRC.COM
SiteSelect=0

[QRZ.COM]
UserID=ユーザーID
Password=パスワード

[QRZCQ.COM]
UserID=ユーザーID
Password=パスワード

~~~
