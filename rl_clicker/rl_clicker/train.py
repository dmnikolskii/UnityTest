import argparse
import os
from pathlib import Path

import gymnasium as gym
import numpy as np

from rl_clicker.envs.gd_like_env import GDLiteRunnerEnv, FrameStackWrapper
from rl_clicker.agents.replay_buffer import ReplayBuffer, Transition
from rl_clicker.agents.dqn_agent import DQNAgent, DQNConfig


def make_env():
	env = GDLiteRunnerEnv()
	env = FrameStackWrapper(env, num_stack=4)
	return env


def main():
	parser = argparse.ArgumentParser()
	parser.add_argument("--total-steps", type=int, default=200000)
	parser.add_argument("--warmup-steps", type=int, default=5000)
	parser.add_argument("--batch-size", type=int, default=64)
	parser.add_argument("--save-dir", type=str, default="checkpoints")
	parser.add_argument("--device", type=str, default="cpu")
	args = parser.parse_args()

	os.makedirs(args.save_dir, exist_ok=True)

	env = make_env()
	obs, _ = env.reset()
	observation_shape = obs.shape  # H, W, C
	agent = DQNAgent(observation_shape, num_actions=env.action_space.n, device=args.device, config=DQNConfig(batch_size=args.batch_size))
	replay = ReplayBuffer(capacity=200000, observation_shape=observation_shape)

	step = 0
	episode = 0
	episode_reward = 0.0

	while step < args.total_steps:
		action = agent.act(obs, step)
		next_obs, reward, terminated, truncated, info = env.step(action)
		replay.add(Transition(state=obs, action=action, reward=reward, next_state=next_obs, terminated=terminated, truncated=truncated))
		obs = next_obs
		episode_reward += reward
		step += 1

		if terminated or truncated:
			print(f"Episode {episode} ended: reward={episode_reward:.1f} steps={info.get('timestep', 0)}")
			obs, _ = env.reset()
			episode_reward = 0.0
			episode += 1

		if len(replay) >= args.warmup_steps and step % 4 == 0:
			batch = replay.sample(agent.config.batch_size)
			loss = agent.train_step(batch)
			if step % 1000 == 0:
				print(f"Step {step}: loss={loss:.5f} epsilon={agent.epsilon_for_step(step):.3f}")

		if step % 10000 == 0:
			ckpt = Path(args.save_dir) / "dqn_latest.pt"
			import torch
			torch.save({
				"model": agent.online_q.state_dict(),
				"config": agent.config.__dict__,
				"step": step,
			}, ckpt)
			print(f"Saved checkpoint to {ckpt}")

	print("Training complete.")


if __name__ == "__main__":
	main()