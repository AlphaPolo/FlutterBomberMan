[English](README_en.md) | [中文](README.md)
---

# Flutter BomberMan
![遊戲示範預覽](display/game_demo.png)
![P2P 房間](display/p2p_room2.png)

## 在線示範

體驗遊玩 BomberMan：[示範](https://flutterbomberman.web.app/)

## 專案概述

這個專案是使用 **Flutter Bonfire** 實現的炸彈超人遊戲。它支持點對點 (P2P) 多人連接，允許兩名玩家無縫連接並一起遊玩。P2P 功能由 **PeerDart** 套件實現。此外，玩家可以自定義 Player 1 (1P) 和 Player 2 (2P) 的控制綁定，並通過直觀的預覽畫面查看鍵位配置。

### 主要特點：

- **P2P 多人遊戲**：通過 P2P 連接與朋友一起遊玩，提供流暢且直接的多人體驗，使用 PeerDart 實現。
  ![P2P 房間](display/p2p_room1.png)
- **自定義鍵綁定**：玩家可以自定義 Player 1 和 Player 2 的控制鍵，提供個性化的遊戲體驗。
  ![鍵位設置](display/key_setting.png)
- **鍵綁定預覽**：可視化預覽兩名玩家的自定義鍵綁定。
  ![鍵盤預覽](display/keyboard_preview.png)

## 能力

在遊戲中，玩家可以獲得各種能力來增強遊戲體驗。以下是可用能力及其各自效果的列表：

### 能力展示：

<table>
  <tr>
    <td><img src="display/tile000.png" alt="炸彈容量" style="width:50px; height:auto;"></td>
    <td><strong>炸彈容量</strong>：獲得此能力後，玩家可以在地圖上同時放置更多炸彈。</td>
  </tr>
  <tr>
    <td><img src="display/tile004.png" alt="爆炸威力" style="width:50px; height:auto;"></td>
    <td><strong>爆炸威力</strong>：增加玩家放置炸彈時四個方向的爆炸範圍，增強其威力。</td>
  </tr>
  <tr>
    <td><img src="display/tile001.png" alt="速度提升" style="width:50px; height:auto;"></td>
    <td><strong>速度提升</strong>：增加玩家的移動速度，使其能夠更快地在地圖上移動。</td>
  </tr>
  <tr>
    <td><img src="display/tile002.png" alt="踢炸彈" style="width:50px; height:auto;"></td>
    <td><strong>踢炸彈</strong>：獲得此能力後，玩家可以踢炸彈，炸彈將會持續向前移動，直到撞到障礙物、玩家或邊界。(目前未在 P2P 模式中實現)。</td>
  </tr>
  <tr>
    <td><img src="display/tile003.png" alt="投擲炸彈" style="width:50px; height:auto;"></td>
    <td><strong>投擲炸彈</strong>：(尚未實現)。此功能將允許玩家在牆上投擲炸彈以獲得戰略優勢。</td>
  </tr>
</table>

---