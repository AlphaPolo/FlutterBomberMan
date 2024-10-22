# Flutter BomberMan
![Game Demo Preview](display/game_demo.png)
![P2P ROOM](display/p2p_room2.png)

## Live Demo

Check out the live demo of BomberMan: [Demo](https://flutterbomberman.web.app/)

## Project Overview

**Flutter BomberMan** is a Bomberman-style game implemented using **Flutter Bonfire**. It supports peer-to-peer (P2P) multiplayer connections, allowing two players to connect and play together seamlessly. The P2P functionality is powered by the **PeerDart** package. Additionally, players can customize the control bindings for both Player 1 (1P) and Player 2 (2P), and preview the key configurations with an intuitive preview screen.

### Key Features:

- **P2P Multiplayer**: Play with friends via P2P connection, providing a smooth and direct multiplayer experience using PeerDart.
  ![P2P ROOM](display/p2p_room1.png)
- **Custom Key Bindings**: Players can customize their control keys for both Player 1 and Player 2, offering a personalized gaming experience.
  ![Key Setting](display/key_setting.png)
- **Key Binding Preview**: Preview the custom key bindings for both players with a visual layout.  
  ![Keyboard Preview](display/keyboard_preview.png)

## Abilities

In the game, players can pick up various abilities that enhance their gameplay. Below is a list of the available abilities with their respective effects:

### Ability Showcase:

<table>
  <tr>
    <td><img src="display/tile000.png" alt="Bomb Capacity" style="width:50px; height:auto;"></td>
    <td><strong>Bomb Capacity</strong>: Picking up this ability allows the player to place more bombs on the map simultaneously.</td>
  </tr>
  <tr>
    <td><img src="display/tile004.png" alt="Explosion Power" style="width:50px; height:auto;"></td>
    <td><strong>Explosion Power</strong>: Increases the explosion range in all four directions when the player places a bomb, making it more powerful.</td>
  </tr>
  <tr>
    <td><img src="display/tile001.png" alt="Speed Boost" style="width:50px; height:auto;"></td>
    <td><strong>Speed Boost</strong>: Grants a temporary increase in the player's movement speed, allowing them to navigate the map faster.</td>
  </tr>
  <tr>
    <td><img src="display/tile002.png" alt="Kick Bomb" style="width:50px; height:auto;"></td>
    <td><strong>Kick Bomb</strong>: When this ability is obtained, the player can kick bombs upon contact, sending them across the map. (Currently not implemented in P2P mode).</td>
  </tr>
  <tr>
    <td><img src="display/tile003.png" alt="Throw Bomb" style="width:50px; height:auto;"></td>
    <td><strong>Throw Bomb</strong>: (Not yet implemented). This feature will allow players to throw bombs over walls for strategic advantage.</td>
  </tr>
</table>

Enjoy!