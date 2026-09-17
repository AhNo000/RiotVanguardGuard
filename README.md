# Riot Vanguard Guard

A lightweight Windows watchdog for Riot Vanguard.

## What it does

- Detects Riot Client / Riot game launches
- Sets the `vgc` service to Automatic if needed
- Starts `vgc` if it is stopped
- Writes actions to `guard.log`

## Installation

1. Download the latest release ZIP.
2. Extract it to a permanent folder.
3. Run `安裝.cmd`.
4. Approve the Administrator prompt.

## Uninstallation

Run `移除.cmd`.

## Important

If you use Riot's Vanguard On-Demand mode, do not use this tool.

## Disclaimer

This project is not affiliated with or endorsed by Riot Games.

# Riot Vanguard Guard

一個簡單的 Windows 背景工具，用來處理 Riot Vanguard 的 `vgc` 服務沒有正常啟動的問題。

## 功能

當 Riot Client 或 Riot 遊戲啟動時，本工具會自動：

- 檢查 `vgc` 服務
- 如果 `vgc` 為「手動」，改為「自動」
- 如果 `vgc` 已停止，自動啟動
- 將執行紀錄寫入 `guard.log`

## 支援的 Riot 程式

目前會偵測包括：

- Riot Client
- League of Legends
- VALORANT
- Legends of Runeterra
- 2XKO

以及安裝在 `Riot Games` 資料夾內的其他 Riot 程式。

## 安裝

1. 到 Releases 下載最新版本 ZIP。
2. 解壓縮到一個固定位置。
3. 執行：

   `安裝.cmd`

4. Windows 跳出系統管理員權限詢問時按「是」。

安裝後會建立 Windows 工作排程：

`Riot Vanguard Guard`

之後每次登入 Windows 都會自動在背景執行。

## Log

執行紀錄會產生在 Guard 所在資料夾：

`guard.log`

例如：

```text
Watcher started.
Started vgc service. PreviousState=Stopped
vgc check complete: StartMode=Auto, State=Running
