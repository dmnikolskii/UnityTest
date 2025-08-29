import argparse
from pathlib import Path

import gymnasium as gym
import numpy as np
import torch

from rl_clicker.envs.gd_like_env import GDLiteRunnerEnv, FrameStackWrapper
from rl_clicker.agents.dqn_agent import DQNAgent, DQNConfig, ConvQNetwork


def make_env():
	env = GDLiteRunnerEnv()
	env = FrameStackWrapper(env, num_stack=4)
	return env


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--checkpoint", type=str, required=True)
	parser.add_argument("--episodes", type=int, default=10)
	parser.add_argument("--device", type=str, default="cpu")
	args = parser.parse_args()

	env = make_env()
	obs, _ = env.reset()
	observation_shape = obs.shape

	agent = DQNAgent(observation_shape, num_actions=env.action_space.n, device=args.device)
	ckpt = torch.load(Path(args.checkpoint), map_location=args.device)
	agent.online_q.load_state_dict(ckpt["model"])
	agent.target_q.load_state_dict(ckpt["model"])

	for ep in range(args.episodes):
		obs, _ = env.reset()
		total_reward = 0.0
		terminated = False
		truncated = False
		step = 0
		while not (terminated or truncated):
			# Greedy action (epsilon = 0)
			state_nchw = np.transpose(obs, (2, 0, 1))[None, ...]
			state_tensor = torch.from_numpy(state_nchw).to(args.device)
			with torch.no_grad():
				q_values = agent.online_q(state_tensor)
				action = int(torch.argmax(q_values, dim=1).item())
			obs, reward, terminated, truncated, info = env.step(action)
			total_reward += reward
			step += 1
		print(f"Episode {ep}: reward={total_reward:.1f} steps={step}")

	print("Evaluation complete.")


if __name__ == "__main__":
	main()