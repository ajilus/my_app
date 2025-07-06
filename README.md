# へんしんおえかき
*Draw ➜ Tap ➜ AI が完成イラストに “へんしん” してくれる子ども向けお絵描きアプリ*

---

## ✨ 主な特徴
- **お絵描きキャンバス**：色／太さ変更、Undo・Redo
- **へんしんボタン**：Genkit + Gemini で AI 生成（強さ 1–10、6 つのテイスト）
- **保存 & 続きから再開**：端末ローカル（Hive）にオフライン保存
- **SNS シェア**：Instagram・LINE・X など OS 標準シェアシート
- **広告モデル**  
  - バナー：常時画面下部  
  - リワード：  
    1. へんしんをタップ → 動画広告  
    2. 再生中に AI 生成開始  
    3. 視聴後すぐ生成結果を表示  
    4. スキップ／失敗 → 「もう一度広告を見る」ダイアログでリトライ

---

## 🗺 画面 / ルーティング
| Route | Widget | 説明 |
|-------|--------|------|
| `/` | **StartScreen** | タイトル＋「スタート」「前回のつづきから」 |
| `/draw` | **DrawingScreen** | キャンバス＋サイドバー＋6 ボタン |
| `/saved` | **SavedGalleryScreen** | 保存一覧 |
| `/prompt` | **TransformDialog** | カテゴリー・テイスト・強さ設定 |
| `/result` | **TransformResultScreen** | 生成イラストのプレビュー |

---

## 📐 技術スタック
| 領域 | 採用 |
|------|------|
| Flutter | 3.22.x (stable) |
| State 管理 | Riverpod v3 – **AsyncNotifier** 3 つ構成 <br>①DrawingNotifier ②AdNotifier ③AiNotifier |
| AI SDK | **Genkit** (Google Gemini Flash Image) |
| 広告 | **google_mobile_ads** <br>Banner / RewardedInterstitial |
| ローカル DB | Hive |
| シェア | share_plus |
| 先行 OS | **Android** (minSdk 24 / target 34) <br>iOS は β 以降 |

---

## 🚀 ローカル実行
```bash
# 1. パッケージ取得
flutter pub get

# 2. Android 実機 or エミュレータで起動
flutter run

## 📌 TODO

- [ ] Optimize canvas performance (FPS 60 以上を維持)
- [ ] Enhance AI generation quality (Genkit fine-tune)
- [ ] Implement undo/redo history (多段階)
- [ ] Improve SNS sharing (Instagram / LINE / X)
- [ ] Refine ad placement & behaviour (Banner bottom / Rewarded flow)
- [ ] Implement local data encryption (Hive 暗号化)
- [ ] Optimize app startup time (< 2 秒)
- [ ] Improve route navigation (go_router)
- [ ] Enhance saved gallery (filter / export)
- [ ] Conduct thorough testing (unit / widget / integration)
