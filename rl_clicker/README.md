# RL Clicker (Game-agnostic)

This project provides a safe, game-agnostic reinforcement learning setup that learns to click/jump in a Geometry-Dash-like 2D runner environment that we fully control. It does not hook or automate any commercial game.

## Features
- Custom Gymnasium environment with 84x84 grayscale frame observations and frame stacking
- Single-button action space: 0 = no click, 1 = click (jump)
- Reward shaping: +1 per step alive, -1 on collision, +100 on level completion
- DQN agent with CNN encoder (PyTorch), experience replay, target network, and epsilon-greedy exploration

## Requirements
- Python 3.10–3.13. PyTorch wheels for 3.13 may require nightly.

Install base deps:
```bash
pip install -r requirements.txt
```

Install PyTorch (CPU example). For Python 3.13 you may need nightly:
```bash
# Stable (if supported by your Python):
# pip install torch --index-url https://download.pytorch.org/whl/cpu

# Nightly (if stable is unavailable on your Python version):
pip install --pre torch --index-url https://download.pytorch.org/whl/nightly/cpu
```

## Train
```bash
python -m rl_clicker.train --total-steps 200000 --save-dir checkpoints
```

## Evaluate
```bash
python -m rl_clicker.evaluate --checkpoint checkpoints/dqn_latest.pt --episodes 10
```

## Notes
- This is a sandbox environment intended for research and learning. It is not designed to control or interact with any external game or service.
- If you'd like to experiment with different environments or actions, modify `rl_clicker/envs/gd_like_env.py` and the observation preprocessing.