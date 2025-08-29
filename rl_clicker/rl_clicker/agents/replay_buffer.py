from __future__ import annotations

from dataclasses import dataclass
from typing import Optional, Tuple
import numpy as np


@dataclass
class Transition:
	state: np.ndarray
	action: int
	reward: float
	next_state: np.ndarray
	terminated: bool
	truncated: bool


class ReplayBuffer:
	def __init__(self, capacity: int, observation_shape: Tuple[int, ...], dtype: np.dtype = np.uint8):
		self.capacity = capacity
		self.observation_shape = observation_shape
		self.dtype = dtype
		self._size = 0
		self._idx = 0

		self.states = np.zeros((capacity, *observation_shape), dtype=dtype)
		self.actions = np.zeros((capacity,), dtype=np.int64)
		self.rewards = np.zeros((capacity,), dtype=np.float32)
		self.next_states = np.zeros((capacity, *observation_shape), dtype=dtype)
		self.dones = np.zeros((capacity,), dtype=np.bool_)

	def __len__(self) -> int:
		return self._size

	def add(self, transition: Transition) -> None:
		self.states[self._idx] = transition.state
		self.actions[self._idx] = transition.action
		self.rewards[self._idx] = transition.reward
		self.next_states[self._idx] = transition.next_state
		self.dones[self._idx] = bool(transition.terminated or transition.truncated)

		self._idx = (self._idx + 1) % self.capacity
		self._size = min(self._size + 1, self.capacity)

	def sample(self, batch_size: int) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
		assert self._size >= batch_size
		idxs = np.random.randint(0, self._size, size=batch_size)
		return (
			self.states[idxs],
			self.actions[idxs],
			self.rewards[idxs],
			self.next_states[idxs],
			self.dones[idxs],
		)