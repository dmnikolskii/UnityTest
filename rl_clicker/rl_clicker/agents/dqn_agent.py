from __future__ import annotations

import math
from dataclasses import dataclass
from typing import Tuple

import numpy as np
import torch
import torch.nn as nn
import torch.optim as optim


class ConvQNetwork(nn.Module):
	def __init__(self, in_channels: int, num_actions: int):
		super().__init__()
		self.backbone = nn.Sequential(
			nn.Conv2d(in_channels, 32, kernel_size=8, stride=4),
			nn.ReLU(),
			nn.Conv2d(32, 64, kernel_size=4, stride=2),
			nn.ReLU(),
			nn.Conv2d(64, 64, kernel_size=3, stride=1),
			nn.ReLU(),
		)
		# Compute linear input size for 84x84 by a dummy forward
		with torch.no_grad():
			dummy = torch.zeros(1, in_channels, 84, 84)
			features = self.backbone(dummy)
			flat_dim = features.reshape(1, -1).shape[1]

		self.head = nn.Sequential(
			nn.Linear(flat_dim, 512),
			nn.ReLU(),
			nn.Linear(512, num_actions),
		)

	def forward(self, x: torch.Tensor) -> torch.Tensor:
		x = x.float() / 255.0
		features = self.backbone(x)
		return self.head(torch.flatten(features, 1))


@dataclass
class DQNConfig:
	gamma: float = 0.99
	learning_rate: float = 1e-4
	target_update_interval: int = 1000
	batch_size: int = 64
	replay_capacity: int = 100000
	min_replay_size: int = 5000
	epsilon_start: float = 1.0
	epsilon_end: float = 0.1
	epsilon_decay_steps: int = 200000


class DQNAgent:
	def __init__(self, observation_shape: Tuple[int, int, int], num_actions: int, device: str = "cpu", config: DQNConfig | None = None):
		self.device = torch.device(device)
		self.config = config or DQNConfig()

		in_channels = observation_shape[2]
		self.online_q = ConvQNetwork(in_channels, num_actions).to(self.device)
		self.target_q = ConvQNetwork(in_channels, num_actions).to(self.device)
		self.target_q.load_state_dict(self.online_q.state_dict())
		self.optimizer = optim.Adam(self.online_q.parameters(), lr=self.config.learning_rate)
		self.num_actions = num_actions
		self.train_steps = 0

	def epsilon_for_step(self, step: int) -> float:
		ratio = min(1.0, step / self.config.epsilon_decay_steps)
		return self.config.epsilon_start + ratio * (self.config.epsilon_end - self.config.epsilon_start)

	@torch.no_grad()
	def act(self, state_nhwc: np.ndarray, step: int) -> int:
		# state as HWC uint8, convert to NCHW
		state_nchw = np.transpose(state_nhwc, (2, 0, 1))[None, ...]
		state_tensor = torch.from_numpy(state_nchw).to(self.device)
		epsilon = self.epsilon_for_step(step)
		if np.random.rand() < epsilon:
			return np.random.randint(self.num_actions)
		q_values = self.online_q(state_tensor)
		return int(torch.argmax(q_values, dim=1).item())

	def train_step(self, batch):
		states, actions, rewards, next_states, dones = batch
		# Convert to torch tensors
		states = torch.from_numpy(np.transpose(states, (0, 3, 1, 2))).to(self.device)
		next_states = torch.from_numpy(np.transpose(next_states, (0, 3, 1, 2))).to(self.device)
		actions = torch.from_numpy(actions).long().to(self.device)
		rewards = torch.from_numpy(rewards).float().to(self.device)
		dones = torch.from_numpy(dones).float().to(self.device)

		# Compute current Q(s,a)
		q_values = self.online_q(states)
		q_sa = q_values.gather(1, actions.view(-1, 1)).squeeze(1)

		# Compute target Q
		with torch.no_grad():
			next_q_values = self.target_q(next_states)
			next_q_max = torch.max(next_q_values, dim=1)[0]
			target = rewards + (1.0 - dones) * self.config.gamma * next_q_max

		loss = nn.functional.smooth_l1_loss(q_sa, target)
		self.optimizer.zero_grad()
		loss.backward()
		nn.utils.clip_grad_norm_(self.online_q.parameters(), max_norm=10.0)
		self.optimizer.step()

		self.train_steps += 1
		if self.train_steps % self.config.target_update_interval == 0:
			self.target_q.load_state_dict(self.online_q.state_dict())

		return float(loss.item())